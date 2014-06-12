package com.oddcast.video 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author ja
	 */
	public class StreamController extends EventDispatcher
	{
		
		public static const STREAM_VIEW:int = 0;
		public static const STREAM_BROADCAST:int = 1;
		public static const STREAM_VOD:int = 2;		
		private static const SERVER_HANDLER_PUBLISH:String = "onPermissionToBroadcastGranted";
		private static const SERVER_HANDLER_PUBLISH_NEXT:String = "onNextToBroadcast";
		private static const SERVER_HANDLER_PUBLISH_FINISH:String = "onFinishBroadcast";
		private static const SERVER_HANDLER_PUBLISH_FINISH_WARN:String = "onFinishBroadcastWarning";
		
		public static var CREATE_BMP_EVERY_QUALITY_SAMPLE = 0;
		
		private var _nc:NetConnection;
		private var _ns:NetStream;
		private var _video:Video;
		private var _iStreamType:int;
		private var _sStreamName:String;
		private var _iId:int;
		private var _nBufferTime:Number;		
		private var _arrQuality:Array;
		private var _timerQualityTest:Timer;
		private var _intervalFlushVideoBufferTimer:int;
		private var _iQualityTimerInterval:int = 2000; //2 seconds
		private var _bmpdataThumb:BitmapData;
		private var _iQualitySampleCounter = 0;
		private var _nStreamDuration:Number;
		private var _bFirstTimePlay:Boolean;
		
		public function StreamController(id:int, url:String, streamName:String, vidWidth:int, vidHeight:int, streamType:int, buf:Number) 
		{
			trace("StreamController::StreamController " + id + ", " + url + ", " + streamName+", _nBufferTime="+buf);
			_iId = id;
			_nBufferTime = buf;
			_iStreamType = streamType;
			_video = new Video(vidWidth, vidHeight);
			// create a connection to the wowza media server
			_nc = new NetConnection();
			_nc.addEventListener(NetStatusEvent.NET_STATUS, ncOnStatus);
			
			if (streamType == STREAM_BROADCAST)
			{
				var _ncClient:Object = new Object();
				_ncClient[SERVER_HANDLER_PUBLISH_NEXT] = onMsgNextToPublish;
				_ncClient[SERVER_HANDLER_PUBLISH] = onMsgPublish;
				_ncClient[SERVER_HANDLER_PUBLISH_FINISH] = onMsgPublishFinish;
				_ncClient[SERVER_HANDLER_PUBLISH_FINISH_WARN] = onMsgPublishFinishWarn;
				_nc.client = _ncClient;
			}
			_nc.connect(url);
			_sStreamName = streamName;
			
			
		}
		/**
		 * Sets the quality timer ping interval
		 * @param	i	miliseconds
		 */
		public function setQualityTimerInterval(i:int):void
		{
			_iQualityTimerInterval = i;
		}
		
		public function getQuality():int
		{
			var sum:int = 0;
			for (var i:int = 0; i < _arrQuality.length; ++i)
			{
				sum += _arrQuality[i];
			}
			var avg:Number = sum / _arrQuality.length;
			return int(avg);
		}
		
		public function getDuration():Number
		{
			return _nStreamDuration;
		}
		
		private function playStream(offset:Number = -2):void
		{
			_bFirstTimePlay = true;
			trace("StreamController.as::playStream "+_sStreamName+" bufTime="+_nBufferTime);
			_ns = new NetStream(_nc);
			_ns.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);			
			var nsPlayClient:Object = new Object();
			_ns.client = nsPlayClient;
			// listen to the NetStream play status information
			nsPlayClient.onPlayStatus = function(infoObject:Object):void
			{
				//trace("nsPlay: onPlayStatus: "+infoObject.code+" ("+infoObject.description+")");
				if (infoObject.code == "NetStream.Play.Complete")
				{
					dispatchEvent(new StreamEvent(StreamEvent.PLAYBACK_STOP, {id:_iId, msg:""}));
				}
			}
			
			nsPlayClient.onMetaData = function(infoObject:Object):void
			{
				trace("onMetaData");
				
				// print debug information about the metaData
				for (var propName:String in infoObject)
				{
					trace("  " + propName + " = " + infoObject[propName]);
					if (propName == "duration")
					{
						_nStreamDuration = Number(infoObject[propName]);
					}
				}
			};
			
		
			// set the buffer time
			_ns.bufferTime = _nBufferTime;
		
			// attach the NetStream object to the right most video object
			_video.attachNetStream(_ns);
			
			// play the movie
			//_ns.play({name:_sStreamName, start:offset});						
			_ns.play(_sStreamName);
		}
		
		public function play(offset:Number = -2):void
		{
			if (_ns != null)
			{
				_ns.play({name:_sStreamName, start:offset});	
			}
			else
			{
				playStream(offset);
			}
		}
		
		/**
		 * Publishes the camera stream
		 */
		public function publish(cam:Camera, mic:Microphone, publishStreamName:String):void
		{
			_arrQuality = new Array();
			
			_timerQualityTest = new Timer(_iQualityTimerInterval);
			_timerQualityTest.addEventListener(TimerEvent.TIMER, sampleQuality);
			_timerQualityTest.start();
			
			
			// create a new NetStream object for publishing
			_ns = new NetStream(_nc);
			
			var nsPublishClient:Object = new Object();
			
			_ns.client = nsPublishClient;
		
			// trace the NetStream status information
			_ns.addEventListener(NetStatusEvent.NET_STATUS, nsPublishOnStatus);
			// attach the camera and microphone to the server
			_ns.attachCamera(cam);
			_ns.attachAudio(mic);			
			
			_bmpdataThumb = new BitmapData(_video.width, _video.height);			
			_bmpdataThumb.draw(_video);
			
			
			// publish the stream by name
			_ns.publish(publishStreamName);// , (AppendCheckbox.selected?"append":"record"));
			
			// add custom metadata to the header of the .flv file
			var metaData:Object = new Object();
			metaData["description"] = "Recorded using BNOW StreamController"
			_ns.send("@setDataFrame", "onMetaData", metaData);
		
			
						
			// data for better performance and higher quality video
			_ns.bufferTime = _nBufferTime;
		}
		
		
		private function onMsgNextToPublish(streamId:int):void
		{			
			trace("StreamController::onMsgNextToPublish");
			dispatchEvent(new StreamEvent(StreamEvent.PUBLISH_NEXT_MSG,  {id:_iId, streamName:streamId}));
		}
		
		private function onMsgPublish(streamId:int):void
		{
			trace("StreamController::onMsgPublish");
			dispatchEvent(new StreamEvent(StreamEvent.PUBLISH_NOW_MSG, {id:_iId, streamName:streamId}));			
		}
		
		private function onMsgPublishFinish():void
		{
			trace("StreamController::onMsgPublishFinish");
			dispatchEvent(new StreamEvent(StreamEvent.PUBLISH_FINISH_MSG, {id:_iId}));		
		}
		
		private function onMsgPublishFinishWarn():void
		{
			trace("StreamController::onMsgPublishFinishWarn");
			dispatchEvent(new StreamEvent(StreamEvent.PUBLISH_FINISH_WARN_MSG, {id:_iId}));		
		}
		
		
		
		private function nsPublishOnStatus(evt:NetStatusEvent):void
		{
			var infoObject:Object = evt.info;			
			//trace("nsPublish: "+infoObject.code+" ("+infoObject.description+")");			
			// After calling nsPublish.publish(false); we wait for a status
			// event of "NetStream.Unpublish.Success" which tells us all the video
			// and audio data has been written to the flv file. It is at this time
			// that we can start playing the video we just recorded.
			switch (infoObject.code)
			{
				case "NetStream.Publish.Start":
					dispatchEvent(new StreamEvent(StreamEvent.PUBLISH_START, { id:_iId, msg:"" } ));
					break;
				case "Netstream.Unpublish.Success":
					//publishDone();
					break;
				
			}
			trace(infoObject.code+"->"+infoObject.description);
			/*
			if (infoObject.code == "NetStream.Unpublish.Success")
			{
				//doPlayStart();
			}
		
			if (infoObject.code == "NetStream.Play.StreamNotFound" || infoObject.code == "NetStream.Play.Failed")
			{
				trace(infoObject.description);
			}
			*/
		}
		/*
		public function getLength():Number
		{
			if (_iStreamType == STREAM_VOD)
			{
				if (_ns != null)
				{
					_ns.dur
				}
			}
			else
			{
				dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, { errId:107, id:_iId, msg:"There is no length parameter for non VOD streams" } ));
			}
		}
		*/
		public function stopPublish():void
		{			
			
			_timerQualityTest.stop();
			_timerQualityTest.removeEventListener(TimerEvent.TIMER, sampleQuality);
			_timerQualityTest = null;
			
			// stop streaming video and audio to the publishing
			// NetStream object
			_ns.attachAudio(null);
			_ns.attachCamera(null);
		
			// After stopping the publishing we need to check if there is
			// video content in the NetStream buffer. If there is data
			// we are going to monitor the video upload progress by calling
			// flushVideoBuffer every 250ms.  If the buffer length is 0
			// we close the recording immediately.
			dispatchEvent(new StreamEvent(StreamEvent.PUBLISH_PROCESSING, {id:_iId, msg:""}));
			
			var buffLen:Number = _ns.bufferLength;
			if (buffLen > 0)
			{				
				_intervalFlushVideoBufferTimer = setInterval(flushVideoBuffer, 250);
				//doPublish.label = 'Wait...';
			}
			else
			{
				trace("nsPublish.publish(null)");
				publishDone();		
				//doPublish.label = 'Record';
			}			
		}
		
		public function getBmpData():BitmapData
		{
			return _bmpdataThumb;
		}
		
		public function makeServerCall(func:String, callback:Function):void
		{
			if (_nc != null)
			{
				_nc.call(func, new Responder(function (str:String)
				{
					callback(str);
				}),true);
			}
			else
			{
				callback("error netconnection is null");
			}
		}
		
		private function sampleQuality(evt:TimerEvent):void
		{
			if (_arrQuality == null)
			{
				_arrQuality = new Array();
			}
			var timeBeforeCall:int = getTimer();
			var pingTime:int;
			//generate thumb from videostream:			
			if (_ns != null && _ns.info!=null)
			{
				trace("current bitrate=" + _ns.info.toString());
			}
			trace("sampleQuality - onPingTest");
			_nc.call("onPingTest", new Responder(function (str:String) 
			{
				
				 pingTime = getTimer() - timeBeforeCall;
				 trace("response from server = " + str + " pingTime=" + pingTime);	
				if (evt == null)
				{
					if (_iStreamType != STREAM_VIEW)
					{
						if (pingTime > 1000)
						{
							_nBufferTime = 20;
						}
						else if (pingTime > 500)
						{
							_nBufferTime = 10;
						}
						else if (pingTime > 200)
						{
							_nBufferTime = 7;
						}
					}
					else
					{
						_nBufferTime = 1;
					}
					trace("StreamController set buffer based on quality to " + _nBufferTime);
					
					if (_iStreamType != STREAM_BROADCAST)
					{
						playStream();
					}
				}
				else
				{
					_arrQuality.push(pingTime);
				}
				 //_ns.bufferTime = pingTime / 20;// _nBufferTime;
				
							
			}), true);
		}
		
		private function flushVideoBuffer():void
		{
			var buffLen:Number = _ns.bufferLength;
			if (buffLen == 0)
			{				
				clearInterval(_intervalFlushVideoBufferTimer);
				_intervalFlushVideoBufferTimer = 0;
				publishDone();
				;//doPublish.label = 'Record';
			}
		}
		
		private function publishDone():void
		{
			_ns.publish("null");			
			dispatchEvent(new StreamEvent(StreamEvent.PUBLISH_DONE, {id:_iId, msg:""}));
		}
		
		public function seek(n:Number):void
		{
			if (_ns != null)
			{
				if (_iStreamType == STREAM_VOD)
				{
					_ns.seek(n);
				}
				else
				{
					dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, {errId:104, id:_iId, msg:"Only VOD streams can be seeked"}));
				}
			}
			else
			{
				dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, {errId:105, id:_iId, msg:"There's no active playback that can be seeked"}));
			}
		}
		
		public function resume():void
		{
			if (_ns != null)
			{
				if (_iStreamType != STREAM_BROADCAST)
				{
					_ns.resume();
				}
				else
				{
					dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, {errId:103, id:_iId, msg:"A broadcast stream can't be paused or resumed"}));
				}
			}
			else
			{
				dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, {errId:102, id:_iId, msg:"There's no active playback stream to pause or resumed"}));
			}
		}
		
		public function pause():void
		{
			if (_ns != null)
			{
				if (_iStreamType != STREAM_BROADCAST)
				{
					_ns.pause();
				}
				else
				{
					dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, {errId:103, id:_iId, msg:"A broadcast stream can't be paused or resumed"}));
				}
			}
			else
			{
				dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, {errId:102, id:_iId, msg:"There's no active playback stream to pause or resumed"}));
			}
		}
		
		
		public function getVideo():Video
		{
			return _video;
		}
		
		public function getPosition():Number
		{
			if (_ns != null)
			{
				return _ns.time;
			}
			else
			{
				return -1;
			}
		}
		
		/**
		 * Stop the stream
		 */
		public function stop():void
		{
			if (_iStreamType == STREAM_BROADCAST)
			{
				
			}
			else
			{
				_video.attachNetStream(null);
				_video.clear();
				
				if (_ns != null)
					_ns.close();
				_ns = null;
			}
		}
		/**
		 * Destorys the object
		 */
		public function destroy():void
		{
			if (_ns != null)
			{
				if (_iStreamType == STREAM_BROADCAST)
				{
					_ns.removeEventListener(NetStatusEvent.NET_STATUS, nsPublishOnStatus);
				}
				else
				{
					_ns.removeEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
				}
				_ns = null;			
			}
			if (_nc != null)
			{
				_nc.removeEventListener(NetStatusEvent.NET_STATUS, ncOnStatus);
				_nc.close();
				_nc = null;
			}
			if (_video != null)
			{
				_video.clear();
				_video = null;
			}
			if (_iStreamType == STREAM_BROADCAST)
			{
				if (_intervalFlushVideoBufferTimer > 0)
				{					
					clearInterval(_intervalFlushVideoBufferTimer);
					_intervalFlushVideoBufferTimer = 0
				}
				if (_timerQualityTest != null)
				{
					_timerQualityTest.removeEventListener(TimerEvent.TIMER, sampleQuality);
					_timerQualityTest.stop();
					_timerQualityTest = null;
				}
				_arrQuality = null;
			}
		}
		
		private function nsPlayOnStatus(evt:NetStatusEvent):void
		{
			var infoObject:Object = evt.info;
			//trace("nsPlay: onPlayStatus: "+infoObject.code+" ("+infoObject.description+")");
			switch (infoObject.code)
			{
				case "NetStream.Play.Complete":
				//case "NetStream.Play.Stop":
					if (_iStreamType == STREAM_VOD)
					{
						dispatchEvent(new StreamEvent(StreamEvent.PLAYBACK_STOP, {id:_iId, msg:""}));
					}
					break;
				case "NetStream.Play.Start":
					
					break;				
				case "NetStream.Play.StreamNotFound":
					dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, {errId:106, id:_iId, msg:infoObject.code + " (" + infoObject.description + ")"}));
					break;
				case "NetStream.Buffer.Full":
						if (_bFirstTimePlay)
						{
							_bFirstTimePlay = false;
							dispatchEvent(new StreamEvent(StreamEvent.PLAYBACK_START, {id:_iId, msg:""}));
						}
					break;

			}
			if (infoObject.code == "NetStream.Play.Complete")
			{
				//doPlayStop();
				
			}
		}
		
		private function ncOnStatus(infoObject:NetStatusEvent):void
		{
			trace("nc: "+infoObject.info.code+" ("+infoObject.info.description+")");
			if (infoObject.info.code == "NetConnection.Connect.Success")
			{
				dispatchEvent(new StreamEvent(StreamEvent.CONNECTION_SUCCESS, {id:_iId, msg:""}));
				trace("ncOnStatus _iStreamType="+_iStreamType+", STREAM_BROADCAST="+STREAM_BROADCAST);
				sampleQuality(null);
				
			}
			else if (infoObject.info.code == "NetConnection.Connect.Failed")
			{
				dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, {errId:100, id:_iId, msg:infoObject.info.code + " (" + infoObject.info.description + ")"}));
				//_tfStatus.text = infoObject.info.code + " (" + infoObject.info.description + ")";
			}
			else if (infoObject.info.code == "NetConnection.Connect.Rejected")
			{
				dispatchEvent(new StreamEvent(StreamEvent.ON_ERROR, {errId:101, id:_iId, msg:infoObject.info.code + " (" + infoObject.info.description + ")"}));
				//_tfStatus.text = infoObject.info.code + " (" + infoObject.info.description + ")"
			}
		}
		
		public function getStreamType():int
		{
			return _iStreamType;
		}
		
		public function getId():int
		{
			return _iId;
		}
		
	}

}
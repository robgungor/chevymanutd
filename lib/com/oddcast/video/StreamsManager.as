package com.oddcast.video 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	/**
	 * ...
	 * @author ja
	 * This class is responsible for all net connection net stream functionality
	 * It allows for:
	 * 1. Camera popup
	 * 2. Taking stream snapshot
	 * 3. Connection to server
	 * 4. playback
	 * 5. broadcast
	 * 6. message exchange
	 * 7. dispatching events
	 */
	public class StreamsManager extends EventDispatcher
	{
		
		
		private var _vStreams:Vector.<StreamController>;
		
		private var _camera:Camera;
		private var _nMaxFramePerSecond:Number;
		private var _mic:Microphone;
		private var _sLastError:String;
		public var _nBufferLive:Number = 5;
		public var _nBufferBroadcast:Number = 5;
		public var _nBufferVOD:Number = 5;
		
		public function StreamsManager() 
		{
			_vStreams = new Vector.<StreamController>();
		}
		/**
		 * When the connection is made a StreamEvent.CONNECTION_SUCCESS is dispatched otherwise StreamEvent.ON_ERROR
		 * @param	url - url of the stream
		 * @param	streamName - name of the stream
		 * @param	vidWidth - width of the video stream
		 * @param	vidHeight - height of the video stream		 
		 * @param	streamType - StreamController.STREAM_VIEW (0) or StreamController.STREAM_BROADCAST (1)
		 * @return index (id) of the StreamController object can be used for getStreamController(id:int)
		 */
		public function addStream(url:String, streamName:String, vidWidth:int, vidHeight:int, streamType:int):int
		{
			trace("StreamsManager::addStream " + url + ", " + streamName + ", " + streamType);
			var streamController:StreamController = new StreamController(_vStreams.length, url, streamName, vidWidth, vidHeight, streamType, getBufferTime(streamType));			
			streamController.addEventListener(StreamEvent.CONNECTION_SUCCESS, streamConnected);
			streamController.addEventListener(StreamEvent.ON_ERROR, streamError);
			streamController.addEventListener(StreamEvent.PLAYBACK_STOP, streamPlaybackStop);
			streamController.addEventListener(StreamEvent.PLAYBACK_START, streamPlaybackStart);
			if (streamType == StreamController.STREAM_BROADCAST)
			{
				streamController.addEventListener(StreamEvent.PUBLISH_START, streamPublishStart);
				streamController.addEventListener(StreamEvent.PUBLISH_PROCESSING, streamPublishProcessing);
				streamController.addEventListener(StreamEvent.PUBLISH_DONE, streamPublishDone);
				
				streamController.addEventListener(StreamEvent.PUBLISH_NEXT_MSG, streamPublishNextMsg);
				streamController.addEventListener(StreamEvent.PUBLISH_NOW_MSG, streamPublishNowMsg);
				streamController.addEventListener(StreamEvent.PUBLISH_FINISH_MSG, streamPublishFinishMsg);
				streamController.addEventListener(StreamEvent.PUBLISH_FINISH_WARN_MSG, streamPublishFinishWarnMsg);
			}
			
			
			return _vStreams.push(streamController)-1; 
		}
		
		/**
		 * Starts the camera object
		 * @param	vidWidth - camera width
		 * @param	vidHeight - camera height
		 * @param	bandwidth - use 0 for unlimited bandwidth
		 * @param	quality - use 0-100 recommended for good quality is 90
		 * @param	fps - frames per second of video capture recommended 30
		 * @param	micRate - audio capture rate
		 */
		public function startCamera(vidWidth:int, vidHeight:int, bandwidth:int = 0, quality:int = 90, fps:int = 30, micRate:int = 11):void
		{
			trace("StreamsManager::startCamera");
			_camera = Camera.getCamera();
			_nMaxFramePerSecond = _camera.fps;			
			_camera.addEventListener(StatusEvent.STATUS, cameraUserSettingChanged);
			_mic = Microphone.getMicrophone();
		
			// here are all the quality and performance settings
			_camera.setMode(vidWidth, vidHeight, fps, true);
			_camera.setQuality(bandwidth, quality);			
			//_camera.setKeyFrameInterval(fps);
			_mic.rate = micRate;	
		}
										
		public function playStream(id:int, offset:Number = -2):void
		{
			_vStreams[id].play(offset);
		}
		
		public function closeStream(id:int):void
		{
			_vStreams[id].destroy();
		}
		
		public function makeServerCall(id:int, func:String, callback:Function):void
		{
			_vStreams[id].makeServerCall(func, callback);
		}
		
		public function publishStream(id:int, streamName:String):void
		{			
			_vStreams[id].publish(_camera, _mic, streamName);
		}
		
		public function stopPublishStream(id:int):void
		{
			_vStreams[id].stopPublish();
		}
		
		public function getQuality(id:int):int
		{
			return _vStreams[id].getQuality();
		}
		
		public function seek(id:int, n:Number):void
		{
			_vStreams[id].seek(n);
		}
		
		public function stopStream(id:int):void
		{
			if (_vStreams[id].getStreamType() == StreamController.STREAM_BROADCAST)
			{
				_vStreams[id].getVideo().attachCamera(null);
			}
			_vStreams[id].stop();
		}
		
		public function getPosition(id:int):Number
		{
			return _vStreams[id].getPosition();
		}
		
		public function getDuration(id:int):Number
		{
			return _vStreams[id].getDuration()
		}
		
		public function getBmpData(id:int):BitmapData
		{
			return _vStreams[id].getBmpData();
		}
		
		public function pause(id:int):void
		{
			_vStreams[id].pause();
		}
		
		public function resume(id:int):void
		{
			_vStreams[id].resume();
		}
		
		
		
		private function streamConnected(evt:StreamEvent):void
		{
			//attach the camera to the video display object
			var id:int = evt.data.id;
			if (_vStreams[id].getStreamType() == StreamController.STREAM_BROADCAST)
			{
				_vStreams[id].getVideo().clear();
				_vStreams[id].getVideo().attachCamera(_camera);
			}			
			dispatchEvent(evt);
		}
		
		private function streamError(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}
		
		private function streamPublishProcessing(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}				
		
		private function streamPublishStart(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}
		
		private function streamPublishNextMsg(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}
		
		private function streamPublishNowMsg(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}
				
		private function streamPublishFinishMsg(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}
		
		private function streamPublishFinishWarnMsg(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}
		
		private function streamPublishDone(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}
		
		private function streamPlaybackStop(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}
		
		private function streamPlaybackStart(evt:StreamEvent):void
		{
			dispatchEvent(evt);
		}
		
		public function getCamera():Camera
		{
			return _camera;
		}
		
		private function cameraUserSettingChanged(evt:StatusEvent):void
		{			
			trace("cameraUserSettingChanged "+evt.code);
			if (evt.code.toLowerCase() == "camera.muted")
			{								
				dispatchEvent(new StreamEvent(StreamEvent.CAMERA_DISABLED, null));				
			}
			else {
				for (var i:int = 0; i < _vStreams.length; ++i)
				{
					trace("cameraUserSettingChanged " + i + " -> " + _vStreams[i].getId()+" _vStreams[i].getStreamType()="+_vStreams[i].getStreamType());
					if (_vStreams[i].getStreamType() == StreamController.STREAM_BROADCAST)
					{
						trace("cameraUserSettingChanged attach camera "+_camera.name);
						_vStreams[i].getVideo().clear();
						_vStreams[i].getVideo().attachCamera(_camera);
					}
				}
				dispatchEvent(new StreamEvent(StreamEvent.CAMERA_ENABLED, null));
			}
		}
		
		private function getBufferTime(streamType:int):Number
		{
			trace("getBufferTime streamType=" + streamType);
			switch (streamType)
			{
				case StreamController.STREAM_BROADCAST:
					trace("STREAM_BROADCAST=" + _nBufferBroadcast);
					return _nBufferBroadcast;					
				case StreamController.STREAM_VIEW:
					trace("STREAM_VIEW=" + _nBufferLive);
					return _nBufferLive;
				case StreamController.STREAM_VOD:
					trace("STREAM_VOD=" + _nBufferVOD);
					return _nBufferVOD;
			}
			return -1;
		}
		
		/**
		 * Acess the StreamController object of a stream based on its index
		 * @param	index
		 * @return The StreamController or null if error. To retrieve error description call getLastError();
		 */
		public function getStreamController(index:int):StreamController
		{
			try
			{
				return _vStreams[index];
			}
			catch (e:Error)
			{
				_sLastError = e.errorID + ", " + e.name + ", " + e.message + " (" + e.getStackTrace() + ")";
				return null;
			}
			return null;
		}
		
		public function getVideo(id:int):Video
		{
			return _vStreams[id].getVideo();
		}
		
		/**
		 * Returns the latest error this class had
		 * @return String with description of last error
		 */
		public function getLastError():String
		{
			return _sLastError;
		}
		
	}

}
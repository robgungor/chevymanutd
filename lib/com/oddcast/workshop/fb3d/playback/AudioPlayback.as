package com.oddcast.workshop.fb3d.playback
{	
	import com.oddcast.event.EventDescription;
	import com.oddcast.event.FB3dControllerEvent;
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.ITalkChannel;
	import com.oddcast.oc3d.shared.*;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;  

	public class AudioPlayback extends EventDispatcher
	{
		//private var _controller:FB3dControllerPlayback;		
		//private var _avatar:IAvatarBuilderProxy;
		private var _bInterrupt:Boolean = true;
		private var _arrAudioQueue:Array;
		private var _dictAudioChannels:Dictionary;		
		private var _iPosInAudioQueue:int;
		private var _vTalkChannelCurrent:Vector.<ITalkChannel>;
		private var _sCurrentAudioUrl:String;
		private var _nCurrentAudioVolume:Number = -1;
		private var _loadSoundAndPlayVisemeOnAllAvailableMorphDeformers:Function;
		
		// playFn:Function<void()>
		public function AudioPlayback(loadSoundAndPlayVisemeOnAllAvailableMorphDeformers:Function)
		{
			_arrAudioQueue = new Array();
			_dictAudioChannels = new Dictionary();
			_loadSoundAndPlayVisemeOnAllAvailableMorphDeformers = loadSoundAndPlayVisemeOnAllAvailableMorphDeformers;
		}
		
		/**
		 * Plays an audio. If the character supports lip sync it will be triggred with the audio. Use FB3dControllerEvent and EventDescription to monitor the following events:
		 * AUDIO_DOWNLOADED, AUDIO_STARTED, AUDIO_ENDED, AUDIO_ERROR and AUDIO_DOWNLOAD_PROGRESS 
		 * @param	url - url to an mp3 audio
		 * @param	sec - offset of the audio to being playing		 
		 */
		public function say(url:String, sec:Number=0):void
		{				
			if (_bInterrupt && _arrAudioQueue.length>0)
			{
				if (_vTalkChannelCurrent!=null)
				{
					for (var i:int=0; i<_vTalkChannelCurrent.length;++i)
					{
						_vTalkChannelCurrent[i].stop();
					}
				}
				cleanUpAudioQueue();
			}
			_arrAudioQueue.push({url:url, offset:sec});
			
			var audioPos:uint = _arrAudioQueue.length - 1;
			
			if (_arrAudioQueue.length==1)
			{				
				_iPosInAudioQueue = 0;
			}

			//if (_controller.getActiveInstanceName()==null)
			//{
			//	if (failedFn != null)
			//		failedFn(url,"Must have an active instance name");
			//	return;
			//}
			_loadSoundAndPlayVisemeOnAllAvailableMorphDeformers
			(
				url, 
				true, 
				sec, 
				function (vTalkChannel:Vector.<ITalkChannel>):void{finishedLoading(url, vTalkChannel, audioPos)}, 
				function ():void{ trace("loadSoundAndPlayVisemeOnAllAvailableMorphDeformers said finishedPlaying"); finishedPlaying(url)}, 
				function (s:String):void{failedFn(url, s)}, 
				progressFn
			);			
			
			function finishedLoading(loadedUrl:String, vTalkChannel:Vector.<ITalkChannel>, audPos:uint):void
			{
				_dictAudioChannels[loadedUrl] = vTalkChannel;								
				var evtDesc:EventDescription = new EventDescription();
				evtDesc.description = loadedUrl;
				evtDesc.obj = vTalkChannel;				
				if (_nCurrentAudioVolume>-1)
				{
					for (var i:int=0; i< vTalkChannel.length; ++i)
					{
						vTalkChannel[i].setVolume(_nCurrentAudioVolume);
					}
				}
				dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.AUDIO_DOWNLOADED,evtDesc));								
				if (_arrAudioQueue[0].url!=loadedUrl || audPos>0)
				{
					for (var i:int=0; i< vTalkChannel.length; ++i)
					{
						vTalkChannel[i].pause();						
					}
				}
				else
				{
					_vTalkChannelCurrent = vTalkChannel;
				}
				dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.AUDIO_STARTED,evtDesc));
				if (_arrAudioQueue[0].url==loadedUrl)
				{
					dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.TALK_STARTED,evtDesc));
				}
			}
			
			function finishedPlaying(finishedUrl:String, failed:Boolean = false):void
			{
				trace("finishedPlaying "+finishedUrl);
				var evtDesc:EventDescription = new EventDescription();
				evtDesc.description = finishedUrl;
				if (!failed)
				{
					dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.AUDIO_ENDED,evtDesc));
				}
				_iPosInAudioQueue++;
				if (_iPosInAudioQueue<_arrAudioQueue.length)
				{
					var vTalkChannel:Vector.<ITalkChannel> = _dictAudioChannels[_arrAudioQueue[_iPosInAudioQueue].url];
					for (var i:int=0; i< vTalkChannel.length; ++i)
					{
						vTalkChannel[i].resume();						
					}
					_vTalkChannelCurrent = vTalkChannel;
				}
				else
				{
					dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.TALK_ENDED,evtDesc));
					//clean up
					cleanUpAudioQueue();
					
				}
				
			}
			
			function failedFn(failedUrl:String, s:String):void
			{
				var evtDesc:EventDescription = new EventDescription();
				evtDesc.description = failedUrl;
				evtDesc.obj = s;
				dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.AUDIO_ERROR,evtDesc));				
				if (_arrAudioQueue.length>1)
				{
					finishedPlaying(failedUrl, true);
				}
			}
			
			function progressFn(loaded:uint, total:uint):void
			{
				var evtDesc:EventDescription = new EventDescription();
				evtDesc.description = url;
				evtDesc.percent = loaded/total;
				dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.AUDIO_DOWNLOAD_PROGRESS,evtDesc));
			}						
		}
		
		private function cleanUpAudioQueue():void
		{
			_vTalkChannelCurrent = null;
			_arrAudioQueue = new Array();
			_dictAudioChannels = new Dictionary();
			_iPosInAudioQueue = 0;
		}
		
		/**
		 * Stops currently playing audio.  		 		 
		 */
		public function stopSpeech():void
		{
			if (_vTalkChannelCurrent!=null)
			{
				var evtDesc:EventDescription = new EventDescription();
				evtDesc.description = _sCurrentAudioUrl;
				for (var i:int=0; i<_vTalkChannelCurrent.length; ++i)
				{
					_vTalkChannelCurrent[i].stop();	
				}
				dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.AUDIO_ENDED,evtDesc));
				dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.TALK_ENDED,evtDesc));
				//clean up
				_arrAudioQueue = new Array();
				_dictAudioChannels = new Dictionary();
				_iPosInAudioQueue = 0;
			}
		}
		
		/**
		 * Freezes currently playing audio and engine  		 		 
		 */
		public function freeze():void
		{
			if (_vTalkChannelCurrent!=null)
			{
				for (var i:int=0; i<_vTalkChannelCurrent.length; ++i)
				{
					_vTalkChannelCurrent[i].pause();	
				}
			}
		}
		/**
		 * Resumes currently playing audio and engine  		 		 
		 */
		public function resume():void
		{
			if (_vTalkChannelCurrent!=null)
			{
				for (var i:int=0; i<_vTalkChannelCurrent.length; ++i)
				{					
					_vTalkChannelCurrent[i].resume();	
				}
			}
		}
		
		/**
		 * Sets the volume for current and future audios played  		 		 
		 */
		public function setVolume(n:Number):void
		{
			_nCurrentAudioVolume = n;
			if (_vTalkChannelCurrent!=null)
			{
				for (var i:int=0; i<_vTalkChannelCurrent.length; ++i)
				{					
					_vTalkChannelCurrent[i].setVolume(n);	
				}
			}
		}
		
		/**
		 * Sets the move of the say function. If interrupt is on each call to say will stop the previous audio otherwise they will stack and play one after the other
		 * @param	b - Boolean interrupt mode	 		 
		 */
		public function setInterrupt(b:Boolean):void
		{
			_bInterrupt = b;			
		}
		
	}
}
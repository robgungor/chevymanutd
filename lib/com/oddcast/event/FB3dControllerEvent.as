
package com.oddcast.event
{
	import flash.events.Event;

	public class FB3dControllerEvent extends Event{
				
		//public static const ENGINE_LOADED:String = "onFb3dEngineLoaded";
		//public static const ENGINE_LOAD_PROGRESS:String = "onFb3dEngineLoadProgress";		
		public static const ON_ERROR:String = "onFb3dError";
		public static const AVATAR_CLICKED:String = "onFb3dAvatarClicked";		
		public static const AUDIO_STARTED:String = "onFb3dAudioStarted";
		public static const AUDIO_ENDED:String = "onFb3dAudioEnded";
		public static const TALK_STARTED:String = "onFb3dTalkStarted";
		public static const TALK_ENDED:String = "onFb3dTalkEnded";
		public static const AUDIO_DOWNLOADED:String = "onFb3dAudioDownloaded";
		public static const AUDIO_ERROR:String = "onFb3dAudioError";		
		public static const AUDIO_DOWNLOAD_PROGRESS:String = "onFb3dAudioDownloadProgress";
		public static const ACCESSORY_SET_LOADED:String = "onFB3dAccessorySetLoaded";
		//public static const ACCESSORY_SET_LOAD_PROGRESS:String = "onFB3dAccessorySetLoadProgress";
		
		public var data:EventDescription;
		
		public function FB3dControllerEvent($type:String, $data:EventDescription = null, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new FB3dControllerEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("FB3dControllerEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
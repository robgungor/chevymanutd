
package com.oddcast.video
{
	import flash.events.Event;

	public class StreamEvent extends Event{
						
		
		public static const ON_ERROR:String = "onStreamError";
		public static const CONNECTION_SUCCESS:String = "onStreamConnected";
		public static const CAMERA_ENABLED:String = "onCameraEnabled";	
		public static const CAMERA_DISABLED:String = "onCameraDisabled";	
		public static const PLAYBACK_STOP:String = "onPlaybackStop";			
		public static const PLAYBACK_START:String = "onPlaybackStart";					
		public static const PUBLISH_START:String = "onPublishStart";
		public static const PUBLISH_PROCESSING:String = "onPublishProcessing";
		public static const PUBLISH_DONE:String = "onPublishDone";
		public static const PUBLISH_NEXT_MSG:String = "onPublishNextMsg";
		public static const PUBLISH_NOW_MSG:String = "onPublishNowMsg";
		public static const PUBLISH_FINISH_MSG:String = "onPublishFinishMsg";
		public static const PUBLISH_FINISH_WARN_MSG:String = "onFinishBroadcastWarningMsg";
		
		public var data:Object;
		
		public function StreamEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new StreamEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("StreamEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
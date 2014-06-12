package com.oddcast.event{
	import flash.events.Event;

	public class SpeechEvent extends Event{
				
		public static const SPEECH_LOAD_ERROR:String = "loadError";		
		public static const SPEECH_STARTED:String = "talkStarted";
		public static const SPEECH_ENDED:String = "talkEnded";
		public static const SPEECH_LOADED:String = "loadDone";
		public static const SPEECH_NEW_WORD:String = "newWord";
		public static const SPEECH_ERROR:String = "speechError";
		
		public var data:Object;
		
		public function SpeechEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new SpeechEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("SpeechEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
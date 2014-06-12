
package com.oddcast.event
{
	import flash.events.Event;

	public class EngineEvent extends Event{
				
		public static const CONFIG_DONE:String = "configDone";
		public static const TALK_STARTED:String = "talkStarted";
		public static const TALK_ENDED:String = "talkEnded";
		public static const AUDIO_ENDED:String = "audioEnded";
		public static const AUDIO_STARTED:String = "audioStarted";
		public static const WORD_ENDED:String = "wordEnded";
		public static const AUDIO_DOWNLOAD_START:String = "audioDownloadEnded";
		public static const AUDIO_ERROR:String = "audioError";
		//events used within engine itself
		public static const NEW_AUDIO_SEQUENCE:String = "newSequence";
		public static const NEW_MOUTH_FRAME:String = "newMouthFrame";
		public static const SMILE:String = "smile";
		public static const AUDIO_TIMER_EVENT:String = "audioTimeEvent";
		public static const SAY_SILENT_ENDED:String = "saySilentEnded";
		//events for configController
		public static const ACCESSORY_LOADED:String = "accessoryLoaded";
		public static const ACCESSORY_INCOMPATIBLE:String = "accessoryIncompatible";
		static public const PROCESSING_STARTED : String = "processingStarted";
		static public const PROCESSING_ENDED : String = "processingEnded";
		public static const MODEL_LOAD_ERROR:String = "modelLoadError";
		public static const ACCESSORY_LOAD_ERROR:String = "accessoryLoadError";
		
		public var data:Object;
		
		public function EngineEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new EngineEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("EngineEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
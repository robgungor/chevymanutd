package com.oddcast.event {
	import flash.events.Event;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class KaraokeEvent extends Event {
		public static const START:String = "karaokeStart";
		public static const STOP:String = "karaokeStop";
		public static const CLOSE:String = "karaokeClose";
		
		public function KaraokeEvent($type:String) {
			super($type);
		}
		
		public override function clone():Event {
			return new KaraokeEvent(type);
		}
		
	}
	
}
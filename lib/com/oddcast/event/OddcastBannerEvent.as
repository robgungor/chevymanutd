
package com.oddcast.event
{
	import flash.events.Event;

	public class OddcastBannerEvent extends Event{
								
		public static const COMPLETE:String = "bannerReady";
		public static const USER_FIRST_ACTION:String = "bannerFirstAction"; 
		
		
		public var data:Object;
		
		public function OddcastBannerEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new OddcastBannerEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("OddcastBannerEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
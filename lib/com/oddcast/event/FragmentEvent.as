
package com.oddcast.event
{
	import flash.events.Event;

	public class FragmentEvent extends Event
	{
								
		public static const FRAGMENT_LOADED:String = "fragmentLoaded";
		public static const FRAGMENT_LOAD_ERROR:String = "fragmentLoadError";
		
		public var data:Object;
		
		public function FragmentEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new FragmentEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("FragmentEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
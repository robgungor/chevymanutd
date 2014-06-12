/**
* ...
* @author Sam Myer
* @version 0.1
* 
* Description - The event for dispatching L
*
* 
* 
* Public Properties/Events:
* 	SUCCESS:String
* 		Event Constant which represents a successful sent message
* 	FAILED:String
* 		Event Constant which represents a failed sent message
* 	NAME_TAKEN:String
* 		Event Constant which represents a failure setting up the receiving LocalConnection due to the connection name being already in use
* 	SECURITY:String //TO BE IMPLEMENTED
* 
* 
*/

package com.oddcast.event {
	
	import flash.events.Event;
	
	public class LCEvent extends Event {
	
		public static const DEFAULT_NAME:String = "com.oddcast.event.LCEvent";
		public static const SUCCESS:String = "success";
		public static const FAILED:String = "failed";
		public static const NAME_TAKEN:String = "isTaken";
		
		public function LCEvent($type:String, $bubbles:Boolean = false, $cancelable:Boolean = false):void
		{
			super($type, $bubbles, $cancelable);
		}
		
		public override function clone():Event
		{
			return new LCEvent(type, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("LCEvent", "type", "bubbles", "cancelable");
		}
		
	}
	
}
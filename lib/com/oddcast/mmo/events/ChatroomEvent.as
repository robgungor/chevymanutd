
package com.oddcast.mmo.events
{
	import flash.events.Event;

	public class ChatroomEvent extends Event{
				
		public static const ON_ERROR:String = "onError";
		public static const ON_INIT:String = "onInit";
		public static const ON_RENDER:String = "onRender";
		public static const ON_SEND_DATA:String = "onSendData";
		public static const ON_RECEIVE_DATA:String = "onReceiveData";
		public static const ON_COMPLETE:String = "onComplete"; //avatar loaded too
		public static const ON_POSITION:String = "onPosition";//avatar position has changed 
		public static const ON_LOG_MSG:String = "onLogMsg"; //chatroom to display things in the chat log panel
		
		public var data:Object;
		
		public function ChatroomEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new ChatroomEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("ChatroomEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
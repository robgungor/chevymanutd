
package com.oddcast.mmo.events
{
	import flash.events.Event;

	public class ChatManagerEvent extends Event{
				
		public static const ON_ERROR:String = "onError";
		public static const ON_CONNECT:String = "onConnect";
		public static const ON_LOGIN:String = "onLogin";
		public static const ON_LOGOUT:String = "onLogout";
		public static const ON_ROOMS_LIST:String = "onRoomsList";
		public static const ON_ENTER_ROOM:String = "onEnterRoom";
		public static const ON_LEAVE_ROOM:String = "onLeaveRoom";
		public static const ON_NEW_DATA:String = "onNewData";					
		public static const ON_CHATROOM_READY:String = "onChatroomReady";
		public static const ON_VOIP_READY:String = "onVoipReady";
		
		public var data:Object;
		
		public function ChatManagerEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new ChatManagerEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("ChatManagerEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
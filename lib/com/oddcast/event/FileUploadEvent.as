//author: jonathan achai

package com.oddcast.event{
	import flash.events.Event;
	import flash.events.TextEvent;

	public class FileUploadEvent extends TextEvent {
				
		public static const ON_SELECT:String = "onSelected";
		public static const ON_DONE:String = "onDone";				
		public static const ON_CANCEL:String = Event.CANCEL;
		public static const ON_PROGRESS:String = "onProgress";
		public static const ON_UPLOAD_START:String = "onUploadStart";
		public static const ON_ERROR:String = "onError";
		public static const ON_HTTP_STATUS:String = "onHttpStatus";
		public var data:Object;
		public var sessionId:String;
		
		public function FileUploadEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = true,$url:String=null,$sessionId:String=null):void
		{
			super($type, $bubbles, $cancelable,$url);
			this.data = $data;
			sessionId = $sessionId;
		}
		
		public override function clone():Event
		{
			var evt:FileUploadEvent = new FileUploadEvent(type, this.data, bubbles, cancelable,text,sessionId);
			return(evt);
		}

		public override function toString():String
		{
			return formatToString("FileUploadEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
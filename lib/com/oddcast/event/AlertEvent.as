/**
* ...
* @author Default
* @version 0.1
*/

package com.oddcast.event {
	import flash.events.Event;
	import flash.events.TextEvent;

	public class AlertEvent extends TextEvent {
		public var code:String;
		public var moreInfo:Object;
		public var callback:Function;
		public var alertType:String;
		/** indicates if the error should be reported to oddcast servers */
		public var report_error:Boolean = true;
		/** indicates if user feedback should be blocked by hiding the ok/cancel/close buttons for example */
		public var block_user_feedback:Boolean = false;
		
		public static const EVENT:String = "error"; //no matter what alertType
		
		public static const ALERT:String="alert";
		public static const ERROR:String="error";
		public static const CONFIRM:String="confirm";
		public static const FACEBOOK_CONFIRM:String = "facebookConfirm";
		/**
		 * NOTE: AlertEvents are always of type AlertEvent.EVENT. No matter what the alert type is, you have to listen
		 * for addListener(AlertEvent.EVENT,fn)!
		 * @param $alertType
		 * @param alertCode
		 * @param alertText
		 * @param info
		 * @param in_callback
		 * 
		 */		
		public function AlertEvent($alertType:String,alertCode:String, alertText:String="", info:Object=null,in_callback:Function=null, _report_error:Boolean=true) {
			super(EVENT,true,false,alertText);
			code = alertCode;
			moreInfo = info;
			callback = in_callback;
			alertType = $alertType;
			report_error = _report_error;
		}
		
		public override function clone():Event {
			return(new AlertEvent(alertType,code,text,moreInfo,callback));
		}
		
		public override function toString():String
		{
			return formatToString("AlertEvent", "code", "moreInfo", "alertType"); 
		}
	}
	
}
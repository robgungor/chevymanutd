/**
* ...
* @author Sam Myer
* @version 0.1
* 
* Events:
* ERROR:
* message = the error message
* 
* SAVE_DONE
* message = the location where the file is saved - either an ID or a URL
* 
* READY_STATE
* newStatus = 0 is mic is muted, 1 if mic is ready
* readyState = true if mic is ready
* 
* STREAM_STATUS
* oldStatus = previous status ID
* newStatus = new Status ID :
* 0-no audio  1=recording 2=stopped 3=playing 4=paused
*/

package com.oddcast.event {
	import flash.events.Event;

	public class MicRecorderEvent extends Event {
		public var message:String;
		public var oldStatus:int;
		public var newStatus:int;
		
		public static var ERROR:String="micError";
		public static var SAVE_DONE:String="micSaveDone";
		public static var READY_STATE:String="readyStateChanged";
		public static var STREAM_STATUS:String = "sceneStatusChange";
		public static var SILENCE_WARNING:String = "micSilenceWarning";
		public static var RESET:String = "micConnectionReset";
		
		public function MicRecorderEvent(in_type:String,in_message:String,in_newStatus:int=0,in_oldStatus:int=0) {
			super(in_type);
			message=in_message;
			oldStatus=in_oldStatus;
			newStatus=in_newStatus;
		}
		
		public function get readyState():Boolean {
			return(newStatus>0);
		}
					
		public override function clone():Event {
			return new MicRecorderEvent(type,message,newStatus,oldStatus);
		}
		
	}
	
}
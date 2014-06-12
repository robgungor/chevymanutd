/**
* ...
* @author Sam
* @version 1.0
* 
* Returns event when processing starts/progresses/finishes
* this is intended to be used solely to indicate when to show/hide progress bars
* 
* constructor:
* new ProcessingEvent(type,processName[,percent])
* 
* parameters:
* type - can be:
* STARTED - processing has started
* PROGRESS - dispatched periodically as progress "percent done" bar is to be updated
* DONE - processing has finished (due to success or error)
* 
* processName - this can be anything, it is a string to identify which process is starting/finishing
* some default names are provided for common processes:
* MODEL,BG,AUDIO,SAVING,AUTOPHOTO,ACESSORY
* 
* percent:
* For PROGRESS event only, this is aa number between 0 and 1 representing the percent done of the process
* 
* message:
* This indicates the title, message or name of the process that is to be displayed on the loading bar.
* e.g. "Loading Character", "Loading Head File"
*/

package com.oddcast.workshop {
	import flash.events.Event;

	public class ProcessingEvent extends Event {
		public var processName:String;
		private var success:Boolean; //to be implemented
		public var percent:Number;
		public var message:String;

		public static const STARTED:String = "processingStarted";
		public static const PROGRESS:String = "processingProgress"; //to be implemented
		public static const DONE:String = "processingDone";
		
		//process names
		public static const MODEL:String = "model";
		public static const BG:String = "bg";
		public static const AUDIO:String = "audio";
		public static const SAVING:String = "saving";
		public static const AUTOPHOTO:String = "autophoto";
		public static const ACCESSORY:String = "accessory";
		public static const FULL_BODY:String = "full_body";
		//public static const VIDEO_DOWNLOAD:String = "download";

		public function ProcessingEvent(in_type:String,in_name:String,in_percent:Number=0) {
			super(in_type);
			processName = in_name;
			percent = in_percent;
		}
		
		public override function clone():Event {
			var evt:ProcessingEvent = new ProcessingEvent(type, processName);
			evt.percent = percent;
			evt.message = message;
			return evt;
		}
	}
	
}
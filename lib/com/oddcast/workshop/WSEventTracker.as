/**
* ...
* @author Sam
* @version 0.1
* 
* Contains a static instance of the EventTracker Object.
* It has it's own class to distinguish it from the PlayerEventTracker.
* 
* @see com.oddcast.reports.EventTracker
*/

package com.oddcast.workshop {
	import com.oddcast.reports.EventTracker;
	import flash.display.LoaderInfo;
	
	public class WSEventTracker {		
		private static var tracker:EventTracker;
		
		public static function init(in_req_url:String, in_init_obj:Object, in_loader:LoaderInfo = null) : void {
			tracker=new EventTracker();
			tracker.init(in_req_url,in_init_obj,in_loader);
		}
		
		public static function event(in_event:String, in_scene:String=null,count:uint=0,value:String=null) : void {
			if (tracker==null) return;
			tracker.event(in_event,in_scene,count,value);
		}
		
		public static function destroy() : void {
			if (tracker == null) return;
			trace("*** DESTROYING TRACKER ***");
			tracker.destroy();
			tracker=null;
		}
		
		public static function getTracker():EventTracker {
			return(tracker);
		}
	}
	
}
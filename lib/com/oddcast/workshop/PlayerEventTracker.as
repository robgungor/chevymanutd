/**
* ...
* @author Default
* @version 0.1
* 
* Contains static instance of event tracker class.  Used to distinguish from WSEventTracker
*/

package com.oddcast.workshop {
	import com.oddcast.reports.EventTracker;
	
	public class PlayerEventTracker {		
		private static var tracker:EventTracker;
		
		public static function init(in_req_url:String, in_init_obj:Object) {
			tracker=new EventTracker();
			tracker.init(in_req_url,in_init_obj);
		}
		
		public static function event(in_event:String, in_scene:String=null,count:uint=0,value:String=null) {
			if (tracker==null) return;
			tracker.event(in_event,in_scene,count,value);
		}
		
		public static function destroy() {
			if (tracker==null) return;
			tracker.destroy();
			tracker=null;
		}
		
		public static function getTracker():EventTracker {
			return(tracker);
		}
	}
	
}
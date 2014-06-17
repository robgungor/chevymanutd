/**
	 * ...
	 * @author Jake Lewis
	 * 6/18/2010 1:12 PM
	 */

package com.oddcast.cv.api;
	//import com.oddcast.cv.api.FaceTrackerSWF;
	
	
	import flash.display.MovieClip;
	
	import com.oddcast.cv.api.IFaceTrackerAPI;
	import com.oddcast.cv.api.FaceTrackerAPI;
	//import com.oddcast.cv.HaxeSWC;
	import com.oddcast.cv.api.FaceAPI_Constants;
	 
	class FaceTrackerSWF extends MovieClip
	{
		
		public function new() 
		{
			super();
			//var haxeSWC = new HaxeSWC(this);  //initialise the swc
			
		}
		
		public function getAPI(trackerMode:TrackerMode = FaceAPI_Constants.TRACKER_MODE_DEFAULT)	:IFaceTrackerAPI {
			return new FaceTrackerAPI(trackerMode);
		}
		
		public function dispose():Void{	}
		
		
	}


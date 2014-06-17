package com.oddcast.cv.api;
	/**
	 * ...
	 * @author Jake Lewis
	 * 6/18/2010 12:10 PM
	 */
	import com.oddcast.cv.api.FaceFinderAPI;
	import com.oddcast.cv.haar.HaarFace;
	import flash.Boot;
	import flash.display.MovieClip;
	import com.oddcast.cv.face.FaceFinder;
	import com.oddcast.cv.IDisposable;
	import jp.maaash.detection.ObjectDetectorOptions;
	import com.oddcast.cv.api.FaceAPI_Constants;

	
	//import com.oddcast.cv.HaxeSWC;
	 
	class FaceFinderSWF extends MovieClip
	{
		
		
		public function new() 
		{
			super();
		}
		
		public function getAPI(trackerMode: TrackerMode=FaceAPI_Constants.TRACKER_MODE_FACE_EYES):IFaceFinderAPI {
			
			var haarFace :HaarFace = null;
			switch trackerMode {
				case FaceAPI_Constants.TRACKER_MODE_FACE:
					haarFace = new com.oddcast.cv.haar.HaarFace(FaceAPI_Constants.DEFAULT_MODE);
				case FaceAPI_Constants.TRACKER_MODE_FACE_EYES:
					haarFace = new com.oddcast.cv.haar.HaarFaceAndEyes(FaceAPI_Constants.DEFAULT_MODE);
				default: throw "Unknown trackerMode:" + trackerMode;					
			}
			
			faceFinder = new FaceFinder 
								(
									haarFace
									,FaceAPI_Constants.DEFAULT_MAX_FACES
									, null
								);
								
		
			var retval = new FaceFinderAPI(faceFinder);
			
			//retval.setMinFaceSize(0.25);//MUSTDO
			//retval.setSearchMode(FaceAPI_Constants.FAST_MODE);//MUSTDO
			return retval;
		
		}
		
		public function dispose():Void {
			faceFinder = Disposable.disposeIfValid(faceFinder);
		}
		
		var faceFinder :FaceFinder;
	}

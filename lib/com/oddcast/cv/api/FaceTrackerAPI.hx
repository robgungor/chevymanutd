
/**
 * ...
 * @author Jake Lewis
 * copyright Oddcast Inc. 2010  All rights reserved
 * 4/8/2010 5:23 PM
 **/


 
package  com.oddcast.cv.api;
	//import com.oddcast.cv.api.FaceTrackerAPI;
	
	import flash.display.Stage;
	import flash.display.BitmapData;
	import com.oddcast.cv.api.FaceAPI_Constants;
	
	
	import com.oddcast.cv.face.FaceFinder;
	//import com.oddcast.cv.haar.HaarFaceEyesNose;
	import com.oddcast.cv.haar.HaarFace;
	import jp.maaash.detection.ObjectDetectorOptions;
	import com.oddcast.cv.api.FrameStoreAPI;
	import com.oddcast.cv.util.SmoothFloat;
	import com.oddcast.cv.haar.HaarFaceAndEyes;
	import com.oddcast.cv.haar.SmoothingFacePoints;
	import com.oddcast.cv.util.IIntermediateSprite;

	typedef UnmuteCallback = Bool->Void;  // api.initWebcam(function (unmute:Boolean):void {	trace ("UNMUTED in as");	}	); 
	
	
	
	 
	class FaceTrackerAPI extends FrameStoreAPI
								,implements IFaceTrackerAPI
								,implements IIntermediateSpriteProvider
	{
		
				
		public function new(trackerMode:TrackerMode) 
		{
			super(trackerMode);	
		}
		
		override public function initWebcam(unmuteCallBack:UnmuteCallback, vidWidth:Int=320, vidHeight:Int=240, fps:Int = 30):Bool{
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("initWebcam(unmuteCallBack, width:"+vidWidth+", height:"+vidHeight+" fps:"+fps+")");
			#end
			return super.initWebcam(unmuteCallBack, vidWidth, vidHeight);
		}
		
		override public function endWebcam() {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("endWebcam()");
			#end
			super.endWebcam();
		}
		
		
		
		public function getStatus():Int {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getStatus():"+state);
			#end
			return state;
		}
		
		
		//connect this to a gui button
		public function mirrorFlip() {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("mirrorFlip()");
			#end
			mirror();
		}
		
		
		//call on EnterFrame 
		//pass Stage  - note that this will Interactivly change the framerate to match the rate delivered by the webcam.
		var lastTime:Int;
		override public function update(stage:Stage):Bool {
			//#if debugtrace
				var time = flash.Lib.getTimer();
				
				var imageProviderActualFrameRate = "";
				if (imageProvider != null) 
					imageProviderActualFrameRate = " webcamFrameRate:" + imageProvider.getActualFramerate();
				/*com.oddcast.util.Utils.releaseTrace("update() - stageFPS:" +stage.frameRate 
													+ imageProviderActualFrameRate
													+ " Actual:"+ Math.round(1000 / (time-lastTime))
												 	);*/
				lastTime = time;
			//#end
			return super.update(stage);
		}
		
		override public function getWebcamBitmapData():BitmapData {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getWebcamBitmapData()");
			#end
			return super.getWebcamBitmapData();
		}
		
		
		public function getFaces():ArrayFaceID {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFaces()");
			#end
			return getFaceIDs();
		}
		
		override public function getFaceBitmap(faceFoundBitmap:FaceFoundBitmap, id:FaceID){
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFaceBitmap(faceFoundBitmap, id:"+id+")");
			#end
			return super.getFaceBitmap(faceFoundBitmap, id);
		}
		
		
		public function isBlinking(id:FaceID, minInterval:Float=FaceAPI_Constants.DEFAULT_BLINK_INTERVAL):Bool {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("isBlinking(id:"+id+", minInterval:"+minInterval+")");
			#end
			return faceFinder.haarFace.isBlinking(minInterval, this, id, parameters);
			return false;
		}
		
		public function getFaceRGB(id:FaceID):Int { 
			return faceFinder.getFaceRGBvalue(id, parameters);
		}
		
		//override public function getSmoothing(id:FaceId
		
				
		
	
		public function getFaceData(
									id:FaceID, 
									required:ArrayFaceData   // of AR_FaceData;
									):ArrayFaceDataResults//of Numbers
									{
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFaceData(id:"+id+", required:"+required.toString()+")");
			#end
									
			return faceFinder.getFaceData(id, required);							
									
		}
		
		public function setSmoothingValue(i:SmoothingIndex, v:SmoothingValue) {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("setSmoothingValue(smoothingIndex:"+i+", smoothingValue:"+v+")");
			#end
			faceFinder.setSmoothingValue(stripSmoothingID(i), v);
		}
		
		public function getSmoothingValue(i:SmoothingIndex):SmoothingValue {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getSmoothingValue(smoothingIndex:"+i+")");
			#end 
			return faceFinder.getSmoothingValue(stripSmoothingID(i));
		}
		
		public function getFaceFinderAPI():IFaceFinderAPI {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFaceFinderAPI()");
			#end 
			return new FaceFinderAPI(faceFinder);
		}
		
		public function resetFace():Void {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("resetFace()");
			#end
			faceFinder.reset();
		}
		
		override public function dispose():Void {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("dispose()");
			#end
			super.dispose();
		}
		
		
		
		// PRIVATE
		
		function stripSmoothingID(i:SmoothingIndex):SmoothingIndex {
			if ((i & SmoothingFacePoints.SMOOTH_MASK) != SmoothingFacePoints.SMOOTH_ID)
				throw "Invalid smoothing index:" + i;
			return i & (SmoothingFacePoints.SMOOTH_MASK ^ 0xffffffff);
		}
		
		
		
		
		override public function createFaceFinder(trackerMode:TrackerMode) {
			
			faceFinder = new FaceFinder 
								(
									createHaarFace(trackerMode)
									, FaceAPI_Constants.DEFAULT_WEBCAM_MAX_FACES, null
								);
		}
		
		override public function initApp():Void { //dont call super
		}
		
		override public function setStageAlign():Void { }
		
		
		

	
	}
	

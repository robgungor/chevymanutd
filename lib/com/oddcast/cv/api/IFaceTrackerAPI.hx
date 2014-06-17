
/**
 * ...
 * @author Jake Lewis
 * copyright Oddcast Inc. 2010  All rights reserved
 * 6/18/2010 3:20 PM
 **/


 
package  com.oddcast.cv.api;
	//import com.oddcast.cv.api.IFaceTrackerAPI;
	
/*	
	
	import com.oddcast.cv.face.FaceFinder;
	import com.oddcast.cv.haar.HaarFaceEyesNose;
	import com.oddcast.cv.haar.HaarFace;
	import jp.maaash.detection.ObjectDetectorOptions;
	import com.oddcast.cv.api.FrameStoreAPI;
	import com.oddcast.cv.util.SmoothFloat;
	import com.oddcast.cv.haar.HaarFaceAndEyes;

*/
	import com.oddcast.cv.api.FaceTrackerAPI;
	import com.oddcast.cv.api.FaceAPI_Constants;
	import com.oddcast.cv.haar.SmoothingFacePoints;
	import com.oddcast.cv.util.SmoothFloat;
	
	import flash.display.Stage;
	import flash.display.BitmapData;
	import com.oddcast.cv.haar.SmoothingFacePoints;
	
	interface IFaceTrackerAPI implements IFrameStoreAPI{
		function initWebcam(unmuteCallBack:UnmuteCallback, vidWidth:Int = 320, vidHeight:Int = 240, fps:Int = 30):Bool;
		function endWebcam():Void;
		function getStatus():Int;	
		function mirrorFlip():Void;
		function update(stage:Stage):Bool;
		function getWebcamBitmapData():BitmapData;
		function getFaces():ArrayFaceID;
		function getFaceBitmap(faceFoundBitmap:FaceFoundBitmap, id:FaceID):Void;
		function getFaceData(
								id:FaceID, 
								required:ArrayFaceData   // of AR_FaceData;
							):ArrayFaceDataResults;//of Numbers
										
			
		function setSmoothingValue(i:SmoothingIndex, v:SmoothingValue):Void;
			
		function getSmoothingValue(i:SmoothingIndex):SmoothingValue;
		function isBlinking(id:FaceID, minInterval:Float = FaceAPI_Constants.DEFAULT_BLINK_INTERVAL):Bool;
		
		function getFaceFinderAPI():IFaceFinderAPI;
		
		function resetFace():Void;
		function getFaceRGB(id:FaceID):Int;
		//function dispose():Void;
	}

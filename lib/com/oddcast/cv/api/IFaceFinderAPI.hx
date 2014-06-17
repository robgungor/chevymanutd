
/**
 * ...
 * @author Jake Lewis
 * copyright Oddcast Inc. 2010  All rights reserved
 * 9/15/2010 6:28 PM
 * 
 * 
 **/

package  com.oddcast.cv.api;
//import com.oddcast.cv.api.IFaceFinderAPI;
	
	import flash.display.BitmapData;
	import com.oddcast.cv.api.FaceAPI_Constants;
	import com.oddcast.cv.api.FaceFoundBitmap;
	/*
	import flash.text.TextField;
	
	
	import com.oddcast.cv.face.FaceFinder;
	import com.oddcast.cv.face.Parameters;
	import com.oddcast.cv.haar.HaarFace;
	import com.oddcast.cv.haar.HaarFaceAndEyes;
	import com.oddcast.cv.imageProvider.ImageProviderPhoto;
	import com.oddcast.cv.haar.HaarObjectFoundRectangle;
	import com.oddcast.cv.face.FaceParts;
	import com.oddcast.cv.util.RotationConverter;
	import com.oddcast.cv.util.Radians;
	import com.oddcast.cv.IDisposable;
	
	import com.oddcast.util.trace.Tracer;
 
	import jp.maaash.detection.ObjectDetectorOptions;
	*/
	
	interface IFaceFinderAPI {
		function setMinFaceSize(min_FaceSize:Float):Float;
		function setSearchMode(searchMode:Int):Void;
		function setMaxFaces(iMaxFaces:Int):Void;
		function getFacesRotated(photoBitmapData:BitmapData, bQuitWhenFound:Bool = true, rotations:Array<Float> = null):ArrayFaceID;
		function getFaces(photoBitmapData:BitmapData, rotation:Float = 0.0):ArrayFaceID;
		function getFaceBitmap(faceFoundBitmap:FaceFoundBitmap, id:FaceID):Void;
		function getFaceData(
									id			:FaceID, 
									required	:ArrayFaceData   // of AR_FaceData;
									):ArrayFaceDataResults;
		function dispose():Void;
		function getFaceRGB(id:FaceID):Int;
	}
	
	

/**
 * ...
 * @author Jake Lewis
 * copyright Oddcast Inc. 2010  All rights reserved
 * 4/8/2010 5:23 PM
 * 
 * loaded via "com.oddcast.cv.api.FaceFinderSWF"
 **/

package  com.oddcast.cv.api;
//import com.oddcast.cv.api.FaceFinderAPI;
	
	 
	import flash.display.BitmapData;
	import flash.text.TextField;
	
	
	import com.oddcast.cv.face.FaceFinder;
	import com.oddcast.cv.face.Parameters;
	import com.oddcast.cv.haar.HaarFace;
	import com.oddcast.cv.api.FaceAPI_Constants;
	import com.oddcast.cv.haar.HaarFaceAndEyes;
	import com.oddcast.cv.imageProvider.ImageProviderPhoto;
	import com.oddcast.cv.haar.HaarObjectFoundRectangle;
	import com.oddcast.cv.face.FaceParts;
	import com.oddcast.cv.util.RotationConverter;
	import com.oddcast.cv.util.Radians;
	import com.oddcast.cv.IDisposable;
	
	import com.oddcast.util.trace.Tracer;
 
	import jp.maaash.detection.ObjectDetectorOptions;
	
	
	
	class FaceFinderAPI implements IFaceFinderAPI
	{
		static public var DEFAULT_ROTATION = Radians.toRadians(35.0);
				
		public function new( faceFinder:FaceFinder ) {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("new()");
			#end
			this.faceFinder = faceFinder;
			tracer = new Tracer();
			parameters = new Parameters();
			
			com.oddcast.util.Utils.releaseTrace(
				"FaceFinder.swf "+
				new com.oddcast.util.BuildInfo().toString()
			);	
		}
		
		public function setMinFaceSize(min_FaceSize:Float):Float {
			if (min_FaceSize > 0.90)
				min_FaceSize = 0.90;
			if (min_FaceSize < 0.05)
				min_FaceSize = 0.05;
			faceFinder.setMinFaceSize(min_FaceSize);
			return min_FaceSize;
		}
		
		public function setSearchMode(searchMode:Int) {
			faceFinder.setSearchMode(searchMode);
		}
		
		public function setMaxFaces(iMaxFaces:Int) {
			faceFinder.setMaxFaces(iMaxFaces);
		}
		
		public function getFacesRotated(photoBitmapData:BitmapData, bQuitWhenFound:Bool = true, rotations:Array<Float> = null):ArrayFaceID { // of uint IDs
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFacesRotated(BitmapData, bQuitWhenFound:"+bQuitWhenFound+" rotations:"+rotations.toString()+")");
			#end
			if (rotations == null)
				rotations = [0.0, DEFAULT_ROTATION, -DEFAULT_ROTATION];
				
			if (bQuitWhenFound == false)
				throw " bQuitWhenFound must be true";  //otherwise we'll need to store all the persistant faces.
			var totalRet = new ArrayFaceID();
			for (rotation in rotations) {
				var ret = getFaces(photoBitmapData, rotation);
				if (  ret != null && ret.length > 0)
					if(bQuitWhenFound)
						return ret;
					else {
						for ( r in ret)
							totalRet.push(r);
					}
			}
			if (totalRet.length > 0)
				return totalRet;
			return null;	
		}
			
		public function getFaces(photoBitmapData:BitmapData, rotation:Float=0.0):ArrayFaceID{ // of uint IDs
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFaces(BitmapData,  rotation:"+rotation+")");
			#end
			faceFinder.reset();
			
			var imageProvider = new ImageProviderPhoto(photoBitmapData);
			
			var inputBitmapData = new BitmapData( 320, 240, false);
		
			
			imageProvider.calcMatrix(inputBitmapData, rotation);
			imageProvider.grabFrameRotated(inputBitmapData, null , 1.0, null);
			
			
			
			var rotationConverter = new RotationConverter(imageProvider.getInverseMatrix(), photoBitmapData.rect);
			faceFinder.setRotation(rotationConverter);
			
			parameters.rotationConverter = rotationConverter;
		//	parameters.webcamBitmapData = photoBitmapData;
			parameters.setInputBitmapData(
											inputBitmapData,
											photoBitmapData  //was inputBitmapData //
											);
				
			var searchRect = new HaarObjectFoundRectangle(
															"inputBitmapData",
															inputBitmapData.rect,
															FacePart.SEARCH_AREA
														);
			foundRectangle = faceFinder.detect(inputBitmapData, searchRect);
			
			//debug
			
			
			
			
			if (foundRectangle != null )
			{
				/*var textField = new TextField();
				foundRectangle.toTextField(textField);
				trace("[ALWAYS]" + textField.text);*/
				//return [0];  //just one face
			}
			//return null;
			return faceFinder.getFaceIDs();
		}
		
		public function getFaceBitmap(faceFoundBitmap:FaceFoundBitmap, id:FaceID):Void {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFaceBitmap(BitmapData,  id:"+FaceID+")");
			#end
			return faceFinder.getFaceBitmap(	faceFoundBitmap, id, parameters); 
		}
		
		
		
		
		
		
	
		public function getFaceData(
									id			:FaceID, 
									required	:ArrayFaceData   // of AR_FaceData;
									):ArrayFaceDataResults		//of Numbers
									{
										
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFaceData(id:"+FaceID+"retuired:"+required.toString()+")");
			#end
			return faceFinder.getFaceData(id, required);							
									
		}
		
		public function getFaceRGB(id:FaceID):Int { 
			return faceFinder.getFaceRGBvalue(id, parameters);
		}
		
		public function dispose():Void {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("dispose()");
			#end
			faceFinder = null; 
			parameters = null;
			foundRectangle = null;
			if (tracer != null) tracer.unload(); tracer = null;
		}
		
		
		//DEBUGGING only
		public function getScaledinputBitmapDataDEBUG():BitmapData {
			return parameters.inputBitmapData;
		}
		
		
		
		// PROTECTED
		
				
		
		private var tracer				:Tracer;
		private var faceFinder			:FaceFinder;
		private var parameters			:Parameters;
		private var foundRectangle		:HaarObjectFoundRectangle;
		
	}
	

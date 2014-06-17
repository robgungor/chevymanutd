package com.oddcast.cv.api {
	import com.oddcast.cv.api.FaceFoundBitmap;
	import flash.display.BitmapData;
	public interface IFaceFinderAPI {
		function setMinFaceSize(min_FaceSize : Number) : Number ;
		function setSearchMode(searchMode : int) : void ;
		function setMaxFaces(iMaxFaces : int) : void ;
		function getFacesRotated(photoBitmapData : flash.display.BitmapData,bQuitWhenFound : Boolean = false,rotations : Array = null) : Array ;
		function getFaces(photoBitmapData : flash.display.BitmapData,rotation : Number = NaN) : Array ;
		function getFaceBitmap(faceFoundBitmap : com.oddcast.cv.api.FaceFoundBitmap,id : int) : void ;
		function getFaceData(id : int,required : Array) : Array ;
		function dispose() : void ;
		function getFaceRGB(id : int) : int ;
	}
}

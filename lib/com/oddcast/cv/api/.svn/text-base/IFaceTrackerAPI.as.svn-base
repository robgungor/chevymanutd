package com.oddcast.cv.api {
	import com.oddcast.cv.api.FaceFoundBitmap;
	import com.oddcast.cv.api.IFaceFinderAPI;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import com.oddcast.cv.api.IFrameStoreAPI;
	public interface IFaceTrackerAPI extends com.oddcast.cv.api.IFrameStoreAPI{
		function initWebcam(unmuteCallBack : Function,vidWidth : int = 0,vidHeight : int = 0,fps : int = 0) : Boolean ;
		function endWebcam() : void ;
		function getStatus() : int ;
		function mirrorFlip() : void ;
		function update(stage : flash.display.Stage) : Boolean ;
		function getWebcamBitmapData() : flash.display.BitmapData ;
		function getFaces() : Array ;
		function getFaceBitmap(faceFoundBitmap : com.oddcast.cv.api.FaceFoundBitmap,id : int) : void ;
		function getFaceData(id : int,required : Array) : Array ;
		function setSmoothingValue(i : uint,v : uint) : void ;
		function getSmoothingValue(i : uint) : uint ;
		function isBlinking(id : int,minInterval : Number = NaN) : Boolean ;
		function getFaceFinderAPI() : com.oddcast.cv.api.IFaceFinderAPI ;
		function resetFace() : void ;
		function getFaceRGB(id : int) : int ;
	}
}

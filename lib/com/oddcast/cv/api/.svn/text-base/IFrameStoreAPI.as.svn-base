package com.oddcast.cv.api {
	import flash.utils.ByteArray;
	import com.oddcast.host.api.FileData;
	import flash.geom.Rectangle;
	import com.oddcast.cv.api.FaceFoundBitmap;
	import flash.display.BitmapData;
	public interface IFrameStoreAPI {
		function createFrameStore_FB(maxFrames : int) : int ;
		function createFrameStore_TB(durationMillisecs : Number,fps : int) : int ;
		function removeFrameStore(frameStoreID : int) : int ;
		function addFrame_FB(id : int,faceFoundBitmap : com.oddcast.cv.api.FaceFoundBitmap,faceDataResults : Array) : int ;
		function addFrame_TB(id : int,faceFoundBitmap : com.oddcast.cv.api.FaceFoundBitmap,faceDataResults : Array) : int ;
		function storeFrame(id : int,wholeImage : flash.display.BitmapData,rect : flash.geom.Rectangle) : int ;
		function makeArchive(id : int,compression : int = 0) : com.oddcast.host.api.FileData ;
		function updateArchive(fileData : com.oddcast.host.api.FileData) : Boolean ;
		function loadFrameStoreFromByteArray(byteArray : flash.utils.ByteArray) : int ;
		function loadFrameStoreFromURL(filename : String) : int ;
		function getFrameStoreLoadProgress(id : int) : Number ;
		function isReady(id : int) : Boolean ;
		function getNumberOfFrames(id : int) : int ;
		function getTotalDuration_TB(id : int) : Number ;
		function getFrameDuration(id : int,frameNo : int) : Number ;
		function replaceInto(id : int,frameNo : int,bitmapData : flash.display.BitmapData) : flash.geom.Rectangle ;
		function retrieveFrame_FB(id : int,frameNo : int,faceFoundBitmap : com.oddcast.cv.api.FaceFoundBitmap) : Array ;
		function getCurrFrameNumber_TB(id : int) : int ;
		function setTime_TB(id : int,timeMillis : Number = NaN) : void ;
		function getTime_TB(id : int) : Number ;
		function getFrameStoreMemoryUsage(id : int) : int ;
		function getImageProviderString(frameStoreID : int) : String ;
		function dispose() : void ;
	}
}

package com.oddcast.cv.api;
//import com.oddcast.cv.api.IFrameStoreAPI;

import com.oddcast.cv.framestore.FrameStore;
import com.oddcast.cv.api.FaceAPI_Constants;

import com.oddcast.host.api.FileData;

import flash.utils.ByteArray;
import flash.geom.Rectangle;
import flash.display.BitmapData;
//import com.oddcast.cv.api.FaceFinderAPI;

/*
import com.oddcast.cv.api.FaceFoundBitmap;
import com.oddcast.cv.IDisposable; 
import com.oddcast.cv.HaxeSWC;
import com.oddcast.cv.imageProvider.IimageProvider;
import com.oddcast.cv.util.HandleID;





import com.oddcast.host.engine3d.texture.TextureWriter;
import com.oddcast.io.archive.oa1.ArchiveOA1;
import com.oddcast.cv.util.JPEGEncodeOddcast;
*/
	
	/**
	 * ... Jake Lewis
	 * 6/18/2010 3:19 PM
	 *  
	 */
	
	 
	
	interface IFrameStoreAPI{
		function createFrameStore_FB(maxFrames:Int):FrameStoreID;
		function createFrameStore_TB(durationMillisecs:Float, fps:Int):FrameStoreID;
		function removeFrameStore(frameStoreID:FrameStoreID):FrameStoreID;
		function addFrame_FB(id:FrameStoreID, faceFoundBitmap:FaceFoundBitmap, faceDataResults:ArrayFaceDataResults):FrameStoreFrameReturnCode;
		function addFrame_TB(id:FrameStoreID, faceFoundBitmap:FaceFoundBitmap, faceDataResults:ArrayFaceDataResults):FrameStoreFrameReturnCode;
		function storeFrame(id:FrameStoreID, wholeImage: BitmapData,  rect:Rectangle) :FrameStoreFrameReturnCode;
		
		function makeArchive(id:FrameStoreID,
									compression:Int = FrameStore.DEFAULT_JPG_COMPRESSION)
								    :FileData;
		function updateArchive(fileData:FileData):Bool;
		//loading
		function loadFrameStoreFromByteArray(byteArray:ByteArray):FrameStoreID;
		function loadFrameStoreFromURL(filename:String):FrameStoreID;
		function getFrameStoreLoadProgress(id:FrameStoreID):Float;
		//playback
		function isReady(id:FrameStoreID):Bool;
		function getNumberOfFrames(id:FrameStoreID):Int;
		function getTotalDuration_TB(id:FrameStoreID):Float;
		function getFrameDuration(id:FrameStoreID, frameNo:Int):Float;
		function replaceInto(id:FrameStoreID, frameNo:Int, bitmapData:BitmapData):Rectangle;
		function retrieveFrame_FB(id:FrameStoreID, frameNo:Int, faceFoundBitmap:FaceFoundBitmap):ArrayFaceDataResults;
		function getCurrFrameNumber_TB(id:FrameStoreID):Int;
		function setTime_TB(id:FrameStoreID, timeMillis:Float = 0.0):Void;
		function getTime_TB(id:FrameStoreID):Float ;
		function getFrameStoreMemoryUsage(id:FrameStoreID):Int ;
		function getImageProviderString(frameStoreID:FrameStoreID):String;
		function dispose():Void ;
	}
	
	
	
package com.oddcast.cv.api;
//import com.oddcast.cv.api.BaseFrameStoreAPI;

import com.oddcast.cv.api.FaceAPI_Constants;
import com.oddcast.cv.api.FaceFoundBitmap;
import com.oddcast.cv.framestore.FrameStore;
import com.oddcast.cv.IDisposable; 
import com.oddcast.cv.imageProvider.IimageProvider;
import com.oddcast.cv.util.HandleID;
import com.oddcast.host.api.FileData;
import com.oddcast.host.engine3d.texture.TextureWriter;
import com.oddcast.io.archive.oa1.ArchiveOA1;
import com.oddcast.cv.util.JPEGEncodeOddcast;


import flash.utils.ByteArray;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.display.MovieClip;

	
	/**
	 * ... Jake Lewis
	 * 3/24/2011 12:05 PM
	 *  base on FrameStoreAPI
	 */
	
	typedef FrameStores = IntHash<FrameStore>;
	
	
	class FrameStoreSWF extends MovieClip {
		public function new() {super();}
		
		public function getAPI():IFrameStoreAPI {
			return new BaseFrameStoreAPI();
		}
		
		/*public function disposeAPI(iFrameStoreAPI:IFrameStoreAPI):Void {
			iFrameStoreAPI.dispose();
		}*/
		
		public function dispose():Void {}
		
	}
	
	class BaseFrameStoreAPI extends MovieClip, implements IFrameStoreAPI
	{
		
		public function new() {
			super();
			frameStores 		= new FrameStores();
			frameStoreHandleID 	= new HandleID(HandleID.FRAMESTOREID);
		}
		/*public function new(mc:MovieClip) {
			//haxe.init(mc);
			new flash.Boot(mc)
		}*/
		
		
		
		//write
		public function createFrameStore_FB(maxFrames:Int):FrameStoreID {
			var frameStore = new FrameStore(null,//imageProvider, 
											maxFrames);
			return addFrameStore(frameStore);
		}
		
		public function createFrameStore_TB(durationMillisecs:Float, fps:Int):FrameStoreID {
			trace("createFrameStore_TB"); 
			var retval =  createFrameStore_FB(Std.int(durationMillisecs * fps / 1000));
			frameStore(retval).setFPS(fps);
			return retval;
		}
		
		
		
		public function removeFrameStore(frameStoreID:FrameStoreID):FrameStoreID {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("removeFrameStore(frameStoreID:"+frameStoreID+")");
			#end
			frameStore(frameStoreID).dispose();
			frameStores.remove(frameStoreID);
			return frameStoreHandleID.releaseHandle(frameStoreID);
		}
		
		public function addFrame_FB(id:FrameStoreID, faceFoundBitmap:FaceFoundBitmap, faceDataResults:ArrayFaceDataResults):FrameStoreFrameReturnCode {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("addFrame_FB(frameStoreID:"+id+" faceFoundBitmap, faceDataResults:"+faceDataResults.toString()+")");
			#end
			return frameStore(id).storeFaceFoundBitmap(faceFoundBitmap, faceDataResults, false);
		}
		
		public function addFrame_TB(id:FrameStoreID, faceFoundBitmap:FaceFoundBitmap, faceDataResults:ArrayFaceDataResults):FrameStoreFrameReturnCode {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("addFrame_TB(frameStoreID:"+id+" faceFoundBitmap, faceDataResults:"+faceDataResults.toString()+")");
			#end
			return frameStore(id).storeFaceFoundBitmap(faceFoundBitmap, faceDataResults, true);
		}
		
		public function storeFrame(id:FrameStoreID, wholeImage: BitmapData,  rect:Rectangle) :FrameStoreFrameReturnCode {
			return frameStore(id).storeFrame(wholeImage, rect) ;
		}
		
		
		public function makeArchive(id:FrameStoreID,
									compression:Int = FaceAPI_Constants.DEFAULT_JPG_COMPRESSION)
								    :FileData {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("makeArchive(frameStoreID:"+id+" compression:"+compression+")");
			#end
												
			var fileDataFrameStore = new FileDataFrameStore(null, FaceAPI_Constants.FRAMESTORE_ARCHIVE_FILE_EXTENSION);
			//fileDataFrameStore.id = id;
			fileDataFrameStore.makeJPEGEncoder(compression);
			fileDataFrameStore.archive = frameStore(id).makeOA1(compression);
			
			return fileDataFrameStore;
		}
		
		
		public function updateArchive(fileData:FileData):Bool {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("updateArchive(fileData)");
			#end
			if(Std.is(fileData, FileDataFrameStore)){
				var fileDataFrameStore : FileDataFrameStore = cast( fileData, FileDataFrameStore);
				var archive = fileDataFrameStore.archive;
				if(archive!=null){
					var compProgress = archive.performOneCompression();
							
					if ( compProgress < 0.0) { //we're all done
						//set the fileData 
						fileDataFrameStore.byteArray = archive.save();
						fileDataFrameStore.progress = 1.0;
						fileDataFrameStore.filesize = fileDataFrameStore.byteArray.length;

						
						//clean up the archiver;
						fileDataFrameStore.disposeJPEGEncoder();
						archive.unload();
						fileDataFrameStore.archive = null;
						return true;
					}else{
						fileDataFrameStore.progress = Math.min(0.99, archive.roughProgress());
						return false;
					}	
				}
			}
			return true;  // TODO throw error
		}
		
		
		//loading
		public function loadFrameStoreFromByteArray(byteArray:ByteArray):FrameStoreID {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("loadFrameStoreFromByteArray(byteArray)");
			#end
			var archive = new ArchiveOA1("fromByteArray", null);
			archive.load(byteArray);
			return loadFrameStore(archive);
		}
		
		public function loadFrameStoreFromURL(filename:String):FrameStoreID {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("loadFrameStoreFromURL(filename:"+filename+")");
			#end
			var archive = new ArchiveOA1(filename, null);
			archive.load();
			return loadFrameStore(archive);
		}
		
		public function getFrameStoreLoadProgress(id:FrameStoreID):Float {
			
			 var progress = frameStore(id).getLoadingProgress();
			 #if debugtrace
				com.oddcast.util.Utils.debugTrace("getFrameStoreLoadProgress(frameStoreID:"+id+"):"+progress);
			#end
			 if (progress < 0.999)
				return progress;
			 return 1.0;
		}
		
		//playback
		
		public function isReady(id:FrameStoreID):Bool {
			return frameStore(id).isReady();
		}
		
		public function getNumberOfFrames(id:FrameStoreID):Int {
			
			var ret  = frameStore(id).getNumberOfFrames();
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getNumberOfFrames(frameStoreID:"+id+"):"+ret);
			#end
			return ret;
		}
		
		public function getTotalDuration_TB(id:FrameStoreID):Float {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getTotalDuration_TB(frameStoreID:"+id+")");
			#end
			return frameStore(id).getDuration();
		}
		
		public function getFrameDuration(id:FrameStoreID, frameNo:Int):Float {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFrameDuration(frameStoreID:"+id+")");
			#end
			return frameStore(id).getFrameDuration(frameNo);
		}
		
		public function replaceInto(id:FrameStoreID, frameNo:Int, bitmapData:BitmapData):Rectangle {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("replaceInto(frameStoreID:"+id+", frameNo:"+frameNo+", bitmapData)");
			#end
			return frameStore(id).replaceInto(frameNo, bitmapData);
		}
		
		public function retrieveFrame_FB(id:FrameStoreID, frameNo:Int, faceFoundBitmap:FaceFoundBitmap):ArrayFaceDataResults {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("retrieveFrame_FB(frameStoreID:"+id+", frameNo:"+frameNo+", faceFoundBitmap)");
			#end
			return frameStore(id).replaceIntoFaceFoundBitmap(frameNo, faceFoundBitmap);
		}
		
		public function getCurrFrameNumber_TB(id:FrameStoreID):Int {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getCurrFrameNumber_TB(frameStoreID:"+id+")");
			#end
			return frameStore(id).getIndexFromTime();
		}
		
		public function setTime_TB(id:FrameStoreID, timeMillis:Float = 0.0) {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("setTime_TB(frameStoreID:"+id+" timeMillis:"+timeMillis+")");
			#end
			frameStore(id).setTime(timeMillis);
		}
		
		public function getTime_TB(id:FrameStoreID):Float {
			var time =  frameStore(id).getTime();
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getTime_TB(frameStoreID:"+id+"):"+time);
			#end
			return time;
		}
		
	
		public function getFrameStoreMemoryUsage(id:FrameStoreID):Int {
			var size = frameStore(id).getMemorySize();
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("getFrameStoreMemoryUsage(frameStoreID:"+id+"):"+size);
			#end
			return size;
		}
		
		public function getImageProviderString(frameStoreID:FrameStoreID):String {
			return frameStore(frameStoreID).getImageProviderString();
		}
		
		public function dispose():Void {
			#if debugtrace
				com.oddcast.util.Utils.debugTrace("dispose()");
			#end
			frameStores = Disposable.disposeIterableIfValid(frameStores);	
			//super.dispose();
		}
		
		/*//frameStoreCallbackFunc
		public function frameStoreCallbackFunc(frameStore:FrameStore):Void {
			//search in all stores
			for (key in frameStores.keys()){
				if (frameStores.get(key) == frameStore)
					
			}
		}*/
		
		
		//                         PRIVATE 
		
		private function addFrameStore(frameStore:FrameStore):FrameStoreID {
			var handleID = frameStoreHandleID.createHandle();
			frameStores.set(handleID, frameStore);
			return handleID;
		}
		
		function loadFrameStore(archive:ArchiveOA1):FrameStoreID {
			var frameStore = FrameStore.loadOA1(archive, null);
			return addFrameStore(frameStore);
		}
		
		private function frameStore(id:FrameStoreID):FrameStore {
			frameStoreHandleID.checkHandle(id);
			if ( frameStores == null ) throw "disposed";
			if ( !frameStores.exists(id) )throw "FrameStoreID invalid:" + id;
			return frameStores.get(id);
		}
		
		
		
		
		private var frameStores				:FrameStores;
		
		private var frameStoreHandleID		:HandleID;
	 
		//private var frameStoreIDCallbackFunc:FrameStoreIDCallbackFunc
	}
	
	
		
	class FileDataFrameStore extends FileData{
		//public var id 	:FrameStoreID;
		public var archive	:ArchiveOA1;
		
		
		public function makeJPEGEncoder(compression:Int) {
			
			jpegEncodeOddcast = new JPEGEncodeOddcast(compression); 
			TextureWriter.setJPGcodec(jpegEncodeOddcast);
			
		}
		public function disposeJPEGEncoder() {  
		
			jpegEncodeOddcast = Disposable.disposeIfValid(jpegEncodeOddcast);
			TextureWriter.setJPGcodec(null);
		 
		}
		
		//private
		 
		private var jpegEncodeOddcast		:JPEGEncodeOddcast;
		 
	}
	

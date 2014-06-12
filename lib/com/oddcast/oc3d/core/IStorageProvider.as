package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.data.AvatarData;
	import com.oddcast.oc3d.data.SceneData;
	
	import flash.display.BitmapData;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public interface IStorageProvider
	{
		// used to download daes and images from the server
		function downloadFile(relativePath:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn<uri:String>
		function uploadFileReference(file:FileReference, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<uri:String>
		function uploadText(data:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<uri:String>
		function uploadBitmap(data:BitmapData, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<uri:String>
		function uploadDisassembledBitmap(data:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<uri:String>
		function uploadBinary(data:ByteArray, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<data:String>
		function downloadText(url:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null, o:Object=null):void;
		// continuationFn<data:BitmapData>
		function downloadBitmap(url:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null, o:Object=null):void;
		// continuationFn<data:Vector.<BitmapData>
		function downloadDisassembledBitmap(uri:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null, o:Object=null):void
		// continuationFn<data:Sound>
		function downloadSound(url:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<data:ByteArray>
		function downloadBinary(url:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null, o:Object=null):void;
		// continuationFn<data:MovieClip>
		function downloadSwf(url:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
/**
* @author Sam Myer, Me^
* 
* @update convertImage is a required param for upload_v3.php
* @see FileUploader_v2 for documentation
*/
package com.oddcast.utils {
	import flash.events.IEventDispatcher;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public interface IFileUploader extends IEventDispatcher 
	{
		/**
		 * param passed to the upload script
		 * @param	_val
		 */
		function set_convert_image_val( _val:Boolean ):void
		function setUploadScriptURL($uploadURL:String):void;
		function setGetUploadedScriptURL($getUploadedURL:String):void;
		function setFileType($typeFilter:Array):void;
		function get defaultImageTypeFilter():Array;
		function setByteSizeLimits(minLimit:uint, maxLimit:uint):void;
		function setPixelSizeLimits(minWidth:int, minHeight:int, maxWidth:int, maxHeight:int):void;
		function set_expiration_timeout( _sec:Number ):void;
		function getByteSizeLimits():Object;
		function getPixelSizeLimits():Object;
		
//-------------------------------------------------  BROWSE  ------------------------------------------------		
		function browse():void;
		function uploadBrowsed():void;
		
//-------------------------------------------------  UPLOAD FILE REFERENCE  ------------------------------------------------		

		function uploadFile($file:FileReference):void;
		function uploadBinary(data:ByteArray, fileType:String = null):void;
		function uploadUrl(url:String):void
	}
	
}
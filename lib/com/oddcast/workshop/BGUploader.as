/**
* ...
* @author Sam, Me^
* @version 0.1
* 
* This class takes care of uploading iamges to the server.  It works by loading the file upload component as
* an external .swf and then using this component to perform upload operations
* See com.oddcast.utils.FileUploader_v2 for more details
* 
******* PROPERTIES *******
* 
* defaultImageTypeFilter - a static class containing image file filter array
* use with setTypeFilter(defaultImageTypeFilter)
* 
******* FUNCTIONS *******
* 
* (static)loadUploadComponent(url) - pass url of file upload component, to initialize BGUploader
* 
* setByteSizeLimits
* setPixelSizeLimits
* 
* setTypeFilter - pass an array of FileFilter objects.  This are the file types displayed in the window
* when you call the browse function
* 
* browse() - opens a browser window
* uploadBrowsed - upload file that has been seelcted
* uploadFile - uploads FileReference
* uploadBinary - uploads ByteArray
* uploadUrl - uploads url
* 
* getUploaderClass - returns the class of the File Upload Component (com.oddcast.utils.FileUploader_v2)
* 
******* EVENTS *******
* 
* AlertEvent.ERROR - there is an error
* ProcessingEvent.STARTED ("bg") - upload has started, so show the loading bar
* ProcessingEvent.DONE ("bg") - upload has finished
* Event.SELECTED - file has been selected, upload has started
* BGEvent.SELECT - bg upload has completed.  returns the new bg as a WSBackgroundStruct object.
* 
*/

package com.oddcast.workshop 
{
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.throttle.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;

	public class BGUploader extends EventDispatcher 
	{
		private static var uploaderClass:Class;
		private static var isUploading:Boolean = false;
		private static var componentLoader:Loader;
		
		private var downloadFileRef:FileReference;
		
		private var minByteSize:uint;
		private var maxByteSize:uint;
		private var minPixelSize:Point;
		private var maxPixelSize:Point;
		private var expiration_timeout_sec:Number = 60;
		private var typeFilter:Array;
		private var uploadScriptURL:String;
		private var getUploadedScriptURL:String;
		private var uploader:IFileUploader;
		
		public var autoSubmitBrowsed:Boolean=false;
		
		public function BGUploader() {
			typeFilter = defaultImageTypeFilter;
			setByteSizeLimits(10 * 1024, 6 * 1024 * 1024); //default 10 kb min 6 Mb max
			setPixelSizeLimits(64, 64, 5000, 5000); //default 64x64 min  5000x5000 max
			uploaderClass = FileUploader_v2;
		}
		
		private function setDefaultUrls() : void {
			uploadScriptURL = ServerInfo.localURL + "api/upload_v3.php";
			getUploadedScriptURL = ServerInfo.localURL + "api/getUploaded_v3.php";
		}
		
		public static function loadUploadComponent(url:String) : void {
			/*
			trace("UPLOADER LOAD COMPONENT");
			componentLoader = new Loader();
			componentLoader.contentLoaderInfo.addEventListener(Event.INIT, uploadComponentLoaded);
			componentLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, uploadComponentLoadError);
			componentLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, uploadComponentLoadError);
			try {
				componentLoader.load(new URLRequest(url));
			}
			catch (e:Error) {
				uploadComponentLoadError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
			*/
		}
		
		private static function uploadComponentLoaded(evt:Event) : void {
			trace("UPLOADER LOADED");
			uploaderClass = (componentLoader.content as Object).getUploaderClass();
		}
		
		private static function uploadComponentLoadError(evt:ErrorEvent) : void {
			trace("UPLOADER LOAD ERROR : " + evt.text);
		}
		
		public static function getUploaderClass():Class {
			return(uploaderClass);
		}
		
		public function get defaultImageTypeFilter():Array {
			var filter:Array = new Array();
			filter.push(new FileFilter("Images (*.jpg *.jpeg *.gif *.png)", "*.jpg;*.jpeg;*.gif;*.png"));
			return(filter);
		}
		
		public function setTypeFilter($filter:Array) : void {
			typeFilter = $filter;
		}
		
		public function setByteSizeLimits(min:uint, max:uint) : void {
			minByteSize = min;
			maxByteSize = max;
		}
		
		public function setPixelSizeLimits(minW:uint, minH:uint, maxW:uint, maxH:uint) : void {
			minPixelSize = new Point(minW, minH);
			maxPixelSize = new Point(maxW, maxH);
		}
		public function set_expiration_timeout( _sec:Number ):void
		{	expiration_timeout_sec = _sec;
		}
		
		
		public function browse() : void {
			createUploader();
			listener_manager( 0, uploader.addEventListener );/*uploader.addEventListener(Event.SELECT, fileSelected);
			uploader.addEventListener(Event.CANCEL, fileSelectCancelled);*/
			
			if (typeFilter != null) uploader.setFileType(typeFilter);
			uploader.browse();
		}
		
		private function fileSelected(evt:Event) : void {
			listener_manager( 0, uploader.removeEventListener );/*uploader.removeEventListener(Event.SELECT, fileSelected);
			uploader.removeEventListener(Event.CANCEL, fileSelectCancelled);*/
			dispatchEvent(evt);
			if (autoSubmitBrowsed) uploadBrowsed();
		}
		private function fileSelectCancelled(evt:Event) : void {
			listener_manager( 0, uploader.removeEventListener );/*uploader.removeEventListener(Event.SELECT, fileSelected);
			uploader.removeEventListener(Event.CANCEL, fileSelectCancelled);*/
			dispatchEvent(evt);
		}
		private function file_upload_progress( _e:ProgressEvent ):void 
		{
			dispatchEvent( _e );
		}
		
		/* @desc:	adds or removes the specific listeners
		 * @eg:		browse_listener_manager( 0, uploader.addEventListener ); */
		private function listener_manager( _mode:int, _control:Function ):void 
		{
			switch( _mode )
			{
				case 0:		_control(Event.SELECT, fileSelected);
							_control(Event.CANCEL, fileSelectCancelled);
							break;
				case 1:		_control(AlertEvent.EVENT	, onError);
							_control(Event.COMPLETE		, onComplete);
							_control(ProgressEvent.PROGRESS, file_upload_progress);
							break;
				case 2:		_control(Event.CANCEL						, cancelHandler);
							_control(Event.COMPLETE						, completeHandler);
							_control(IOErrorEvent.IO_ERROR				, onDownloadError);
							_control(SecurityErrorEvent.SECURITY_ERROR	, onDownloadError);
							break;
			}
		}
		
		public function uploadBrowsed() : void {
			if (isUploading) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t506", "An upload is already in progress.  Please wait for that upload to finish."));
				return;
			}
			
			startUploader();
			uploader.uploadBrowsed();
		}
		
		private function createUploader() : void {
			if (uploadScriptURL == null) setDefaultUrls();
			if (uploader == null) {
				uploader = new uploaderClass();
				uploader.setUploadScriptURL(uploadScriptURL);
				uploader.set_convert_image_val(ServerInfo.convert_uploaded_images);
				uploader.setGetUploadedScriptURL(getUploadedScriptURL);
				uploader.setByteSizeLimits(minByteSize, maxByteSize);
				uploader.setPixelSizeLimits(minPixelSize.x, minPixelSize.y, maxPixelSize.x, maxPixelSize.y);
				uploader.set_expiration_timeout( expiration_timeout_sec );
			}
		}
		
		private function startUploader() : void 
		{
			createUploader();
			listener_manager( 1, uploader.addEventListener );/*uploader.addEventListener(AlertEvent.EVENT, onError);
			uploader.addEventListener(Event.COMPLETE, onComplete);*/
			isUploading = true;
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, "upload"));
		}
		
		public function stopUploader() : void 
		{
			listener_manager( 1, uploader.removeEventListener );/*uploader.removeEventListener(AlertEvent.EVENT, onError);
			uploader.removeEventListener(BGEvent.SELECT, onComplete);*/
			isUploading = false;
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, "upload"));
		}
		
		/**
		 * uploads a file to the server
		 * @param	file filereference
		 * @param	_check_for_server_capacity for APC for example we need to check if there is capacity for an upload
		 */
		public function uploadFile(file:FileReference, _check_for_server_capacity:Boolean = false):void
		{
			if (isUploading) 
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t506", "An upload is already in progress.  Please wait for that upload to finish."));
				return;
			}
			
			if (_check_for_server_capacity)
				Throttler.autophoto_upload_allowed( upload_file, server_capacity_surpassed, server_capacity_surpassed );
			else
				upload_file();
			
			function upload_file(  ):void 
			{
				startUploader();
				uploader.uploadFile(file);
			}
			function server_capacity_surpassed(  ):void 
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "", "Server capacity surpassed.  Please try again later."));
			}
		}
		
		/**
		 * uploads a file to the server
		 * @param	data the file data
		 * @param	fileType type of file
		 * @param	_check_for_server_capacity  for APC for example we need to check if there is capacity for an upload
		 */
		public function uploadBinary(data:ByteArray, fileType:String = null, _check_for_server_capacity:Boolean = false):void
		{
			if (isUploading) 
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t506", "An upload is already in progress.  Please wait for that upload to finish."));
				return;
			}
			
			if (_check_for_server_capacity)
				Throttler.autophoto_upload_allowed( upload_file, server_capacity_surpassed, server_capacity_surpassed );
			else
				upload_file();
			
			function upload_file(  ):void 
			{
				startUploader();
				uploader.uploadBinary(data, fileType);
			}
			function server_capacity_surpassed(  ):void 
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "", "Server capacity surpassed.  Please try again later."));
			}
			
		}
		
		/**
		 * uploads a file to the server
		 * @param	url url of file from another server
		 * @param	_check_for_server_capacity for APC for example we need to check if there is capacity for an upload
		 */
		public function uploadUrl(url:String, _check_for_server_capacity:Boolean = false):void
		{
			if (isUploading) 
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t506", "An upload is already in progress.  Please wait for that upload to finish."));
				return;
			}
			
			if (_check_for_server_capacity)
				Throttler.autophoto_upload_allowed( upload_file, server_capacity_surpassed, server_capacity_surpassed );
			else
				upload_file();
			
			function upload_file(  ):void 
			{
				startUploader();
				uploader.uploadUrl(url);
			}
			function server_capacity_surpassed(  ):void 
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "", "Server capacity surpassed.  Please try again later."));
			}
		}
		
		private function onError(evt:AlertEvent) : void {
			stopUploader();
			dispatchEvent(evt);
		}
		private function onComplete(evt:TextEvent) : void {
			stopUploader();
			
			var bg:WSBackgroundStruct = new WSBackgroundStruct(evt.text);
			bg.isUploadPhoto = true;
			dispatchEvent(new BGEvent(BGEvent.SELECT,bg));
		}
//---------------------------------------------------		
		
		public function downloadFile(url:String, defaultFileName:String = null) : void {
			if (downloadFileRef == null) {
				downloadFileRef = new FileReference();
				listener_manager( 2, downloadFileRef.addEventListener );/*downloadFileRef.addEventListener(Event.CANCEL, cancelHandler);
				downloadFileRef.addEventListener(Event.COMPLETE, completeHandler);
				downloadFileRef.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
				downloadFileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);*/
			}
			trace("DownloadVideo::downloadFile");
			var fileName:String = defaultFileName == null?url.slice(url.lastIndexOf("/") + 1):defaultFileName;
			
			try 					{	downloadFileRef.download(new URLRequest(url), fileName);	}
			catch (e:Error)			{	onDownloadError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));	}
		}
		
		private function cancelHandler(evt:Event) : void {
			//dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.SAVING));
			dispatchEvent(evt);
		}
		
		private function completeHandler(evt:Event) : void {
			//dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.SAVING));
			dispatchEvent(evt);
		}
		
		private function onDownloadError(evt:ErrorEvent) : void {
			trace("DownloadVideo::errorHandler");
			dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t520","Error downloading file : "+evt.text,{details:evt.text}));
		}
	}
	
}
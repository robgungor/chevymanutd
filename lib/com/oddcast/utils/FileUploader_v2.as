/**
* ...
* @author Sam Myer, Me^
* @update added event expiration, moved "one use" functions as nested functions, added listener manager
* 
* FileUploader v2 class
* 
* ****************  CONFIGURATION FUNCTIONS:  *******************
* 
* setUploadScriptURL(url) - set the url of upload.php script e.g. "http://host.oddcast.com/api/upload_v3.php"
* 
* setGetUploadedScriptURL(url) - set the url of getUploaded.php script e.g. "http://host.oddcast.com/api/getUploaded_v3.php"
* 
* setFileType(typeFilter:Array) - pass an array of FileFilter objects to be used when browsing
* 
* setFileTypeToImages() - sets typeFilter to a predefined array of FileFilters
* 
* setByteSizeLimits(min,max) - set minimum and maximum number of bytes allowed for uploaded file.
* If the uploaded file is bigger or smaller than the limits, an error is dispatched
* 
* setPixelSizeLimit(minW,minH,maxW,maxH) - set minimum and maximum pixel size
* If the uploaded file is bigger or smaller than the limits, an error is dispatched
* 
* ****************     UPLOAD FUNCTIONS:      *******************
* These functions do the process of uploading a file to the server
* 
* uploadFile(file:FileReference) - file is a FileReference object (usually created by calling browse())
* 
* uploadBinary(data:ByteArray,fileType:String) - uploads ByteArray object
* fileType is the extension of the file.  currently, this is being used just to set the mime type of the
* file being sent in binary mode
* There are 2 methods of sending the binary - sending by binary, and converting to base64 and sending as a string
* parameter
* Right now, the file is always being uploaded as a base64 in order to bypass security restrictions in flash player 10
* and flash player 9.0.155.0
* 
* uploadUrl(url:String) - uploads a url from the internet (e.g. google search)
* 
* browse() - browse function is added for convenience, but I recommend you create your own FileReference
* object in your application and then call uploadFile() when you are ready to upload it.
* This function creates a FileReference object and calls browse on it.  It returns Event.COMPLETE when done
* 
* uploadBrowsed() - uploads the file that has been selected in the Event.SELECT event after the last browse() call
* 
* ****************          EVENTS:           *******************
* 
* Event.COMPLETE (as TextEvent) - dispatched when upload is complete.  This is dispatched as a TextEvent,
* where the text parameter is the url of the uploaded file
* 
* AlertEvent.EVENT - dispatched whenever there is an error.  current error codes are fuc1, fuc2, fuc3, fuc4
* 
* Event.SELECT (as TextEvent) - dispatched after a browse() call.  This is dispatched as a TextEvent,
* where the text parameter is the filename of the user-selected file
* 
* Event.CANCEL - dispatched after a browse() call if the user closes the dialogue without selecting a file.
* 
*/
package com.oddcast.utils {
	
	import com.adobe.crypto.MD5;
	import com.dynamicflash.util.Base64;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.MultipartFormPoster;
	import com.oddcast.utils.XMLLoader;
	
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;

	public class FileUploader_v2 extends EventDispatcher implements IFileUploader {
		private var sessionCode:String;
		private var uploadFileRef:FileReference;
		private var browseFileRef:FileReference;
		private var formPoster:MultipartFormPoster;
		//options:
		private var byteSizeLimit:uint;
		private var byteMinimumLimit:uint;
		private var minPixelDimensions:Point;
		private var maxPixelDimensions:Point;
		private var typeFilter:Array;
		private var uploadScriptURL:String;
		private var getUploadedScriptURL:String;
		/** set from server info */
		private var convert_image_param:Boolean = true;
		
		private var listener_manager:Listener_Manager = new Listener_Manager();
		private var event_expiration:Event_Expiration = new Event_Expiration();
		private const EXPIRATION_EVENT_UPLOAD:String = 'EXPIRATION_EVENT_UPLOAD';
		private var timeout_expiration:Number;
		
		public static const UPLOAD_COMPLETE:String = "uploadComplete";
		
		public function FileUploader_v2() {
			setFileType(defaultImageTypeFilter);
			setByteSizeLimits(10 * 1024, 6 * 1024 * 1024); //default 25 kb min 2.5 Mb max
			setPixelSizeLimits(64, 64, 5000, 5000); //default 64x64 min  5000x5000 max
			set_expiration_timeout( 120 );
		}
		
		private function start_expiration(  ):void 
		{	//event_expiration.add_event( EXPIRATION_EVENT_UPLOAD, timeout_expiration, event_expired );
			event_expiration.add_event( EXPIRATION_EVENT_UPLOAD, 120000, event_expired );
		}
		private function event_expired(  ):void 
		{	dispatchEvent(new AlertEvent(AlertEvent.ERROR, 'fue006', 'File upload timed out'));
		}
		private function event_occured(  ):void 
		{	event_expiration.remove_event( EXPIRATION_EVENT_UPLOAD );
		}
		
		public function set_convert_image_val( _val:Boolean ):void
		{
			convert_image_param = _val;
		}
		public function setUploadScriptURL($uploadURL:String):void
		{
			uploadScriptURL = $uploadURL;
		}
		public function setGetUploadedScriptURL($getUploadedURL:String):void
		{
			getUploadedScriptURL=$getUploadedURL;
		}
		public function set_expiration_timeout( _sec:Number ):void
		{	if(!isNaN(_sec)) timeout_expiration = (_sec < 0) ? 0 : _sec * 1000;
		}
		
		public function setFileType($typeFilter:Array):void
		{
			typeFilter = $typeFilter;
		}
		public function get defaultImageTypeFilter():Array {
			var filter:Array = new Array();
			filter.push(new FileFilter("Images (*.jpg *.jpeg *.gif *.png)", "*.jpg;*.jpeg;*.gif;*.png"));
			return(filter);
		}
		public function setByteSizeLimits(minLimit:uint, maxLimit:uint):void
		{
			byteMinimumLimit = minLimit;
			byteSizeLimit = maxLimit;
		}
		public function setPixelSizeLimits(minWidth:int, minHeight:int, maxWidth:int, maxHeight:int):void
		{
			if (minWidth<=0||minHeight<=0) minPixelDimensions = null;
			else minPixelDimensions = new Point(minWidth, minHeight);
			if (maxWidth<=0||maxHeight<=0) maxPixelDimensions = null;
			else maxPixelDimensions = new Point(maxWidth, maxHeight);
		}
		public function getByteSizeLimits():Object {
			return( { min:byteMinimumLimit, max:byteSizeLimit } );
		}
		public function getPixelSizeLimits():Object {
			return( { min:minPixelDimensions, max:maxPixelDimensions } );
		}
		private function generateSessionCode():String {
			//generates a quasi-unique code for this user session based on current time
			//send this to the php to generate a unique filename
			var curTime:Number = (new Date()).time;
			var rand:String = Math.floor(Math.random() * 1000).toString();
			return(MD5.hash(curTime.toString()+rand));
		}
		
		private function buildUploadUrl():String {
			sessionCode=generateSessionCode();
			var url:String = uploadScriptURL + query_session() + query_convert_image();
			if (minPixelDimensions != null) url += "&minW=" + minPixelDimensions.x + "&minH=" + minPixelDimensions.y;
			if (maxPixelDimensions != null) url += "&maxW=" + maxPixelDimensions.x + "&maxH=" + maxPixelDimensions.y;
			return(url);
			
			/**
			 * initial query indicating session for backend to reuse when retrieving the uploaded file
			 * @return
			 */
			function query_session(  ):String
			{	
				return "?sessId=" + sessionCode;
			}
			/**
			 * some files are not usable formats (JPG) and this indicates to convert them to that from something such as a BMP
			 * @return
			 */
			function query_convert_image(  ):String
			{	
				return '&convertImage=' + convert_image_param.toString();
			}
		}
//-------------------------------------------------  BROWSE  ------------------------------------------------		
		
		public function browse():void {
			if (browseFileRef == null)
				browseFileRef = new FileReference();
			add_browse_listeners();
			try 
			{
				browseFileRef.browse(typeFilter);
			}
			catch (e:Error) 
			{
				listener_manager.remove_all_listeners_ever_added();
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "fue004", "Error opening browse window for file upload : "+e.message,{details:e.message}));
			}
			function add_browse_listeners():void
			{
				listener_manager.add(browseFileRef, Event.SELECT, fileSelected, this);
				listener_manager.add(browseFileRef, Event.CANCEL, fileSelectCancelled, this);
			}
		}
		
		private function fileSelected(evt:Event) : void {
			listener_manager.remove_all_listeners_ever_added();
			trace("FileUploader::file selected: " + browseFileRef.name);
			dispatchEvent(new TextEvent(evt.type,evt.bubbles,evt.cancelable,browseFileRef.name));
			//upload();
		}
		
		private function fileSelectCancelled(evt:Event) : void {
			listener_manager.remove_all_listeners_ever_added();
			dispatchEvent(evt);
		}
		
		public function uploadBrowsed():void {
			uploadFile(browseFileRef);
		}
		
//-------------------------------------------------  UPLOAD FILE REFERENCE  ------------------------------------------------		

		public function uploadFile($file:FileReference):void {
			uploadFileRef = $file;
			listener_manager.add( uploadFileRef, Event.COMPLETE, onUploadFileComplete, this );
			listener_manager.add( uploadFileRef, IOErrorEvent.IO_ERROR, onUploadError, this );
			listener_manager.add( uploadFileRef, IOErrorEvent.DISK_ERROR, onUploadError, this );
			listener_manager.add( uploadFileRef, IOErrorEvent.NETWORK_ERROR, onUploadError, this );
			listener_manager.add( uploadFileRef, IOErrorEvent.VERIFY_ERROR, onUploadError, this );
			listener_manager.add( uploadFileRef, SecurityErrorEvent.SECURITY_ERROR, onUploadError, this );
			listener_manager.add( uploadFileRef, HTTPStatusEvent.HTTP_STATUS, onUploadFileHTTPStatusError, this );
			listener_manager.add( uploadFileRef, ProgressEvent.PROGRESS, onUploadFileProgress, this );
			
			var fileSize:Number;
			
			try 			{	fileSize = uploadFileRef.size;	}
			catch (e:Error) {	if (e is IOError)	dispatchEvent(new AlertEvent(AlertEvent.ERROR, "fue005", "File cannot be opened or read", { details:e.message } ));
								else				onUploadError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
							}
			
			// set params for error
			var sizeKb		:int 		= Math.round(fileSize / 1024);
			var minSizeKb	:int 		= Math.round(byteMinimumLimit / 1024);
			var sizeMb		:int 		= Math.round(fileSize / (1024 * 1024));
			var maxSizeMb	:int		= Math.round(byteSizeLimit / (1024 * 1024));		
			
			if (fileSize <= byteMinimumLimit) 
			{	dispatchEvent(new AlertEvent(AlertEvent.ERROR, "fue001", "File size is too small", { size:fileSize, minSize:byteMinimumLimit, sizeKb:sizeKb, minSizeKb:minSizeKb } ));
				return;
			}
			else if (byteSizeLimit > 0 && fileSize > byteSizeLimit)
			{	dispatchEvent(new AlertEvent(AlertEvent.ERROR, "fue002", "File exceeds allowed size", { size:fileSize, maxSize:byteSizeLimit, sizeMb:sizeMb, maxSizeMb:maxSizeMb } ));
				return;
			}
			
			var url:String = buildUploadUrl();
			start_expiration();
			try 			{	uploadFileRef.upload(new URLRequest(url));		}
			catch (e:Error) {	onUploadError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));	}
			
			function onUploadFileComplete(evt:Event):void
			{	listener_manager.remove_all_listeners_ever_added();
				event_occured();
				retreiveUploaded();
			}
			function onUploadFileHTTPStatusError(evt:HTTPStatusEvent):void
			{	listener_manager.remove_all_listeners_ever_added();
				event_occured();
				if (evt.status == 0 || evt.status == 200) return;
			}
			function onUploadFileProgress(evt:ProgressEvent):void
			{	dispatchEvent(evt);
			}
		}
		
		//----------------------------------------------------------------------------
		
		public function uploadBinary(data:ByteArray, fileType:String = null) :void
		{
			uploadImageAsBase64(data,fileType);
		}

		private function uploadAsBinary(binaryData:ByteArray,fileType:String)  : void
		{
			formPoster=new MultipartFormPoster();
			listener_manager.add( formPoster, Event.COMPLETE, binaryUploaded, this );
			listener_manager.add( formPoster, ErrorEvent.ERROR, binaryUploadError, this );
			var url:String = buildUploadUrl();
			var mimeType:String;
			if (fileType == "png") mimeType = "image/png";
			else if (fileType == "jpg") mimeType = "image/jpeg";
			else mimeType = "application/octet-stream";
			formPoster.addFile("Filedata",binaryData,mimeType,"Filedata");
			formPoster.post(url);
		}
		
		private function binaryUploaded(evt:Event):void
		{
			listener_manager.remove_all_listeners_on_object(formPoster);
			retreiveUploaded();
		}
		
		private function binaryUploadError(evt:ErrorEvent):void
		{
			listener_manager.remove_all_listeners_on_object(formPoster);
			onUploadError(evt);
		}
		
		private function uploadImageAsBase64(binaryData:ByteArray, fileType:String)  : void
		{
			var base64Data:String = Base64.encodeByteArray(binaryData);
			
			var url:String = buildUploadUrl();
			var postVars:URLVariables = new URLVariables();
			postVars.FileDataBase64 = base64Data;
			start_expiration();
			if ( fileType ) 
				url += "&extension=" + fileType;
			XMLLoader.sendAndLoad(url, imageBase64Uploaded, postVars,String);
		
			function imageBase64Uploaded(s:String) : void 
			{	event_occured();
				if (s == null) onUploadError(new ErrorEvent(ErrorEvent.ERROR,false,false,XMLLoader.lastError));
				else retreiveUploaded();
			}
		}
//-------------------------------------------------------------------------

		public function uploadUrl(url:String) :void
		{
			sessionCode = generateSessionCode();
			var phpUrl:String = buildUploadUrl() + "&url=" + url;
			start_expiration();
			XMLLoader.sendAndLoad(phpUrl, uploadUrlDone, null, String);
			
			function uploadUrlDone(s:String) : void
			{	event_occured();
				if (s == null) onUploadError(new ErrorEvent(ErrorEvent.ERROR,false,false,XMLLoader.lastError));
				else retreiveUploaded();
			}
		}
		
		
//-------------------------------------------------------------------------
		
		private function onUploadError(evt:ErrorEvent)  : void
		{
			listener_manager.remove_all_listeners_ever_added();
			event_occured();
			dispatchEvent(new AlertEvent(AlertEvent.ERROR, "fue003", "Error uploading file : "+evt.text,{details:evt.text}));
		}

		private function retreiveUploaded():void
		{
			var url:String = session_upload_url();
			XMLLoader.loadXML(url, gotImageUrl);
		}
		
		private function session_upload_url(  ):String
		{	
			return getUploadedScriptURL + "?sessId=" + sessionCode;
		}
		

		/**
		 * file is written on oddcast server
		 * @param	_xml	either containing the error or the url
		 */
		private function gotImageUrl(_xml:XML):void
		{
			if (_xml && _xml.name() == "FILE") 
			{	var fileUrl:String = _xml.@URL.toString();
				dispatchEvent(new TextEvent(Event.COMPLETE, false, false, fileUrl));
			}
			else 
			{	var err_code:String = _xml && _xml.@CODE.toString() 	? _xml.@CODE.toString() 	: 'f9t532';	// if the response is blank
				var err_msg	:String = _xml && _xml.@ERRORSTR.toString() ? _xml.@ERRORSTR.toString() : 'blank response from script: ' + session_upload_url();
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, err_code, unescape(err_msg)));
			}
		}
		
	}
	
}
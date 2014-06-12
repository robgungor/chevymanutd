/**
* ...
* @author Sam Myer
* 
* This class handles capturing images nad videos of the scene
* 
* FUNCTIONS:
* 
* captureVideo(mId,defFileName) - Downloads scene as video
* 	-mId (required) = the message id of the saved scene
* 	-defFileName (optional) = the default filename in the save as... dialog box that pops up.  if omitted, this
* 							defaults to the filename sent by the server
* 
* captureScreen(bmp,defFileName,quality) - saves a BitmapData object as a jpeg
* 	-bmp : bitmapdata to be saved
* 	-defFileName : default filename in save as... dialog box.
* 	-quality : a number between 0 and 100 specifying jpeg quality.  defaults to 100
* 
* captureMC(mc,captureWindow,defFileName,quality) - captures and saves a DisplayObject as a jpeg
* 	-same as captureScreen but automatically generates bitmapdata from displayobject
*   -uses captureWindow as the capture area of the image
* 
* EVENTS:
* 	AlertEvent.ERROR - for errors
* 	Event.COMPLETE - when download video is complete
* 	ProcessingEvent.DONE - when saving is complete or canceled or causes an error
*/

package com.oddcast.workshop {
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.BGEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.utils.BMPCapture;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.ProcessingEvent;
	import com.oddcast.workshop.ServerInfo;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class DownloadVideo extends EventDispatcher {
		private var mid:String;
		private var sessionId:String;
		private var pollTimer:Timer;
		private var file:FileReference;
		private var defaultFileName:String;
		public var capturedSceneUrl:String;
		public var uploader:BGUploader;
				
		public function DownloadVideo() {
			pollTimer = new Timer(5000, 1);
			pollTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onPoll);
			
			file = new FileReference();
			file.addEventListener(Event.CANCEL, cancelHandler);
			file.addEventListener(Event.COMPLETE, completeHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			//file.addEventListener(Event.OPEN, openHandler);
			//file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			//file.addEventListener(Event.SELECT, selectHandler);
			uploader = new BGUploader();
			uploader.addEventListener(AlertEvent.ERROR,dispatchError);
		}
		public function set_expiration_timeout( _sec:Number ):void
		{	
			uploader.set_expiration_timeout( _sec );
		}
			
		
		public function downloadFile(url:String,$userFilename:String=null) : void {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, ProcessingEvent.SAVING));
			
			if ($userFilename != null) defaultFileName = $userFilename;
			var fileName:String
			if (defaultFileName == null) fileName = url.slice(url.lastIndexOf("/") + 1);
			else if (defaultFileName.indexOf(".") == -1) {
				var extension:String = url.slice(url.lastIndexOf("."));
				fileName = defaultFileName + extension;
			}
			else fileName = defaultFileName;
			
			trace("DownloadVideo::downloadFile : "+fileName);
			try {
				file.download(new URLRequest(url), fileName);
			}
			catch (e:Error) {
				trace("DownloadVideo::downloadFile try-catch error - " + e.message);
				//errorHandler(new ErrorEvent(ErrorEvent.ERROR, false, false,e.message, e.errorID));
				errorHandler(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}
		
		private function cancelHandler(evt:Event) : void {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.SAVING));
		}
		
		private function completeHandler(evt:Event) : void {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.SAVING));
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function errorHandler(evt:ErrorEvent) : void {
			trace("DownloadVideo::errorHandler");
			dispatchError(new AlertEvent(AlertEvent.ERROR, "f9t520","Error downloading file : "+evt.text,{flashError:evt.text}));
		}
		
		private function dispatchError(evt:AlertEvent) : void {
			pollTimer.stop();
			dispatchEvent(evt);
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.SAVING));
		}
		
		//****************************    DOWNLOAD VIDEO     *******************************
		
		public function captureVideo(in_mid:String, defFileName:String = null, format:String = "MP4", $w:Number = 0, $h:Number = 0) : void
		{
			//throw new Error("Download video is not implemented yet!");
			//return;
			
			mid = in_mid;
			defaultFileName = defFileName;
			
			var postVars:URLVariables	= new URLVariables();
			postVars.doorId				= ServerInfo.door;
			postVars.clientId			= ServerInfo.client;
			postVars.mId				= mid;
			postVars.format				= format;
			if ($w > 0 && $h > 0) //optional
			{
				postVars.ht = $h.toString();
				postVars.wt = $w.toString();
			}
			//see http://intranet.oddcast.com/wiki/index.php/RandD:Flash_API%27s:downloadVideo for details
			
			var url:String = ServerInfo.localURL + "api/downloadVideo.php";
			var request:Gateway_Request=new Gateway_Request(url, new Callback_Struct(fin,null,error));
			request.response_eval_method=response_eval
			Gateway.upload(postVars,request)
			function response_eval(_content:String):Boolean
			{
				var xml:XML;
				try
				{
					xml=new XML(_content);
				}
				catch(_e:Error)
				{}
				if (xml && xml.@APSSESSION && xml.@APSSESSION.toString().length>0)
					return true;
				return false;
			}
			function fin(_content:String):void
			{
				var xml:XML=new XML(_content);
				dispatchEvent(new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.SAVING,0));
				sessionId = xml.@APSSESSION.toString();
				pollTimer.reset();
				pollTimer.start();
			}
			function error(_msg:String):void
			{
				dispatchError(new AlertEvent(AlertEvent.ERROR,'f9t521','error accessing script',{details:_msg}));
			}
		}
		
		private function onPoll(evt:TimerEvent):void
		{
			var url:String = ServerInfo.videostar_pingUrl + "?sesId=" + sessionId + "&rand=" + Math.floor(Math.random() * 1000000);
			Gateway.retrieve_XML(url, new Callback_Struct(fin,null,error));
			function fin(_xml:XML):void
			{
				// validate xml data
				if (_xml.@RES.toString() == "ERROR") 
				{
					var errorMsg:String = _xml.@INFORMATION.toString();
					dispatchError(new AlertEvent(AlertEvent.ERROR, "f9t523", "Download video APS Error : " + errorMsg, { sessionId:sessionId, message:errorMsg } ));
				}
				else if (_xml.@STATUS == "1")
				{
					var videoUrl:String = _xml.@URL.toString();
					capturedSceneUrl = videoUrl;
					dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.SAVING));
					dispatchEvent(new SendEvent(SendEvent.DONE,SendEvent.DOWNLOAD_VIDEO));
				}
				else 
				{
					var percentDone:Number = parseFloat(_xml.@PERCENT.toString()) / 100;
					dispatchEvent(new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.SAVING, percentDone));
					pollTimer.reset();
					pollTimer.start();
				}
			}
			function error(_msg:String):void
			{
				dispatchError(new AlertEvent(AlertEvent.ERROR,'f9t522','error accessing script',{details:_msg}));
			}
		}
		
		//*************************     CAPTURE IMAGE     ****************************

		/**
		 * 
		 * @param	mc				bject you want to create a bitmap of
		 * @param	captureWindow	display object that defines the capture area frame of the image.  if you don't specify captureWindow, it will default to the mc itself
		 * @param	defFileName		
		 * @param	quality			
		 * @param	fileType		
		 * @param	_scale			scale 0-1 of the original captured image
		 * @param	_dimensions		dimensions of the capture, x=width y=height
		 * @param	_offset			offset from the registration point of the target
		 */
		public function captureMC
		(
			mc:DisplayObject, 
			captureWindow:DisplayObject, 
			defFileName:String = null, 
			quality:Number = 100, 
			fileType:String = "jpg", 
			_scale:Number = Number.NaN , 
			_dimensions:Point = null, 
			_offset:Point = null
		):void
		{
			trace("DownloadVideo::captureMC");
			//automatically generates bmp from display object
			
			var bmp				:BitmapData;
			var tempMask		:DisplayObject	= mc.mask;
			mc.mask								= null;
			var transparentBG	:Boolean		= (fileType == "png");
			
			try				{	bmp = BMPCapture.capture(mc, captureWindow, 0, 0, transparentBG, _scale, _dimensions, _offset);			}
			catch (e:Error) {	dispatchError(new AlertEvent(AlertEvent.ERROR, "f9t505", "Security error while trying to capture image : " + e.message));
								return;
							}
			mc.mask = tempMask;
			captureScreen(bmp, defFileName, quality,fileType);
			bmp.dispose();
		}
		
		/* saves a BitmapData object as a jpeg	-bmp : bitmapdata to be saved -defFileName : default filename
		-quality : a number between 0 and 100 specifying jpeg quality.  defaults to 100*/
		public function captureScreen(bmp:BitmapData, defFileName:String = null, quality:Number = 100, fileType:String = "jpg"):void
		{
			trace("DownloadVideo::captureScreen");
			//you provide your own bmp
			
			defaultFileName = defFileName;
			//var url:String = ServerInfo.acceleratedURL + "api/imageUploader.php"
			
			var data:ByteArray;
			if (fileType=="jpg") {
				var jpgEncoder:JPGEncoder=new JPGEncoder(quality);
				data = jpgEncoder.encode(bmp);
			}
			else if (fileType == "png") {
				data = PNGEncoder.encode(bmp);
			}
			else throw new Error("Unsupported image type in captureScreen : please use jpg or png");
			
			uploader.addEventListener(BGEvent.SELECT, imageUploaded);
			uploader.uploadBinary(data, fileType);
		}
		
		private function imageUploaded(evt:BGEvent) : void {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.SAVING));
			capturedSceneUrl = evt.bg.url;
			dispatchEvent(new SendEvent(SendEvent.DONE,SendEvent.DOWNLOAD_IMAGE));
			//dispatchEvent(evt);
		}
		
		private function imageUploadError(evt:AlertEvent) : void {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.SAVING));
			dispatchEvent(evt);
		}
	}
	
}
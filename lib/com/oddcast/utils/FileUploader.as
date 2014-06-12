/**
* ...
* @author Jonathan Achai (based on Sam's BGUploader
* @version 0.1
*/

package com.oddcast.utils {
	import com.oddcast.event.FileUploadEvent;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	

	public class FileUploader extends EventDispatcher {		
		private var uploadFile:FileReference;
		public var fileTypeArr:Array;
		private var _nByteSizeLimit:Number = 5000 * 1024;
		private var _nMinByteSizeLimit:Number = 0;
		private var _pMaxDimensions:Point;
		private var _pMinDimensions:Point;
		private var _sUploadUrl:String;
		private var _sErrorMsgPreamble = "Please check your Internet connection, and that the file you are uploading is not used by another application, and try again ";
		private var _bMacFlash10x0Fix:Boolean;
		
		private function testForMacBug():void
		{
			// Get the player’s version by using the flash.system.Capabilities class.
			var versionNumber:String = Capabilities.version;
			//trace("versionNumber: "+versionNumber);
			
			// The version number is a list of items divided by “,”
			var versionArray:Array = versionNumber.split(",");
			var length:Number = versionArray.length;
			
			// The main version contains the OS type too so we split it in two
			// and we’ll have the OS type and the major version number separately.
			var platformAndVersion:Array = versionArray[0].split(" ");
			
			var majorVersion:Number = parseInt(platformAndVersion[1]);
			var minorVersion:Number = parseInt(versionArray[1]);
			var buildNumber:Number = parseInt(versionArray[2]);
			
			//trace("Platform: "+platformAndVersion[0]);
			//trace("Major version: "+majorVersion);
			//trace("Minor version: "+minorVersion);
			//trace("Build number: "+buildNumber);
			
			if (platformAndVersion[0]=='MAC' && majorVersion==10 && minorVersion==0)
			{
				_bMacFlash10x0Fix = true;
			}
		}
		
		public function FileUploader(url:String=null) {			
			//trace("FileUploader::FileUploader ");
			testForMacBug();
			uploadFile=new FileReference();
			uploadFile.addEventListener(Event.SELECT,fileSelected);
			uploadFile.addEventListener(Event.COMPLETE,onFinishUpload);
			
			uploadFile.addEventListener(Event.CANCEL, onCancel);            
            uploadFile.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            uploadFile.addEventListener(Event.OPEN, onStartUpload);
            uploadFile.addEventListener(ProgressEvent.PROGRESS, onProgress);
            uploadFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);     
			
			uploadFile.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			uploadFile.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
			
			/*
			  dispatcher.addEventListener(Event.CANCEL, cancelHandler);
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(Event.SELECT, selectHandler);
            dispatcher.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,uploadCompleteDataHandler
			 
			*/
			_sUploadUrl = url;
		}
		
		public function setUploadUrl(s:String, randomUrl:Boolean = true):void
		{
			_sUploadUrl = s;
			//apply randomness
			if (randomUrl)
			{
				var rndStr:String = "rnd=" + String(Math.random() * 123456789);
				rndStr = (_sUploadUrl.indexOf("?") >= 0 ? "&" : "?") + rndStr;
				_sUploadUrl += rndStr;				
			}
			if (_pMaxDimensions!=null)
			{
				var maxDimStr:String = "maxW="+_pMaxDimensions.x+"&maxH="+_pMaxDimensions.y;
				maxDimStr = (_sUploadUrl.indexOf("?") >= 0 ? "&" : "?") + maxDimStr;
				_sUploadUrl += maxDimStr;		
			}
			
			if (_pMinDimensions!=null)
			{
				var minDimStr:String = "minW="+_pMinDimensions.x+"&minH="+_pMinDimensions.y;
				minDimStr = (_sUploadUrl.indexOf("?") >= 0 ? "&" : "?") + minDimStr;
				_sUploadUrl += minDimStr;		
			}
			//trace("FileUploader::setUploadUrl "+_sUploadUrl);
		}
		
		public function addImageFileType():void
		{		
			fileTypeArr = [new FileFilter("Images (*.jpg *.jpeg *.png *.gif)","*.jpg;*.jpeg;*.png;*.gif")];
		}
	
		public function addAudioFileType():void
		{
			//WAV (PCM), MP3, WMA
			fileTypeArr = [new FileFilter("Audios (*.wav (PCM), *.mp3, *.wma)","*.mp3;*.wav;*.wma")];
		}
		
		public function setSizeLimit(ksize:Number):void
		{
			//trace(" setSizeLimit("+ksize+")");
			_nByteSizeLimit = ksize*1024;
		}
		
		public function setMinSizeLimit(ksize:Number):void
		{
			_nMinByteSizeLimit = ksize * 1024;
		}
		
		public function setMaxDimensions(w:int, h:int):void
		{
			_pMaxDimensions = new Point(w,h);			
		}
		
		public function setMinDimensions(w:int, h:int):void
		{
			_pMinDimensions = new Point(w,h);			
		}
		
		private function onCancel(event:Event):void {
			//trace("FileUploader::onCancel "+event.toString());
        }
        
        private function onIOError(event:IOErrorEvent):void {            
			//trace("ioErrorHandler: " + event);
			//trace("FileUploader::onIOError "+event.toString());
			dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_ERROR,{id:0,event:event,msg:_sErrorMsgPreamble, info:"IOErrorEvent "+event.text+" "+_sUploadUrl}));	
        }

        private function onStartUpload(event:Event):void {
            //trace("openHandler: " + event);
			//trace("FileUploader::onStartUpload "+event.toString());
			dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_UPLOAD_START,event));	
        }

        private function onProgress(event:ProgressEvent):void {            
            //trace("FileUploader::onProgress name=" + uploadFile.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
			dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_PROGRESS,{percent:(event.bytesLoaded/event.bytesTotal)}));
			//if (_bMacFlash10x0Fix && event.bytesLoaded>100 && event.bytesLoaded==event.bytesTotal)
			//{
				//dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_DONE,event));
			//}
        }

        private function onSecurityError(event:SecurityErrorEvent):void {
            //trace("securityErrorHandler: " + event);
			//trace("FileUploader::onSecurityError "+event.toString());
			dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_ERROR,{id:2,event:event,msg:_sErrorMsgPreamble, info:"SecurityErrorEvent "+event.text+" "+_sUploadUrl}));	
        }
		
		private function uploadCompleteDataHandler(event:DataEvent):void {
			//trace("FileUploader::uploadCompleteData "+event.toString());
            //trace("FileUploader::uploadCompleteData: " + event.data);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
           // trace("FileUploader::httpStatusHandler: " + event);
			//trace("FileUploader::httpStatusHandler "+event.toString());
			dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_HTTP_STATUS,event));	
        }


						
		public function browse():void {
			//trace("FileUploader::browse ");
			try {
				uploadFile.browse(fileTypeArr);
			}
			catch (e:Error) {
				dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_ERROR,{id:1,event:null,msg:_sErrorMsgPreamble, info:e.message}));
				//trace("FileUploader::browse error");
			}
		}						
		
		private function fileSelected(evt:Event):void
		{				
			//_nMinByteSizeLimit
			//trace("APC::fileSelected "+uploadFile.size+" limit at="+_nByteSizeLimit);
			var limitText:String;
			if (uploadFile.size > 0)
			{
				if (uploadFile.size > _nByteSizeLimit)
				{
					//trace("_nByteSizeLimit="+_nByteSizeLimit);
					limitText = (_nByteSizeLimit/1024) > 1024? (Math.floor((_nByteSizeLimit/1024/1024)*10)/10) + " MB":_nByteSizeLimit/1024 + " KB";
					dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_ERROR,{id:3,event:null,msg:'File size exceeds limit of '+limitText}));	
				}
				else if (_nMinByteSizeLimit > 0 && uploadFile.size < _nMinByteSizeLimit)
				{
					//trace("_nMinByteSizeLimit=" + _nMinByteSizeLimit);
					limitText = (_nMinByteSizeLimit/1024) > 1024? (Math.floor((_nMinByteSizeLimit/1024/1024)*10)/10) + " MB":_nMinByteSizeLimit/1024 + " KB";
					dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_ERROR,{id:4,event:null,msg:'File size must be at least '+limitText}));	
				}
				else
				{
					dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_SELECT,evt));	
				}
				
				
			}						
		}
		public function upload():void
		{				
			if (_bMacFlash10x0Fix)
			{
				//if the problematic mac version comes up dispatch error to upgrade flash
				dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_ERROR,{id:7,event:null,msg:'There is a problem with the adobe flash player version installed. Please upgrade to the latest version'}));	
				return;	
			}
			//trace("FileUploader::upload _sUploadUrl="+_sUploadUrl);
			if (_sUploadUrl == null) throw new Error("FileUploader::upload - You must set upload url first");
				if (uploadFile!=null)
				{
					
					var req:URLRequest = new URLRequest(_sUploadUrl + "&rnd=" + (Math.random() * 9999999));
					//trace("FileUploader::upload to " + req.url);
					try {
						uploadFile.upload(req);
					}
					catch (e:Error) {
						dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_ERROR,{id:5,event:null,msg:_sErrorMsgPreamble, info:e.message}));	
					}
				}
				else
				{
					dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_ERROR,{id:6,event:null,msg:'No File to upload'}));
				}
			
		}
		
		private function onFinishUpload(evt:Event):void
		{
			//progressBar.tf_status.text="RETREIVING..."
			dispatchEvent(new FileUploadEvent(FileUploadEvent.ON_DONE,evt));			
		}
		
		public function getFile():FileReference {
			return(uploadFile);
		}
	}
	
}
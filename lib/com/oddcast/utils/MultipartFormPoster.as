/**
* ...
* @author Jonathan Achai
* @version 0.1
* 
* Utility to send a multipart/form-data post
* 
* Usage:
* var formPoster:MultipartFormPoster = new MultipartFormPoster();
* formPoster.addEventListener(Event.COMPLETE,postComplete);
* formPoster.addFile(filename:String,byteArray:ByteArray);
* formPoster.addVariable(fieldname:String,value:String);
* formPoster.post("http://www.workboy.com/jon/as3upload/");
* 
*/

package com.oddcast.utils
{
	import com.oddcast.event.AlertEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import com.oddcast.utils.MultipartFormFile;
	
	

	public class  MultipartFormPoster extends EventDispatcher
	{
		private var _arrFiles:Array;
		private var _sBoundary:String; 
		private var _sEndHeader:String = "";
		private var _oFields:Object;
		
		public var data:String;
		public var errorMsg:String;
		
		private var loader:FileLoaderInstance;
		
		public static const MIME_TYPE_TEXT:String = 'text/plain';		
		
		function MultipartFormPoster()
		{
			_sBoundary = makeBoundaryString();			
			_arrFiles = new Array();
			_oFields = new Object();
		}
		
		
		private function makeBoundaryString():String
		{
			return Number(Math.random()*999999999999).toString(16);
		}
		
		public function addFile(filename:String,bytes:ByteArray,mimeType:String="application/octet-stream",fieldName:String=null):void
		{			
			_arrFiles.push(new MultipartFormFile(filename,bytes,_sBoundary,mimeType,fieldName));
		}
		
		public function addVariable(name:String,value:String):void
		{
			_oFields[name] = value;
		}
		
		public function getRequest(url:String):URLRequest {
			//make the post request bytes
			var sendBytes:ByteArray = new ByteArray();
			var tmpFileBytes:ByteArray
			for (var i:uint=0;i<_arrFiles.length;++i)
			{
				tmpFileBytes = MultipartFormFile(_arrFiles[i]).getBytes(i);
				sendBytes.writeBytes(tmpFileBytes,0,tmpFileBytes.length);
			}
			
			for (var name:String in _oFields)
			{				
				tmpFileBytes = getFieldBytes(name);
				sendBytes.writeBytes(tmpFileBytes,0,tmpFileBytes.length);
				
			}			
			
			//build post request			
			var request:URLRequest = new URLRequest(url);			
			request.data = sendBytes;
			request.method = URLRequestMethod.POST 
			request.contentType = "multipart/form-data; boundary="+_sBoundary;
			
			return(request);
		}
		
		public function post(url:String):void {
			var request:URLRequest=getRequest(url);
			
			loader = new FileLoaderInstance();
			loader.addEventListener(Event.COMPLETE, postComplete,false,0,true);
			loader.addEventListener(ErrorEvent.ERROR, onError,false,0,true);
			
			loader.loadRequest(request, String);
/*			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,postComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR,onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);

			try {
				loader.load(request);
			} catch (error: Error) {
				onError(new ErrorEvent(ErrorEvent.ERROR,false,false,error.message));
				trace("Unable to load requested document.");
			}*/
		}
		
		private function postComplete(evt:Event):void
		{
			data = evt.target.data;
			errorMsg=null;
			//trace("postCompelete "+evt.toString()+" -> "+evt.target.data);
			loader.removeEventListener(Event.COMPLETE, postComplete);
			loader.removeEventListener(ErrorEvent.ERROR, onError);
			dispatchEvent(evt);
		}
		
		private function onError(evt:ErrorEvent):void {
			data=null;
			errorMsg=evt.text;
			loader.removeEventListener(Event.COMPLETE, postComplete);
			loader.removeEventListener(ErrorEvent.ERROR, onError);
			dispatchEvent(evt);
		}
		
		public function checkForAlertEvent(errorCodeLoadFailed:String = null,errorCodeBadData:String=null):AlertEvent {
			if (loader == null) return(null);
			if (errorCodeBadData == null) errorCodeBadData = errorCodeLoadFailed;
			var alertEvt:AlertEvent = loader.getAlertEvent();
			if (alertEvt != null && alertEvt.code == null) {
				if (data == null) alertEvt.code = errorCodeLoadFailed;
				else alertEvt.code = errorCodeBadData;
			}
			return(alertEvt);
		}
		
		private function getFieldBytes(name:String):ByteArray
		{
			var s:String = '--'+_sBoundary+'\r\n';			
			s+='Content-Disposition: form-data; name="'+name+'"\r\n\r\n';
			s+=_oFields[name]+'\r\n';
			s+='--'+_sBoundary+'--\r\n';
			var retBytes:ByteArray = new ByteArray();
			retBytes.writeMultiByte(s,"ascii");
			return retBytes;			
		}
	}
	
	
	
}
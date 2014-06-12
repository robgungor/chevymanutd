package com.oddcast.utils {
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class XMLLoaderInstance {
		public var url:String;
		public var errorStr:String;
		private var loader:URLLoader;
		private var callback:Function;
		private var receiveClass:Class;
		private var args:Array;
		private var loadTimer:Timer;
		public var timeoutSeconds:Number = 30;
		public var customContentType:String = null;
		
		public function get data():String {
			return(loader.data);
		}
		
		public function load($url:String,$callback:Function,sendObj:*,$receiveClass:Class, $args:Array) {
			url = $url;
			receiveClass = $receiveClass;
			callback = $callback;
			args = $args;
			
			loadTimer = new Timer(timeoutSeconds*1000,1);
			loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timeOut);
			loadTimer.start();
			
			loader=new URLLoader();
			
			loader.addEventListener(Event.COMPLETE,onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR,onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			
			if (receiveClass == URLVariables) loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			else if (receiveClass == ByteArray) loader.dataFormat = URLLoaderDataFormat.BINARY;
			else loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			var request:URLRequest=new URLRequest(url);
			if (sendObj!=null) request.method=URLRequestMethod.POST;
			
			if (sendObj is URLVariables) request.data=sendObj;
			else if (sendObj is XML) {
				request.data=sendObj.toXMLString();
				request.contentType="text/xml";
			}
			else if (sendObj is String) request.data = sendObj;
			else if (sendObj is ByteArray) {
				request.data = sendObj;
				request.contentType = "application/octet-stream";
			}
			if (customContentType != null) request.contentType = customContentType;
			
			try {
				loader.load(request);
			}
			catch (e:Error) {
				onError(new ErrorEvent(ErrorEvent.ERROR,false,false,e.message));
			}
			
		}
		
		private function onComplete(evt:Event) {
			trace("got XML from "+url+" : "+loader.data);
			//lastData=loader.data;
			try {
				var receiveObj:*;
				if (receiveClass == XML) receiveObj = new XML(loader.data);
				else if (receiveClass == URLVariables) receiveObj = loader.data as URLVariables;
				else if (receiveClass == ByteArray) receiveObj = loader.data as ByteArray;
				else if (receiveClass == String) receiveObj = loader.data as String;
			}
			catch (e:Error) {
				//----trace("error parsing xml : "+loader.data);
				onError(new ErrorEvent(ErrorEvent.ERROR,false,false,e.message));
				return;
			}
			
			errorStr = null;
			
			loader.removeEventListener(Event.COMPLETE,onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loadTimer.stop();
			loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timeOut);
			
			XMLLoader.loadDone(this)
			callback.apply(null,[receiveObj].concat(args));
		}
			
		private function onError(evt:ErrorEvent) {
			//----trace("XMLLoader: error calling "+url+" : "+evt.text);
			errorStr = evt.text;
			//request from Gil and Naphtail to show if error 1088 the following message:
			if (errorStr.indexOf("1088") >= 0)
			{
				errorStr = "Thank you for using our application. It is very popular! Please come back later and try again. (" +evt.text + ")"; 
			}
			
			loader.removeEventListener(Event.COMPLETE,onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loadTimer.stop();
			loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timeOut);
			
			XMLLoader.loadDone(this);
			callback.apply(null,[null].concat(args));
		}
		
		private function timeOut(evt:TimerEvent) {
			onError(new ErrorEvent(ErrorEvent.ERROR, false, false, "Loading has timed out.  Please check your connection."));
		}
		
		private function onHTTPStatus(evt:HTTPStatusEvent) {
			//----trace("HTTPStatus : " + evt.status);
		}
	}
	
}
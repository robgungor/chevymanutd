/**
* @author Sam Myer, Me^
* 
* This is the base class used for sending and fetching URLRequests
* 
* It is used by the static class XMLLoader as well as MultipartFormPoster
* @see com.oddcast.utils.XMLLoader
* @see com.oddcast.utils.MultipartFormPoster
* 
* METHODS:
* 
* loadWithCallback(url,callback,sendObj,receiveClass,args)
* 	url - the url of the file you are loading
* 	callback - callback of the file you are .  Leave this null if you don't want a callback
* 	sendObj - the object you are sending to the file.  Can be of type URLVariables, String, XML, ByteArray, or null.
*   receiveClass - the class of file you are expecting back (XML, URLVariables, ByteArray or String) - this will be sent to the callback function
* 	args - any other arguments that you want to pass along to the callback function
* 
* loadRequest(request,receiveClass) - this function is similar to loadWithCallback, except you build the request
* yourself and there is no callback.  This function is used mostly by MultipartFormPoster because it needs customized
* headers
* 
* getAlertEvent() - you can use this function to see if the call completed successfully and returned VALID data.
* It verifies the result of the last loader call and returns an AlertEvent with the reason for failure if there was a problem
* see the function below for more documentation
* 
* PROPERTIES:
* url - the url being called (this is set when you call loadWithCallback or loadRequest)
* callback - the callback function  (set when you call loadWithCallback)
* args  (set when you call loadWithCallback)
* timeoutSeconds - number of seconds to wait before cancelling load and reporting that the connection timed out
* errorStr - if no data was received, this string contains the reason.  If data was received, this is null.
* 			(There might be an error even if data was received due to invalid data - use getAlertEvent to check)
* data - data received.  If no data was received, this is null.
* 
* EVENTS:
* Event.COMPLETE - data is received - URLLoader returns Event.COMPLETE
* ErrorEvent.ERROR - data isn't received.
* 
* EXAMPLE:
* Normally you use the XMLLoader class to accomplish this without having to create a class variable every time you want to load.
* However, if you really want to use this class.
* 
* var fli:FileLoaderInstance=new FileLoaderInstance()
* var extraData:String="extra"
* fli.loadWithCallback("test.php",gotData,new URLVariables("a=1&b=2"),XML,extraData)
* 
* function gotData(_xml:XML,extraData:String) {
* 	var alertEvt:AlertEvent=fli.getAlertEvent();
*   if (alertEvt!=null) {
*      dispatchEvent(alertEvt);
*      return;
*   }
*   trace(extraData);  //extra
* }
*/
package com.oddcast.utils {
	import com.oddcast.event.AlertEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
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
	
	public class FileLoaderInstance extends EventDispatcher {
		public var url:String;
		private var request:URLRequest;
		public var errorStr:String;
		public var callback:Function;
		private var receiveClass:Class;
		public var args:Array;
		public var retries:uint = 0;
		private var retriesLeft:uint = 0;
		
		private var loader:URLLoader;
		private var loadTimer:Timer;
		public var timeoutSeconds:Number = 120;
		//private var _completeEvent:Event;
		
		public function get data():String {
			return(loader.data);
		}
		
		/*public function get completeEvent():Event {
			return(_completeEvent);
		}*/
		
		public function loadWithCallback($url:String, $callback:Function, sendObj:*, $receiveClass:Class, $args:Array):void
		{
			//automatically builds request for you
			
			var newRequest:URLRequest=new URLRequest($url);
			if (sendObj!=null) newRequest.method=URLRequestMethod.POST;
			
			//trace("XMLLoader:: loadWithCallback : " + $url);// + " -- " + sendObj + "  is? " + (sendObj is URLVariables));
			//if (sendObj is URLVariables) trace(sendObj.toString());
			if (sendObj is URLVariables) newRequest.data=sendObj;
			else if (sendObj is XML) {
				newRequest.data=sendObj.toXMLString();
				newRequest.contentType="text/xml";
			}
			else if (sendObj is String) newRequest.data = sendObj;
			else if (sendObj is ByteArray) {
				newRequest.data = sendObj;
				newRequest.contentType = "application/octet-stream";
			}
			
			load(newRequest, $callback, $receiveClass, $args);
		}
		
		public function loadRequest($request:URLRequest, $receiveClass:Class = null):void 
		{
			if ($receiveClass==null) $receiveClass=String
			load($request, null, $receiveClass, null);
		}
		
		private function load($request:URLRequest, $callback:Function, $receiveClass:Class, $args:Array, $retry:Boolean = false):void
		{
			//you create the request
			
			request = $request;
			url = request.url;
			receiveClass = $receiveClass;
			callback = $callback;
			args = $args;
			errorStr = null;
			if (!$retry)
				retriesLeft = retries;
			
			stop_load_timer();
			start_load_timer();
			
			loader=new URLLoader();
			
			loader.addEventListener(Event.COMPLETE,onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR,onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			
			if (receiveClass == URLVariables) loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			else if (receiveClass == ByteArray) loader.dataFormat = URLLoaderDataFormat.BINARY;
			else loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			try {
				loader.load(request);
			}
			catch (e:Error) {
				onError(new ErrorEvent(ErrorEvent.ERROR,false,false,e.message));
			}
			
		}
		
		private function start_load_timer():void
		{
			loadTimer = new Timer(timeoutSeconds*1000,1);
			loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timeOut);
			loadTimer.start();
		}
		
		private function stop_load_timer():void
		{
			if (loadTimer == null)
				return;	// nothing to stop
			loadTimer.stop();
			loadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timeOut);
			loadTimer = null;
		}
		
		private function onComplete(evt:Event):void
		{
			//trace("got XML from "+url+" : "+loader.data);
			//lastData=loader.data;
			try {
				var receiveObj:*;
				if (receiveClass == XML) receiveObj = new XML(loader.data);
				else if (receiveClass == URLVariables) receiveObj = loader.data as URLVariables;
				else if (receiveClass == ByteArray) receiveObj = loader.data as ByteArray;
				else if (receiveClass == String) receiveObj = loader.data as String;
				else receiveObj = loader.data; //default is String
			}
			catch (e:Error) {
				//trace("error parsing xml : "+loader.data);
				onError(new ErrorEvent(ErrorEvent.ERROR,false,false,e.message));
				return;
			}
			
			errorStr = null;
			
			loader.removeEventListener(Event.COMPLETE,onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			stop_load_timer();
			
			dispatchEvent(evt);
			if (callback!=null) callback.apply(null,[receiveObj].concat(args));
		}
			
		private function onError(evt:ErrorEvent):void
		{
			if (retriesLeft > 0) {
				retriesLeft--;
				load(request, callback, receiveClass, args, true);
				return;
			}
			
			//trace("XMLLoader: error calling "+url+" : "+evt.text);
			errorStr = evt.text;
			/*
			//request from Gil and Naphtail to show if error 1088 the following message:
			// REMOVED (by Sam) - custom error messages should be handled in the front end, not here.
			// Error 1088 means the XML returned was bad.
			if (errorStr.indexOf("1088") >= 0) 	{
				errorStr = "Thank you for using our application. It is very popular! Please come back later and try again. (" +evt.text + ")"; 
			}*/
			
			stop_load_timer();
			loader.removeEventListener(Event.COMPLETE,onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,evt.text));
			if (callback!=null) callback.apply(null,[null].concat(args));
		}
		
		private function timeOut(evt:TimerEvent):void 
		{
			onError(new ErrorEvent(ErrorEvent.ERROR, false, false, "Loading has timed out.  Please check your connection."));
			try {
				loader.close();
			}
			catch (e:Error) {
				trace("error: could not close URLLoader");
			}
		}
		
		private function onHTTPStatus(evt:HTTPStatusEvent):void 
		{
			//trace("HTTPStatus : " + evt.status);
		}
		
		public function getAlertEvent():AlertEvent {
			//verifies the result of the last loader call and returns an AlertEvent if there was a problem
			//if the result is fine, returns null
			
			//if the data received follows the standard error back-end syntax, then the error code/message will be parsed out from that message
			//The standard error syntax for Strings is :  "Error: [nnn] Error Message Here"
			//For XML it is : <APIERROR CODE="nnn" ERRORSTR="Your Error Message Here"/>
			
			//if there are any other problems with the result, or if no result is received, then this function will return
			//an AlertEvent where code=null and message="Error loading http://www.oddcast.com/urlthatwasloaded.php : The reason why it failed"
			//it also includes an object for dynamic error messages in the errors.xml file:
			//"Error loading {url} : {details}"
			
			//trace("GetAlertEvent receiveClass = " + receiveClass);
			var evt:AlertEvent;
			var errorReason:String;
			if (data == null) {
				if (errorStr == null) errorReason="Data is null";
				else errorReason=errorStr;
			}
			else if (data.length == 0) {
				errorReason="No data returned";
			}
			else if (receiveClass == XML) {
				var _xml:XML;
				try {
					_xml = new XML(data);
				}
				catch (e:Error) {
					_xml = null;
				}
				if (_xml == null) errorReason = "XML not well-formed";
				else if (_xml.name() == null) {
					evt = getAlertEventFromString(data);
					if (evt == null) errorReason = "XML is missing root node";
				}
				else evt = getAlertEventFromXML(_xml);
			}
			else if (receiveClass==String) evt = getAlertEventFromString(data);
			
			if (evt == null && errorReason != null) evt = new AlertEvent(AlertEvent.ERROR, null, "Error loading " + url + " : " + errorReason, { url:url, details:errorReason } );
			return(evt);
		}
		
		private function getAlertEventFromString(s:String):AlertEvent {
			//you send in raw string data, and this function will parse it out into an AlertEvent message.
			//If there is no problem with the data, this function will return null.
			//Otherwise it will parse the code and message out from the data.
			
			if (s == null || s.length == 0) return(null);
			if (s.indexOf("Error") != 0) return(null);
			var startIndex:int = s.indexOf("[");
			var endIndex:int = s.indexOf("]",startIndex);
			var code:String;
			if (startIndex != -1 && endIndex != -1) code = s.slice(startIndex + 1, endIndex);
			if (code == null || code.length == 0) return(null);
			else return(new AlertEvent(AlertEvent.ERROR, code, s));
		}
		
		private function getAlertEventFromXML(_xml:XML):AlertEvent {
			//you send in XML data, and this function will parse it out into an AlertEvent message.
			//If there is no problem with the data, this function will return null.
			//Otherwise it will parse the code and message out from the data.
			
			if (_xml == null||_xml.name() == null) return(null);
			else if (_xml.name().toString() == "APIERROR") {
				return(new AlertEvent(AlertEvent.ERROR, _xml.@CODE, unescape(_xml.@ERRORSTR)));
			}
			else return(null);
		}
	}
	
}
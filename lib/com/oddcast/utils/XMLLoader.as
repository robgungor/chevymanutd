/**
* ...
* @author Sam Myer
* @version 1.1
* @usage
* 
* simplifies loading operations into one line.  handles creation and deletion of loader instances
* (actual loading is now done in instances of FileLoaderInstance)
* 
* Methods:
* loadXML(url,function,...) - loads url and calls function with xml when loading is complete or null if there was an error
* loadVars(url,function,...) - loads url and calls function with Url Variables
* sendXML(url,function,myXml,...) - sends myXml to url and calls function with xml reply
* sendVars(url,function,myURLVars,...) - sends myURLVars to url and calls function with xml reply
* 
* sendAndLoad(url,function,sendObj,receiveClass,...) - generalized sendAndLoad function
* sendObj can (currently) be of type XML, URLVariables, ByteArray, String, or null
* receiveClass is the class of variable that is being received (XML, URLVariables, ByteArray or String)
* 
* in case of error, the callback function is called with a null value and the error message can
* be accessed as XMLLoader.lastError
* 
* UPDATE Feb 2 2009 :
* checkForAlertEvent(errorCodeLoadFailed,errorCodeBadData):AlertEvent - validates data returned.
* If ok, returns null, otherwise returns an AlertEvent.
* If you pass only 1 error code, it will use that error code for both cases 1 & 2.
* There are 4 cases :
* 1) There is a load error and no data is received (callback is null)
*    returns an AlertEvent with code errorCodeLoadFailed.  The message contains the url and the flash error received
* 2) Data is received (callback is non-null) but it is bad (zero-length, or invalid XML) :
*    returns an AlertEvent with code errorCodeBadData.  The message contains the url and the reason why the data is bad.
* 3) Data is received, PHP script returns an error in the form "Error: [nnn] Error text" or <APIERROR CODE="nnn" ERRORSTR="Error%20text" />
*    returns an AlertEvent with code nnn and the message "Error text"
* 4) All other cases - there is no apparent problem with the data
*    returns null
* @see com.oddcast.utils.FileLoaderInstance for more details
* 
* Example:
* function getXML(url:String) {
* 	XMLLoader.loadXML(url,gotXML,2)
* }
* function gotXML(_xml:XML,param1:Number) {
*   var alertEvt:AlertEvent=XMLLoader.checkForAlertEvent("error123")
* 	if (alertEvt!=null) {
*       trace("there was an error")
*       dispatchEvent(alertEvt);
*       return;
*   }
* 	trace(param1) //2
*   ...
* }
*/

package com.oddcast.utils {
	import com.oddcast.event.AlertEvent;
	
	import flash.accessibility.Accessibility;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	public class XMLLoader {
		
		public static var lastError:String;
		public static var lastData:String;
		public static var lastUrl:String;
		private static var lastAlertEvent:AlertEvent;
		private static var loaders:Array = new Array(); //stack of FileLoaderInstance objects
		public static var retries:uint = 1;
		
		public static function loadXML(url:String,callback:Function, ...args:Array):void 
		{
			load(url,callback,null,XML,args);
		}
		
		public static function destroy():void
		{
			while (loaders.length > 0)
			{
				removeLoader(loaders[0]);
			}
		}
		
		public static function loadVars(url:String,callback:Function, ...args:Array):void 
		{
			load(url,callback,null,URLVariables,args);
		}
		
		public static function loadFile(url:String,callback:Function, ...args:Array):void
		{
			load(url,callback,null,ByteArray,args);
		}
		
		public static function sendXML(url:String,callback:Function,_xml:XML, ...args:Array):void
		{
			load(url,callback,_xml,XML,args);
		}
		
		public static function sendVars(url:String, callback:Function, urlVars:URLVariables, ...args:Array):void 
		{
			load(url,callback,urlVars,XML,args);
		}

		public static function sendFile(url:String,callback:Function,bytes:ByteArray, ...args:Array):void
		{
			load(url,callback,bytes,XML,args);
		}
		
		public static function sendAndLoad(url:String,callback:Function,sendObj:*,receiveClass:Class, ...args:Array):void
		{
			load(url,callback,sendObj,receiveClass,args);
		}
		
		private static function load(url:String, callback:Function, sendObj:*, receiveClass:Class, args:Array):void
		{
			var loader:FileLoaderInstance = new FileLoaderInstance();
			loader.addEventListener(Event.COMPLETE, loadDone);
			loader.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent):void 
			{
				loadError(e);
				if (callback != null)
					callback(null);
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
			{
				if (callback != null)
					callback(null);
			});
			loader.retries = retries;
			loaders.push(loader);
			loader.loadWithCallback(url, callback, sendObj, receiveClass, args);
		}
		
		private static function loadDone(evt:Event):void
		{
			var loader:FileLoaderInstance = evt.target as FileLoaderInstance;
			removeLoader(loader); //when loader is finished, delete it from the stack.
			
			lastError = null;
			lastAlertEvent = loader.getAlertEvent();
			lastUrl = loader.url;
			lastData = loader.data;
		}
		
		private static function loadError(evt:ErrorEvent):void
		{
			var loader:FileLoaderInstance = evt.target as FileLoaderInstance;
			removeLoader(loader); //when loader is finished, delete it from the stack.
			
			lastError = evt.text;
			lastUrl = loader.url;
			lastData = null;
			lastAlertEvent = loader.getAlertEvent();
		}
		
		private static function removeLoader(loader:FileLoaderInstance):void 
		{
			loader.removeEventListener(Event.COMPLETE, loadDone);
			loader.removeEventListener(ErrorEvent.ERROR, loadError);
			var index:int = loaders.indexOf(loader);
			if (index == -1) return; //if this loader was not instantiated by XMLLoader, return
			delete loaders[index];
			loaders.splice(index, 1);			
		}
		
		public static function checkForAlertEvent(errorCodeLoadFailed:String = null,errorCodeBadData:String=null):AlertEvent 
		{
			//this function uses the call to getAlertEvent on FileLoaderInstance to validate the loader results.
			//if there is no error code coming from the back end, errorCodeLoadFailed or errorCodeBadData will be used for the error code
			if (errorCodeBadData == null) errorCodeBadData = errorCodeLoadFailed;
			if (lastAlertEvent != null && lastAlertEvent.code == null) {
				if (lastData == null) lastAlertEvent.code = errorCodeLoadFailed;
				else lastAlertEvent.code = errorCodeBadData;
			}
			return(lastAlertEvent);
		}
	}
}
package com.oddcast.utils
{
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.*;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.utils.*;
	
 	
	public class ErrorReportingLoader extends Loader
	{
		private static const TIMEOUT_TIME:int = 30000;
		private static const DATA_TIMEOUT:int = 1000;
		private static var REPORTED:Boolean = false;
		public static var ERROR_REPORTING_ACTIVE:Boolean = true;
		public static var REPORTING_URL:String = "http://track.oddcast.com/grabError.php";
		public static var PAGE_DOMAIN:String;
		
		private var timeout_ref:int;
		private var prog_size:int;
		private var prog_timer:Timer;
		private var request_url:String;
		
		public function ErrorReportingLoader()
		{
			//trace("ErrorReportingLoader -- init");
			super();
		}
		
		public override function load(request:URLRequest, context:LoaderContext=null):void
		{
			//trace("ErrorReportingLoader -- ERROR_REPORTING_ACTIVE: "+ERROR_REPORTING_ACTIVE +" REPORTING_URL: " + REPORTING_URL +" REPORTED: "+REPORTED);
			if (ERROR_REPORTING_ACTIVE && REPORTING_URL && !REPORTED)
			{
				timeout_ref = setTimeout(onTimeout, TIMEOUT_TIME);
				addListeners();
			}
			request_url = request.url;
			super.load(request, context);
		}
		
		public function report(str:String = "", url:String = ""):void
		{
			if (ERROR_REPORTING_ACTIVE && REPORTING_URL && !REPORTED)
			{
				try
				{
					var req:URLRequest = new URLRequest(REPORTING_URL);
					var url_vars:URLVariables = new URLVariables();
					url_vars.error = (str.length > 0) ? "ERL::"+str : "ERL::file_load_error";
					if (request_url && request_url.length > 0)
					{
						url_vars.addInfo = request_url;
					} 
					else if (url && url.length > 0)
					{
						url_vars.addInfo = url;
					}
					
					if (contentLoaderInfo && contentLoaderInfo.loaderURL) url_vars.originator = contentLoaderInfo.loaderURL;
					if (PAGE_DOMAIN && PAGE_DOMAIN.length > 0) url_vars.appVer = PAGE_DOMAIN;
					//trace("ELR :: url_vars.code: " + url_vars.code + " PAGE_DOMAIN: "+PAGE_DOMAIN);
					url_vars.browser = Capabilities.os + " " + Capabilities.version;
					/*
					What we want to collect - 
					* time/date stamp
					* ksize of file
					* URL of file
					* client ip 
					* server ip (if akamai this identifies their edge server)
					* browser & version
					* platform & version (i.e. MacOS 10.5.3)
					* Flash version
					anything else?
					*/
					req.data = url_vars;
					//trace("REPORT LOADER ERROR : "+req.data+" url: "+req.url);
					
					sendToURL(req);
				}
				catch (error:Error)
				{
					trace("REPORT LOADER - sendToUrl error!!");
				}
			}
		}
		
		private function addListeners():void
		{
			//trace("REPORT LOADER ERROR ::  ");
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.contentLoaderInfo.addEventListener(Event.UNLOAD, onUnload);
		}
		
		private function removeListeners():void
		{
			clearTimeout(timeout_ref);
			if (prog_timer)
			{
				prog_timer.stop();
				prog_timer.removeEventListener(TimerEvent.TIMER, onProgTimer);
				prog_timer = null;
			}
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.contentLoaderInfo.removeEventListener(Event.UNLOAD, onUnload);
		}
		
		private function onTimeout():void
		{
			//trace("ERL ::: on timeout  time:"+getTimer());
			clearTimeout(timeout_ref);
			if (contentLoaderInfo && contentLoaderInfo.bytesLoaded)
			{
				prog_size = contentLoaderInfo.bytesLoaded;
				prog_timer = new Timer(1000);
				prog_timer.addEventListener(TimerEvent.TIMER, onProgTimer);
				prog_timer.start();
			}
			else
			{
				removeListeners();
				report();
			}
		}
		
		private function onProgTimer(event:TimerEvent):void
		{
			//trace("ERL ::: on prog timer time: "+getTimer()+"  bl: "+contentLoaderInfo.bytesLoaded+" prog_size:" +prog_size);
			if (contentLoaderInfo.bytesLoaded - prog_size <= 1000)
			{
				removeListeners();
				report();
			}
			else
			{
				prog_size = contentLoaderInfo.bytesLoaded;
			}
		}
		
		private function onComplete(event:Event):void
		{
			//trace("REPORT LOADER ERROR :: COMPLETE "+request_url);
			removeListeners();
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			//trace("REPORT LOADER ERROR :: IO ERROR "+request_url);
			removeListeners();
			report("io_error");
		}
		
		private function onUnload(event:Event):void
		{
			removeListeners();
		}
	}
}
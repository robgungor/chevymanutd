package com.oddcast.utils
{
	import flash.events.*;
	import flash.net.*;
	import flash.system.Capabilities;
	import flash.utils.*;

	public class ErrorReportingURLLoader extends URLLoader
	{
		private static const TIMEOUT_TIME:int = 30000;
		private static const DATA_TIMEOUT:int = 1000;
		private static var REPORTED:Boolean = false;
		public static var ERROR_REPORTING_ACTIVE:Boolean = true;
		public static var REPORTING_URL:String = "http://track.oddcast.com/grabError.php";
		public static var PAGE_DOMAIN:String;
		public static var PLAYER_URL:String;
		
		private var timeout_ref:int;
		private var prog_size:int;
		//private var prog_timer:Timer;
		private var request_url:String;
		
		public function ErrorReportingURLLoader(request:URLRequest=null)
		{
			super(request);
		}
		
		public override function load(request:URLRequest):void
		{
			if (ERROR_REPORTING_ACTIVE && REPORTING_URL && !REPORTED)
			{
				timeout_ref = setTimeout(onTimeout, TIMEOUT_TIME);
				addListeners();
			}
			request_url = request.url;
			super.load(request);
		}	
		
		public function report(str:String = ""):void
		{
			if (ERROR_REPORTING_ACTIVE && REPORTING_URL && !REPORTED)
			{
				try
				{
					var req:URLRequest = new URLRequest(REPORTING_URL);
					var url_vars:URLVariables = new URLVariables();
					url_vars.error = (str.length > 0) ? "ERL::"+str : "ERL::file_load_error";
					
					url_vars.addInfo = request_url;
					//if (data_str.length > 0) url_vars.addInfo = data_str;
					url_vars.browser = Capabilities.os + " " + Capabilities.version;
					if (PAGE_DOMAIN && PAGE_DOMAIN.length > 0) url_vars.appVer = PAGE_DOMAIN;
					if (PLAYER_URL && PLAYER_URL.length > 0) url_vars.originator = PLAYER_URL;
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
					trace("REPORT LOADER ERROR :: "+req.data.toString()+" url: "+req.url);
					
					sendToURL(req);
				}
				catch (error:Error){}
			}
		}
		
		private function addListeners():void
		{
			this.addEventListener(Event.COMPLETE, onComplete);
			this.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.addEventListener(Event.UNLOAD, onUnload);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
		
		private function removeListeners():void
		{
			clearTimeout(timeout_ref);
			/* if (prog_timer)
			{
				prog_timer.stop();
				prog_timer.removeEventListener(TimerEvent.TIMER, onProgTimer);
				prog_timer = null;
			} */
			this.removeEventListener(Event.COMPLETE, onComplete);
			this.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.removeEventListener(Event.UNLOAD, onUnload);
			this.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
		}
		
		private function onTimeout():void
		{
			//trace("ERL ::: on timeout  time:"+getTimer());
			/* if (contentLoaderInfo && contentLoaderInfo.bytesLoaded)
			{
				prog_size = this.bytesLoaded;
				prog_timer = new Timer(1000);
				prog_timer.addEventListener(TimerEvent.TIMER, onProgTimer);
				prog_timer.start();
			}
			else
			{ */
				removeListeners();
				report();
			/* } */
		}
		
		private function onComplete(event:Event):void
		{
			removeListeners();
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			removeListeners();
			report("io_error");
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			removeListeners();
			report("security_error");
		}
		
		private function onUnload(event:Event):void
		{
			removeListeners();
		}
	}
}
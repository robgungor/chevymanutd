/**
 * 
 * Manages multiple event trackers in the same project
 * 04.16.2010
 * David Segal
 * 
 */

package com.oddcast.reports
{
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.net.sendToURL;
	
	public class MultiUrlEventTracker extends EventTracker
	{
		
		private var url_array:Array;
		
		public function MultiUrlEventTracker()
		{
			url_array = new Array();
			super();
		}
		
		override public function init(in_req_url:String, in_init_obj:Object, in_loader:LoaderInfo = null):void
		{
			url_array.push(in_req_url);
			super.init(in_req_url, in_init_obj, in_loader);
		}
		
		override protected function sendRequest(in_str:String):void
		{
			for (var i:int = 0; i < url_array.length; ++i)
			{
				sendToURL(new URLRequest(url_array[i]+in_str));
			}
		}
		
		public function addReportingUrl(in_url:String):void
		{
			url_array.push(in_url);
		}
	
	}
}
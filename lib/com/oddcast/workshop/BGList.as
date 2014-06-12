/**
* @author Sam Myer
* This class is for loading and storing a list of door backgrounds.  In the MVC pattern, this is the model class.
* 
***** Functions:
* loadBGs() - makes php call to load audios
* 
* getBGByName - returns loaded background matching the given name (loadBGs must be called first)
* 
***** Properties:
* bgArr - after loading is complete, this points to an array of WSBackgroundStruct objects
* 
***** Events:
* Event.COMPLETE - when loading successfully completes
* AlertEvent.ERROR - when there is a loading error
*/
package com.oddcast.workshop {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.utils.XMLLoader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class BGList extends EventDispatcher {
		private var isProcessing:Boolean;
		private var arr:Array;
		/* flag indicatin if the list is downloaded already */
		public var list_loaded:Boolean = false;
		
		public function BGList() {
			arr = new Array();
		}
		
		public function load_backgrounds( _callbacks:Callback_Struct = null ):void
		{
			if (!isProcessing && !list_loaded)
			{
				isProcessing = true;
				var url:String = ServerInfo.acceleratedURL + "php/vhss_editors/getBackgrounds/doorId=" + ServerInfo.door;
				//Gateway.download_XML(new Gateway_Request( url, new Callback_Struct( fin, progress, error )));
				Gateway.retrieve_XML( url, new Callback_Struct( fin, progress, error ));
				function fin( _content:XML ):void 
				{	
					parseBGs( _content );
					isProcessing = false;
					list_loaded = true;
					dispatchEvent(new Event(Event.COMPLETE));
					if (_callbacks && _callbacks.fin != null)	_callbacks.fin(  );
				}
				function progress( _percent:int ):void
				{
					if (_callbacks && _callbacks.progress != null)	_callbacks.progress( _percent );
				}
				function error( _msg:String ):void 
				{	
					dispatchEvent( new AlertEvent(AlertEvent.ERROR, 'f9t310', 'Error loading backgrounds list', { details:_msg } ));
					if (_callbacks && _callbacks.error != null)	_callbacks.error( _msg );
				}
			}
		}
				
		private function parseBGs(_xml:XML) 
		{
			arr = new Array();
			var item		:XML;
			var bg			:WSBackgroundStruct;
			var baseUrl		:String					= _xml.@BASEURL;
			var bgUrl		:String;
			var thumbUrl	:String;
			var default_bg	:Boolean				= true;	// these are all default backgrounds to avoid cropping or editting them
			for (var i:int = 0; i < _xml.BG.length(); i++) 
			{
				item		= _xml.BG[i];
				bgUrl		= item.@FILENAME.toString();
				
				if (bgUrl.indexOf("http://") != 0)	bgUrl = baseUrl + bgUrl;
				
				thumbUrl	= item.@THUMB.toString();
				bg			= new WSBackgroundStruct(bgUrl, parseInt(item.@ID.toString()), thumbUrl, item.@DESC.toString(), 0, 0, default_bg);
				arr.push(bg);
			}
			return(arr);
		}
		
		public function get bgArr():Array {
			return(arr);
		}
		
		public function getBGByName(name:String):WSBackgroundStruct {
			var bg:WSBackgroundStruct;
			for (var i:int = 0; i < arr.length; i++) {
				bg = arr[i];
				if (bg.name == name) return(bg);
			}
			return(null);
		}
	}
	
}
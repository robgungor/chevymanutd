package com.oddcast.utils
{
	
	import com.oddcast.utils.XMLLoader;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	public class CaptionManager
	{
		private static var _arCaptions:Array;		
		
		protected static var disp:EventDispatcher;
    	public static function addEventListener(p_type:String, p_listener:Function, p_useCapture:Boolean=false, p_priority:int=0, p_useWeakReference:Boolean=false):void {
			if (disp == null) { disp = new EventDispatcher(); }
			disp.addEventListener(p_type, p_listener, p_useCapture, p_priority, p_useWeakReference);
		}
		public static function removeEventListener(p_type:String, p_listener:Function, p_useCapture:Boolean=false):void {
			if (disp == null) { return; }
			disp.removeEventListener(p_type, p_listener, p_useCapture);
		}
		public static function dispatchEvent(p_event:Event):void {
			if (disp == null) { return; }
			disp.dispatchEvent(p_event);
		}
		
		public static function init():void
		{
			_arCaptions = new Array();
		}
		
		public static function load(url:String):void
		{			
			XMLLoader.loadXML(url,CaptionManager.parseCaptions);			
		}
		
		public static function parseCaptions(vXml:XML):void
		{
			var captionsList:XMLList = vXml.child("CAPTION");
			var item:XML;
			for each(item in captionsList)
			{
				if (_arCaptions[item.@NAME]==undefined) //if a caption was set manually don't overwrite it
				{
					_arCaptions[item.@NAME] = (item.@CAPS=="true")?String(item.@TEXT).toUpperCase():item.@TEXT;
				}
			}			
			CaptionManager.dispatchEvent(new Event(Event.COMPLETE));			
		}
		
		public static function setCaption(s:String,val:String):void
		{
			//trace(" setCaption "+s+", val="+val);
			_arCaptions[s] = val;
		}
		
		public static function getCaption(s:String):String
		{
			//trace("   getCaption("+s+")="+_arCaptions[s]);		
			return _arCaptions[s];
		}
		
		public static function traceAll():void
		{
			for (var i in _arCaptions)
			{
				trace(i+"->"+_arCaptions[i]);
			}
		}
	}
}
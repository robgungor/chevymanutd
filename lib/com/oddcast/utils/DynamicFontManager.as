package com.oddcast.utils
{
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.LoaderInfo
	import com.oddcast.utils.IDynamicFont;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class DynamicFontManager 
	{
		protected static var disp:EventDispatcher;
		private static var _arrFonts:Array;
		private static var _iFontsToLoad:int;
		private static var _arrFontsToLoad:Array;
		
		private static function init():void
		{
			if (_arrFonts == null)
			{
				_arrFonts = new Array();
			}
		}
		
		private static function fontLoaded(evt:Event):void
		{			
			var loader : Loader = (evt.target as LoaderInfo).loader;
			// remove events
			loader.contentLoaderInfo.removeEventListener(Event.INIT,fontLoaded);
			loader.content.addEventListener("font_registered", fontReady);			
		}
		
		private static function fontReady(evt:Event):void
		{
			if (_iFontsToLoad == 1)
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				_iFontsToLoad--;
				loadFontFile(_arrFontsToLoad[_iFontsToLoad - 1]);
			}
		}
		
		public static function loadFonts(filenames:Array):void
		{
			init();
			_iFontsToLoad = filenames.length;
			loadFontFile(filenames[_iFontsToLoad-1]);
			_arrFontsToLoad = filenames;
			
		}
		
		public static function loadFont(filename:String):void
		{
			init();
			if (_arrFonts[escape(filename)] == null)
			{
				_iFontsToLoad = 1;
				loadFontFile(filename);
				
			}
			else
			{
				fontReady(null);
			}
		}
		
		private static function loadFontFile(filename:String):void
		{
			if (_arrFonts[escape(filename)] == null)
			{
				var loader : Loader = new Loader();
				var ctx:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
				loader.contentLoaderInfo.addEventListener(Event.INIT, fontLoaded);
				_arrFonts[escape(filename)] = loader;
				loader.load(new URLRequest(filename),ctx);
			}
			else
			{
				fontReady(null);
			}
		}
		
		public static function applyFont(tf:TextField, filename:String, size:Number = 0):void
		{			
			//trace("DynamicFontManager::applyFont " + tf.text );
			//trace("DynamicFontManager::" + escape(filename));
			/*
			for (var i in _arrFonts)
			{
				trace("DynamicFontManager:: i=" + i);
			}
			*/
			var fmt:TextFormat = tf.getTextFormat()
			if (fmt != null)
			{
				//trace(fmt.font);				
				fmt.font = IDynamicFont(Loader(_arrFonts[escape(filename)]).content).getFontName();
				if (size > 0)
				{
					fmt.size = size;
				}
				tf.setTextFormat(fmt);
				tf.embedFonts = true;
			}
		}
		
		
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
	}
	
}
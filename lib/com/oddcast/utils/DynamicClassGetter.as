package com.oddcast.utils
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	/**
	* ...
	* @author Jonathan Achai
	*/
	public class  DynamicClassGetter extends EventDispatcher
	{
		private var loader:Loader;
		
		public function load($url:String, $lc:LoaderContext = null):void
		{
			trace("DynamicClassGetter::load "+$url);
			loader = new Loader();
			var req:URLRequest = new URLRequest($url);
			var ctx:LoaderContext = ($lc == null) ? new LoaderContext() : $lc;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fileLoaded);
			loader.load(req, ctx);			
		}
		
		public function getClass(name:String):Class
		{
			if (loader.contentLoaderInfo.applicationDomain.hasDefinition(name))
			{				
				return loader.contentLoaderInfo.applicationDomain.getDefinition(name) as Class;
			}
			else
			{ 
				return null;
			}
		}
		
		public function getInstance(name:String):Object
		{
			if (loader.contentLoaderInfo.applicationDomain.hasDefinition(name))
			{
				var theClass:Class = loader.contentLoaderInfo.applicationDomain.getDefinition(name) as Class;
				return new theClass();
			}
			else
			{
				return null;
			}
		}
		
		public function doesClassExists(name:String):Boolean
		{
			return loader.contentLoaderInfo.applicationDomain.hasDefinition(name);
		}
		
		private function fileLoaded(evt:Event):void  
		{			
			trace("DynamicClassGetter::fileLoaded"); 
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
	
}
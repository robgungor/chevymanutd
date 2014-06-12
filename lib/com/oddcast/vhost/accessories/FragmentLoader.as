package com.oddcast.vhost.accessories
{
	import flash.events.EventDispatcher;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import com.oddcast.event.FragmentEvent;
	
	public class FragmentLoader extends EventDispatcher
	{
		private var _loader:Loader;
		private var _oData:Object;
		private var _appDomain:ApplicationDomain;
		private var _url:String;
		private var _content:MovieClip;
		private var _apiFragment:*;
		private var _oResourceData:Object;
		
		function FragmentLoader(url:String,o:Object)
		{
			_loader = new Loader();
			_appDomain = new ApplicationDomain();
			_oData = o;
			_url = url;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,fragmentLoaded);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,fragmentLoadError);
					
			/*
			var _fragLoader:Loader = new Loader();
			trace("AccessoryGroup::setAccessory 10");
			var fragAppDomain:ApplicationDomain = new ApplicationDomain();								
			_fragLoader.contentLoaderInfo.parameters.loadAs = newMC; //use this movieclip for data after loaded
			_fragLoader.contentLoaderInfo.parameters.appDomain = fragAppDomain;
			_fragLoader.contentLoaderInfo.parameters.test = "test";
			trace("AccessoryGroup::setAccessory 11");
			_fragLoader.contentLoaderInfo.addEventListener(Event.INIT,onLoadInit);
			_fragLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);								
			var _urlReq:URLRequest = new URLRequest(fragUrl);
			var _fragLoaderContext:LoaderContext = new LoaderContext(false,fragAppDomain);
			_fragLoader.load(_urlReq,_fragLoaderContext);				
			*/
		}
		
		public function load():void
		{
			var _loaderContext:LoaderContext = new LoaderContext(false,_appDomain);
			var _urlReq:URLRequest = new URLRequest(_url);	
			_loader.load(_urlReq,_loaderContext);
		}
		
		public function getData(name:String):*
		{
			return _oData[name];
		}
		
		public function getResourceData(name:String):*
		{
			return _oResourceData[name];
		}				
		
		public function getContent():MovieClip
		{
			return _content;
		}
				
		
		private function fragmentLoaded(evt:Event):void
		{			
			var fragClass:Class = _appDomain.getDefinition("Fragment") as Class;			
			_content =  MovieClip(new fragClass());
			
			var apiClass:Class = _appDomain.getDefinition("API") as Class
			_apiFragment = new apiClass();			
			if (String(_apiFragment.getData()).length>0)
			{
				_oResourceData = Object(new URLVariables(_apiFragment.getData()));					
			}
			else
			{
				_oResourceData = new Object();
			}
			
			dispatchEvent(new FragmentEvent(FragmentEvent.FRAGMENT_LOADED,this));
		}
		
		private function fragmentLoadError(evt:IOErrorEvent):void
		{
			dispatchEvent(new FragmentEvent(FragmentEvent.FRAGMENT_LOAD_ERROR,evt));
		}
		
	}
}
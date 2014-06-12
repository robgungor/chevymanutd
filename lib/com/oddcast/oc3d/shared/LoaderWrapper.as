package com.oddcast.oc3d.shared
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	public class LoaderWrapper
	{
		private var _loader:*; //can be either a Loader or URLLoader
		private var _contFn:Function;
		private var _failFn:Function;
		private var _progressFn:Function;
		private var _type:String;
		private var _url:String;
		private var _byteArray:ByteArray;
		private var _sErrorState:String;
		
		private static const LOADERS_TYPES:Array = [DBContentDataProviderFilesManager.TYPE_BITMAPDATA, DBContentDataProviderFilesManager.TYPE_SWF];
		private static const URLLOADERS_TYPES:Array = [DBContentDataProviderFilesManager.TYPE_BINARY, DBContentDataProviderFilesManager.TYPE_STRING];
		private static const SOUNDLOADERS_TYPES:Array = [DBContentDataProviderFilesManager.TYPE_AUDIO];
		
		public function LoaderWrapper(type:String)
		{
			
			_type = type;			
			if (URLLOADERS_TYPES.indexOf(_type)>=0)
			{
				_loader = new URLLoader();
				if (_type==DBContentDataProviderFilesManager.TYPE_BINARY)
				{					
					_loader.dataFormat = URLLoaderDataFormat.BINARY;				
				}
				return;
			}
			
			if (LOADERS_TYPES.indexOf(_type)>=0)
			{
				_loader = new Loader();
				return;
			}
			
			if (SOUNDLOADERS_TYPES.indexOf(_type)>=0)
			{
				_loader = new Sound();
				return;
			}
			
			_sErrorState = "LoaderWrapper::Unknown Type "+type
			
		}
		
		public function loadUrl(url:String,contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			trace("LoaderWrapper:loadUrl "+url);
			_url = url;
			load(contFn, failFn, progressFn);
		}
		
		public function loadData(ba:ByteArray, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			_byteArray = ba;
			load(contFn, failFn, progressFn);
			
		}
		
		private function load(contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			if (_sErrorState!=null)
			{
				if (failFn!=null)	
				{
					failFn(_sErrorState);
				}
				destroy();
				
			}
			_contFn = contFn;
			_failFn = failFn;
			_progressFn = progressFn;
			initListeners();
			if (_byteArray != null)
			{
				
				if (_loader is Loader)
				{					
					_loader.loadBytes(_byteArray);
				}
				else
				{
					DBContentDataProviderFilesManager.genericFailFn("LoaderWrapper does not support loading data from byteArray for this type", failFn);					
				}
			}
			else
			{		
				if (_loader is Sound)
				{
					var slc:SoundLoaderContext = new SoundLoaderContext();
					slc.checkPolicyFile = true;
					_loader.load(new URLRequest(_url), slc);	
				}
				else
				{
					_loader.load(new URLRequest(_url));
				}
			}
		}
		
		public function getApplicationDomain():ApplicationDomain
		{
			if (_loader is Loader)
				return _loader.contentLoaderInfo.applicationDomain;
			else
				return null;
		}
		
		public function destroy():void
		{
			removeListeners();
			_loader = null;
			_contFn = null;
			_failFn = null;
			_progressFn = null;
			_type = null;
			_url = null;
			_byteArray = null;
			_sErrorState = null;
		}
		
		private function completeListener(e:Event):void
		{
			trace("LoaderWrapper:completeListener "+_url+" ("+_type+")");
			switch (_type)
			{
				case DBContentDataProviderFilesManager.TYPE_BINARY:
					
					var ba:ByteArray = ByteArray(_loader.data);
					trace("ba.length="+ba.length);
					_contFn(ba);
					break;
				case DBContentDataProviderFilesManager.TYPE_STRING:
					var s:String = unescape(String(_loader.data));
					_contFn(s);					
					break;
				case DBContentDataProviderFilesManager.TYPE_BITMAPDATA:
					var bmpData:BitmapData = Bitmap(_loader.content).bitmapData;
					_contFn(bmpData);
					break;
				case DBContentDataProviderFilesManager.TYPE_SWF:					
					_contFn(MovieClip(_loader.content));
					break;
				case DBContentDataProviderFilesManager.TYPE_AUDIO:
					_contFn(_loader);
					break;
					
			}
			destroy();
		}
		
		private function initListeners():void
		{
			if (_loader is Loader)
			{
				_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressListener);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorListener);
				_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorListener);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListener);	
			}
			else if (_loader is URLLoader || _loader is Sound)
			{
				_loader.addEventListener(ProgressEvent.PROGRESS, progressListener);
				_loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorListener);
				_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorListener);
				_loader.addEventListener(Event.COMPLETE, completeListener);	
			}			
		}
		
		private function removeListeners():void
		{
			if (_loader is Loader)
			{
				_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressListener);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorListener);
				_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorListener);
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeListener);
			}
			else if (_loader is URLLoader || _loader is Sound)
			{
				_loader.removeEventListener(ProgressEvent.PROGRESS, progressListener);
				_loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorListener);
				_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorListener);
				_loader.removeEventListener(Event.COMPLETE, completeListener);
			}
		}
		
		
		
		private function securityErrorListener(e:SecurityErrorEvent):void
		{
			DBContentDataProviderFilesManager.genericFailFn(e.toString(), _failFn);			
			destroy();
		}
		
		private function ioErrorListener(e:IOErrorEvent):void
		{
			DBContentDataProviderFilesManager.genericFailFn(e.toString(), _failFn);	
			if (_failFn!=null)			
			destroy();
		}
		
		private function progressListener(e:ProgressEvent):void
		{
			if (_progressFn!=null)
			{
				_progressFn(e.bytesLoaded,e.bytesTotal);
			}
		}
	}
		
}
package com.oddcast.video {
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SimpleSWFPlayer extends Sprite {
		private var loader:Loader;
		private var swf:MovieClip;
		
		private var loadedUrl:String
		private var vidW:Number=0;
		private var vidH:Number = 0;
		
		public function SimpleSWFPlayer(w:Number=0,h:Number=0) {
			loader = new Loader();
			addChild(loader);
			if (w > 0 && h > 0) setDimensions(w, h);
		}
		public function setDimensions(w:Number, h:Number) {
			vidW = w;
			vidH = h;
		}
		public function load($url:String) {
			if ($url == loadedUrl) {
				dispatchEvent(new Event("ready"));
			}
			else {
				loadedUrl = $url;
				loader.contentLoaderInfo.addEventListener(Event.INIT, onLoaded);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
				try {
					loader.load(new URLRequest(loadedUrl));					
				} catch (e:Error) {
					onLoadError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
				}
			}
		}
		private function onLoaded(evt:Event) {
			loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoaded);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			
			swf = loader.content as MovieClip;
			swf.stop();
			if (vidW > 0) swf.width = vidW;
			if (vidH > 0) swf.height = vidH;
			dispatchEvent(new Event("ready"));
		}
		private function onLoadError(evt:ErrorEvent) {
			loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoaded);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			
			trace("onLoadError : " + evt.text);
		}
		public function play($url:String = null) {
			if (swf!=null) {
				swf.addEventListener(Event.ENTER_FRAME, enterFrame);
				swf.gotoAndPlay(1);
			}
		}
		public function stop() {
			if (swf != null) {
				swf.removeEventListener(Event.ENTER_FRAME, enterFrame);
				swf.gotoAndStop(1);
			}
		}
		public function unload() {
			loader.unload();
		}
		private function enterFrame(evt:Event) {
			if (swf.currentFrame == swf.totalFrames) {
				dispatchEvent(new Event("complete"));
				stop();
			}
		}
	}
	
}
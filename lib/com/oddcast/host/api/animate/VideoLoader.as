package com.oddcast.host.api.animate {
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.geom.Point;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import com.oddcast.host.api.animate.IAnimationDriver;
	import flash.media.Video;
	import flash.events.Event;
	import com.oddcast.host.api.IHostAPI;
	import flash.display.DisplayObject;
	
	public class VideoLoader extends flash.display.Loader implements com.oddcast.host.api.animate.IAnimationDriver{
		public function VideoLoader() : void {  {
			super();
		}}
		
		public var aHostAPI : Array;
		protected var paused : Boolean;
		public function getPaused() : Boolean {
			return this.paused;
		}
		
		public function setPaused(p : Boolean) : void {
			if(this.isReady()) {
				if(p) this.mc.stop();
				else this.mc.play();
				this.pauseAudio(p);
			}
			this.paused = p;
		}
		
		protected var dirty : Boolean;
		public override function load(request : flash.net.URLRequest,context : flash.system.LoaderContext = null) : void {
			super.load(request,context);
			this.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,this.videoLoadedHandler);
			this.contentLoaderInfo.addEventListener(flash.events.Event.INIT,this.videoInitedHandler);
			this.aHostAPI = new Array();
		}
		
		public function setSegment(startFrame : int,endFrame : int) : void {
			null;
		}
		
		protected function videoInitedHandler(event : flash.events.Event) : void {
			this.contentLoaderInfo.removeEventListener(flash.events.Event.INIT,this.videoInitedHandler);
			this.mc = (flash.display.MovieClip)(this.content);/*
				var $r : flash.display.MovieClip;
				var $t : flash.display.DisplayObject = $this.content;
				if(is($t,flash.display.MovieClip)) (($t) as flash.display.MovieClip);
				else throw "Class cast error";
				$r = $t;
				return $r;
			*/
			var loaderInfo : flash.display.LoaderInfo = this.mc.loaderInfo;
			this.fps = loaderInfo.frameRate;
			null;
			this.mc.addEventListener(flash.events.Event.ENTER_FRAME,this.onEnterVideoFrame);
			this.mc.gotoAndStop(0);
		}
		
		protected function videoLoadedHandler(event : flash.events.Event) : void {
			this.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE,this.videoLoadedHandler);
			this.dispatchEvent(new flash.events.Event(flash.events.Event.COMPLETE));
		}
		
		public function isReady() : Boolean {
			return this.getMC() != null;
		}
		
		public function getMC() : flash.display.MovieClip {
			return this.mc;
		}
		
		public function getVideo() : flash.media.Video {
			if(this.isReady()) {
				var _g1 : int = 0, _g : int = this.mc.numChildren;
				while(_g1 < _g) {
					var iChild : int = _g1++;
					var dObj : flash.display.DisplayObject = this.mc.getChildAt(iChild);
					try {
						var retval : flash.media.Video = (flash.media.Video)(dObj);/*
							var $r : flash.media.Video;
							var $t : flash.display.DisplayObject = dObj;
							if(is($t,flash.media.Video)) (($t) as flash.media.Video);
							else throw "Class cast error";
							$r = $t;
							return $r;
						*/
						return retval;
					}
					catch( e : * ){
						null;
					}
				}
			}
			return null;
		}
		
		public function getVideoDimensions() : flash.geom.Point {
			var vid : flash.media.Video = this.getVideo();
			if(vid != null) return new flash.geom.Point(vid.width,vid.height);
			return null;
		}
		
		public function play(frame : int = 0) : void {
			this.setPaused(false);
			if(this.mc != null) this.getMC().gotoAndPlay(frame);
		}
		
		protected function onEnterVideoFrame(event : flash.events.Event) : void {
			if(this.mc != null) this.forceHostUpdate();
		}
		
		public function addHostAPI(hostAPI : com.oddcast.host.api.IHostAPI) : void {
			this.aHostAPI.push(hostAPI);
		}
		
		public function removeHostAPI(hostAPI : com.oddcast.host.api.IHostAPI) : void {
			this.aHostAPI.remove(hostAPI);
		}
		
		public function forceHostUpdate() : void {
			if(!this.paused || this.dirty) {
				this.dirty = false;
				if(this.aHostAPI != null) {
					var _g : int = 0, _g1 : Array = this.aHostAPI;
					while(_g < _g1.length) {
						var hostAPI : com.oddcast.host.api.IHostAPI = _g1[_g];
						++_g;
						hostAPI.forceOneFrameUpdate();
						null;
					}
				}
			}
		}
		
		public function pauseAudio(pause : Boolean) : void {
			if(this.aHostAPI != null) {
				var _g : int = 0, _g1 : Array = this.aHostAPI;
				while(_g < _g1.length) {
					var hostAPI : com.oddcast.host.api.IHostAPI = _g1[_g];
					++_g;
					hostAPI.pauseAudio(pause);
				}
			}
		}
		
		public function setDirty() : void {
			this.dirty = true;
		}
		
		public function isActive() : Boolean {
			return true;
		}
		
		public function getCurrFrame() : int {
			if(!this.isReady()) return 0;
			return this.mc.currentFrame;
		}
		
		public function getCurrTime(offsetMillis : Number = 0.0,desc : String = null) : Number {
			return this.frameToTime(this.getCurrFrame());
		}
		
		public function setCurrFrame(frame : int) : void {
			this.setDirty();
			if(this.mc != null) {
				this.mc.gotoAndPlay(frame);
				if(this.paused) this.mc.stop();
			}
		}
		
		public function setCurrTime(time : Number) : void {
			this.setCurrFrame(this.timeToFrame(time));
		}
		
		protected function frameToTime(frame : int) : Number {
			return (frame - 1) / this.fps;
		}
		
		protected function timeToFrame(time : Number) : int {
			return Math.floor((time + 0.01) * this.fps) + 1;
		}
		
		public function timeToFrameInclusive(time : Number) : int {
			return Math.ceil((time + 0.01) * this.fps) + 1;
		}
		
		public override function unload() : void {
			if(this.mc != null) {
				this.mc.stop();
				this.mc.removeEventListener(flash.events.Event.ENTER_FRAME,this.onEnterVideoFrame);
				this.mc = null;
			}
			this.aHostAPI = null;
			super.unload();
		}
		
		protected var mc : flash.display.MovieClip;
		public var fps : Number;
		static public var TIME_ROUNDING_ERROR : Number = 0.01;
	}
}

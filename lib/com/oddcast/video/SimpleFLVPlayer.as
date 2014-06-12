package com.oddcast.video {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SimpleFLVPlayer extends Sprite {
		private var v:Video;
		private var conn:NetConnection;
		private var stream:NetStream;
		private var urlToLoad:String;
		private var loadedUrl:String;
		
		private var _duration:Number;
		private var _origWidth:Number;
		private var _origHeight:Number;
		private var _framerate:Number;
		
		public function SimpleFLVPlayer(w:Number=0,h:Number=0) {
			v=new Video();
			addChild(v);
			if (w > 0 && h > 0) setDimensions(w, h);
		}
		
		public function setDimensions(w:Number, h:Number) {
			v.width = w;
			v.height = h;
		}
		
		private function initStream() {
			conn=new NetConnection();
			conn.connect(null);
			stream=new NetStream(conn);
			stream.client={onMetaData:onMetaData,onCuePoint:onCuePoint,onPlayStatus:onPlayStatus};
			stream.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
			v.attachNetStream(stream);
		}
		
		public function load(url:String) {
			urlToLoad = url;
		}
		
		private function removeVideo() {
			if (stream!=null) {
				stream.pause();
				v.visible=false;
			}
		}
		
		public function play() {
			if (urlToLoad==null) return;
			if (stream == null) initStream();
			//trace("SimpleFLVPlayer::play - urlToLoad=" + urlToLoad + "  loadedUrl=" + loadedUrl);
			if (loadedUrl==urlToLoad) {
				stream.resume();
				stream.seek(0);
			}
			else {
				stream.play(urlToLoad)
				loadedUrl=urlToLoad;
			}
		}
		
		public function pause() {
			if (stream==null) return;
			stream.pause();
		}
		
		public function unload() {
			stream.close();
		}
		
		private function onStatus(evt:NetStatusEvent) {
			trace("netstatus: "+evt.info.level+" - "+evt.info.code);
		}
		private function onPlayStatus(info:Object) {
			trace("netstatus: "+info.level+" - "+info.code);
			if (info.code.indexOf("Complete")>=0) {
				dispatchEvent(new Event("complete"));
			}
		}
		
		private function onMetaData(info:Object):void {
			trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
			dispatchEvent(new Event("onMetaData"));
			
			_duration = info.duration;
			_origWidth = info.width;
			_origHeight = info.height;
			_framerate = info.framerate;
		}
		
		public function get duration():Number { return(_duration); }
		public function get origWidth():Number { return(_origWidth); }
		public function get origHeight():Number { return(_origHeight); }
		public function get framerate():Number { return(_framerate); }
		
		private function onCuePoint(info:Object):void {
			trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
		
	}
	
}
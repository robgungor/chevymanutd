/**
* ...
* @author Default
* @version 0.1
*/

package com.oddcast.audio {
	import com.oddcast.event.AlertEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	public class AudioPlayer extends EventDispatcher {
		private var sound:Sound;
		private var channel:SoundChannel;
		private var playOnLoad:Boolean;
		private var curTime:Number=0;
		
		private var curStatus:String;
		
		public static const NO_AUDIO:String="noAudio";
		public static const LOADING:String="loading";
		public static const STOPPED:String="stopped";
		public static const PLAYING:String="playing";
		
		public static const SOUND_STARTED:String="soundStarted";
		public static const SOUND_LOADED:String="soundLoaded";
		
		public function AudioPlayer() {
			curStatus = NO_AUDIO;
		}
		
		public function load($url:String) {
			if (curStatus==PLAYING) stop();
			if ($url==url||$url==null) {
				dispatchEvent(new Event(SOUND_LOADED));
				return;
			}
			
			loadAudio($url,false);
		}
		
		public function play($url:String=null) {
			//trace("AudioPlayer::play");
			if ($url==null||$url==url) {
				if (curStatus==STOPPED) playAudio();
			}
			else {
				if (curStatus==PLAYING) stop();
				loadAudio($url,true);
			}
		}
		
		public function unload() {
			if (sound != null) {
				try {
					sound.close();
				} catch (err:Error) {
					onError(err);
				}
				sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				sound.removeEventListener(Event.COMPLETE, soundLoaded);
			}
			if (channel != null) {
				channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
				channel = null;
			}
			curTime = 0;
			curStatus = NO_AUDIO;
			
		}
		
		private function loadAudio($url:String,$playOnLoad:Boolean) {
			playOnLoad = $playOnLoad;
			curTime = 0;
			curStatus = LOADING;
			sound = new Sound();
			sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			sound.addEventListener(Event.COMPLETE,soundLoaded);			
			try {
				sound.load(new URLRequest($url));
			}
			catch (err:Error) {
				onError(err);
			}
		}
		
		private function playAudio() {
			curStatus=PLAYING;
			channel=sound.play(curTime);
			channel.addEventListener(Event.SOUND_COMPLETE,soundComplete,false,0,true);
			dispatchEvent(new Event(SOUND_STARTED));
		}
		
		public function stop() {
			curTime = 0;
			stopAudio();
		}
		
		private function stopAudio() {			
			if (curStatus==PLAYING) {
				channel.stop();
				curStatus = STOPPED;
			}
			else if (curStatus==LOADING) playOnLoad=false;
		}
		
		public function pause() {
			curTime = position;
			stopAudio();
		}
		
		public function get url():String {
			if (sound==null) return(null);
			else return(sound.url);
		}
		
		private function soundLoaded(evt:Event) {
			curStatus=STOPPED;
			dispatchEvent(new Event(SOUND_LOADED));
			if (playOnLoad) play();
		}
		
		private function soundComplete(evt:Event) {
			curStatus = STOPPED;
			curTime = 0;
			dispatchEvent(new Event(Event.SOUND_COMPLETE));
		}
		
		public function get status():String {
			return(curStatus);
		}
		public function get duration():Number {
			return(sound.length);
		}
		public function get position():Number {
			if (isPlaying) return(channel.position);
			else return(curTime);
		}
		public function set position(t:Number) {
			curTime = t;		
			if (status == PLAYING) {
				stopAudio();
				playAudio();
			}
		}
		
		public function get volume():Number {
			if (channel == null) return(0);
			else return(channel.soundTransform.volume);
			
		}
		
		public function set volume(v:Number) {
			if (channel == null) return;
			if (v < 0) v = 0;
			if (v > 1) v = 1;
			var trans:SoundTransform = channel.soundTransform;
			trans.volume = v;
			channel.soundTransform = trans;
		}
		
		public function get isPlaying():Boolean {
			return(status==PLAYING);
		}
		
		private function onIOError(evt:IOErrorEvent) {
			onError(new Error(evt.text));
		}
		
		private function onError(err:Error) {
			dispatchEvent(new AlertEvent(AlertEvent.ERROR, "", err.message));
		}
		
	}
	
}
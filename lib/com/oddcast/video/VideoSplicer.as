/**
*
* @author Sam Myer
* 
* VideoSplicer is a video player that uses 2 FLVPlayback objects to seamlessly play a queue of videos.  It takes
* VideoSpliceData objects which contain the url of the .flv video and the time in seconds of the crossfade
* at the beginning of the video (default 0).  It also has the ability to play a background audio while the
* videos are playing.  Most of the functions, properties and events are equivalent to those in the FLVPlayback class
* 
* ***** METHODS *****
* constructor(w,h)
* setSize(w,h)
* 
* addVideo(v:VideoSpliceData)
* setVideos(array of VideoSpliceData objects)
* 
* playVideo()
* pauseVideo()
* stopVideo()
* seek(timeInSeconds)
* 
* ***** PROPERTIES *****
* totalTime  -readonly
* playheadTime  -readonly
* state   -readonly  - this is equal to a String in flash's fl.video.VideoState class
* volume    -read/write  a number between 0 and 1
* 
* ***** EVENTS *****
* VideoEvent.READY - videos are preloaded.  note that this event will not be called if you try to load videos that are already preloaded
* VideoEvent.COMPLETE - the video queue is done playing
* VideoEvent.STATE_CHANGE - the video state has been changed.  the parameters for this event are the same as those sent from FLVPlayback
* VideoSplicer.VIDEO_CHANGED - the next video in the queue has started playing.  this event contains the vp property
* which is the position (0-based) in the queue of the video that has started (e.g. 0=first video)
*/

package com.oddcast.video {
	import com.oddcast.audio.AudioPlayer;
	import fl.video.FLVPlayback;
	import fl.video.MetadataEvent;
	import fl.video.VideoError;
	import fl.video.VideoEvent;
	import fl.video.VideoState;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class VideoSplicer extends Sprite {
		private var videoArr:Array; //array of VideoSpliceData objects
		private var videoPlayers:Array;  //array of FLVPlayback objects
		private var curVideo:int = 0;
		private var playerVideoIds:Array=[-1,-1];
		private var fadeTimer:Timer;
		private static const SWAP_CUE:String = "swap_cue";
		public static const VIDEO_CHANGED:String = "videoChanged";
		private var audioPlayer:AudioPlayer;
		//this is the last state the user requested : play, pause, or stop.  if the video reaches the end, this is reset
		//to stopped
		private var userRequestedState:String = VideoState.STOPPED;
		
		public function VideoSplicer(w:Number = 0, h:Number = 0) {
			fadeTimer = new Timer(100, 0);
			fadeTimer.addEventListener(TimerEvent.TIMER, fadeInterval);
			videoPlayers = new Array();
			var player:FLVPlayback;
			for (var i:int = 0; i < 2; i++) {
				player = new FLVPlayback();
				player.addEventListener(VideoEvent.READY, videoReady);
				player.addEventListener(VideoEvent.COMPLETE, videoComplete);
				player.addEventListener(VideoEvent.STATE_CHANGE, playerStateChange);
				addChild(player);
				videoPlayers.push(player);
				player.autoPlay = false;
				player.visible = false;
			}
			audioPlayer = new AudioPlayer();
			if (w > 0 && h > 0) setSize(w, h);
			videoArr = new Array();
		}
		
		public function setSize(w:Number, h:Number) {
			for (var i:int = 0; i < 2; i++) videoPlayers[i].setSize(w, h);
		}
		
		public function addVideo($video:VideoSpliceData) {
			var newVideoId:uint = videoArr.length;
			videoArr.push($video);
			preload();
		}
		
		public function addAudio($url:String) {
			audioPlayer.load($url);
		}
		
		private function preload() {
			var videosToLoad:Array = new Array();
			var i:int;
			var playerId:int;
			var playerFree:Array = [true, true];
			var nextFreePlayer:int;
			var player:FLVPlayback;
			
			for (i = curVideo; i < videoArr.length; i++) {
				if (i == -1) continue;
				playerId = getPlayerId(i);
				if (playerId>=0) {
					playerFree[playerId] = false;
				}
				else {
					playerId = playerFree.indexOf(true);
					if (playerId == -1) break; //no more free players
					playerFree[playerId] = false;
					player = videoPlayers[playerId];
					player.removeASCuePoint(SWAP_CUE);
					player.load(videoArr[i].url);
					playerVideoIds[playerId] = i;
					trace("videoPlayers[" + playerId + "].load(" + videoArr[i].url + ");");
				}
			}
			trace("preload done - " + playerVideoIds);
		}
		
		private function getPlayerId(videoId:int):int {
			if (playerVideoIds[0] == videoId) return(0);
			else if (playerVideoIds[1] == videoId) return(1);
			else return(-1);
		}
		
		private function getPlayer(videoId:int):FLVPlayback {
			var playerId:int = getPlayerId(videoId);
			if (playerId == -1) return(null);
			else return(videoPlayers[playerId]);
		}
		
		public function unload() {
			trace("unload::fadeTimer stop");
			fadeTimer.stop();
			setCurVideo(0);
			playerVideoIds = [ -1, -1];
			for (var i:int = 0; i < videoPlayers.length; i++) {
				if (videoPlayers[i].playing) videoPlayers[i].stop();
			}
			videoArr = new Array();
		}
		
		//add an array of VideoSpliceData objects
		public function setVideos($videos:Array) { 
			unload();
			videoArr = $videos;
			preload();
		}
		
		private function get isFading():Boolean {
			var player:FLVPlayback = getPlayer(curVideo);
			if (player == null) return(false);
			if (player.buffering) return(false);
			if (getPlayer(curVideo + 1) == null) return(false);
			var timeLeft:Number = player.totalTime - player.playheadTime;
			var boolFading:Boolean = (timeLeft>0&&timeLeft < videoArr[curVideo].spliceTime);
			trace("isFading === " + boolFading + " timeLeft=" + player.totalTime.toFixed(3) + " - " + player.playheadTime + "  splicetime=" + videoArr[curVideo].spliceTime);
			return(boolFading);
		}
		
		public function playVideo() {
			userRequestedState = VideoState.PLAYING;
			
			for (var i:int = 0; i < videoPlayers.length; i++) {
				videoPlayers[i].visible = false;
				videoPlayers[i].alpha=1;
			}
			
			if (curVideo == videoArr.length) setCurVideo(0);
			trace("ViceoSplicer::playvideo :: curPlayer="+getPlayerId(curVideo)+" curVideo="+curVideo);
			
			if (getPlayerId(curVideo) == -1) preload();
			trace(getPlayerId(curVideo) + ".play();");
			var player:FLVPlayback = getPlayer(curVideo);
			player.play();
			player.visible = true;
			
			audioPlayer.play();
			
			if (isFading) {
				trace("fade video : "+getPlayerId(curVideo+1) + ".play();");
				player = getPlayer(curVideo + 1)
				player.play();
				player.visible = true;
				addChildAt(player, numChildren);
				player.alpha = 0;
				trace("playVideo::fadeTimer start");
				fadeTimer.start();
			}
		}
		
		public function pauseVideo() {
			//if the video is buffering due to slow connection, the flvplayer thinks it is paused, so if you press pause
			//it won't dispatch the statechange event automatically.  this should to fix that problem
			var oldState:String = state;
			userRequestedState = VideoState.PAUSED;
			if (state != oldState) dispatchEvent(new VideoEvent(VideoEvent.STATE_CHANGE, false, false, state, playheadTime,curVideo));
			
			for (var i:int = 0; i < videoPlayers.length; i++) {
				videoPlayers[i].pause();
			}
			trace("pauseVideo::fadeTimer stop");
			fadeTimer.stop();
			audioPlayer.pause();
		}
		
		public function stopVideo() {
			userRequestedState = VideoState.STOPPED;
			
			for (var i:int = 0; i < videoPlayers.length; i++) {
				videoPlayers[i].stop();
			}
			setCurVideo(0);
			preload();
			trace("stopVideo::fadeTimer stop");
			fadeTimer.stop();
			audioPlayer.stop();
		}
		
		
		//****************** CALLBACKS ****************************
		
		
		private function videoReady(evt:VideoEvent) {
			trace("videoready time=" + evt.target.totalTime);
			var playerId:int = videoPlayers.indexOf(evt.target);
			if (playerId == -1) return;
			
			var totalTime:Number= evt.target.totalTime;
			if (videoArr == null || videoArr[playerId] == null) return;
			var spliceTime:Number = videoArr[playerId].spliceTime;
			videoArr[playerId].totalTime = totalTime;
			
			if (!isNaN(spliceTime)&&spliceTime>0) {
				evt.target.addASCuePoint( { name:SWAP_CUE, time:totalTime-spliceTime, type:"actionscript" } );
				evt.target.addEventListener(MetadataEvent.CUE_POINT, cuePoint);
			}
			
			if (playerId == 0) dispatchEvent(new VideoEvent(VideoEvent.READY));
		}
				
		private function videoComplete(evt:VideoEvent) {
			var playerId:int = videoPlayers.indexOf(evt.target);
			if (playerId == -1) return;
			//trace("video " + videoId + " complete");
			
			
			if (playerId != getPlayerId(curVideo)) {
				trace("WARNING :: Unexpected video ended");
				return;
			}
			
			setCurVideo(curVideo+1);
			preload();
			
			if (curVideo == videoArr.length) {
				userRequestedState = VideoState.STOPPED;
				dispatchEvent(new VideoEvent(VideoEvent.COMPLETE));
				audioPlayer.pause();
				trace("videoComplete::all done");
			}
			else {
				var thisPlayer:FLVPlayback = evt.target as FLVPlayback;
				var nextPlayer:FLVPlayback = getPlayer(curVideo);
				thisPlayer.visible = false;
				thisPlayer.alpha = 1;
				nextPlayer.visible = true;
				nextPlayer.play();
			}			
		}
		
		private function playerStateChange(evt:VideoEvent) {
			if (evt.target == getPlayer(curVideo)) {
				//sometimes the player returns "PAUSED" when it is buffering
				//this is to make sure we have the correct state:
				evt.state = state;
				dispatchEvent(evt);
			}
		}
		
		private function cuePoint(evt:MetadataEvent) {
			trace("REACHED CUE POINT!!  - curId="+curVideo);
			var nextPlayer:FLVPlayback = getPlayer(curVideo + 1);
			if (nextPlayer == null) return;
			addChildAt(nextPlayer, numChildren); //move to top
			nextPlayer.alpha = 0;
			nextPlayer.visible = true;
			nextPlayer.play();
			fadeTimer.reset();
			trace("cuePoint::fadeTimer start");
			fadeTimer.start();
		}
		
		//****************** UTILITY ****************
		
		private function fadeInterval(evt:TimerEvent) {
			var thisPlayer:FLVPlayback = getPlayer(curVideo);
			var nextPlayer:FLVPlayback = getPlayer(curVideo+1);
			if (!isFading) {
				trace("fadeInterval::fadeTimer stop");
				fadeTimer.stop();
				if (thisPlayer != null) thisPlayer.alpha = 1;
				if (nextPlayer != null) nextPlayer.alpha = 1;
			}
			else {
				var percent:Number = nextPlayer.playheadTime / videoArr[curVideo].spliceTime;
				if (percent > 1) percent = 1;
				if (percent < 0) percent = 0;
				trace("fade video " + curVideo+"  percent=" + percent.toFixed(2));				
				nextPlayer.alpha = percent;
			}
		}

		private function getAvgTime():Number {
			var totalCount:uint = 0;
			var totalTime:Number = 0;
			var i:int;
			for (i = 0; i < videoArr.length; i++) {
				if (!isNaN(videoArr[i].totalTime)) {
					totalTime += videoArr[i].totalTime;
					totalCount++;
				}
			}
			if (totalCount == 0) return(10); //totally arbitrary
			else return(totalTime / totalCount);
		}
				
		public function seek(time:Number) {
			var curState:String = state;
			var timeInfo:Object = getVideoAtTime(time);
			if (timeInfo == null) return;
			setCurVideo(timeInfo.id);
			var curVideoTime:Number = timeInfo.time;
			fadeTimer.stop();
			preload();
			
			audioPlayer.position = time;
			
			var player:FLVPlayback;
			for (var i = 0; i < videoPlayers.length; i++ ) {
				player = videoPlayers[i];
				if (playerVideoIds[i] == curVideo) {
					trace("player "+i+" : seek "+curVideoTime.toFixed(2)+"  state="+player.state)
					player.seek(curVideoTime);
					if (curState==VideoState.PLAYING) player.play();
					player.alpha = 1;
					player.visible = true;
				}
				else {
					trace("player " + i + " : stop  state="+player.state);
					player.stop();
					player.seek(0);
					player.visible = false;
				}
			}
			
		}
		
		private function getVideoAtTime(t:Number):Object {
			if (videoArr.length == 0) return(null);
			
			var avgTime:Number = getAvgTime();			
			var vidTime:Number;
			var vidStartTime:Number=0;
			var thisVidStart:Number;
			var videoId:int = -1;
			
			for (var i:int = 0; i < videoArr.length; i++) {
				trace("if (" + vidStartTime +"<= " + t + ") {");
				if (vidStartTime <= t) {
					thisVidStart = vidStartTime;
					videoId = i;
				}
				else break;
				
				vidTime = videoArr[i].totalTime;
				if (isNaN(vidTime)) vidTime = avgTime;
				vidStartTime += vidTime - videoArr[i].spliceTime;
			}
			
			var vidPlayTime:Number = t - thisVidStart;
			if (videoId<0||videoId>videoArr.length||isNaN(videoArr[videoId].totalTime)) vidPlayTime = 0;
			
			trace("SEEK id="+videoId+" time="+vidPlayTime);
			return({ id:videoId, time:vidPlayTime});
		}
		
		private function setCurVideo(videoId:uint) {
			if (curVideo == videoId) return;
			var oldState:String = state;
			curVideo = videoId;
			var newState:String = state;
			
			dispatchEvent(new VideoEvent(VIDEO_CHANGED, false, false, null, Number.NaN, curVideo));
			if (oldState != newState) {
				dispatchEvent(new VideoEvent(VideoEvent.STATE_CHANGE, false, false, newState,Number.NaN,curVideo));
			}
		}
		
		//*******************  PROPERTIES **********************
		
		public function get totalTime():Number {
			if (videoArr.length == 0) return(0);
			
			var avgTime:Number = getAvgTime();			
			var vidTime:Number;
			var spliceTime:Number;
			var vidStartTime:Number = 0;
			for (var i:int = 0; i < videoArr.length; i++) {
				vidTime = videoArr[i].totalTime;
				if (isNaN(vidTime)) vidTime = avgTime;
				spliceTime=videoArr[i].spliceTime;
				if (isNaN(spliceTime)) spliceTime = 0;
				vidStartTime += vidTime - spliceTime;
				//trace("totalTime - " + i + " vidtime=" + vidTime + " splcietime=" + spliceTime + " avgimte=" + avgTime + " starttime=" + vidStartTime);
			}
			return(vidStartTime);
		}
	
		public function get playheadTime():Number {
			if (videoArr.length == 0) return(0);
			
			var avgTime:Number = getAvgTime();			
			var vidTime:Number;
			var vidStartTime:Number=0;
			for (var i:int = 0; i < curVideo; i++) {
				vidTime = videoArr[i].totalTime;
				if (isNaN(vidTime)) vidTime = avgTime;
				vidStartTime += vidTime - videoArr[i].spliceTime;
			}
			
			if (getPlayer(curVideo) == null) return(vidStartTime);
			else return(vidStartTime+getPlayer(curVideo).playheadTime);
		}
		
		public function get state():String {
			if (curVideo == videoArr.length) return(VideoState.STOPPED);
			var curPlayer:FLVPlayback = getPlayer(curVideo);
			if (curPlayer == null) return(VideoState.DISCONNECTED);
			//when the video is buffering because the connection speed is too slow, the videoplayer returns "paused" instead
			//of buffering.  this is to fix that bug.
			else if (curPlayer.state == VideoState.PAUSED && userRequestedState != VideoState.PAUSED) return(VideoState.BUFFERING);
			else return(curPlayer.state);
		}
		
		public function get volume():Number {
			return(videoPlayers[0].volume);
		}
		public function set volume(v:Number) {
			for (var i:int = 0; i < 2; i++) videoPlayers[i].volume = v;
			audioPlayer.volume = v;
		}
		
		/*public function getStatusStr():String {
			var str:String = "____________STATUS_____________\n";
			str += "Time : " + playheadTime.toFixed(2) + " / " + totalTime.toFixed(2) + "   current video : "+curVideo+"\n";
			var player:FLVPlayback;
			var vidStartTime:Number;
			var vidEndTime:Number;
			for (var i:int = 0; i < videoPlayers.length; i++) {
				player = videoPlayers[i];
				if (i == 0) vidStartTime = 0;
				else vidStartTime = vidEndTime - videoArr[i - 1].spliceTime;
				vidEndTime = vidStartTime + player.totalTime;
				
				str += "Video " + i + " : state=" + player.state + "  time=" + player.playheadTime.toFixed(2) + " / " + player.totalTime.toFixed(2)+"   start/end="+vidStartTime.toFixed(2)+"-"+vidEndTime.toFixed(2)+"\n";				
			}
			
			return(str);
		}*/
	}
	
}
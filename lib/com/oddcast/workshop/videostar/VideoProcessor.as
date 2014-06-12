/**
* ...
* @author Default
* @version 0.1
* 
* 
* settings is an object optionally contatining the following variables:
* 
* audios:Array		-an array of AudioData objects
* images:Array		-an array of WSBackgroundStruct objects
* captions:Array	-an array of CaptionText objects
* aps:Object		-an associative array of parameters to be set in videostarconfiguration
* 
* 
* Here is an example of the new XML for video Star:
* 
* <VideoStarConfiguration version="1.0">
  <Clips>
    <Clip use-default-audio="false" name="bridezilla6" id="101" cutoffTime="5914">
      <Face>
        <Fg>http://host.oddcast.com/videostar/test.fg</Fg>
        <Name>man1</Name>
        <audio offset="0" duration="5914">http://url.to.audio/file.mp3</audio>
      </Face>
    </Clip>
  </Clips>
</VideoStarConfiguration>
*/

package com.oddcast.workshop.videostar {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.workshop.WSVideoStruct;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLVariables;

	public class VideoProcessor extends EventDispatcher {
		public var videoUrl:String;
		public var percentDone:Number;
		private var threadArr:Array;   //array of VideoProcessThread ojbects;
		private var threadsLeft:int = 0;
		
		public function VideoProcessor() {
			threadArr = new Array();
		}
		
		public function processVideo(videoArr:Array, $settings:Object = null) {
			if (videoArr == null) return;
			if (videoArr.length == 0) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t400", "No videos to process!"));
				return;
			}
			
			//this shuold be phased out - included here to support backwards compatibility
			if ($settings!=null) {
				var settings:VideoSettings = new VideoSettings();
				settings.aps = $settings.aps;
				settings.audios = $settings.audios;
				settings.captions = $settings.captions;
				settings.images = $settings.images;
				settings.bgImages=$settings.bgImages
				videoArr[0].settings = settings;
			}
			
			destroyThreads();
			
			var i:int;
			threadArr = new Array();
			var thread:VideoProcessThread;
			for (i = 0; i < videoArr.length;i++) {
				thread = new VideoProcessThread();
				thread.addEventListener(AlertEvent.EVENT, threadError,false,0,true);
				thread.addEventListener(ProgressEvent.PROGRESS, threadProgress,false,0,true);
				thread.addEventListener(Event.COMPLETE, threadComplete,false,0,true);
				thread.processVideo(videoArr[i]);
				threadArr.push(thread);
			}
			threadsLeft = videoArr.length;
		}
				
		public function destroyThreads() {
			if (threadArr == null) return;
			
			var thread:VideoProcessThread;
			for (var i:int = 0; i < threadArr.length; i++) {
				thread = threadArr[i];
				thread.removeEventListener(AlertEvent.EVENT, threadError);
				thread.removeEventListener(ProgressEvent.PROGRESS, threadProgress);
				thread.removeEventListener(Event.COMPLETE, threadComplete);
				thread.destroy();
			}
			threadArr = new Array();
		}
		
		private function threadError(evt:AlertEvent) {
			destroyThreads();
			dispatchEvent(evt);
		}
		
		private function threadProgress(evt:ProgressEvent) {
			var total:Number = 0;
			for (var i:int = 0; i < threadArr.length; i++) total += threadArr[i].percentDone;
			percentDone = total/threadArr.length;
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
		}
		
		private function threadComplete(evt:Event) {
			threadsLeft--;
			if (threadsLeft == 0) allThreadsComplete();
		}
		
		private function allThreadsComplete() {
			videoUrl = threadArr[0].getOutput().url;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function getOutput():Array {
			var outputArr:Array = new Array();
			for (var i:int = 0; i < threadArr.length; i++) {
				outputArr.push(threadArr[i].getOutput());
			}
			return(outputArr);
		}
	}
	
}
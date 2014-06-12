package com.oddcast.video {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class VideoSpliceData {
		public var url:String;
		public var name:String;
		public var spliceTime:Number;
		public var totalTime:Number;
		
		public function VideoSpliceData($url:String, $time:Number=0) {
			url = $url;
			spliceTime = $time;
		}
	}
	
}
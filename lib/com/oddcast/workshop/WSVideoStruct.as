/**
* ...
* @author Sam Myer
* @version 0.1
* 
* This is the data structure for videos.
* It's a version of the background struct class, extended for use with videostar.
* 
* ---videostarSource:
* 
* For videostar 1.0, the server returns a list of source videos.  The user selects a head and this is submitted to 
* the APS to create an end video.  The source video must be specified with the end video however.
* com.oddcast.workshop.videostar.VideoStruct is used to store the source video
* This class is used to store the end video.  the videostarSource variable is a reference to the source video.
*/

package com.oddcast.workshop {
	import com.oddcast.video.VideoSpliceData;
	import com.oddcast.workshop.videostar.VideoStruct;

	public class WSVideoStruct extends WSBackgroundStruct {
		private var videostarSourceStruct:VideoStruct; //this is the pre-photoface source video that was used
														//to create this videostar video
		public var duration:Number;  //in mSec
		public var spliceTime:Number;
		
		public function WSVideoStruct ($url:String,$id:int=0,$thumb:String=null,$name:String=null,$catId:int=0,$typeId:int=0) {
			super($url,$id,$thumb,$name,$catId,$typeId);
		}
		
		public function get isVideostar():Boolean {
			return(videostarSource != null);
		}
		
		public function get videostarSource():VideoStruct {
			return(videostarSourceStruct);
		}
		
		public function setVideostarSource(v:VideoStruct) : void {
			videostarSourceStruct = v;
			duration = v.duration;
		}
		
		public function get fileType():String {
			if (url == null || url.lastIndexOf(".") == -1) return(null);
			var extension:String;
			var dotPos:int;
			var questionMarkPos:int = url.lastIndexOf("?");
			if (questionMarkPos == -1) questionMarkPos = url.length;
			
			extension = url.slice(url.lastIndexOf(".",questionMarkPos) + 1,questionMarkPos);
			
			return(extension.toLowerCase());
		}
		
		/**
		 * this is a data structure used by the com.oddcast.video.VideoSplicer player (in the videostar 1.0 player).
		 * use this function to get an object you can pass to the player.
		 * @return
		 */
		public function getSpliceData():VideoSpliceData {
			var spliceData:VideoSpliceData = new VideoSpliceData(url, duration);
			spliceData.spliceTime = spliceTime;
			return(spliceData);
		}
		
	}
	
}
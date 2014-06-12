package com.oddcast.workshop.videostar {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class VideoCategory {
		public var id:int;
		public var title:String;
		public var description:String;
		public var thumbUrl:String;
		
		public function VideoCategory($id:int, $title:String="", $desc:String="", $thumbUrl:String=null) {
			id = $id;
			title = $title;
			description = $desc;
			thumbUrl = $thumbUrl;
		}
	}
	
}
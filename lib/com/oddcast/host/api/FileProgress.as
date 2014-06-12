package com.oddcast.host.api {
	
	public class FileProgress {
		public function FileProgress() : void {  {
			this.progress = 0.0;
			this.filesize = UNDETERMINED;
		}}
		
		public var progress : Number;
		public var filesize : int;
		static public var UNDETERMINED : int = -1;
	}
}

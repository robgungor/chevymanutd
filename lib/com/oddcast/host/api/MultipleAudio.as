package com.oddcast.host.api {
	
	public class MultipleAudio {
		public function MultipleAudio(url : String = null,offset : Number = NaN) : void {  {
			this.url = url;
			this.offset = offset;
			this.beatsync = 1.0;
			this.lipsync = 1.0;
		}}
		
		public var url : String;
		public var offset : Number;
		public var beatsync : Number;
		public var lipsync : Number;
	}
}

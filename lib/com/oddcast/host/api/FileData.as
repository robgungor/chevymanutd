package com.oddcast.host.api {
	import flash.utils.ByteArray;
	
	import com.oddcast.host.api.FileProgress;
	public class FileData extends com.oddcast.host.api.FileProgress {
		public function FileData(byteArray : flash.utils.ByteArray = null,extension : String = null) : void {  {
			super();
			this.byteArray = byteArray;
			this.extension = extension;
		}}
		
		public var byteArray : flash.utils.ByteArray;
		public var extension : String;
	}
}

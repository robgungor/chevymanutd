package com.oddcast.host.api.events {
	import com.oddcast.host.api.events.Event3D;
	import flash.events.Event;
	
	public class Event3DFileError extends com.oddcast.host.api.events.Event3D {
		public function Event3DFileError(filename : String = null,event : flash.events.Event = null,errorType : String = null,fileDesc : String = null) : void {  {
			this.filename = filename;
			this.errorType = errorType;
			this.fileDesc = fileDesc;
			super(EVENT3D_FILE_ERROR,event);
		}}
		
		public var filename : String;
		public var errorType : String;
		public var fileDesc : String;
		public override function toString() : String {
			return super.toString() + " fileDesc:" + this.fileDesc + " filename:" + this.filename + " errorType:" + this.errorType;
		}
		
		static public var EVENT3D_FILE_ERROR : String = "Event3DFileError";
		static public var IO_ERROR_EVENT : String = "IOErrorEvent";
		static public var SECURITY_ERROR_EVENT : String = "SecurityErrorEvent";
		static public var FILE_DESC_MP3 : String = "mp3";
		static public var FILE_DESC_CTL : String = "ctl";
		static public var FILE_DESC_FG : String = "fg";
		static public var FILE_DESC_IMG : String = "img";
		static public var FILE_DESC_ACC : String = "acc_";
	}
}

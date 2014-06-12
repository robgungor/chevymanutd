
package com.oddcast.event
{
	import flash.events.Event;

	public class ArchiverEvent extends Event{
						
		
		public static const ON_ERROR:String = "onArchvierError";
		public static const FILE_DOWNLOADED:String = "onArchiverFileDownloaded";
		public static const DOWNLOAD_COMPLETE:String = "onArchvierDownloadComplete";	
		public static const INDEX_DOWNLOADED:String = "onArchiverIndexDownloaded";	
		public static const ARCHIVE_UPLOADED:String = "onArchiverUploaded";			
		
		public var data:Object;
		
		public function ArchiverEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new ArchiverEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("ArchiverEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
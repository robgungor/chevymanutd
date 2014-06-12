package com.oddcast.oc3d.shared
{
	import com.oddcast.event.ArchiverEvent;
	import com.oddcast.io.archive.oa1.OA1File;
	import com.oddcast.io.archiver.OA1Archiver;
	import com.oddcast.io.archiver.OA1FileDesc;
	
	import flash.utils.ByteArray;

	public class ArchiverWrapper
	{
		private var _archiver:OA1Archiver;
		private var _contFn:Function;
		private var _failFn:Function;
		private var _progressFn:Function;
		private var _url:String;
		private var _byteArray:ByteArray;		
		private var _iFilesCount:int = 0;
		public var _iFilesTotal:int;
		
		public function ArchiverWrapper()
		{		
			_archiver = new OA1Archiver();
		}
		
		public function loadUrl(url:String,contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			trace("ArchiverWrapper:loadUrl "+url);
			_url = url;
			load(contFn, failFn, progressFn);
		}
		
		public function loadData(ba:ByteArray, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			_byteArray = ba;
			load(contFn, failFn, progressFn);
			
		}
		/*
		public function archiveCompletelyRead():Boolean
		{
			if (_url!=null)
			{
				trace("ArchiveWrapper "+_url+" completely read? "+(_iFilesCount==_iFilesTotal && _iFilesCount>0))
				return (_iFilesCount==_iFilesTotal && _iFilesCount>0);
			}
			else return false;
		}
		
		public function fileRead():void
		{		
			if (_url!=null)
			{
				_iFilesCount++;
				trace("ArchiveWrapper "+_url+" read:"+_iFilesCount+" of "+_iFilesTotal);
			}
			
		}
		*/
		public function getDataByName(s:String):*
		{
			var fileDesc:OA1FileDesc = _archiver.getFileByName(s)
			if (fileDesc!=null)
			{			
				_iFilesCount++;				
				return fileDesc.data;
			}
			return null;
		}
		
		private function load(contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			_contFn = contFn;
			_failFn = failFn;
			_progressFn = progressFn;				
			initListeners();
			if (_byteArray != null)
			{
				_archiver.extract(_byteArray);
				completeListener(null);
			}
			else
			{
				_archiver.load(_url);
			}
		}
						
		public function destroy():void
		{	
			removeListeners();
			if (_archiver!=null)
			{
				_archiver.destroy();
			}
			_archiver = null;
			_contFn = null;
			_failFn = null;
			_progressFn = null;
			_url = null;
			_byteArray = null;
		}
		
		private function completeListener(e:ArchiverEvent):void
		{
			trace("ArchiveWrapper:completeListener "+_url);//+" ("+_type+")");
			if (_archiver.getFilesArr()!=null)
			{
				var files:Array = _archiver.getFilesArr().slice();
				_iFilesTotal = files.length;
				if (_progressFn != null)
				{
					var ttl:uint = 0;
					for (var i:uint=0; i<files.length; ++i)
					{
						var desc:OA1FileDesc = OA1FileDesc(files[i]);
						if (desc.data is ByteArray)
							ttl += ByteArray(desc.data).length;
					}
					_progressFn(ttl, ttl);
				}
				_contFn(files);
			}
			else
			{
				if (_failFn!=null)
				{
					_failFn("Error while openning archive "+_url);
				}
				else
				{
					trace("Error while openning archive "+_url)
				}
				destroy();
			}
			//destroy();
		}
		
		private function initListeners():void
		{
			_archiver.addEventListener(ArchiverEvent.ON_ERROR, errorListener);
			_archiver.addEventListener(ArchiverEvent.FILE_DOWNLOADED, fileReadyListener);
			_archiver.addEventListener(ArchiverEvent.DOWNLOAD_COMPLETE, completeListener);
		}
		private function removeListeners():void
		{
			if (_archiver!=null)
			{
				_archiver.removeEventListener(ArchiverEvent.ON_ERROR, errorListener);
				_archiver.removeEventListener(ArchiverEvent.FILE_DOWNLOADED, fileReadyListener);
				_archiver.removeEventListener(ArchiverEvent.DOWNLOAD_COMPLETE, completeListener);
			}
		}
		
		private function fileReadyListener(e:ArchiverEvent):void
		{
			
		}
		
		private function errorListener(e:ArchiverEvent):void
		{
			if (_failFn!=null)
			{
				_failFn(e.toString());
			}
			else
			{
				trace(e.toString());
			}
			
			destroy();
		}
		
	}
}
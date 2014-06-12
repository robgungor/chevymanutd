package com.oddcast.io.archiver
{
	import com.oddcast.event.ArchiverEvent;
	import com.oddcast.io.archive.*;
	import com.oddcast.io.archive.oa1.OA1File;
	import com.oddcast.io.archive.oa1.ParsingArchiveOA1;
	import com.oddcast.utils.MultipartFormPoster;
	
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	
	public class OA1Archiver extends EventDispatcher
	{		
		private var _baArchive:ByteArray; //byte array which is going to get posted
		private var _usDownloadStream:URLStream; //byte stream whici is being downloaded
		private var _arrArchiveFiles:Array;		
		private var _bDownloading:Boolean;
		private var _oa1Parser:ParsingArchiveOA1
		private var _iVersion:int = 1;
		private var _arrOA1FileMap:Array;
		private var _isFirstFile:Boolean;
		public var _iLastStatus:int;
		private var _bErrorState:Boolean;
		private var formPoster:MultipartFormPoster;		
		private var _bDestroyed:Boolean;
		public static const OA1_SIGNATURE:String = "ODDARC01";
		
		public function OA1Archiver()
		{
			
		}
		
		public function load(s:String):void
		{
			_bDownloading = true;
			_arrArchiveFiles = new Array();	
			_isFirstFile = true;
			_usDownloadStream = new URLStream();
			configureListeners(_usDownloadStream);
			var req:URLRequest = new URLRequest(s);
			_usDownloadStream.load(req);											
		}				
		
		public function destroy():void
		{
			if (!_bDestroyed)
			{
				removeListeners(_usDownloadStream);
				_baArchive = null;
				_usDownloadStream = null;
				_arrArchiveFiles = null;
				_oa1Parser = null;
				_arrOA1FileMap = null;
				formPoster = null;
				_bDestroyed = true;
			}
		}
		
		public function extract(ba:ByteArray):void
		{
			_bDownloading = true;
			_arrArchiveFiles = new Array();	
			_isFirstFile = true;
			doParsing(ba);
		}
		
		public function createArchive():ByteArray
		{
			//preparing archive file
			_baArchive = new ByteArray();
			_baArchive.endian = Endian.LITTLE_ENDIAN;
			_baArchive.writeUTFBytes(OA1_SIGNATURE);
			_baArchive.writeInt(_iVersion);
			
			var indexXML:XML = fileIndexToXML();
			var indexOA1File:OA1File = new OA1File("index.xml");
			var indexOA1BA:ByteArray = new ByteArray();
			indexOA1BA.writeUTFBytes(indexXML);
			indexOA1File.fill(indexOA1BA,true);
			indexOA1File.serialize(_baArchive);
			
			for (var i:int=0; i<_arrOA1FileMap.length;++i)
			{
				var fdesc:OA1FileDesc = OA1FileDesc(_arrOA1FileMap[i]);
				var oa1File:OA1File = new OA1File(fdesc.name);
				var oa1BA:ByteArray;
				if (fdesc.isString)
				{
					oa1BA = new ByteArray();
					oa1BA.writeUTFBytes(fdesc.data);
				} 
				else
				{
					oa1BA = fdesc.data;
				}
				oa1File.fill(oa1BA,fdesc.compress);
				oa1File.serialize(_baArchive);
			}
			return _baArchive;
		}
		
		public function save(postUrl:String, filename:String, postVarsAssocArr:Array = null):void
		{
			
			_bDownloading = false;
						
			//posting archive file to specified url
			formPoster = new MultipartFormPoster();
			formPoster.addEventListener(Event.COMPLETE,postComplete);
			formPoster.addEventListener(ErrorEvent.ERROR, onFormPosterError);
			formPoster.addFile(filename, _baArchive);			
			if (postVarsAssocArr!=null)
			{
				for (var varname:String in postVarsAssocArr)
				{
					formPoster.addVariable(varname, postVarsAssocArr[varname]);
				}
			}
			formPoster.post(postUrl);
		}
				
		
		public function addFile(file:OA1FileDesc):void
		{			
			if (_arrOA1FileMap==null)
			{
				_arrOA1FileMap = new Array();
			}
			_arrOA1FileMap.push(file);						
		}
				
		public function getFileByName(s:String):OA1FileDesc
		{
			
			for (var i:int=0; i<_arrOA1FileMap.length; ++i)
			{
				var fdesc:OA1FileDesc = OA1FileDesc(_arrOA1FileMap[i]);
				if (_arrArchiveFiles[i]!=null)
				{
					if (fdesc.name == s)
					{
						return new OA1FileDesc(s,_arrArchiveFiles[i], fdesc.isString, fdesc.compress);
					}
				}
				else
				{
					dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"file "+s+" did not finish download yet"));
					return null;
				}
			}
			return null;
		}	
		
		public function getFilesByName(s:String):Array
		{
			var retArr:Array = new Array();
			for (var i:int=0; i<_arrOA1FileMap.length; ++i)
			{
				var fdesc:OA1FileDesc = OA1FileDesc(_arrOA1FileMap[i]);
				if (_arrArchiveFiles[i]!=null)
				{
					if (fdesc.name.indexOf(s)==0)
					{
						retArr.push(new OA1FileDesc(s,_arrArchiveFiles[i], fdesc.isString, fdesc.compress));											
					}
				}
				else
				{
					dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"file "+s+" did not finish download yet"));
					return null;
				}
			}
			return retArr;
		}		
		
		public function getFileByIndex(i:int):OA1FileDesc
		{
			if (i<_arrOA1FileMap.length)
			{
				var fdesc:OA1FileDesc = OA1FileDesc(_arrOA1FileMap[i]);
				if (_arrArchiveFiles[i]!=null)
				{
					return new OA1FileDesc(fdesc.name, _arrArchiveFiles[i],fdesc.isString,fdesc.compress);
				}
				else
				{
					dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"file "+fdesc.name+" did not finish download yet"));
					return null;
				}
			}
			else
			{
				dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"request file index "+i+" doesn't exist in map"));
				return null;
			}
		}
		
		public function getFilesArr():Array
		{
			var retArr:Array = new Array();
			if (_arrOA1FileMap==null)
			{
				dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"file map could not be read"));
				return null;
			}
			for (var i:int=0; i<_arrOA1FileMap.length; ++i)
			{
				var fdesc:OA1FileDesc = OA1FileDesc(_arrOA1FileMap[i]);
				if (_arrArchiveFiles[i]!=null)
				{
					retArr.push(new OA1FileDesc(fdesc.name,_arrArchiveFiles[i], fdesc.isString, fdesc.compress))					
				}
				else
				{
					dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"file "+fdesc.name+" did not finish download yet"));
					return null;
				}
			}
			return retArr;
		}
		
		public function setVersion(i:int):void
		{
			_iVersion = i;
		}
		
		public function getVersion():int
		{
			return _iVersion;
		}				
		
		private function doParsing(input:IDataInput = null)
		{					
			var data:IDataInput = input != null? input : _usDownloadStream;
			
			if (_bDownloading)
			{
				data.endian = flash.utils.Endian.LITTLE_ENDIAN;
				if (_oa1Parser==null)
				{
					_oa1Parser = new ParsingArchiveOA1();
				}
				do
				{							
					var avail:uint = data.bytesAvailable;
					//trace("avail="+avail);
					switch(_oa1Parser.getState())
					{										
						case com.oddcast.io.archive.oa1.ParsingArchiveOA1.PARSE_SIGNATURE:							
							if (avail < OA1_SIGNATURE.length) return false;
							var header:String = data.readUTFBytes(OA1_SIGNATURE.length);
							if (header!=OA1_SIGNATURE)
							{
								//this.dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"File signature doesn't match"));
								_bErrorState = true;
								break;
							}
							_oa1Parser.incState();
							break;
						case com.oddcast.io.archive.oa1.ParsingArchiveOA1.PARSE_VERSION:
							if (avail <4)
								return;
							_iVersion = data.readInt();						
							_oa1Parser.incState();
							break;
						case com.oddcast.io.archive.oa1.ParsingArchiveOA1.PARSE_FILES:
							//trace("_oa1Parser.getState()="+_oa1Parser.getState());
							if (_oa1Parser.currfile==null)
							{
								_oa1Parser.currfile = new OA1File(null);
							}
							var finished:Boolean = _oa1Parser.currfile.parse(data);
							
							if (finished)
							{
								if (_isFirstFile)
								//first file in archive is an xml describing it 
								{	
									_isFirstFile = false;
									var tempS:String = String(_oa1Parser.currfile.content)									
									parseIndexFile(new XML(_oa1Parser.currfile.content));
									dispatchEvent(new ArchiverEvent(ArchiverEvent.INDEX_DOWNLOADED,null));
								}
								else
								{
									_arrArchiveFiles.push(_oa1Parser.currfile.content);								
									dispatchEvent(new ArchiverEvent(ArchiverEvent.FILE_DOWNLOADED,(_arrArchiveFiles.length-1)));
								}
								//trace("read file: "+_oa1Parser.currfile.content);
								_oa1Parser.currfile = null;
								
							}
							else
							{
								return;
							}						
							break;
							
					}
				} while (data.bytesAvailable>0 && !_bErrorState);	
			}
		}
		
		private function postComplete(evt:Event):void
		{
			dispatchEvent(new ArchiverEvent(ArchiverEvent.ARCHIVE_UPLOADED,_baArchive));
			
			
		}
		
		private function onFormPosterError(evt:ErrorEvent):void
		{
			dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"failed to post archive "+evt.text));
			formPoster.removeEventListener(Event.COMPLETE,postComplete);
			formPoster.removeEventListener(ErrorEvent.ERROR, onFormPosterError);
		}
		
		private function configureListeners(dispatcher:EventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }  
		
		private function removeListeners(dispatcher:EventDispatcher):void
		{
			if (dispatcher!=null)
			{
				dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
				dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				dispatcher.removeEventListener(Event.OPEN, openHandler);
				dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
				dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			}
		}

		private function parseIndexFile(xml:XML):void
		{
			/*
			Index File looks like this:
				<FILES_INDEX FILES="3">
					<FILE NAME="file1" STRING="true" COMPRESS"true"/>
					<FILE NAME="file2"/>
					<FILE NAME="file3"/>
				</FILES_INDEX>
			*/
			//trace(xml);
			_arrOA1FileMap = new Array();
			var xmlFiles:XMLList = xml.child("FILE");
			var n:XML;
			for each (n in xmlFiles)
			{
				_arrOA1FileMap.push(new OA1FileDesc(n.@NAME,null,n.@STRING=="true",n.@COMPRESS=="true"));
			}			
		}
		
		private function fileIndexToXML():XML
		{
			var retXML:XML = new XML('<FILES_INDEX/>');	
			retXML.@FILES = _arrOA1FileMap.length;		
			for (var i:int=0; i< _arrOA1FileMap.length ; ++i)
			{
				var fdesc:OA1FileDesc = OA1FileDesc(_arrOA1FileMap[i]);
				var xmlFileNode:XML = new XML("<FILE/>");
				xmlFileNode.@NAME = fdesc.name;
				if (fdesc.isString)
				{
					xmlFileNode.@STRING = "true";
				}
				if (fdesc.compress)
				{
					xmlFileNode.@COMPRESS = "true";
				}
				retXML.appendChild(xmlFileNode);
			}
			return retXML;
		}

		private function completeHandler(event:Event):void {
		    //trace("completeHandler: " + event);    
		    dispatchEvent(new ArchiverEvent(ArchiverEvent.DOWNLOAD_COMPLETE,null));        
		}

		private function openHandler(event:Event):void {
		    //trace("openHandler: " + event);
		}

		private function progressHandler(event:ProgressEvent):void {
		    //trace("progressHandler: " + event);
		   // trace("progress:" + event.bytesLoaded + " of " + event.bytesTotal);
		    doParsing();
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void {
		    //trace("securityErrorHandler: " + event);
			dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"securityErrorHandler: " + event));
		}

		private function httpStatusHandler(event:HTTPStatusEvent):void {
			_iLastStatus = event.status;
		    //trace("httpStatusHandler: " + event);
		}

		private function ioErrorHandler(event:IOErrorEvent):void {
		    //trace("ioErrorHandler: " + event);
			_bErrorState = true;
			dispatchEvent(new ArchiverEvent(ArchiverEvent.ON_ERROR,"ioErrorHandler: " + event));
		}


	}
}
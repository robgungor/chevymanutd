/* things to add
isDisposed do not continune
*/
package com.oddcast.oc3d.shared
{
	import com.oddcast.io.archiver.OA1FileDesc;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
		

	public class DBContentDataProviderFilesManager
	{
		
		private static var _dictFilesData:Dictionary;
		private static var _dictLoaders:Dictionary;
		private static var _dictArchives:Dictionary;
				
		public static var BASE_URL:String = "";
		
		public static const AUDIO_IDS_FILENAME:String = "audioIds.rsc";
		public static const AUDIO_SWF_FILENAME:String = "audioSwf.swf";
		public static const TYPE_BINARY:String = "binary";
		public static const TYPE_SWF:String = "swf";
		public static const TYPE_BITMAPDATA:String = "bitmap";
		public static const TYPE_XML:String = "xml";
		public static const TYPE_STRING:String = "string";
		public static const TYPE_TEXTURES:String = "textures";
		public static const TYPE_AUDIO:String = "mp3";
		public static const TYPE_ARCHIVE:String = "archive";
		
		
		
		public function DBContentDataProviderFilesManager()
		{
		}				
				
		public static function destroy():void
		{
			var item:Object;
			for each (item in _dictArchives)
			{
				ArchiverWrapper(item).destroy();				
			}

			for each (item in _dictLoaders)
			{
				LoaderWrapper(item).destroy();
			}
			for each (item in _dictFilesData)
			{
				item = null;
			}
			
			_dictFilesData = null;
			_dictLoaders = null;
			_dictArchives = null;
		}
		
		public static function init():void
		{
			_dictFilesData = new Dictionary();
			_dictLoaders = new Dictionary();	
			_dictArchives = new Dictionary();
		}
		
		public static function downloadFile(url:String, type:String, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			url = cleanupUrl(url, BASE_URL, DBContentDataProviderRead.IS_LOCAL);
			
			if (_dictFilesData[url]!=null)
			{
				contFn(_dictFilesData[url]);
				//data was accessed delete content from here to avoid duplicate memory usage								
				_dictFilesData[url] = null;
				delete _dictFilesData[url];							
				
				return;
			}
						
			switch (type)
			{
				case TYPE_ARCHIVE:
					_dictArchives[url] = new ArchiverWrapper();
					ArchiverWrapper(_dictArchives[url]).loadUrl(url, function(filesArr:Array):void
					{
						contFn(filesArr);
						//if .avt file do not destory the files might get called later
						if (url.indexOf(".avt")==-1)
						{
							ArchiverWrapper(_dictArchives[url]).destroy();
							_dictArchives[url] = null;
							delete _dictArchives[url];
						}
					}, failFn, progressFn);					
					break;				
				default: //bitmap, binary, swf, string
					_dictLoaders[url] = new LoaderWrapper(type);					
					LoaderWrapper(_dictLoaders[url]).loadUrl(url,function(o:Object):void
					{
						//_dictFilesData[url] = o;						
						contFn(o);//_dictFilesData[url]);
						LoaderWrapper(_dictLoaders[url]).destroy();
						_dictLoaders[url] = null;
						delete _dictLoaders[url];
						
					}, failFn, progressFn);
					
			}
		}								
		
		public static function extractPackage(url:String, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			downloadFile(url, DBContentDataProviderFilesManager.TYPE_ARCHIVE, function (filesArr:Array):void
			{
				var filesLoaded:int = 0;
				var filesTotal:int = filesArr.length;
				
				var addToFileCount:Function = function():void
				{
					filesLoaded++;
					//trace(" filesLoaded="+filesLoaded+", filesTotal="+filesTotal);
					if (filesTotal==filesLoaded) 
					{
						contFn();	
						//ArchiverWrapper(_dictArchives[url]).destroy();
						//_dictArchives[url] = null;
						//delete _dictArchives[url];
					}
				}
				
				if (_dictArchives[url]==null) genericFailFn("DBContentDataProviderFileManager tried to read package archive "+url+" but it was null");
				var audioData:* = ArchiverWrapper(_dictArchives[url]).getDataByName(AUDIO_IDS_FILENAME);
				var audioSwfDataStr:String;								
				if (audioData!=null)
				{
					audioSwfDataStr = unescape(String(audioData));					
					addToFileCount();					
				}
				for each (var fileDesc:OA1FileDesc in filesArr)
				{
					var ext:String = String(fileDesc.name.split(".")[1]).toLowerCase();
					switch (ext)
					{
						case "dae":
							_dictFilesData[cleanupUrl(BASE_URL+fileDesc.name)] = new XML(unescape(fileDesc.data));
							addToFileCount();							
							break;
						case "fbd":
							_dictFilesData[cleanupUrl(BASE_URL+fileDesc.name)] = fileDesc.data;
							addToFileCount();
							break;
						case "fbt":
							_dictArchives[cleanupUrl(BASE_URL+fileDesc.name)] = new ArchiverWrapper();
							ArchiverWrapper(_dictArchives[cleanupUrl(BASE_URL+fileDesc.name)]).loadData(ByteArray(fileDesc.data), (function (fd:OA1FileDesc):Function { return  function(fbtFilesArray:Array):void
							{								
								_dictFilesData[cleanupUrl(BASE_URL+fd.name)] = fbtFilesArray;
								addToFileCount();	
								ArchiverWrapper(_dictArchives[cleanupUrl(BASE_URL+fd.name)]).destroy();
								_dictArchives[cleanupUrl(BASE_URL+fd.name)] = null;
								delete _dictArchives[cleanupUrl(BASE_URL+fd.name)];
							}})(fileDesc), failFn, progressFn);
							break;
						case "png":
							_dictLoaders[cleanupUrl(BASE_URL+fileDesc.name)] = new LoaderWrapper(DBContentDataProviderFilesManager.TYPE_BITMAPDATA);							
							LoaderWrapper(_dictLoaders[cleanupUrl(BASE_URL+fileDesc.name)]).loadData(ByteArray(fileDesc.data),(function (fd:OA1FileDesc):Function { return function (bmpData:BitmapData):void
							{
								_dictFilesData[cleanupUrl(BASE_URL+fd.name)] = bmpData;
								addToFileCount();
								LoaderWrapper(_dictLoaders[cleanupUrl(BASE_URL+fd.name)]).destroy();
								
							}})(fileDesc), failFn, progressFn)
							break;
						case "swf": //either a regular swf or an audio package
							_dictLoaders[cleanupUrl(BASE_URL+fileDesc.name)] = new LoaderWrapper(DBContentDataProviderFilesManager.TYPE_SWF);
							LoaderWrapper(_dictLoaders[cleanupUrl(BASE_URL+fileDesc.name)]).loadData(ByteArray(fileDesc.data),(function (fd:OA1FileDesc):Function { return function (swf:MovieClip):void
							{
								_dictFilesData[cleanupUrl(BASE_URL+fd.name)] = swf;
								if (fileDesc.name==AUDIO_SWF_FILENAME)
								{
									var tempArr:Array = audioSwfDataStr.split("|");
									var audioIds:Array = tempArr[0].split(",");
									var audioUrls:Array = tempArr[1].split(",");
									var appDomain:ApplicationDomain = LoaderWrapper(_dictLoaders[cleanupUrl(BASE_URL+fd.name)]).getApplicationDomain();
									for (var k:int=0; k<audioIds.length; ++k)
									{
										
										if (appDomain.hasDefinition("EmbeddedAudio_"+String(audioIds[k])))
										{
											var loadedSoundClass:Class = appDomain.getDefinition("EmbeddedAudio_"+String(audioIds[k])) as Class;
											var loadedSound:Sound = new loadedSoundClass();
											//trace("indexed in _dictPackageDownloadedFiles at: "+audioUrls[k]);
											_dictFilesData[cleanupUrl(BASE_URL+audioUrls[k])] = loadedSound;										
										}
										else
										{
											trace("Couldn't extract embedded Audio loader "+String(audioIds[k]));
										}
									}
									_dictFilesData[cleanupUrl(BASE_URL+fd.name)] = null;
									delete _dictFilesData[cleanupUrl(BASE_URL+fd.name)];
								}
								addToFileCount();
								
								LoaderWrapper(_dictLoaders[cleanupUrl(BASE_URL+fd.name)]).destroy();
								_dictLoaders[cleanupUrl(BASE_URL+fd.name)] = null;
								delete _dictLoaders[cleanupUrl(BASE_URL+fd.name)];								
							}})(fileDesc), failFn, progressFn)													
							break;						
					}
				}				
			},failFn, progressFn);
		}
		
		public static function getBitmapDataVector(url:String, filesArr:Array, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{			
			url = cleanupUrl(url, BASE_URL, DBContentDataProviderRead.IS_LOCAL);
			var bmpArr:Array = new Array();
			var filesTotal:int = filesArr.length;
			var filesRead:int = 0;
			
			for (var i:int=0; i<filesArr.length; ++i)
			{
				var fileDesc:OA1FileDesc = filesArr[i];
				_dictLoaders[url+"?file="+fileDesc.name] = new LoaderWrapper(TYPE_BITMAPDATA);
				LoaderWrapper(_dictLoaders[url+"?file="+fileDesc.name]).loadData(ByteArray(fileDesc.data), (function(idx:uint, fd:OA1FileDesc):Function { return function(bmpData:BitmapData):void
				{
					bmpArr.push({index:idx, data:bmpData});
					if (bmpArr.length==filesArr.length)
					{
						var retVec:Vector.<BitmapData> = new Vector.<BitmapData>();
						bmpArr.sortOn(["index"]);
						for (var j:int=0; j<bmpArr.length; ++j)
						{
							retVec.push(bmpArr[j].data);
						}
						contFn(retVec);
						
						LoaderWrapper(_dictLoaders[url+"?file="+fd.name]).destroy();
						_dictLoaders[url+"?file="+fd.name] = null;					
						delete _dictLoaders[url+"?file="+fd.name];
						filesRead++;
						if (filesRead==filesTotal && _dictArchives[url]!=null)
						{
							ArchiverWrapper(_dictArchives[url]).destroy();
							_dictArchives[url] = null;
							delete _dictArchives[url];
						}
					}					
				}; })(i, fileDesc));								
			}			
		}
		
		public static function getArchiveFile(url:String, fileName:String, type:String, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			url = cleanupUrl(url, BASE_URL, DBContentDataProviderRead.IS_LOCAL);
			var err:String;
			if (ArchiverWrapper(_dictArchives[url])!=null)
			{
				var data:* = ArchiverWrapper(_dictArchives[url]).getDataByName(fileName);
				if (data!=null)
				{
					switch(type)
					{
						case TYPE_STRING:
							contFn(unescape(String(data)));
							break;
						case TYPE_XML:							
							contFn(new XML(unescape(String(data))));
							break;
						case TYPE_BITMAPDATA:
						case TYPE_SWF:						
							_dictLoaders[url+"?file="+fileName] = new LoaderWrapper(type);							
							LoaderWrapper(_dictLoaders[url+"?file="+fileName]).loadData(ByteArray(data),contFn, failFn, progressFn)
							LoaderWrapper(_dictLoaders[url+"?file="+fileName]).destroy();
							_dictLoaders[url+"?file="+fileName] = null;
							delete _dictLoaders[url+"?file="+fileName]
							break;		
						case TYPE_BINARY:
							contFn(data);
							break;						
						case TYPE_TEXTURES:
							_dictArchives[url+"?file="+fileName] = new ArchiverWrapper();							 
							ArchiverWrapper(_dictArchives[url+"?file="+fileName]).loadData(ByteArray(data), contFn, failFn, progressFn);
							break;
						case TYPE_AUDIO:
							
							break;						
					}
				}
				else
				{
					genericFailFn("DBContentDataProviderFileManager tried to access a null file "+fileName+" in archive "+url);
				}
			}
			else
			{
				genericFailFn("DBContentDataProviderFileManager tried to access a null archive "+url)				
			}
			
		}
		
		public static function genericFailFn(err:String, failFn:Function = null)
		{
			if (failFn!=null)
				failFn(err);
			else
				trace(err);
		}
		
		
		public static function cleanupUrl(url:String, baseUrl:String = null, isLocal:Boolean = false):String
		{
			if (baseUrl==null)
			{
				baseUrl = BASE_URL;
			}
			var s:String = (url.indexOf("http:")>=0 || isLocal)?url:baseUrl+url;
			var httpStr:String = "http://";
			var sNoHttp:String;
			var needHttp:Boolean;
			if (s.indexOf(httpStr)>=0)
			{
				sNoHttp = s.split(httpStr)[1];
				needHttp = true;
			}
			else
			{
				sNoHttp = s;
			}	
			var regex:RegExp = /\/\//g;
			return (needHttp?httpStr:'')+sNoHttp.replace(regex,"/");
		}				
	}
}
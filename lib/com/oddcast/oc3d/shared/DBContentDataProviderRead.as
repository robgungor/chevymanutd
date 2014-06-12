package com.oddcast.oc3d.shared
{
	import com.oddcast.encryption.Base64;
	import com.oddcast.event.ArchiverEvent;
	import com.oddcast.io.archiver.*;
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.IContentProvider;
	import com.oddcast.oc3d.core.IStorageProvider;
	import com.oddcast.oc3d.data.*;
	import com.oddcast.utils.XMLLoader;
	
	import flash.display.*;
	import flash.media.Sound;
	import flash.net.*;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/*
	objectTypeId 	objectTypeName
	1 	Accessory
	2 	Animation
	3 	Audio
	4 	Group
	5 	Mask
	6 	MaterialConfiguration
	7 	Script
	8 	Selector
	9 	Slot
	10 	Thumbnail
	11 	Folder
	12 	Material
	13 	MaterialLayer
	14 	Thumbnail
	15 	AccessorySet
	16 	Avatar
	17 	Configuration
	18 	ItemSet
	19 	AccessoryBin
	20 	Preset
	21 	TextureMaterialLayer
	22 	ColorMaterialLayer
	23 	Decal
	24 	Category
	25 	AnimationBin
	26 	MaterialBin
	27 	MaterialConfigurationBin
	28 	Action
	29	Item
	30	DecalConfigurationBin
	31	DecalConfiguration
	32 	Area
	33	Package
	34	Command
	35	ProtocalBinding
	36  Texture
	37  Swf
	*/
	
	public class DBContentDataProviderRead implements IContentProvider, IStorageProvider
	{
		public static var PACKAGE_CACHE_URL_SUFFIX:String = "/fb.fbp";
		public static var IS_LOCAL:Boolean = false;
		public static var API_ZIP_RESPONSE:Boolean = false;
		
		protected var _sAPIURL:String;		
		protected var _bIsAccelerated:Boolean;
		protected var _sGetPackageURL:String; //use http://contnet.dev.oddcast.com/char/fb/ for testing on dev
		
		private var _arrAssociations:Array;	 
		protected var _arrObjectsCache:Dictionary;
		private var _arrTypes:Array;
		private var _bAccessorySetAssociationsCached:Boolean;	
		private var _bItemSetAssociationsCached:Boolean;
		private var _bSceneSetAssociationsCached:Boolean;
		private var _dictProps:Dictionary;					
		protected var _bUsePackages:Boolean = false;		
		//protected var _iAccessorySetId = 0;
		//protected var _iItemSetId = 0;
		//protected var _iSceneSetId =0;
		private var isDisposed_:Boolean = false;
		private var _sSceneSetDataUrl:String;
		//private var assetLoader:Loader;
		private var _bSetAssociationsCached:Boolean;			
		
		private var collada2ScenePlugInUrl_:String;
		
		public function downloadFile(relativePath:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void{}
		
		public function DBContentDataProviderRead()
		{
			collada2ScenePlugInUrl_ = "Collada2ScenePlugIn.swf";
						
			_arrAssociations = new Array();	
			_arrObjectsCache = new Dictionary();		
			_dictProps = new Dictionary();
			_arrTypes = new Array();						
			//set defaults
			_dictProps["thumbnail-width"] = "50";
			_dictProps["thumbnail-height"] = "50";
			XMLLoader.retries = 2;
			DBContentDataProviderFilesManager.init();
		}
		
		public function destroy():void
		{
			DBContentDataProviderFilesManager.destroy();
			isDisposed_ = true;			
			_arrAssociations = null;
			_arrObjectsCache = null;
			_dictProps = null;
			_arrTypes = null;					
			XMLLoader.destroy();
			
		}
		
		public function downloadAvatar(configData:XML, fullResData:ByteArray, disassembledTextures:Vector.<Vector.<ByteArray>>, lowResData:ByteArray, lowResTexture:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function setAPIURLs(apiUrl:String, uploadUrl:String = null, getUploadedUrl:String = null):void
		{
			_sAPIURL = apiUrl;			
		}
		public function setContentDomain(s:String):void
		{
			_dictProps['CONTENT_DOMAIN'] = s;
			DBContentDataProviderFilesManager.BASE_URL = s;
		}
		
		public function set isAccelerated(b:Boolean):void
		{
			_bIsAccelerated = b;
		}
		
		public function clearCache():void
		{
			_arrAssociations = new Array();
			_arrObjectsCache = new Dictionary();
		}
		
		public function setPackageUrl(s:String, asId:int = -1):void
		{
			_sGetPackageURL = s;
			/*
			if (asId != -1)
			{
				_iAccessorySetId = asId;
			}
			*/
			_bUsePackages = true;
		}				
		
		private var webServerCachingAllowed_:Boolean = true;
		
		public function setWebServerCachingAllowed(b:Boolean):void{ webServerCachingAllowed_ = b; }
		
		private function tryExtractContentUrisFromFullMesh(dae:XML, extractId:Boolean = false):Array
		{
			namespace collada = "http://www.collada.org/2005/11/COLLADASchema";
			use namespace collada;
			var n:XMLList = dae.asset.contributor.(author == "data:materials");
			if (n == null || n.length() == 0)
				return null;
			var data:String = Str.unescape(String(n[0].comments[0].text()[0]));
			var result:Array = new Array();
			var reg:RegExp = /\( *bmp +\"[^\"]+\" +[0-9]+ +[0-9]+ +\"([^\"]+)\" *\)/g;
			var matches:Object;
			while ((matches = reg.exec(data)) != null)
			{
				if (extractId)
				{
					var reg2:RegExp = /.*_([0-9]+)\.png/;
					var matches2:Object = reg2.exec(matches[1]);
					result.push(matches2[1]);
				}
				else
				{
					result.push(matches[1]);
				}
			}
			return result;	
		}		
		/*
		private function stripUrlDoubleSlashes(s:String):String
		{
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
		*/
		
		public function downloadBinary(url:String, contFn:Function, failedFn:Function=null, progressedFn:Function=null, o:Object = null):void
		{						
			if (url.indexOf("avt")>=0)
			{
				var fullUrl:String = DBContentDataProviderFilesManager.cleanupUrl(url, _dictProps['CONTENT_DOMAIN'], IS_LOCAL);
				var baseUrl:String = fullUrl.split("?")[0];
				var fileName:String = fullUrl.split("?file=")[1];
				DBContentDataProviderFilesManager.getArchiveFile(baseUrl,fileName,DBContentDataProviderFilesManager.TYPE_BINARY,contFn, failedFn, progressedFn);																		
			}			
			else
			{
				DBContentDataProviderFilesManager.downloadFile(url,DBContentDataProviderFilesManager.TYPE_BINARY,contFn, failedFn, progressedFn);				
			}
		}
		
		// continuationFn<data:String>
		public function downloadText(url:String, contFn:Function, failedFn:Function=null, progressedFn:Function=null, o:Object = null):void
		{					
			if (url.indexOf("avt")>=0)
			{
				var fullUrl:String = DBContentDataProviderFilesManager.cleanupUrl(url, _dictProps['CONTENT_DOMAIN'], IS_LOCAL);
				var baseUrl:String = fullUrl.split("?")[0];
				var fileName:String = fullUrl.split("?file=")[1];
				DBContentDataProviderFilesManager.getArchiveFile(baseUrl,fileName,DBContentDataProviderFilesManager.TYPE_XML,contFn, failedFn, progressedFn);															
			}
			else
			{
				DBContentDataProviderFilesManager.downloadFile(url,DBContentDataProviderFilesManager.TYPE_STRING,contFn, failedFn, progressedFn);
			}			
		}
		
		// continuationFn<data:BitmapData>
		public function downloadBitmap(url:String, contFn:Function, failedFn:Function=null, progressedFn:Function=null, o:Object = null):void
		{
			if (url.indexOf("avt")>=0)
			{
				var fullUrl:String = DBContentDataProviderFilesManager.cleanupUrl(url, _dictProps['CONTENT_DOMAIN'], IS_LOCAL);
				var baseUrl:String = fullUrl.split("?")[0];
				var fileName:String = fullUrl.split("?file=")[1];
				DBContentDataProviderFilesManager.getArchiveFile(baseUrl,fileName,DBContentDataProviderFilesManager.TYPE_BITMAPDATA,contFn, failedFn, progressedFn);															
			}
			else
			{
				DBContentDataProviderFilesManager.downloadFile(url,DBContentDataProviderFilesManager.TYPE_BITMAPDATA,contFn, failedFn, progressedFn);
			}					
		}
		
		// continuationFn<data:MovieClip>
		public function downloadSwf(url:String, contFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			DBContentDataProviderFilesManager.downloadFile(url,DBContentDataProviderFilesManager.TYPE_SWF,contFn, failedFn, progressedFn);			
		}
		
		// continuationFn<data:Vector.<BitmapData>>
		public function downloadDisassembledBitmap(url:String, contFn:Function, failedFn:Function=null, progressedFn:Function=null, o:Object=null):void
		{			
			if (url.indexOf("avt")>=0)
			{
				var fullUrl:String = DBContentDataProviderFilesManager.cleanupUrl(url, _dictProps['CONTENT_DOMAIN'], IS_LOCAL);
				var baseUrl:String = fullUrl.split("?")[0];
				var fileName:String = fullUrl.split("?file=")[1];				
				DBContentDataProviderFilesManager.getArchiveFile(baseUrl,fileName,DBContentDataProviderFilesManager.TYPE_TEXTURES,function (filesArr:Array):void
				{
					DBContentDataProviderFilesManager.getBitmapDataVector(url,filesArr,contFn, failedFn, progressedFn);
				}, failedFn, progressedFn);															
			}
			else
			{
				DBContentDataProviderFilesManager.downloadFile(url,DBContentDataProviderFilesManager.TYPE_ARCHIVE,function (filesArr:Array):void
				{
					DBContentDataProviderFilesManager.getBitmapDataVector(url,filesArr,contFn, failedFn, progressedFn);
				}, failedFn, progressedFn);
			}						 
		}
				
		
		public function preloadPackage(nodeSetId:int, assetIds:Array, contFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{			
			if (_bUsePackages)
			{
				trace("DBContentProviderRead - Preloading packages starting... (this may take a while) ids="+assetIds.join(",")); 
				//remove items which are not in the tree (if application level filter happened)								
				var packUrl:String = _sGetPackageURL; //something like http://contnet.dev.oddcast.com/char/fb/				
				packUrl+=String(nodeSetId)+"/";
				packUrl+=assetIds.join("/");
				packUrl+=PACKAGE_CACHE_URL_SUFFIX;								
				//if there's a failure try to resume functionality with packages turned off.
				DBContentDataProviderFilesManager.extractPackage(packUrl, function ():void
				{
					contFn();
				}, function (err:String):void
				{
					trace(err);
					_bUsePackages = false;
					contFn();
				}, progressedFn);
						
			}
			else
			{
				contFn();
			}
		}				
		
		// continuationFn<data:Sound>
		public function downloadSound(url:String, contFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{			
			DBContentDataProviderFilesManager.downloadFile(url,DBContentDataProviderFilesManager.TYPE_AUDIO,contFn, failedFn, progressedFn);											
		}
		
		
		protected function sendXMLCallback(_xml:XML,functions:Object):void
		{
			var typeName:String
			if (_xml==null)
			{
				if (functions.ffn != null)
					functions.ffn(XMLLoader.lastError);
				return;
			} 
			
			//trace("sendXMLCallback "+_xml.toXMLString());
			if (_xml.@RES=="ERROR")
			{
				functions.ffn(_xml.@MSG);
				return;
			}
			else
			{
				var xmlNode:XML;
				var returnArr:Array;
				var tempRetArr:Array;
				var assocList:XMLList;
				var xmlList:XMLList;
				var item:XML;
				switch (functions.act)
				{					
					case "selectSceneSetCommandsByAccessorySetId":
						var objectsList:XMLList = _xml.OBJECTS.OBJECT;
						var commandNames:Vector.<String> = new Vector.<String>();
						for each(xmlNode in objectsList)
						{
							var tempObject:Object = new Object();
							xmlList = xmlNode.children();															
							for each (item in xmlList) { 																
								tempObject[item.localName()] = item.toString();
							}
							commandNames.push(tempObject['name']);
						}
						functions.cfn(commandNames);
						break;
																				
					case "deleteObject": functions.cfn(); break;
					default:
						var id:int = int(_xml.@objectId);//(_xml.child("ID").toString());
						if (id>0)
						{
							functions.cfn(id);
						}
						else
						{
							functions.cfn(0)
						}						
				}								
			}
		}				
		
		private function selectAllAssociationsFromCache(node:String, nodeId:int):Array
		{
			var retArr:Array = new Array();
			for(var i:int=0; i<_arrAssociations.length;++i)
			{
				if ((_arrAssociations[i][0]==node && _arrAssociations[i][1]==nodeId) || (_arrAssociations[i][2]==node && _arrAssociations[i][3]==nodeId))
				{					
					retArr.push(_arrAssociations[i]);
				}
			}
			
			return retArr;
		}
		
		
		private function buildQueryString(xml:XML):String
		{
			var retStr:String = "";
			var xmlNode:XML;
			
			retStr = (_bIsAccelerated?"/":"?")+"action="+xml.@action+(_bIsAccelerated?"/":"");
			
			for each(xmlNode in xml.attributes())
			{
				if (xmlNode.name()=="action")
				{
					continue;
				}				
				
				retStr += retStr.length==0 ? "?" : "&";
				retStr += "params["+xmlNode.name()+"]="+xmlNode.valueOf();					
			}
			return retStr;
		}
		
		
		//continuation function void
		protected function getSelectInitialDataXML(xml:XML, contFn:Function , failFn:Function = null, progressFn:Function = null):void
		{			
			xml.@action = "selectSetInitialData";
			
			if (API_ZIP_RESPONSE)
			{
				xml.@z = 1;
			}
			var xmlUrl:String = _sAPIURL + (IS_LOCAL ? "" : buildQueryString(xml))
			
			if (xml.@objectType=="SceneSet" || xml.@objectType=="Avatar")
			{
				if (IS_LOCAL)
				{
					xmlUrl = _sAPIURL!=null?_sAPIURL:""+xml.@setId+".xml";
				}
				else if (_bUsePackages && _sGetPackageURL!=null)
				{
					xmlUrl = _sGetPackageURL+xml.@setId+"/"+(xml.@objectType=="Avatar"?"av_":"")+"xml"+(API_ZIP_RESPONSE?"/z":"")+PACKAGE_CACHE_URL_SUFFIX;
				}
			}			
				
			if (API_ZIP_RESPONSE)
			{
				DBContentDataProviderFilesManager.downloadFile(xmlUrl, DBContentDataProviderFilesManager.TYPE_ARCHIVE, function(filesArr:Array):void
				{
					contFn(parseSelectInitialDataXML(new XML(String(OA1FileDesc(filesArr[0]).data))));
					
				}, failFn, progressFn);
			}
			else
			{
				xmlUrl = DBContentDataProviderFilesManager.cleanupUrl(xmlUrl);
				XMLLoader.loadXML(xmlUrl, function (resXml:XML):void
				{
					if (resXml==null)
					{
						DBContentDataProviderFilesManager.genericFailFn("Failed to load xml from "+xmlUrl+" "+XMLLoader.lastError,failFn)
					}
					else if (resXml.@RES=="ERROR")
					{
						DBContentDataProviderFilesManager.genericFailFn("Server has returned error from "+xmlUrl+" code:"+resXml.@CODE+" "+resXml.@MSG,failFn);
					}
					else if (resXml.@RES=="OK")
					{
						contFn(parseSelectInitialDataXML(resXml));
					}
					else
					{
						DBContentDataProviderFilesManager.genericFailFn("Server returned invalid respose from "+xmlUrl+" response:"+resXml.toString(), failFn);
					}
				});
			}
		}		
		//continuation function with an array of id,type associative arrays
		protected function getSelectAssociatedChildrenXML(xml:XML, contFn:Function, failFn:Function=null, progressFn:Function = null):void
		{
			xml.@action = "selectAssociatedChildren";
			if (API_ZIP_RESPONSE)
			{
				xml.@z = 1;
			}
			var xmlUrl:String = _sAPIURL + (IS_LOCAL ? "" : buildQueryString(xml))
			
			if (API_ZIP_RESPONSE)
			{
				DBContentDataProviderFilesManager.downloadFile(xmlUrl, DBContentDataProviderFilesManager.TYPE_ARCHIVE, function(filesArr:Array):void
				{
					contFn(parseSelectAssociatedChildrenXML(new XML(String(OA1FileDesc(filesArr[0]).data))));
					
				}, failFn, progressFn);
			}
			else
			{
				xmlUrl = DBContentDataProviderFilesManager.cleanupUrl(xmlUrl);
				XMLLoader.loadXML(xmlUrl, function (resXml:XML):void
				{
					if (resXml==null)
					{
						DBContentDataProviderFilesManager.genericFailFn("Failed to load xml from "+xmlUrl+" "+XMLLoader.lastError,failFn)
					}
					else if (resXml.@RES=="ERROR")
					{
						DBContentDataProviderFilesManager.genericFailFn("Server has returned error from "+xmlUrl+" code:"+resXml.@CODE+" "+resXml.@MSG,failFn);
					}
					else if (resXml.@RES=="OK")
					{
						contFn(parseSelectAssociatedChildrenXML(resXml));
					}
					else
					{
						DBContentDataProviderFilesManager.genericFailFn("Server returned invalid respose from "+xmlUrl+" response:"+resXml.toString(), failFn);
					}
				});
			}
			
		}
		//continuation function with object
		protected function getSelectObjectXML(xml:XML, contFn:Function, failFn:Function=null, progressFn:Function = null):void
		{
			xml.@action = "selectObject";
			if (API_ZIP_RESPONSE)
			{
				xml.@z = 1;
			}
			var xmlUrl:String = _sAPIURL + (IS_LOCAL ? "" : buildQueryString(xml))
			
			if (API_ZIP_RESPONSE)
			{
				DBContentDataProviderFilesManager.downloadFile(xmlUrl, DBContentDataProviderFilesManager.TYPE_ARCHIVE, function(filesArr:Array):void
				{
					contFn(parseSelectObjectXML(new XML(String(OA1FileDesc(filesArr[0]).data))));
					
				}, failFn, progressFn);
			}
			else
			{
				xmlUrl = DBContentDataProviderFilesManager.cleanupUrl(xmlUrl);
				XMLLoader.loadXML(xmlUrl, function (resXml:XML):void
				{
					if (resXml==null)
					{
						DBContentDataProviderFilesManager.genericFailFn("Failed to load xml from "+xmlUrl+" "+XMLLoader.lastError,failFn)
					}
					else if (resXml.@RES=="ERROR")
					{
						DBContentDataProviderFilesManager.genericFailFn("Server has returned error from "+xmlUrl+" code:"+resXml.@CODE+" "+resXml.@MSG,failFn);
					}
					else if (resXml.@RES=="OK")
					{
						contFn(parseSelectObjectXML(resXml));
					}
					else
					{
						DBContentDataProviderFilesManager.genericFailFn("Server returned invalid respose from "+xmlUrl+" response:"+resXml.toString(), failFn);
					}
				});
			}
			
		}
		
		protected function makeAPICall(action:String, xml:XML, successFn:Function, FailFn:Function, ProgressFn:Function = null):void
		{
			var getStr:String;						
			xml.@action = action;		
						
			if (action=="downloadFile")
			{
				getStr = buildQueryString(xml);
				navigateToURL(new URLRequest(_sAPIURL+getStr),"_blank");
				successFn();
			}
			else
			{										
				var vars:URLVariables = new URLVariables();
				vars.xml = xml.toXMLString();
				
				//trace ("MAKE-API-CALL: " + vars.toString());
				var fns:Object = {act:action, cfn:successFn, ffn:FailFn, pfn:ProgressFn};
				XMLLoader.sendVars(_sAPIURL, function(xml:XML):void
				{
					sendXMLCallback(xml, fns);
					
				}, vars);
							
				//XMLLoader.sendVars(_sAPIURL,sendXMLCallback,vars,{act:action, cfn:successFn, ffn:FailFn, pfn:ProgressFn});
			}
			
		}				
		
		//selects
		//continuation function with an array of id,type associative arrays
		public function selectAssociatedChildren(nodeSetId:int, parent:String, parentId:int, types:Array, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{			
					var xml:XML = new XML("<?xml version='1.0' encoding='ISO-8859-1'?><FB3D></FB3D>");			
			
			xml.@parentType = parent;
			xml.@parentId = parentId;
			xml.@setId = nodeSetId;			
			xml.@types = types.join(',');
			
			getSelectAssociatedChildrenXML(xml, continuationFn, failedFn, progressedFn);													
		}
		
		public function downloadAvatarObjectsData(nodeSetId:int, continuationFn:Function, failedFn:Function = null, progressedFn:Function = null):void
		{
			getSelectInitialDataXML(getNewXMLObject(nodeSetId, nodeSetId, "Avatar"), continuationFn, failedFn, progressedFn);
		}	
		
		public function selectAllAssociations(nodeSetId:int, node:String, nodeId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void 
		{			
			if (!_bSetAssociationsCached)
			{								
				getSelectInitialDataXML(getNewXMLObject(nodeSetId, nodeId, node), function():void
				{
					var result:Array = selectAllAssociationsFromCache(node, nodeId);
					if (result!=null)
					{
						continuationFn(result);
					}
					else
					{
						DBContentDataProviderFilesManager.genericFailFn("Associations could not be read for "+node+" "+nodeId+" returned null",failedFn);
					}
				}, failedFn, progressedFn);
			}
			else
			{
				var result:Array = selectAllAssociationsFromCache(node, nodeId);
				if (result!=null)
				{
					continuationFn(result);
				}
				else
				{
					DBContentDataProviderFilesManager.genericFailFn("Associations are marked as cached but selectAllAssociationsFromCache for "+node+" "+nodeId+" returned null",failedFn);
				}
			}			
		}				
		
		// stub return null if property not found
		public function selectProperty(nodeSetId:int, type:String, parentId:int, propertyName:String):String
		{
			return _dictProps[propertyName];
		}
		
		private function getNewXMLObject(setId:int, objectId:int, objectType:String):XML
		{
			var xml:XML = new XML("<?xml version='1.0' encoding='ISO-8859-1'?><FB3D></FB3D>");						
			xml.@objectType = objectType;
			xml.@id = objectId;	
			xml.@setId = setId;
			return xml;
		}
		
		private function parseSelectAssociatedChildrenXML(xml:XML):Array
		{
			/*xml looks like:
			<fb3d RES="OK">
			<typeName>
			<ID>id</ID>
			</typeName>
			</fb3d>
			*/
			var returnArr = new Array();
			var xmlNode:XML;
			var tablesList:XMLList = xml.children();						
			for each(xmlNode in tablesList)
			{							
				var	tableIdList:XMLList = xmlNode.child('ID');
				var idXMLNode:XML;												
				for each(idXMLNode in tableIdList)
				{
					var tempRetArr = new Array();
					tempRetArr['type'] = xmlNode.name();
					tempRetArr['id'] = int(idXMLNode.valueOf());
					returnArr.push(tempRetArr)														
				}													
			}
			return returnArr;			
		}
		
		private function parseSelectInitialDataXML(xml:XML):void
		{
			_bSetAssociationsCached = true;
			var xmlNode:XML;
			var attrList:XMLList = xml.attributes();
			for each (xmlNode in attrList)
			{							
				if (xmlNode.localName()!='CONTENT_DOMAIN' || _dictProps['CONTENT_DOMAIN'] == null)
				{
					if (xmlNode.localName()=='CONTENT_DOMAIN') 
					{
						DBContentDataProviderFilesManager.BASE_URL =xmlNode.valueOf();
					}
					_dictProps[xmlNode.localName()] = xmlNode.valueOf();
				}
			}
			
			var typesList:XMLList = xml.TYPES.TYPE;
			for each(xmlNode in typesList)
			{				
				_arrTypes[xmlNode.@ID] = xmlNode.@NAME;							
			}
			
			var assocList:XMLList = xml.ASSOCIATIONS.ASSOC;
			for each(xmlNode in assocList)
			{							
				var tempRetArr:Array = new Array();
				tempRetArr.push(_arrTypes[xmlNode.@PARENTTYPE]);
				tempRetArr.push(int(xmlNode.@PARENTID));
				tempRetArr.push(_arrTypes[xmlNode.@CHILDTYPE]);
				tempRetArr.push(int(xmlNode.@CHILDID));
				tempRetArr.push(int(xmlNode.@PARENTSET));
				tempRetArr.push(int(xmlNode.@CHILDSET));
				_arrAssociations.push(tempRetArr);
			}
			
			var objectsList:XMLList = xml.OBJECTS.OBJECT;
			for each(xmlNode in objectsList)
			{
				var tempObject:Object = new Object();
				var xmlList:XMLList = xmlNode.children();												
				for each (var item:XML in xmlList) { 																
					tempObject[item.localName()] = item.toString();
				}					
				_arrObjectsCache[int(xmlNode.@ID)] = tempObject;				
			}											
		}
		
		private function parseSelectObjectXML(xml:XML):Object
		{
			var returnObj:Object = new Object();
			var xmlList:XMLList = xml.OBJECTS.OBJECT.children();						
			
			for each (var item:XML in xmlList) 
			{ 					
				returnObj[item.localName()] = item.toString();
			}
			return returnObj;
		}
		
		public function selectAccessory(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Accessory"), continuationFn, failedFn, progressedFn);
			}			
		}
		
		public function selectSlot(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Slot"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		
		public function selectGroup(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Group"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		public function selectSelector(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Selector"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		public function selectMaterial(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Material"), continuationFn, failedFn, progressedFn);
			}								
		}
		
		public function selectTextureMaterialLayer(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "TextureMaterialLayer"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		public function selectColorMaterialLayer(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "ColorMaterialLayer"), continuationFn, failedFn, progressedFn);
			}						
		}		
		
		public function selectMaterialConfiguration(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "MaterialConfiguration"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		public function selectFolder(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Folder"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		public function selectMask(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Mask"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		public function selectAnimation(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Animation"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		public function selectThumbnail(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Thumbnail"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		// continuationFn:Function<Object>
		public function selectScript(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(prepareData(_arrObjectsCache[id]))
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Script"), function(obj:Object):void
				{
					// on the result call if the code isCompressed, uncompress; otherwise unescape
					
					continuationFn(prepareData(obj));
					
				}, failedFn, progressedFn);
			}	
			
			function prepareData(o:Object):Object
			{
				var objPrime:Object = {};
				for (var prop:String in o) objPrime[prop] = o[prop];
				objPrime.isCompressed = int(o.isCompressed);
				if (objPrime.isCompressed >= 2)
				{
					var baCode:ByteArray = Base64.decode(o.code);
					baCode.inflate();
					objPrime.code = baCode.readUTF();
				}
				else if (objPrime.isCompressed >= 1)
					objPrime.code = Str.occrpt(unescape(o.code), 4);
				else
					objPrime.code = Str.unescape(Str.xmlUnescape(o.code));
				return objPrime;
			}
		}
		// continuationFn:Function<Object>
		public function selectAudio(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Audio"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		public function selectAvatar(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{				
				prepareData(_arrObjectsCache[id], continuationFn, failedFn, progressedFn);
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Avatar"), function (returnObj:Object):void
				{
					prepareData(returnObj, continuationFn, failedFn, progressedFn);
							
				}, failedFn, progressedFn);
			}		
			
			function prepareData(obj:Object, contFn:Function, failFn:Function = null, progressFn:Function = null):void
			{
				DBContentDataProviderFilesManager.downloadFile(obj['avtUrl'],DBContentDataProviderFilesManager.TYPE_ARCHIVE, function(fileDescArr:Array):void
				{
					var textureArr:Vector.<String> = new Vector.<String>;
					for (var i:int=0; i<fileDescArr.length; ++i)
					{
						if (OA1FileDesc(fileDescArr[i]).name.indexOf("texture")==0)
						{
							textureArr.push(obj['avtUrl'] + "?file="+OA1FileDesc(fileDescArr[i]).name);	
						}
						else
						{
							obj[OA1FileDesc(fileDescArr[i]).name+"Url"] = obj['avtUrl'] + "?file="+OA1FileDesc(fileDescArr[i]).name;
						}
					}
					obj["fullResTexUrls"] = textureArr;
					contFn(obj);
				}, failFn, progressFn);	
			}
			
		}
		public function selectMap(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			trace("select map not implemented");
		}
		
		public function selectAnimationBin(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "AnimationBin"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		public function selectAccessoryBin(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "AccessoryBin"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		public function selectMaterialConfigurationBin(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "MaterialConfigurationBin"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		public function selectMaterialBin(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "MaterialBin"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		public function selectDecalConfigurationBin(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "DecalConfigurationBin"), continuationFn, failedFn, progressedFn);
			}			
		}
		
		public function selectPreset(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Preset"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		public function selectTexture(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Texture"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		public function selectCategory(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Category"), continuationFn, failedFn, progressedFn);
			}				
		}
		
		public function selectAction(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Action"), continuationFn, failedFn, progressedFn);
			}				
		}
		
		public function selectDecalConfiguration(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "DecalConfiguration"), continuationFn, failedFn, progressedFn);
			}							
		}
		
		public function selectItem(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Item"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		// continuationFn:Function<Object>
		public function selectArea(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Area"), continuationFn, failedFn, progressedFn);
			}							
		}
		
		public function selectPackage(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Package"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		// continuationFn:Function<Object>
		public function selectCommand(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Command"), continuationFn, failedFn, progressedFn);
			}					
		}
		
		// continuationFn:Function<Object>
		public function selectProtocolBinding(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "ProtocalBinding"), continuationFn, failedFn, progressedFn);
			}						
		}

		// continuationFn:Function<Object>
		public function selectSwf(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Swf"), continuationFn, failedFn, progressedFn);
			}						
		}
		// continuationFn:Function<Object>
		public function selectAvatarParameter(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "AvatarParameter"), continuationFn, failedFn, progressedFn);
			}					
		}
		public function selectMapParameter(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "MapParameter"), continuationFn, failedFn, progressedFn);
			}						
		}
		// continuationFn:Function<Object>
		public function selectBlob(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				prepareData(_arrObjectsCache[id], continuationFn, failedFn, progressedFn);				
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Blob"), function(retObj:Object):void
				{
					prepareData(retObj, continuationFn, failedFn, progressedFn);										
				}, failedFn, progressedFn);
			}		
			
			function prepareData(obj:Object, contFn:Function, failFn:Function = null, progressFn:Function = null):void
			{
				downloadBinary(obj.url, function(ba:ByteArray):void
				{
					obj.data = ba;
					contFn(obj);
					
				}, failFn, progressFn);	
			}
		}
		// continuationFn:Function<Object>
		public function selectModel(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "Model"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		// continuationFn:Function<Object>
		public function selectFarNode(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if ( _arrObjectsCache[id]!=null)
			{
				continuationFn(_arrObjectsCache[id])
			}
			else
			{
				getSelectObjectXML(getNewXMLObject(nodeSetId, id, "FarNode"), continuationFn, failedFn, progressedFn);
			}						
		}
		
		//inserts
		public function insertAssociation(nodeSetId:int,parentType:String, parentId:int, childType:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		//function insertFarAssociation(parentNodeSet:INodeSet, parentType:String, parentId:int, childNodeSet:INodeSet, childType:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		public function insertFarAssociation(parentNodeSetId:int,parentType:String, parentId:int, childNodeSetId:int, childType:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertAccessory(nodeSetId:int, name:String, slotString:String, sceneData:ByteArray, maskMode:uint, defaultMaterialConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertSlot(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertGroup(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertSelector(nodeSetId:int, name:String, defaultType:String, defaultId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertMaterial(nodeSetId:int, name:String, perspectiveCorrectionEnabled:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertTextureMaterialLayer(nodeSetId:int, name:String, blendingMode:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertColorMaterialLayer(nodeSetId:int, name:String, blendingMode:int, value:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertMaterialConfiguration(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertFolder(nodeSetId:int, name:String, continuationFn:Function, failedfn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertMask(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertAnimation(nodeSetId:int, name:String, data:ByteArray, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertThumbnail(nodeSetId:int, name:String, data:BitmapData, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertScript(nodeSetId:int, name:String, code:String, isCompressed:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertAudio(nodeSetId:int, name:String, sound:Sound, hasViseme:Boolean, boundMorphName:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertAvatar(nodeSetId:int, name:String, configData:XML, data:ByteArray, disassembledTextures:Vector.<Vector.<ByteArray>>, lowResData:ByteArray, lowResTexture:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertPreset(nodeSetId:int, name:String, config:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertTexture(nodeSetId:int, name:String, img:Vector.<ByteArray>, transformStr:String, width:String, height:String, hasAlpha:String, byteCount:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertCategory(nodeSetId:int, name:String, preloads:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function insertAction(nodeSetId:int, name:String, protocolIdString:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}		
		
		// continuationFn<id:int>
		public function insertDecalConfiguration(nodeSetId:int, name:String, visible:Boolean, blendingMode:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		
		
		// continuationFn<id:int>
		public function insertItem(nodeSetId:int, name:String, data:ByteArray, slotString:String, defaultMaterialConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void		
		{}
		
		// continuationFn<id:int>
		public function insertArea(nodeSetId:int, name:String, config:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		public function insertPackage(nodeSetId:int, name:String, contentIdsString:String, autoUpdatingEnabled:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<id:int>
		public function insertCommand(nodeSetId:int, name:String, description:String, signatureString:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<id:int>
		public function insertProtocolBinding(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		public function insertSwf(nodeSetId:int, name:String, data:ByteArray, transformStr:String, width:String, height:String, byteCount:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		// continuationFn<id:int>
		public function insertAvatarParameter(nodeSetId:int, name:String, accessorySetId:String, avatarId:String, extra:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		// continuationFn<id:int>
		public function insertMapParameter(nodeSetId:int, name:String, itemSetId:String, mapId:String, extra:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		// continuationFn<id:int>		
		public function insertBlob(nodeSetId:int, name:String, data:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void		
		{}
		// continuationFn<id:int>
		public function insertModel(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<id:int>
		public function insertFarNode(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		
		
		//updates
		
		public function updateAccessory(nodeSetId:int, id:int, name:String, slotString:String, data:ByteArray, maskMode:uint, defaultMaterialConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateSlot(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateGroup(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateSelector(nodeSetId:int, id:int, name:String, defaultType:String, defaultId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateMaterial(nodeSetId:int, id:int, name:String, perspectiveCorrectionEnabled:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateTextureMaterialLayer(nodeSetId:int, id:int, name:String, blendingMode:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateColorMaterialLayer(nodeSetId:int, id:int, name:String, blendingMode:int, value:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateMaterialConfiguration(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateFolder(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateMask(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateAnimation(nodeSetId:int, id:int, name:String, data:ByteArray, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateThumbnail(nodeSetId:int, id:int, name:String, data:BitmapData, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateScript(nodeSetId:int, id:int, name:String, code:String, isCompressed:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateAudio(nodeSetId:int, id:int, name:String, data:Sound, hasViseme:Boolean, boundMorphName:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateAvatar(nodeSetId:int, id:int, name:String, configData:XML, fullResData:ByteArray, disassembledTextures:Vector.<Vector.<ByteArray>>, lowResData:ByteArray, texture:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updatePreset(nodeSetId:int, id:int, name:String, config:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function updateTexture(nodeSetId:int, id:int, name:String, img:Vector.<ByteArray>, transformStr:String, width:String, height:String, hasAlpha:String, byteCount:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{			
		}		
		
		public function updateCategory(nodeSetId:int, id:int, name:String, preloads:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{		
		}
		
		public function updateAction(nodeSetId:int, id:int, name:String, protocolIdString:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{		
		}
		
		// continuationFn<>
		public function updateDecalConfiguration(nodeSetId:int, id:int, name:String, visible:Boolean, blendingMode:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<uri:String>
		public function updateItem(nodeSetId:int, id:int, name:String, data:ByteArray, slotString:String, defaultMaterialConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<>
		public function updateArea(nodeSetId:int, id:int, name:String, config:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		public function updatePackage(nodeSetId:int, id:int, name:String, contentIdsString:String, autoUpdatingEnabled:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<>
		public function updateCommand(nodeSetId:int, id:int, name:String, description:String, argString:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<>
		public function updateProtocolBinding(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		public function updateProperty(nodeSetId:int, nodeId:int, propertyName:String, value:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<uri:String>
		public function updateSwf(nodeSetId:int, id:int, name:String, data:ByteArray, transformStr:String, width:String, height:String, byteCount:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<>
		public function updateAvatarParameter(nodeSetId:int, id:int, name:String, accessorySetId:String, avatarId:String, extra:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		// continuationFn<>
		public function updateMapParameter(nodeSetId:int, id:int, name:String, itemSetId:String, mapId:String, extra:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		// continuationFn<>
		public function updateBlob(nodeSetId:int, id:int, name:String, data:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		// continuationFn<>
		public function updateModel(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn<>
		public function updateFarNode(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}

		//deletes
		public function deleteAssociation(nodeSetId:int, parentType:String, parentId:int, childType:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteAllAssociations(nodeSetId:int, nodeType:String, nodeId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteFarAssociation(parentNodeSetId:int, parentType:String, parentId:int, childNodeSetId:int, childType:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteAllFarAssociations(nodeSetId:int, nodeType:String, nodeId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteAccessory(nodeSetId:int, accId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteSlot(nodeSetId:int, sloId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteSelector(nodeSetId:int, selId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteGroup(nodeSetId:int, grpId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteMaterial(nodeSetId:int, matId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteTextureMaterialLayer(nodeSetId:int, layerId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteColorMaterialLayer(nodeSetId:int, layerId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteMaterialConfiguration(nodeSetId:int, configId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteFolder(nodeSetId:int, folderId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteMask(nodeSetId:int, maskId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteAnimation(nodeSetId:int, animId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteThumbnail(nodeSetId:int, thumbId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteScript(nodeSetId:int, scriptId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteAudio(nodeSetId:int, soundId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteAvatar(nodeSetId:int, avatarId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deletePreset(nodeSetId:int, presetId:int, continuationFn:Function, failedFn:Function=null, progresedFn:Function=null):void
		{
		}
		
		public function deleteTexture(nodeSetId:int, decald:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function deleteCategory(nodeSetId:int, categoryId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{		
		}
		
		public function deleteAction(nodeSetId:int, actionId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{		
		}
		
		// continuationFn:Function<>
		public function deleteDecalConfiguration(nodeSetId:int, decalConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn:Function<>
		public function deleteItem(nodeSetId:int, itemId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn:Function<>
		public function deleteArea(nodeSetId:int, areaId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		public function deletePackage(nodeSetId:int, pkgId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn:Function<>
		public function deleteCommand(nodeSetId:int, cmdId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn:Function<>
		public function deleteProtocolBinding(nodeSetId:int, bndId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn:Function<>
		public function deleteSwf(nodeSetId:int, swfId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}

		// continuationFn:Function<>
		public function deleteAvatarParameter(nodeSetId:int, parameterId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}

		// continuationFn:Function<>
		public function deleteMapParameter(nodeSetId:int, parameterId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn:Function<>
		public function deleteBlob(nodeSetId:int, blobId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		// continuationFn:Function<>
		public function deleteModel(nodeSetId:int, modelId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}
		
		// continuationFn:Function<>
		public function deleteFarNode(nodesetId:int, farNodeId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{}

		//file
		
		public function uploadFileReference(file:FileReference, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function uploadText(data:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function uploadBinary(data:ByteArray, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			
		}
		
		public function uploadBitmap(data:BitmapData, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
		
		public function uploadDisassembledBitmap(data:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void		
		{
		}
		
		public function uploadSceneData(sceneData:SceneData, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
		}
	}
}
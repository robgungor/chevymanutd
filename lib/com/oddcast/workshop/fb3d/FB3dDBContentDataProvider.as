package com.oddcast.workshop.fb3d
{
	import com.oddcast.io.archiver.*;
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Jonathan Achai
	 */
	public class FB3dDBContentDataProvider extends DBContentDataProviderRead
	{
		
		private var _arrAvatars:Array;
		private var _arrAvatarUrls:Array;
		
		public function FB3dDBContentDataProvider() 
		{
			_arrAvatars = new Array();
			_arrAvatarUrls = new Array();			
		}
		
		/**
		 * get available scene commands
		 * @param sceneSetId - id of the scene
		 * @param contFn - continuation function is called with Vector.<String> of Command Names		 
		 */
		public function getSceneCommandNames(accessorySetId:int, sceneSetId:int, contFn:Function, failedFn:Function = null):void
		{
			var xml:XML = new XML("<?xml version='1.0' encoding='ISO-8859-1'?><FB3D></FB3D>");									
			xml.@sceneSetId = sceneSetId;	
			xml.@asId = accessorySetId;
			makeAPICall("selectSceneSetCommandsByAccessorySetId",xml,contFn,failedFn);						
		}			
		
		public function getAvatarByteArray(id:int):ByteArray
		{
			return _arrAvatars[id];
		}
		
		public function setAvatarUrl(id:int, url:String):void
		{
			_arrAvatarUrls[id] = url;
		}
		
		// continuationFn<id:int, configDataUrl:String, fullResDataUrl:String, fullResTexUrls:Vector.<String>, lowResDataUrl:String, lowResTexUrl:String>
		//public function insertAvatar(name:String, configData:XML, data:ByteArray, disassembledTextures:Vector.<Vector.<ByteArray>>, lowResData:ByteArray, lowResTexture:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void		
		override public function insertAvatar(nodeSetId:int, name:String, configData:XML, fullResData:ByteArray, disassembledTextures:Vector.<Vector.<ByteArray>>, lowResData:ByteArray, lowResTexture:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void		
		{						
			var oa1BA:ByteArray = createAvatarOA1(configData,fullResData,disassembledTextures, lowResData,lowResTexture);
			var d:Date = new Date();
			var timestamp:int = int(d.getTime());
			_arrAvatars[timestamp] = oa1BA;			
			continuationFn(timestamp, "avtUrl?file=0", "avtUrl?file=1", new Vector.<String>(), "avtUrl?file=2", "avtUrl?file=3"); //fake call			
		}
		
		//override public function insertAssociation(parent:String, parentId:int, child:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void		
		override public function insertAssociation(nodeSetId:int, parentType:String, parentId:int, childType:String, childId:int, continuationFn:Function, failedFn:Function = null, progressedFn:Function = null):void
		{		
			continuationFn(0);			
		}
		
		override public function selectAvatar(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			var returnObj:Object = new Object();									
			returnObj['objectId'] = id;
			returnObj['name'] = "Avatar";
			returnObj['objectTypeId'] = 16;
			returnObj['avtUrl'] = _arrAvatarUrls[id];
			
			DBContentDataProviderFilesManager.downloadFile(returnObj['avtUrl'],DBContentDataProviderFilesManager.TYPE_ARCHIVE, function(fileDescArr:Array):void
			{
				var textureArr:Vector.<String> = new Vector.<String>;
				for (var i:int=0; i<fileDescArr.length; ++i)
				{
					if (OA1FileDesc(fileDescArr[i]).name.indexOf("texture")==0)
					{
						textureArr.push(returnObj['avtUrl'] + "?file="+OA1FileDesc(fileDescArr[i]).name);	
					}
					else
					{
						returnObj[OA1FileDesc(fileDescArr[i]).name+"Url"] = returnObj['avtUrl'] + "?file="+OA1FileDesc(fileDescArr[i]).name;
					}
				}
				returnObj["fullResTexUrls"] = textureArr;
				continuationFn(returnObj);
			}, failedFn, progressedFn);				
		}
		
		public function createAvatarOA1(configData:XML, fullResData:ByteArray, disassembledTextures:Vector.<Vector.<ByteArray>>, lowResData:ByteArray, lowResTex:Vector.<ByteArray>):ByteArray
			//public function createAvatarOA1(configData:XML, fullResData:XML, lowResData:XML, lowResTexture:BitmapData):ByteArray
		{
			var archiver:OA1Archiver = new OA1Archiver();
			archiver.addFile(new OA1FileDesc('configData',escape(configData.toString())));
			archiver.addFile(new OA1FileDesc('fullResData',fullResData, false, false));
			if (disassembledTextures!=null)
			{
				for (var i:int=0; i< disassembledTextures.length; ++i)
				{
					archiver.addFile(new OA1FileDesc('texture'+i, createTextureOA1(disassembledTextures[i]), false, false));
				}
			}
			if (lowResData!=null)
			{
				archiver.addFile(new OA1FileDesc('lowResData', lowResData, false, false));
			}
			if (lowResTex!=null)
			{						
				archiver.addFile(new OA1FileDesc('lowResTex',createTextureOA1(lowResTex),false,false));
			}			
			return archiver.createArchive();
		}
		
		private function createTextureOA1(data:Vector.<ByteArray>):ByteArray
		{
			var archiver:OA1Archiver = new OA1Archiver();
			for (var i:uint=0; i<data.length; ++i)
			{
				var ba:ByteArray = data[i];
				archiver.addFile(new OA1FileDesc("file1",ba, false, false));	
			}
			return archiver.createArchive();
		}
		
	}
	
}
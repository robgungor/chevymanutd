/**
* ...
* @author Sam
* @version 1.0
* 
* data structure that parses workshop xml and stores message data
* 
* *********** PROPERTIES **************
* 
* mid - message id
* replyTo, from, messageTxt - name, email, and message of sender
* sceneArr - an array of SceneStruct objects
* extraData - extra custom data
* 
* the following are for convenience and backwards-compatilibility for messages with only one scene:
* 
* model - Model data structure
* audio - Audio datastructure
* bg - Background data structure
* hostMatrix - Matrix transform that stores x,y, and scaling of host
*         - you can apply matrix to movieclip by calling :  mc.transform.matrix=hostPos
* 		  - you can get x,y,etc. with MoveZoomUtil.matrixToObject(hostPos);
* 
* 
* *********** FUNCTIONS ***************
* 
* parseXML(_xml) - parse xml from getWorkhopInfo.php script
*/

package com.oddcast.workshop {
	import com.oddcast.assets.structures.EngineStruct;
	import com.oddcast.assets.structures.LoadedAssetStruct;
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.audio.TTSVoice;
	import com.oddcast.utils.MoveZoomUtil;
	import flash.geom.Matrix;
	import flash.net.URLVariables;

	public class WorkshopMessage {		
		public var mid:int;
		public var messageTxt:String;
		public var from:String;
		public var replyTo:String;
		
		/*private var xpos:Number;
		private var ypos:Number;
		private var scale:Number;*/
		
		public var sceneArr:Array;
		
		public var extraData:URLVariables;
		public var searchStr:String
		//public var isAutoPhoto:Boolean;
		//public var autoPhoto_sessionId:String;
		//private var vme, userId,affId:int;
		
		public function WorkshopMessage(in_messageId:int) {
			mid=in_messageId;
		}
		
		public function parseXML(_xml:XML) : void {
			var audioAssets:Array=new Array();
			var ttsAudioAssets:Array=new Array();
			var modelAssets:Array=new Array();
			var bgAssets:Array = new Array();
			var videoAssets:Array = new Array();
			var engineAssets:Array = new Array();
			var keyFileAssets:Array = new Array();
			
			var xasset:XML;
			var assetId:int;
			var assetList:XMLList;
			var i:int;
			var j:int;
			var engine:EngineStruct;
			
			assetList=_xml.assets.elements("engine");
			for (i=0;i<assetList.length();i++) {
				xasset = assetList[i];
				assetId = parseInt(xasset.@id.toString());
				engine = new EngineStruct(xasset.@url.toString(), assetId);
				engine.ctlUrl = xasset.@ctl.toString();
				engine.type = xasset.@type.toString();
				engineAssets[assetId] = engine;
			}
			
			
			/*if (engine3d == null) {
				trace("NO ENGINE FOUND -- USING DEFAULT ENGINE");
				var ohEngineUrl:String = (ServerInfo.staging?"http://char.dev.oddcast.com/":"http://char.oddcast.com/") + "engines/3D/v1/engineH3Dv1.swf";
				engine3d=new EngineStruct(ohEngineUrl);
			}*/
			
			assetList = _xml.assets.elements("avatar");
			var ohBaseUrl:String = _xml.params.oh_base_url.toString();
			for (i=0;i<assetList.length();i++) {
				xasset=assetList[i];
				assetId = parseInt(xasset.@id.toString());
				var engineId:int=parseInt(xasset.@engine.toString());
				var modelType:String;
				var modelIs3D:Boolean;
				if (xasset.hasOwnProperty("type")) {
					modelType = xasset.@type.toString();
					modelIs3D= (modelType == "3D");
				}
				else modelIs3D = (xasset.@is3d.toString() == "1"); //for backwards compatibility
				var modelUrl:String;
				if (modelIs3D) modelUrl = xasset.toString();
				else modelUrl = ohBaseUrl + xasset.toString();
				
				var modelId:int=parseInt(xasset.@modelId.toString());
				var modelObj:WSModelStruct=new WSModelStruct(modelUrl,modelId,"","");
				modelObj.is3d = modelIs3D;
				modelObj.charId = assetId;
				modelObj.engine = engineAssets[engineId];
				if (modelObj.engine == null) {
					throw new Error("WorkshopMessage : ERROR in playScene.php - there is no engine for avatar with id " + assetId);
				}
				modelObj.type = modelType;
				modelAssets[assetId]=modelObj;
			}
			
			assetList=_xml.assets.elements("audio");
			for (i=0;i<assetList.length();i++) {
				xasset=assetList[i];
				var audioObj:AudioData;
				
				var audioType:String = xasset.@type.toString();
				var isTTS:Boolean = xasset.hasOwnProperty("text");
				if (isTTS) {
					assetId=parseInt(xasset.@id.toString());
					var ttsText:String=unescape(unescape(xasset.text.toString()));
					var ttsVoice:TTSVoice=new TTSVoice();
					ttsVoice.setFromWorkshopCode(xasset.voice.toString());
					audioObj=new TTSAudioData(ttsText,ttsVoice);
					//ttsAudioAssets[assetId]=audioObj;
					audioAssets[assetId]=audioObj;
					trace("WorkshopMessage::creating audio : "+ttsText+" - "+ttsVoice+" = "+audioObj.url);
				}
				else {
					assetId=parseInt(xasset.@id.toString());
					var audioUrl:String=xasset.toString();
					if (audioUrl.lastIndexOf(".")<=audioUrl.lastIndexOf("/")) audioUrl+=".mp3";
					audioObj=new AudioData(audioUrl,assetId,audioType,"");
					audioAssets[assetId]=audioObj;
				}				
			}
			
			assetList=_xml.assets.elements("bg");
			for (i=0;i<assetList.length();i++) {
				xasset=assetList[i];
				assetId=parseInt(xasset.@id.toString());
				bgAssets[assetId]=new WSBackgroundStruct(xasset.toString(),assetId,"", xasset.@name.toString());
			}
			
			assetList = _xml.assets.elements("video");
			var vid:WSVideoStruct;
			for (i=0;i<assetList.length();i++) {
				xasset=assetList[i];
				var vidId:int = parseInt(xasset.@vidId.toString());
				vid = new WSVideoStruct(xasset.toString(), vidId);
				vid.duration = parseFloat(xasset.@length.toString()) / 1000;
				vid.spliceTime = parseFloat(xasset.@endEditDuration.toString()) / 1000;
				videoAssets[xasset.@id.toString()] = vid;
			}
			
			assetList=_xml.assets.elements("keyfile");
			for (i=0;i<assetList.length();i++) {
				xasset=assetList[i];
				assetId=parseInt(xasset.@id.toString());
				keyFileAssets[assetId]=new LoadedAssetStruct(xasset.toString(),assetId);
			}
			
			// put the scene together with the assets...
			
			var xscene:XML;

			var scene:SceneStruct;
			sceneArr = new Array();
			
			for (i = 0; i < _xml.scenes.scene.length();i++) {
				xscene = _xml.scenes.scene[i];
				scene = new SceneStruct();
				scene.id = parseInt(xscene.id.toString());
				
				var char:WSSceneCharStruct;
				assetList = xscene.elements("avatar");
				for (j = 0; j < assetList.length();j++) {
					xasset = assetList[j];
					assetId = parseInt(xasset.id.toString());
					
					var hostPos:Object = new Object();
					hostPos.x = parseFloat(xasset.x.toString());
					hostPos.y = parseFloat(xasset.y.toString());
					hostPos.scaleX = hostPos.scaleY = parseFloat(xasset.scale.toString()) / 100;
					
					char = new WSSceneCharStruct(modelAssets[assetId]);
					char.pos = MoveZoomUtil.objectToMatrix(hostPos);
					
					var keyFileId:int;
					if (xasset.hasOwnProperty("keyfile")) {
						keyFileId=parseInt(xasset.keyfile.@id.toString());
						char.keyFile = keyFileAssets[keyFileId];
					}
					scene.modelArr.push(char);
				}
				
				assetList = xscene.elements("audio");
				for (j = 0; j < assetList.length();j++) {
					xasset = assetList[j];
					if (xasset.elements("id").length() == 0) continue;
					assetId=parseInt(xasset.id.toString())
					scene.audioArr.push(audioAssets[assetId]);
				}
				
				assetList = xscene.elements("bg");
				for (j = 0; j < assetList.length();j++) {
					xasset = assetList[j];
					assetId=parseInt(xasset.id.toString())
					scene.bgArr.push(bgAssets[assetId]);
				}
				
				assetList = xscene.elements("video");
				for (j = 0; j < assetList.length();j++) {
					xasset = assetList[j];
					assetId=parseInt(xasset.id.toString())
					scene.videoArr.push(videoAssets[assetId]);
				}

				sceneArr.push(scene);
			}
			sceneArr.sortOn("id", Array.NUMERIC);
			
			messageTxt=_xml.message.body.toString();
			from=_xml.message.from.name.toString();
			replyTo = _xml.message.from.email.toString();
			
			
			var extraDataStr:String = unescape(_xml.extradata.toString());
			trace("extraData = '" + extraDataStr + "'");
			if (extraDataStr != null && extraDataStr.length > 0) {
				try {
					extraData = new URLVariables(extraDataStr);
				}
				catch (e:Error) {
					extraData = null;
					trace("Invalid Extra Data");
				}
			}
			else extraData = new URLVariables();
			
			searchStr = unescape(_xml.searchdata.toString());
		}
		
		public function get bg():WSBackgroundStruct {
			if (sceneArr && sceneArr[0])
				return(sceneArr[0].bg);
			return null;
		}
		public function get model():WSModelStruct {
			if (sceneArr && sceneArr[0])
				return(sceneArr[0].model);
			return null;
		}
		public function get audio():AudioData {
			if (sceneArr && sceneArr[0])
				return(sceneArr[0].audio);
			return null;
		}
		public function get hostMatrix():Matrix {
			if (sceneArr && sceneArr[0])
				return(sceneArr[0].hostMatrix);	
			return null;		
		}
		
		/*
		public function get extraVars():URLVariables { //to be deprecated...
			trace("please, could you change extraVars to extraData");
			return(extraData);
		}*/
	}
	
}
/**
* ...
* @author Sam
* @version 0.1
* 
* class for saving workshop xml:
* 
* ********** FUNCTIONS **********
* 
* saveWorkshop(saveEvent:SendEvent, scene:Array or SceneStruct, extraData:URLVariables,tags:String,params:MessageParams) - 
* saveEvent - the SendEvent object usually returned by the email/post panels.
*           - saveEvent.message is the XML containing email to/from, post title, body etc that will be placed directly into the saving xml
* 			- saveEvent.sendMode is the sending mode (Sendevent.EMAIL, SendEvent.POST, etc.)
* scene     - is 1) an array of SceneStruct objects containing all the scene information to be saved (audio, bg, model, etc.)
* 			- or 2) you can also pass a single SceneStruct object if you only have one scene
* extraData - is an optional URLVariables object containing custom data to be saved 
* tags		- is an optional String containing tags to be saved for sql searching later
* params	- is a MessageParams object containing all additional saving information (language, etc.)
* 
* 
* resend(saveEvent,mid,extraData,tags,params) - sends a message that has already been saved
* instead of sending a SceneStruct object, send the mId
* e.g. if you have already got the embed code for a message, and you want to email it, use this function with the mid.
* 
* 
* ********* CALLBACKS ************
* ProcessingEvent.STARTED / ProcessingStarted.DONE
* dispatched when processing starts and finishes - type is "saving"
* 
* SendEvent.DONE - dispatched when sending is done
* AlertEvent.ERROR - in case of error
*/

package com.oddcast.workshop {
	import com.dynamicflash.util.Base64;
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.MoveZoomUtil;
	import com.oddcast.utils.MultipartFormPoster;
	import com.oddcast.utils.XMLLoader;
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.navigateToURL;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import com.oddcast.event.SendEvent;
	import flash.utils.Timer;

	public class WorkshopSaver extends EventDispatcher {
		private var saving:Boolean=false;
		private var saveEvent:SendEvent;
		private var sceneArr:Array;  //array of SceneStruct objects
		private var extraData:URLVariables;
		private var tags:String;
		private var msgParams:MessageParameters;
		private var formPoster:MultipartFormPoster;
		private var saveOA1SceneId:int;
		private var checkSavedTimer:Timer;
		
		private var lastMid:String;
		
		public function WorkshopSaver() {
			checkSavedTimer = new Timer(250, 120);
		}

		/* saveEvent - the SendEvent object containing message XML and sendMode
		scene  - a SceneStruct or an array of SceneStruct objects containing audio, bg, model, etc.
		extraData - an optional URLVariables object containing custom data to be saved 
		tags	- is an optional String containing tags to be saved for sql searching later
		params	- is a MessageParams object containing all additional saving information (language, etc.)*/
		public function saveWorkshop(in_saveEvent:SendEvent, in_scene:*, in_extraData:URLVariables, in_tags:String = null,in_params:MessageParameters=null):void
		{
			//----trace("WorkshopSaver::saveWorkshop - type=" + in_saveEvent.sendMode);
			if (saving) return;
			trace("start delay");
			saving = true;
			
			if (in_scene is SceneStruct) sceneArr = [in_scene];
			else if (in_scene is Array) {
				sceneArr = in_scene as Array;
				if (sceneArr.length == 0 && !(sceneArr[0] is SceneStruct)) {
					sceneArr = null;
					throw new TypeError("in_scene must be a SceneStruct or an array of 1 or more SceneStruct objects")
					return;
				}
			}
			else {
				throw new TypeError("in_scene must be a SceneStruct or an array of 1 or more SceneStruct objects");
				return;
			}
			
			saveEvent=in_saveEvent;
			extraData = in_extraData;
			tags = in_tags;
			msgParams = in_params;
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,"saving"));
			/*if (scene.hasUploadPhoto()&&scene.bg!=null&&scene.bg.isUploadPhoto) {
				//if user has uploaded a photo, call crop image and wait before
				//calling the send function
				//photoUploadUI.cropImage();
			}
			else sendHost();*/
			sendHost();
		}
			
		public function destroy():void
		{
			checkSavedTimer.removeEventListener(TimerEvent.TIMER, checkSaveInterval);
			checkSavedTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, checkSaveTimeout);
			checkSavedTimer = null;
			if (formPoster != null)
			{
				formPoster.removeEventListener(Event.COMPLETE, oa1BinaryUploaded);
				formPoster.removeEventListener(ErrorEvent.ERROR, oa1BinaryUploadError);
				formPoster = null;
			}
			msgParams = null;
			
		}
				
		private function sendHost():void
		{
			//----trace("WorkshopSaver::sendHost");
			saveOA1SceneId = -1;
			if (checkSaved()) saveOA1();
			else {
				checkSavedTimer.reset();
				checkSavedTimer.addEventListener(TimerEvent.TIMER, checkSaveInterval);
				checkSavedTimer.addEventListener(TimerEvent.TIMER_COMPLETE, checkSaveTimeout);
				checkSavedTimer.start();
			}
		}
		
		private function checkSaveInterval(evt:TimerEvent):void 
		{
			if (checkSaved()) {
				checkSavedTimer.removeEventListener(TimerEvent.TIMER, checkSaveInterval);
				checkSavedTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, checkSaveTimeout);
				checkSavedTimer.stop();
				saveOA1();
			}
		}
		
		private function checkSaveTimeout(evt:TimerEvent):void
		{
			checkSavedTimer.removeEventListener(TimerEvent.TIMER, checkSaveInterval);
			checkSavedTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, checkSaveTimeout);
			onError(new AlertEvent(AlertEvent.ERROR, "f9t510", "There was an error saving the model - saving process timed out."));
		}
		
		private function checkSaved():Boolean 
		{
			return(checkSavedProgress() > 0.999);
		}
		
		private function checkSavedProgress():Number 
		{
			var totalPercent:Number = 0;
			var totalScenes:uint = 0;
			var scene:SceneStruct;
			for (var i:int = 0; i < sceneArr.length; i++) {
				scene = sceneArr[i];
				if (scene.hasFileData && scene.ohUrl == null) {
					
					totalScenes++;
					totalPercent += scene.optimizedHost.progress;
				}
			}
			var saveProgress:Number = (totalScenes == 0) ? 1 : (totalPercent / totalScenes);
			//----trace("WorkshopSaver::checkSavedProgress = " + saveProgress);
			return(saveProgress);
		}
		
		private function saveOA1():void 
		{
			//----trace("WorkshopSaver::saveOA1");
			//determine if there is a scene whose optimized host needs saving
			var scene:SceneStruct;
			var sceneId:int = -1;
			
			//when the 3d engine saves a model, it returns a byte array
			//that byte array is stored in the optimizedHost variable, and the ohUrl is set to null
			//so if this scene has a 3d model, and the optimizedHost is non-null and the ohUrl is null,
			//the optimizedHost binary data must be saved to produce the ohUrl
			for (var i:int = saveOA1SceneId + 1; i < sceneArr.length; i++) {
				scene = sceneArr[i];
				if (scene.hasFileData && scene.ohUrl == null) {
					sceneId = i;
					break;
				}
			}
			
			if (sceneId == -1) {
				//if sceneId==-1, there are no models that need saving, so we can proceed to the main save script
				doSendHost();
			}
			else {
				//sceneId>=0, therefore we need to save this scene model.  when the model is saved, we will call
				//this function sendOA1() again to see if any more scenes with models that need saving
				//save the sceneId which will be saved in the saveOA1SceneId variable
				saveOA1SceneId = sceneId;
				
				var versionString:String = Capabilities.version.split(" ")[1];
				var versionNum:int = parseInt(versionString.split(",")[0]);
				//----trace("flash version is " + versionNum);
				//if (versionNum == 10) uploadOA1AsBase64(scene.optimizedHost.byteArray);
				//else uploadOA1Binary(scene.optimizedHost.byteArray);
				uploadOA1AsBase64(scene.optimizedHost.byteArray);
			}
		}
		
		private function uploadOA1Binary(oa1Binary:ByteArray):void 
		{
			formPoster=new MultipartFormPoster();
			formPoster.addEventListener(Event.COMPLETE, oa1BinaryUploaded);
			formPoster.addEventListener(ErrorEvent.ERROR, oa1BinaryUploadError);
			var url:String=ServerInfo.localURL+"api/oa1Uploader.php?rand="+Math.floor(Math.random()*1000000).toString();
			formPoster.addFile("Filedata",oa1Binary,"application/octet-stream","Filedata");
			formPoster.addVariable("doorId",ServerInfo.door.toString());
			formPoster.post(url);
			//----trace("WorkshopSaver::uploadOA1Binary : oa1 file length="+oa1Binary.length);			
		}
		
		private function oa1BinaryUploaded(evt:Event):void 
		{
			formPoster.removeEventListener(Event.COMPLETE, oa1BinaryUploaded);
			formPoster.removeEventListener(ErrorEvent.ERROR, oa1BinaryUploadError);
			oa1Saved(evt.target.data.toString());
		}
		
		private function oa1BinaryUploadError(evt:ErrorEvent):void 
		{
			formPoster.removeEventListener(Event.COMPLETE, oa1BinaryUploaded);
			formPoster.removeEventListener(ErrorEvent.ERROR, oa1BinaryUploadError);
			sendError(evt);
		}
		
		protected function uploadOA1AsBase64(oa1Binary:ByteArray):void 
		{
			var oa1Base64:String = Base64.encodeByteArray(oa1Binary);
			trace("WorkshopSaver::uploadOA1AsBase64 : oa1 binary length="+oa1Binary.length+"  oa1 base64 length="+oa1Base64.length);
			
			var url:String=ServerInfo.localURL+"api/oa1Uploader.php?rand="+Math.floor(Math.random()*1000000).toString();
			var postVars:URLVariables = new URLVariables();
			postVars.FileDataBase64 = oa1Base64;
			postVars.doorId = ServerInfo.door.toString();
			XMLLoader.sendAndLoad(url, oa1Base64Uploaded, postVars,String);
		}
		
		protected function oa1Base64Uploaded(s:String):void 
		{
			if (s == null) sendError(new ErrorEvent(ErrorEvent.ERROR,false,false,XMLLoader.lastError));
			else oa1Saved(s);
		}
		
		private function oa1Saved(url:String):void 
		{
			if (url.indexOf("http://") == -1) {
				sendError(new ErrorEvent(ErrorEvent.ERROR,false,false,url));
				return;
			}
			
			var scene:SceneStruct = sceneArr[saveOA1SceneId];
			if (url == null) url = ""; //set ohUrl to non-null so we don't save this oa1 again in infinite loop
			scene.ohUrl = url;
			saveOA1(); //repeat to see if any more scenes need saving
		}
		
		private function doSendHost():void 
		{
			var scene:SceneStruct = sceneArr[0];
			
			//----trace("WorkshopSaver::sendHost");
			
			var url:String;
			//if (ServerInfo.appType==ServerInfo.WORKSHOP_APP) url=ServerInfo.localURL+"sendMessage2.php";
			//else url = ServerInfo.localURL + "videostar/sendMessage.php";
			if (saveEvent.sendMode == SendEvent.EMAIL) url = ServerInfo.localURL + "api/sendMessage.php";
			else if (saveEvent.sendMode == SendEvent.POST) url = ServerInfo.localURL+"galleryAPI/postToGallery.php";
			else url = ServerInfo.localURL + "api/saveWorkshopData.php";
			
			var saveXML:XML=getSaveXML();
			trace("SAVE MESSAGE jul16 : " + saveXML);
			
			var vars:URLVariables = new URLVariables();
			vars.xmlData = saveXML;
			XMLLoader.sendVars(url,sendDone,vars)
			
			/*
			formPoster=new MultipartFormPoster();
			formPoster.addEventListener(Event.COMPLETE,sendDone,false,0,true);
			formPoster.addEventListener(ErrorEvent.ERROR,sendError,false,0,true);			
			formPoster.addVariable('xmlData',escape(saveXML.toXMLString()));
			formPoster.post(url);*/
		}
		
		//resend sends a message that has already been saved.  called with mid instead of SceneStruct Object
		public function resend(in_saveEvent:SendEvent,mid:String=null,in_extraData:URLVariables=null,in_tags:String = null,in_params:MessageParameters=null):void
		{
			saveEvent=in_saveEvent;
			var useMid:String = (mid == null) ? lastMid : mid;
			//----trace("WorkshopSaver::resend - type=" + saveEvent.sendMode);
			
			/*   for embed you can dispatch an event immediately - need to test if this will break stuff before i implement it
			if (saveEvent.sendMode == SendEvent.EMBED_CODE) {
				var reply:XML = new XML("<AUTOREPLY MID="+useMid+" />");
				dispatchEvent(new SendEvent(SendEvent.DONE, saveEvent.sendMode, reply));
			}
			*/
			
			if (extraData == null) extraData = in_extraData;
			tags = in_tags;
			msgParams = in_params;
			
			var url:String;

			if (saveEvent.sendMode==SendEvent.EMAIL) url = ServerInfo.localURL + "api/sendMessage.php";
			else if (saveEvent.sendMode == SendEvent.POST) url = ServerInfo.localURL+"galleryAPI/postToGallery.php";
			else url = ServerInfo.localURL + "api/saveWorkshopData.php";
			
			var node:XML = new XML("<player />")
			var paramsNode:XML = getParamsNode();
			paramsNode.mid =useMid
			node.appendChild(paramsNode);
			
			if (saveEvent.messageXML!=null) node.message=saveEvent.messageXML;
			if (extraData != null) node.extradata = extraData.toString();
			
			trace("SAVE MESSAGE : "+node);
			
			var vars:URLVariables = new URLVariables();
			vars.xmlData = node;
			XMLLoader.sendVars(url,sendDone,vars)
		}
		
		private function getSaveXML():XML {
			var node:XML=new XML("<player />")
			node.appendChild(getParamsNode());
			
			node.assets = new XML();
			node.scenes=new XML();
			var scene:SceneStruct;
			var modelArr:Array = new Array();
			var bgArr:Array = new Array();
			var audioArr:Array = new Array();
			var videoArr:Array = new Array();
			var i:int;
			var j:int;
			var sceneXML:XML;
			for (i = 0; i < sceneArr.length; i++) {
				scene = sceneArr[i];
				if (scene.model != null) node.assets.appendChild(getModelXML(scene.model, scene));
				
				for (j = 0; j < scene.bgArr.length;j++) pushUnique(bgArr, scene.bgArr[j]);
				for (j = 0; j < scene.audioArr.length;j++) pushUnique(audioArr, scene.audioArr[j]);
				for (j = 0; j < scene.videoArr.length;j++) pushUnique(videoArr, scene.videoArr[j]);
				
				sceneXML = getSceneXML(scene);
				sceneXML.id = (i + 1).toString();
				node.scenes.appendChild(sceneXML);
			}
			
			for (i = 0; i < bgArr.length; i++) node.assets.appendChild(getBGXML(bgArr[i]));
			for (i = 0; i < audioArr.length; i++) node.assets.appendChild(getAudioXML(audioArr[i]));
			for (i = 0; i < videoArr.length; i++) node.assets.appendChild(getVideoXML(videoArr[i]));
			
			if (saveEvent.messageXML!=null) node.message=saveEvent.messageXML;
			
			if (extraData != null) node.extradata = extraData.toString();
			if (tags != null) node.searchdata = escape(tags);
			
			return(node);
		}
		
		private function pushUnique(arr:Array, obj:Object):void { //don't allow null or duplicate items in array
			if (obj != null && arr.indexOf(obj) < 0) arr.push(obj);
		}
		
		private function getParamsNode():XML {
			var paramsNode:XML = new XML("<params />");
			paramsNode.door=ServerInfo.door.toString();
			paramsNode.client=ServerInfo.client.toString();
			paramsNode.topic = ServerInfo.topic.toString();
			if (saveEvent.sendMode == SendEvent.EMAIL || saveEvent.sendMode == SendEvent.POST) paramsNode.mode = saveEvent.sendMode;
			else paramsNode.mode = SendEvent.EMBED_CODE;
			
			//paramsNode.mode=saveEvent.sendMode;
			paramsNode.appType = ServerInfo.appType;
			if (msgParams!=null) {
				if (msgParams.language!=null) paramsNode.lang = msgParams.language;
				if (msgParams.optIn != null) paramsNode.optIn = msgParams.optIn;
			}
			return(paramsNode);
		}
		
		private function getSceneXML(scene:SceneStruct):XML {
			var node:XML=new XML("<scene />")
			var i:int;
			
			if (scene.model!=null) {
				var modelNode:XML = new XML("<avatar />");
				//modelNode.id = scene.model.id.toString();
				modelNode.tempid = scene.model.tempId.toString();
				var hostPos:Object = MoveZoomUtil.matrixToObject(scene.hostMatrix);
				modelNode.x=hostPos.x.toFixed(2);
				modelNode.y=hostPos.y.toFixed(2);
				modelNode.scale=(hostPos.scaleX*100).toFixed(2);
				node.appendChild(modelNode);
			}
			
			var audio:AudioData;
			if (scene.audioArr != null)	for (i = 0; i < scene.audioArr.length; i++) {
				audio = scene.audioArr[i];
				var audioNode:XML=new XML("<audio />");
				if (audio.hasId) audioNode.id=audio.id.toString();
				else audioNode.tempid=audio.tempId.toString();
				
				node.appendChild(audioNode);
			}
			
			var bg:WSBackgroundStruct;
			if (scene.bgArr!=null) for (i = 0; i < scene.bgArr.length; i++) {
				bg = scene.bgArr[i];
				node.bg=new XML();
				if (bg.hasId) node.bg.id=bg.id.toString();
				else node.bg.tempid=bg.tempId.toString();
			}
			
			var video:WSVideoStruct;
			if (scene.videoArr != null) for (i = 0; i < scene.videoArr.length; i++) {
				//----trace("videoArr.length = "+scene.videoArr.length+"  videoArr[0]="+scene.videoArr[0])
				video = scene.videoArr[i];
				node.video=new XML();
				if (video.hasId) node.video.id=video.id.toString();
				else node.video.tempid=video.tempId.toString();
			}
			
			return(node);
		}

		/*private function getAssetXML(asset:*):XML {
			if (asset is WSModelStruct) return(getModelXML(asset as WSModelStruct));
			else if (asset is WSBackgroundStruct) return(getBGXML(asset as WSBackgroundStruct));
			else if (asset is AudioData) return(getAudioXML(asset as AudioData));
			else if (asset is WSVideoStruct) return(getVideoXML(asset as WSVideoStruct));
			else return(new XML());
		}*/
		
		private function getModelXML(model:WSModelStruct,scene:SceneStruct):XML {
			var node:XML = new XML("<avatar />");
			node.@modelId=model.id; //modelId
			node.@tempid = model.tempId;
			node.@type = model.is3d?"3D":"2D";
			node.@is3d = model.is3d?"1":"0";
			node.appendChild(scene.ohUrl);
			return(node);
		}
		
		private function getBGXML(bg:WSBackgroundStruct):XML {
			var node:XML=new XML("<bg />");	
			if (bg.hasId) node.@id=bg.id;
			else node.@tempid = bg.tempId;
			if (bg.name!=null) node.@name = escape(bg.name);
			node.appendChild(bg.url);
			return(node);			
		}
		
		private function getVideoXML(vid:WSVideoStruct):XML {
			var node:XML=new XML("<video />");	
			if (vid.hasId) node.@id=vid.id;
			else node.@tempid = vid.tempId;
			if (vid.name != null) node.@name = escape(vid.name);
			trace("WorkshopSaver::getVideoXML - vid.isVideoStar : " + vid.isVideostar);
			if (vid.isVideostar) {
				node.@vidId = vid.videostarSource.id.toString();
				node.@length = vid.videostarSource.duration.toString();
			}
			node.appendChild(vid.url);
			return(node);			
		}
		
		private function getAudioXML(audio:AudioData):XML {
			var node:XML = new XML("<audio />");
			
			if (audio.type == null || audio.type.length == 0) throw(new Error("Audio must have a valid type in order to save it."));
			else if (audio.type == AudioData.UPLOADED||audio.type==AudioData.USER_GENERIC) node.@type = AudioData.PHONE;
			else node.@type=audio.type;
			
			if (audio.hasId) node.@id=audio.id;
			else node.@tempid = audio.tempId;
			
			if (audio.name != null) node.@name = escape(audio.name);
			
			if (audio is TTSAudioData) {
				var ttsAudio:TTSAudioData=audio as TTSAudioData;
				node.voice=ttsAudio.voice.getWorkshopCode();
				node.text=escape(ttsAudio.text);				
				if (ttsAudio.fx!=null) {
					node.fx_type=ttsAudio.fx.type;
					node.fx_level=ttsAudio.fx.level;
				}
			}
			else {
				node.appendChild(audio.url);
			}
			return(node);
		}

	//send object callback

		public function sendDone(_xml:XML):void 
		{
			saving=false;
			if (_xml == null) {
				//onError(new AlertEvent(AlertEvent.ERROR, "f9t511", "Could not load sending script : " + XMLLoader.lastError));
				onError(new AlertEvent(AlertEvent.ERROR, "f9t511", "Could not load sending script.  Please check your connection."));
				return;
			}
			else if (_xml.name()==null||_xml.toXMLString().length == 0) {
				onError(new AlertEvent(AlertEvent.ERROR, "f9t512", "Sending script returned no data"));
				return;
			}
			else if (_xml.name()!=null&&_xml.name().toString() == "APIERROR" || _xml.@ERRORSTR.toString().length > 0) {
				//dispatchEvent(new AlertEvent(AlertEvent.ERROR,"saveError",_xml.@ERRORSTR));
				onError(new AlertEvent(AlertEvent.ERROR, _xml.@CODE, unescape(_xml.@ERRORSTR)));
				return;
			}
			else if (_xml.name().toString() != "MESSAGE") {
				onError(new AlertEvent(AlertEvent.ERROR, "f9t513", "Sending script returned improper data : '"+_xml.toXMLString()+"'"));
				return;				
			}
			//----trace("send done : " + _xml.toXMLString())

			lastMid = _xml.@MID;
			if (parseInt(lastMid) <= 0) {
				onError(new AlertEvent(AlertEvent.ERROR, "f9t513", "Sending script returned improper data : invalid message ID "+lastMid));
				return;				
			}
			
			//processing_send._visible=false;
			trace("res : "+_xml.@RES.toString())
			var result:String=unescape(_xml.@RES.toString()).toUpperCase();
			
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,"saving"));
			dispatchEvent(new SendEvent(SendEvent.DONE,saveEvent.sendMode,_xml));
		}
		
		private function sendError(evt:ErrorEvent):void
		{
			onError(new AlertEvent(AlertEvent.ERROR,"f9t514","Error uploading oa1 file : "+evt.text,{details:evt.text}));
		}
		
		private function onError(evt:AlertEvent):void
		{
			dispatchEvent(evt);
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,"saving"));
		}
						
		public function getLastMid():String {
			return(lastMid);
		}
	}
}
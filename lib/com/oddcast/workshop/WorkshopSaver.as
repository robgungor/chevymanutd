/**
* ...
* @author Sam Myer, Me^
* @version 0.2
* 
* @update 10.02.04 Me^: bug fixed where useMid can be null in resend
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
* getLastMid() - returns mid of last saved message as a string
* 
* ********* CALLBACKS ************
* ProcessingEvent.STARTED / ProcessingStarted.DONE
* dispatched when processing starts and finishes - type is "saving"
* 
* SendEvent.DONE - dispatched when sending is done
* AlertEvent.ERROR - in case of error
*/

package com.oddcast.workshop {
	import com.dynamicflash.util.*;
	import com.oddcast.assets.structures.*;
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	import com.oddcast.event.*;
	import flash.utils.*;

	public class WorkshopSaver extends EventDispatcher {
		private var saving				:Boolean				= false;
		/* array of SceneStruct objects */
		private var sceneArr			:Array;
		private var tags				:String;
		private var formPoster			:MultipartFormPoster;
		private var oa1SaveQueue		:Array;
		private var checkSavedTimer		:Timer;
		private var file_uploader		:OA1_Uploader;
		/** string to add before the temp id of the full body */
		private const FULL_BODY_ID_PRE	:String = '10';
		
		private var orig_saving_data	:Original_Saving_Data;
		
		public function WorkshopSaver( _max_email_recipients:int = 100 )
		{
			max_email_recipients = _max_email_recipients;
			checkSavedTimer = new Timer(250, 120);
			init_file_uploader();
		}
		
		/**
		 * initializes the file uplader class
		 */
		private function init_file_uploader(  ):void 
		{
			file_uploader = new OA1_Uploader();
			file_uploader.addEventListener( ProcessingEvent.PROGRESS, on_file_uploader_progress );
		}
		/**
		 * callback when the progress updates in the file uploader
		 * @param	_e event containing the percentage
		 */
		private function on_file_uploader_progress( _e:ProcessingEvent ):void 
		{
			dispatchEvent( _e );	// dispatch it to all listening classes
		}

		/**
		 * saves a new MID
		 * @param	in_saveEvent	the SendEvent object containing message XML and sendMode
		 * @param	in_scene		a SceneStruct or an array of SceneStruct objects containing audio, bg, model, etc.
		 * @param	in_extraData	an optional URLVariables object containing custom data to be saved 
		 * @param	in_tags			is an optional String containing tags to be saved for sql searching later
		 * @param	in_params		 is a MessageParams object containing all additional saving information (language, etc.)
		 */
		public function saveWorkshop(in_saveEvent:SendEvent, in_scene:*, in_extraData:URLVariables, in_tags:String = null, in_params:MessageParameters = null):void
		{
			if (saving) return;
			saving = true;
			orig_saving_data = new Original_Saving_Data( in_saveEvent, in_scene, in_extraData, in_tags, in_params );
			
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
			
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,"saving"));
			/*if (scene.hasUploadPhoto()&&scene.bg!=null&&scene.bg.isUploadPhoto) {
				//if user has uploaded a photo, call crop image and wait before
				//calling the send function
				//photoUploadUI.cropImage();
			}
			else sendHost();*/
			trim_email_recipients();
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
			oa1SaveQueue = null;
		}
				
		private function sendHost():void
		{
			trace("WorkshopSaver::sendHost");
			oa1SaveQueue = null;
			if (checkSaved()) saveOA1Files();
			else {
				checkSavedTimer.reset();
				checkSavedTimer.addEventListener(TimerEvent.TIMER, checkSaveInterval);
				checkSavedTimer.addEventListener(TimerEvent.TIMER_COMPLETE, checkSaveTimeout);
				checkSavedTimer.start();
			}
		}
		
		private function checkSaveInterval(evt:TimerEvent):void {
			if (checkSaved()) {
				checkSavedTimer.removeEventListener(TimerEvent.TIMER, checkSaveInterval);
				checkSavedTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, checkSaveTimeout);
				checkSavedTimer.stop();
				saveOA1Files();
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
			var totalOA1s:uint = 0;
			var scene:SceneStruct;
			var char:WSSceneCharStruct;
			var i:int;
			var j:int;
			for (i = 0; i < sceneArr.length; i++) {
				scene = sceneArr[i];
				for (j = 0; j < scene.modelArr.length;j++) {
					char = scene.modelArr[j];
					if (char.hasFileData && char.ohUrl == null) {
						totalOA1s++;
						totalPercent += char.oa1File.progress;
					}
				}
			}
			var saveProgress:Number = (totalOA1s == 0) ? 1 : (totalPercent / totalOA1s);
			trace("WorkshopSaver::checkSavedProgress = " + saveProgress);
			return(saveProgress);
		}
		
		private function saveOA1Files():void {
			var char:WSSceneCharStruct;
			var i:int;
			var j:int;
			oa1SaveQueue = new Array();
			for (i = 0; i < sceneArr.length; i++) {
				for (j = 0; j < sceneArr[i].modelArr.length;j++) {
					char = sceneArr[i].modelArr[j];
					//when the 3d engine saves a model, it returns a byte array
					//that byte array is stored in the optimizedHost variable, and the ohUrl is set to null
					//so if this scene has a 3d model, and the optimizedHost is non-null and the ohUrl is null,
					//the optimizedHost binary data must be saved to produce the ohUrl
					if (char.hasFileData && char.ohUrl == null) {
						oa1SaveQueue.push(char);
					}
				}
			}
			
			saveNextOA1();
		}
		
		/**
		 * saves all the heads in the queue until empty, then uploads all the bodies
		 */
		private function saveNextOA1():void 
		{	
			if (oa1SaveQueue.length > 0)	saveOA1(oa1SaveQueue[0]);
			else 							doSendHost();
		}
		
		/**
		 * DEPRECATED SINCE AVT URLS ARE PROVIDED BY THE FB ENGINE
		 * uploads all the bodies in the queue_of_bodies<WS_Body_Struct> that dont have an url aready
		 * calls doSendHost when all models are uploaded
		 
		private function upload_all_bodies(  ):void 
		{	
			var num_of_scenes:int = sceneArr.length;
			var queue_of_bodies:Array = new Array();
			build_body_to_upload_arr();
			upload_next_body();
			
			/**
			 * creates an array of bodies to upload
			 *
			function build_body_to_upload_arr(  ):void
			{
				for (var i:int = 0; i < num_of_scenes; i++) 
				{	
					var cur_scene		:SceneStruct	= sceneArr[i];
					var num_of_bodies	:int			= cur_scene.full_body_arr.length;
					for (var ii:int = 0; ii < num_of_bodies; ii++) 
					{	
						var cur_body:WS_Body_Struct = cur_scene.full_body_arr[ii];
						queue_of_bodies.push( cur_body );
					}
				}
			}
				
			/**
			 * finds the next body that needs to be uploaded and upload each recursively
			 *
			function upload_next_body(  ):void 
			{	
				// find next body that needs to be uploaded
				find_body:for (var i:int = 0; i < queue_of_bodies.length; i++) 
				{	
					var cur_body:WS_Body_Struct = queue_of_bodies[i];
					if (cur_body.avatar_url == null &&	// we dont have an url (not previously saved)
						cur_body.byte_array != null		// we have ByteArray data to save
						)
					{	
						file_uploader.upload_AVT( cur_body.byte_array, fin, onError );
						break find_body;
					
						function fin( _url:String ):void 
						{	
							if (url_valid( _url ))
							{	
								cur_body.avatar_url = _url;
								upload_next_body();
							}
						}
					}
				}
			}
		}*/
		
		private function saveOA1(char:WSSceneCharStruct):void {
			trace("WorkshopSaver::saveOA1");
			var versionString:String = Capabilities.version.split(" ")[1];
			var versionNum:int = parseInt(versionString.split(",")[0]);
			trace("flash version is " + versionNum);
			//if (versionNum == 10) uploadOA1AsBase64(scene.optimizedHost.byteArray);
			//else uploadOA1Binary(scene.optimizedHost.byteArray);
			
///			uploadOA1AsBase64(char.oa1File.byteArray);	// upload OA1 file in one huge chuck
			file_uploader.upload_OA1( char.oa1File.byteArray, oa1Saved, onError );
		}
		
		private function uploadOA1Binary(oa1Binary:ByteArray):void {
			formPoster=new MultipartFormPoster();
			formPoster.addEventListener(Event.COMPLETE, oa1BinaryUploaded);
			formPoster.addEventListener(ErrorEvent.ERROR, oa1BinaryUploadError);
			var url:String=ServerInfo.localURL+"api/oa1Uploader.php?rand="+Math.floor(Math.random()*1000000).toString();
			formPoster.addFile("Filedata",oa1Binary,"application/octet-stream","Filedata");
			formPoster.addVariable("doorId",ServerInfo.door.toString());
			formPoster.post(url);
			trace("WorkshopSaver::uploadOA1Binary : oa1 file length="+oa1Binary.length);			
		}
		
		private function oa1BinaryUploaded(evt:Event):void 	{
			formPoster.removeEventListener(Event.COMPLETE, oa1BinaryUploaded);
			formPoster.removeEventListener(ErrorEvent.ERROR, oa1BinaryUploadError);
			
			//data was successfully received, but it might contain an error message or be corrupt -
			var errorEvt:AlertEvent = formPoster.checkForAlertEvent("f9t514");
			if (errorEvt == null) {  //no error event - we are all good.
				var result:String = evt.target.data.toString();
				oa1Saved(result);
			}
			else onError(errorEvt);
		}
		
		private function oa1BinaryUploadError(evt:ErrorEvent):void {
			formPoster.removeEventListener(Event.COMPLETE, oa1BinaryUploaded);
			formPoster.removeEventListener(ErrorEvent.ERROR, oa1BinaryUploadError);
			
			var errorEvt:AlertEvent = formPoster.checkForAlertEvent("f9t514");
			if (errorEvt == null) errorEvt = new AlertEvent(AlertEvent.ERROR, "f9t514", "Error loading character (oa1) file.");
			onError(errorEvt);
		}
		
		protected function uploadOA1AsBase64(oa1Binary:ByteArray):void {
			var oa1Base64:String = Base64.encodeByteArray(oa1Binary);
			trace("WorkshopSaver :: uploadOA1AsBase64 : oa1 binary length="+oa1Binary.length+"  oa1 base64 length="+oa1Base64.length);
			
			var url:String=ServerInfo.localURL+"api/oa1Uploader.php?rand="+Math.floor(Math.random()*1000000).toString();
			var postVars:URLVariables = new URLVariables();
			postVars.FileDataBase64 = oa1Base64;
			postVars.doorId = ServerInfo.door.toString();
			XMLLoader.sendAndLoad(url, oa1Base64Uploaded, postVars,String);
		}
		
		protected function oa1Base64Uploaded(s:String):void {
			var alertEvt:AlertEvent = XMLLoader.checkForAlertEvent("f9t514");
			if (alertEvt == null) oa1Saved(s);
			else onError(alertEvt);
		}
		
		/*private function onOA1UploadError(evt:ErrorEvent):void {
			onError(new AlertEvent(AlertEvent.ERROR,"f9t514","Error uploading oa1 file : "+evt.text,{details:evt.text}));
		}*/
		/* oa1 file successfully uploaded and here is the OA1 url received */
		private function oa1Saved(url:String):void {
			trace("WORKSHOPSAVER -- oa1Saved "+url);
			
			if (url_valid(url))
			{	//oa1 has been saved; remove first character from the oa1 queue and assign it to the "char" variable
				var char:WSSceneCharStruct=oa1SaveQueue.shift(); 
				char.ohUrl = url; //store the url of the saved oa1 file
				
				saveNextOA1(); //repeat to see if any more oa1 files are in the queue needing saving
			}
		}
		
		private function url_valid( _url:String ):Boolean
		{	if (_url == null || _url == "") {
				onError(new AlertEvent(AlertEvent.ERROR,"f9t515","OA1 upload script returned invalid url"));
				return false;
			}
			if (_url.indexOf("http://") == -1) {
				onError(new AlertEvent(AlertEvent.ERROR,"f9t515","OA1 upload script returned invalid url : "+_url,{url:_url}));
				return false;
			}
			return true;
		}
		
		private function doSendHost():void 
		{
			var scene:SceneStruct = sceneArr[0];
			
			trace("WorkshopSaver::sendHost");
			
			var url:String;
			//if (ServerInfo.appType==ServerInfo.WORKSHOP_APP) url=ServerInfo.localURL+"sendMessage2.php";
			//else url = ServerInfo.localURL + "videostar/sendMessage.php";
			if (orig_saving_data.save_event.sendMode == SendEvent.EMAIL) url = ServerInfo.localURL + "api/sendMessage.php";
			else if (orig_saving_data.save_event.sendMode == SendEvent.POST) url = ServerInfo.localURL+"galleryAPI/postToGallery.php";
			else url = ServerInfo.localURL + "api/saveWorkshopData.php";
			url+="?rand="+Math.floor(Math.random() * 1000000).toString();
			
			var saveXML:XML=getSaveXML();
			trace("SAVE MESSAGE : " + saveXML);

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
		
		/**
		 * resends previous MID information
		 * @param	in_saveEvent	
		 * @param	mid				if null, it will use the last MID sent successfully
		 * @param	in_extraData
		 * @param	in_tags
		 * @param	in_params
		 */
		public function resend(in_saveEvent:SendEvent, mid:String = null, in_extraData:URLVariables = null, in_tags:String = null, in_params:MessageParameters = null):void
		{
			orig_saving_data = new Original_Saving_Data(in_saveEvent, null, in_extraData, in_tags, in_params );
			var useMid:String = (orig_saving_data.mid_is_valid()) ? orig_saving_data.saved_mid : mid;
			
			// check useMid for being valid
			if (useMid == null ||
				useMid == ''  ||
				useMid == 'null' ||
				useMid == 'undefined' ||
				useMid.length < 2)
			{	
				onError( new AlertEvent(AlertEvent.ERROR, 'f9t530', 'Cannot resend this message', { details:'invalid lastMid:' + useMid } ));
				return;
			}
				
			
			/*   for embed you can dispatch an event immediately - need to test if this will break stuff before i implement it
			if (orig_saving_data.save_event.sendMode == SendEvent.EMBED_CODE) {
				var reply:XML = new XML("<AUTOREPLY MID="+useMid+" />");
				dispatchEvent(new SendEvent(SendEvent.DONE, orig_saving_data.save_event.sendMode, reply));
			}
			*/
			
			trim_email_recipients();
			
			if (orig_saving_data.extra_data == null) orig_saving_data.extra_data = in_extraData;
			
			var url:String;

			if 		(orig_saving_data.save_event.sendMode == SendEvent.EMAIL)	url = ServerInfo.localURL + "api/sendMessage.php";
			else if (orig_saving_data.save_event.sendMode == SendEvent.POST)	url = ServerInfo.localURL + "galleryAPI/postToGallery.php";
			else 																url = ServerInfo.localURL + "api/saveWorkshopData.php";
			
			var node:XML = new XML("<player />")
			var paramsNode:XML = getParamsNode();
			paramsNode.mid =useMid
			node.appendChild(paramsNode);
			
			if (orig_saving_data.save_event.messageXML!=null) node.message=orig_saving_data.save_event.messageXML;
			if (orig_saving_data.extra_data != null) node.extradata = orig_saving_data.extra_data.toString();
			
			trace("SAVE MESSAGE : "+node);
			
			var vars:URLVariables = new URLVariables();
			vars.xmlData = node;
			XMLLoader.sendVars(url, sendDone, vars);
		}
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** SPLIT EMAIL RECIPIENTS INTO GROUPS OF 100 OR SO */
		/* list of recipients that have to be emailed */
		private var pending_email_recipients_queue:Array = new Array();
		/* max email recipients that can be sent at once */
		private var max_email_recipients:int;
		/**
		 * splits the email recipients into batches to not send to all at once.
		 * @param	_e
		 * @return
		 */
		private function trim_email_recipients(  ):void
		{
			if (orig_saving_data.save_event.sendMode == SendEvent.EMAIL &&
				orig_saving_data.save_event.messageXML &&
				orig_saving_data.save_event.messageXML.to &&
				orig_saving_data.save_event.messageXML.to.length() > max_email_recipients)
			{
				pending_email_recipients_queue = new Array();
				// backup list of original recipients
				for (var n:int = orig_saving_data.save_event.messageXML.to.length(), i:int = 0; i < n; i++)				
					pending_email_recipients_queue.push(new Email_Recipient_Item( orig_saving_data.save_event.messageXML.to[i].name, 
																				  orig_saving_data.save_event.messageXML.to[i].email));
				// delete list of recipients to be sent
				delete orig_saving_data.save_event.messageXML.to;
				
				add_email_recipients_from_queue();
			}
		}
		private function add_email_recipients_from_queue(  ):void
		{
			while (orig_saving_data.save_event.messageXML.to.length() < max_email_recipients &&
					pending_email_recipients_queue.length > 0)
			{
				var to_node:XML = new XML('<to/>');
				var queued_item:Email_Recipient_Item = pending_email_recipients_queue.shift();
				to_node.name	= queued_item.name;
				to_node.email	= queued_item.email;
				orig_saving_data.save_event.messageXML.appendChild(to_node);
			}
		}
		/**
		 * check if there are remaining email recipients to send to
		 * @return
		 */
		private function email_recipients_queue_not_empty(  ):Boolean
		{
			return (pending_email_recipients_queue && pending_email_recipients_queue.length > 0 );
		}
		/**
		 * sends to the remaining recipients in the queue
		 */
		private function send_next_batch_email_recipients(  ):void
		{
			if (orig_saving_data.mid_is_valid()) // have a valid last mid saved
			{
				// delete current already sent list
				delete orig_saving_data.save_event.messageXML.to;
				// add remaining list
				add_email_recipients_from_queue();
				// resend... duh
				resend( orig_saving_data.save_event, orig_saving_data.saved_mid, orig_saving_data.extra_data, orig_saving_data.tags, orig_saving_data.params );
			}
		}
		
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		*/
		
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
			for (i = 0; i < sceneArr.length; i++) 
			{
				scene = sceneArr[i];
				
				for (j = 0; j < scene.modelArr.length; j++) 	pushUnique(modelArr, scene.modelArr[j]);
				for (j = 0; j < scene.bgArr.length; j++) 		pushUnique(bgArr, scene.bgArr[j]);
				for (j = 0; j < scene.audioArr.length; j++) 	pushUnique(audioArr, scene.audioArr[j]);
				for (j = 0; j < scene.videoArr.length; j++) 	pushUnique(videoArr, scene.videoArr[j]);
				
				sceneXML = getSceneXML(scene);
				sceneXML.id = (i + 1).toString();
				node.scenes.appendChild(sceneXML);
			}
			
			var char:WSSceneCharStruct;
			for (i = 0; i < modelArr.length; i++) 
			{
				char = modelArr[i];
				if (char.model.has_head_data())		node.assets.appendChild(get_head_xml(char));
				if (char.keyFile != null) 			node.assets.appendChild(getKeyFileXML(char.keyFile));
				if (char.model.has_body_data())		node.assets.appendChild(get_body_xml(char));
			}
			for (i = 0; i < bgArr.length; i++) 		node.assets.appendChild(getBGXML(bgArr[i]));
			for (i = 0; i < audioArr.length; i++) 	node.assets.appendChild(getAudioXML(audioArr[i]));
			for (i = 0; i < videoArr.length; i++) 	node.assets.appendChild(getVideoXML(videoArr[i]));
			
			if (orig_saving_data.save_event.messageXML != null) node.message = orig_saving_data.save_event.messageXML;
			
			if (orig_saving_data.extra_data != null) node.extradata = orig_saving_data.extra_data.toString();
			if (orig_saving_data.tags != null) node.searchdata = escape(orig_saving_data.tags);
			
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
			if (orig_saving_data.save_event.sendMode == SendEvent.EMAIL || orig_saving_data.save_event.sendMode == SendEvent.POST) paramsNode.mode = orig_saving_data.save_event.sendMode;
			else paramsNode.mode = SendEvent.EMBED_CODE;
			
			//paramsNode.mode=orig_saving_data.save_event.sendMode;
			paramsNode.appType = ServerInfo.appType;
			if (orig_saving_data.params!=null) {
				if (orig_saving_data.params.language!=null) paramsNode.lang = orig_saving_data.params.language;
				if (orig_saving_data.params.optIn != null) paramsNode.optin = orig_saving_data.params.optIn;
			}
			return(paramsNode);
		}
		
		private function getSceneXML(scene:SceneStruct):XML
		{
			var node:XML = new XML("<scene />");
			var i:int;
			
			// add full body camera info
			if (scene && scene.body_data)
			{
				node.fb_scene_id = scene.body_data.scene_id;
/*			NOT BEING SAVED ANYMORE FOR FULL BODY
				node.cam_pos = scene.body_data.camera_position;
				node.cam_aim = scene.body_data.camera_aim;
*/
			}
			
			
			var char:WSSceneCharStruct;
			if (scene.modelArr != null) 
				for (i = 0; i < scene.modelArr.length; i++) 
				{
					char = scene.modelArr[i];
					var modelNode:XML = new XML("<avatar />");
					// add model head information
					if (char.model.has_head_data())
					{
						modelNode.tempid = char.tempId.toString();	// id of the head in the assets node
						// model position
						if (char.pos != null) 
						{
							var hostPos:Object = MoveZoomUtil.matrixToObject(char.pos);
							modelNode.x=hostPos.x.toFixed(2);
							modelNode.y=hostPos.y.toFixed(2);
							modelNode.scale = (hostPos.scaleX * 100).toFixed(2);
						}
						// keyfile data
						if (char.keyFile != null) {
							modelNode.keyfile = new XML();
							modelNode.keyfile.@id = char.keyFile.id.toString();
						}
					}
					// add full body data to the model
					if (char.model.has_body_data())
					{
						var body_temp_id:XML = new XML(<tempid/>);
						body_temp_id.appendChild( FULL_BODY_ID_PRE + char.tempId.toString() );
						modelNode.appendChild( body_temp_id );
					}
					node.appendChild(modelNode);
				}
			
			var audio:AudioData;
			if (scene.audioArr != null)	
				for (i = 0; i < scene.audioArr.length; i++) 
				{
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
				trace("videoArr.length = "+scene.videoArr.length+"  videoArr[0]="+scene.videoArr[0])
				video = scene.videoArr[i];
				node.video=new XML();
				if (video.hasId) node.video.id=video.id.toString();
				else node.video.tempid=video.tempId.toString();
			}
			
			return(node);
		}

		/*private function getAssetXML(asset:*):XML {
			if (asset is WSModelStruct) return(get_head_xml(asset as WSModelStruct));
			else if (asset is WSBackgroundStruct) return(getBGXML(asset as WSBackgroundStruct));
			else if (asset is AudioData) return(getAudioXML(asset as AudioData));
			else if (asset is WSVideoStruct) return(getVideoXML(asset as WSVideoStruct));
			else return(new XML());
		}*/
		
		private function get_head_xml(char:WSSceneCharStruct):XML 
		{
			var node:XML = new XML("<avatar />");
			node.@modelId=char.model.id; //modelId
			node.@tempid = char.tempId.toString();
			node.@type = char.model.is3d?"3D":"2D";
			node.@is3d = char.model.is3d?"1":"0";
			node.appendChild(char.ohUrl);
			return(node);
		}
		
		private function get_body_xml( _char:WSSceneCharStruct ):XML
		{
			var node:XML 	= new XML("<avatar />");
			node.@modelId	= _char.model.id; //modelId
			node.@tempid	= FULL_BODY_ID_PRE + _char.tempId.toString();
			node.@type		= 'FB3D';
			node.appendChild( _char.model.full_body_struct.avatar_url );
			return(node);
		}
		
		private function getKeyFileXML(keyFile:LoadedAssetStruct) : XML {
			var node:XML = new XML("<keyfile />");	
			node.@id=keyFile.id.toString();
			node.appendChild(keyFile.url);
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
				node.text=escape(ttsAudio.textWithProsody);	
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

		private function sendDone(_xml:XML):void 
		{
			saving = false;
			var alertEvt:AlertEvent = XMLLoader.checkForAlertEvent("f9t511", "f9t512");
			if (alertEvt != null) {
				onError(alertEvt);
				return;
			}
			else if (_xml.name().toString() != "MESSAGE") {
				onError(new AlertEvent(AlertEvent.ERROR, "f9t513", "Sending script returned improper data : '"+_xml.toXMLString()+"'"));
				return;				
			}
			trace("send done : " + _xml.toXMLString())

			orig_saving_data.saved_mid = _xml.@MID;
			
			if (!orig_saving_data.mid_is_valid()) {
				onError(new AlertEvent(AlertEvent.ERROR, "f9t513", "Sending script returned improper data : invalid message ID "+_xml.@MID));
				return;				
			}
			
			// check in there are more recipients pending emails to be sent to
			if (email_recipients_queue_not_empty())
			{
				send_next_batch_email_recipients();
			}
			else // saving finished
			{
				
				//processing_send._visible=false;
				
				var result:String=unescape(_xml.@RES.toString()).toUpperCase();
				
				_xml.appendChild("<bgURL>"+orig_saving_data.scene.bg.url+"</bgURL>");
				trace("bgURL : "+_xml.toString())
				dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,"saving"));
				dispatchEvent(new SendEvent(SendEvent.DONE, orig_saving_data.save_event.sendMode, _xml));
			}
		}
		
		private function onError(evt:AlertEvent):void
		{
			saving = false;
			dispatchEvent(evt);
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,"saving"));
		}
						
		public function getLastMid():String 
		{
			if (orig_saving_data)
				return(orig_saving_data.saved_mid);
			return null;
		}
	}
}









import com.oddcast.event.*;
import com.oddcast.workshop.*;
import flash.net.*;
class Email_Recipient_Item
{
	public var name:String = '';
	public var email:String = '';
	public function Email_Recipient_Item( _name:String, _email:String )
	{
		name	= _name ? _name : '';
		email	= _email;
	}
}
class Original_Saving_Data
{
	public var save_event:SendEvent;
	public var scene:*;
	public var extra_data:URLVariables;
	public var tags:String;
	public var params:MessageParameters;
	public var saved_mid:String;
	public function Original_Saving_Data( _save_event:SendEvent, _scene:*, _extra_data:URLVariables, _tags:String, _params:MessageParameters )
	{
		save_event		= _save_event;
		scene			= _scene;
		extra_data		= _extra_data;
		tags			= _tags;
		params			= _params;
	}
	public function mid_is_valid(  ):Boolean
	{
		return (
					saved_mid && 
					saved_mid.length > 0 && 
					!isNaN(parseInt(saved_mid))
				);
	}
}
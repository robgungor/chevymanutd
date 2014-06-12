/**
* ...
* @author Sam, Me^
* @version 0.5
* 
* This is the scene controller for the 3D host/workshop.
* 
* @see com.oddcast.workshop.ISceneController for documentation
* 
*/

package com.oddcast.workshop 
{
	import com.adobe.serialization.json.JSON;
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.host.api.*;
	import com.oddcast.host.api.fullbody.IHeadPlugin;
	import com.oddcast.host.api.morph.babymaker.CalcRace;
	import com.oddcast.utils.*;
	import com.oddcast.vhost.accessories.*;
	import com.oddcast.vhost.ranges.*;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.throttle.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;

	public class SceneController3D extends SceneControllerBase implements ISceneController {
		private var engine3DLoaded				:Boolean				= false;
		private var lastSceneSaved				:SceneStruct			= null;
		private var accessoryProgressArray		:Array;
		private var morphing_api				:Morph_Controller		= new Morph_Controller();
		private var fb_controller				:IBody_Controller;
		
		public function SceneController3D(in_player:Sprite, _host_mask:Sprite = null, _bg_mask:Sprite = null, _host_loader:HostLoader = null, _bg_loader:IBGLoader = null)
		{	super(in_player, _host_mask, _bg_mask, _host_loader, _bg_loader);
			accArr = new Object();
			morphing_api.init_params( this );
		}
				
		protected function get hostAPI():IHostAPI 
		{
			if (hostMC == null) return(null);
			else return(hostMC.api as IHostAPI);
		}
		protected function get hostEditorAPI():IEditorAPI 
		{
			return(hostAPI as IEditorAPI);
		}
		public function get full_body(  ):IBody_Controller
		{	return fb_controller;
		}
		public function set full_body( _fb_controller:IBody_Controller ):void
		{	if (fb_controller)	throw new Error('SceneController3D.full_body already set');
			fb_controller = _fb_controller;
		}
		public function full_body_ready():Boolean
		{	if (fb_controller)	return true;
			else 				return false;
		}
		
		//----------------------------  AUDIO FUNCTIONS -------------------------
		
		/*The first audio is the lipsync audio, the rest are the beat sync audios*/
		public function sayMultiple(audioArr:Array):void {
			var mAudio:MultipleAudio;
			var mAudioArr:Array = new Array();
			for (var i:int = 0; i < audioArr.length; i++) {
				mAudio = new MultipleAudio(audioArr[i].url, 0);
				if (i == 0) mAudio.beatsync = 0;
				else mAudio.lipsync = 0;
				mAudioArr.push(mAudio);
			}
			trace("SceneController::sayMultiple : ");
			for (i = 0; i < mAudioArr.length; i++) {
				mAudio = mAudioArr[i];
				trace(i + " ----- beatsync=" + mAudio.beatsync + "  lipsync=" + mAudio.lipsync + "  ofset=" + mAudio.offset + "  url=" + mAudio.url);
			}
			hostAPI.sayMultiple(mAudioArr);
		}
		
		override public function previewAudio(in_audio:AudioData):void 
		{
			if (can_play_audio(in_audio))
			{
				trace('(Oo) :: SceneController3D.previewAudio().in_audio.url :', in_audio.url, typeof(in_audio.url));
				stopAudio();
				dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, ProcessingEvent.AUDIO));
				
				/** throttle TTS requests */
				if (in_audio is TTSAudioData)
				{
					Throttler.tts_request_allowed( in_audio.url, say_audio, no_capacity, no_capacity );
					function say_audio():void
					{
						play_audio(in_audio.url + Throttler.append_tts_limit());
					}
					function no_capacity():void
					{
						dispatchEvent(new SceneEvent(SceneEvent.TALK_ERROR));
						dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.AUDIO));
					}
				}
				else
					play_audio(in_audio.url);
			}
		
			/**
			 * validates if the workshop is in a state that can play audio
			 * if the audio is correct, if theres an engine to handle audio playback
			 * @param	_audio
			 * @return
			 */
			function can_play_audio( _audio:AudioData ):Boolean
			{
				return (	_audio &&				// valid audio
							_audio.url &&
							_audio.url != '' &&
							model &&				// valid model
							(	model.has_head_data() || 	// model has to have head engine
								model.has_body_data()		// or model has to have body engine
							)
						)
			}
		}
		
		public function stopAudio() :void
		{	
			if (model && model.has_head_data() )
				hostAPI.stopSpeech();
			else if (model && model.has_body_data() )
				fb_controller.stop_audio();
		}
		
		/**
		 * once all the checks are done use this to submit straight to the API (body || head)
		 * @param	_audio_url
		 */
		private function play_audio( _audio_url:String ):void
		{
			if (model && model.has_head_data() )
				hostAPI.say( _audio_url );			// submit request to the head
			else if (model && model.has_body_data() )
				fb_controller.say( _audio_url );	// submit request to the body
		}
		
		//----------------------------  MODEL FUNCTIONS -------------------------
		
		public function loadModel(in_model:WSModelStruct, _force_clean_reload:Boolean = false) :void
		{
			modelToLoad = in_model;
			check_if_engine_reload_needed( in_model, _force_clean_reload );
			
			if ( model_has_head_data() )	// load the head
			{
				dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, ProcessingEvent.MODEL));
				hostMC.loadModel(in_model);
			}
			else	// no head to load
				modelLoaded(null);
			
			function model_has_head_data( ):Boolean
			{
				return (in_model &&		// has to be non null
						in_model.engine)// if theres an engine associated with it then we have head data
			}
		}
		
		/*	engine reload is needed if the mesh (OA1) files are changing from host to host */
		private function check_if_engine_reload_needed( _to_be_loaded_model:WSModelStruct, _force_clean_reload:Boolean ):void 
		{
			if ( sceneModel == null )	return;	// we dont have a current model loaded so this is redundant
			
			// if mesh OA1 files are not matching engine needs reloaded
			if (( sceneModel.url != _to_be_loaded_model.url ) || _force_clean_reload )
			{
				morphing_api.destroy_current_morpher();
				hostMC.destroy();
			}
		}
		
		private function hostEvt(evt:Event):void {
			dispatchEvent(evt);
		}
		
		
		override protected function modelLoaded(evt:Event):void
		{
			sceneModel = modelToLoad;
			trace('(Oo) :: SceneController3D.modelLoaded().sceneModel :', sceneModel, typeof(sceneModel));
			
			if (hostAPI)
				hostAPI.addEventListener("controlRequireUpdate", controlsUpdate, false, 0, true);
			check_if_to_morph();
		}
		
		/*	after loading the base model we need to check if to morph	*/
		private function check_if_to_morph(  ):void 
		{
			if ( morphing_api.is_morphing_pending() )	morphing_api.base_model_loaded();
			else head_now_ready();
		}
		
		/*	head is now completely ready	*/
		private function head_now_ready(  ):void 
		{
			dispatchEvent(new SceneEvent(SceneEvent.MODEL_LOADED)); //modelLoaded = "configDone"
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.MODEL));
			//accArr=new Object();  -  will have to keep track of accessories per model
			load_full_body();
		}
		
		/**
		 * loads the full body data if there is one available for loading
		 */
		private function load_full_body(  ):void
		{
			if (full_body_ready() &&
				model &&
				model.has_body_data())
			{
				dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, ProcessingEvent.FULL_BODY));
				new Body_Loader( 	new Callback_Struct( fin, progress, error ), 
									full_body, 
									model, 
									model.has_head_data() ? getHostMC().ihead_plugin : null,	// pass a reference to the head only if this model is intended to have a head
									talkStarted, 
									talkEnded, 
									talkError );
				function fin():void 
				{	
					dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.FULL_BODY));
				}
				function progress( _percent:int ):void 
				{	
					var processing_event:ProcessingEvent = new ProcessingEvent( ProcessingEvent.PROGRESS, ProcessingEvent.FULL_BODY, _percent );
					dispatchEvent( processing_event );
				}
				function error( _msg:String ):void 
				{	
					dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.FULL_BODY));
					dispatchEvent(new SceneEvent(SceneEvent.FULL_BODY_LOAD_ERROR, _msg ) );
				}
			}
		}
		
		public function resetHost():void {
			hostEditorAPI.setButton(EditLabel.B_RESET, true, API_Constant.UNDO_FLAGS_RESET);
			//dispatchEvent(new Event(SIZING_UPDATED));
		}
		
		private function controlsUpdate(evt:Event):void {
			dispatchEvent(new SceneEvent(SceneEvent.SIZING_UPDATED));
		}

		public function freeze():void {
			//api.allowRender(false);
			hostAPI.freeze();
		}
		
		public function resume():void {
			//api.allowRender(true);
			hostAPI.resume();			
		}
		
		//----------------------------  MORPH FUNCTIONALITY -------------------------
		
		/*	morphs the 2 models while changing engine and oa1 files if need be	*/
		public function morph_models( _target_model:WSModelStruct, _back_model:WSModelStruct, _color_dominance:Boolean, _morph_class:Class ):void 
		{
			if (_target_model		== null)	throw( new Error('MISSING TARGET MODEL :: com.oddcast.workshop.SceneController3D.morph_models()') );
			if (_back_model			== null)	throw( new Error('MISSING BACK MODEL :: com.oddcast.workshop.SceneController3D.morph_models()') );
			if (_morph_class		== null)	throw( new Error('MISSING MORPH CLASS :: com.oddcast.workshop.SceneController3D.morph_models()') );
			morphing_api.morph_these_models( _target_model, _back_model, _color_dominance, morphing_finished, _morph_class );
		}
		
		/*	apply the morph color dominancy either to the face or to the head	*/
		public function change_color_analyzer( _value:Boolean ):void
		{
			morphing_api.change_color_dependency_on_current_models( _value );
		}
		
		/*	called when all the morphing is complete and dispatches the event	*/
		private function morphing_finished(  ):void 
		{
			head_now_ready();
		}
		
		//----------------------------  ACCESSORY FUNCTIONS -------------------------
		
		public function loadAccessory($acc:AccessoryData):void {
			//if (loadingAccessory) return;
			if (!$acc is AccessoryData3D) return;
			var acc:AccessoryData3D = $acc as AccessoryData3D;
			
			
			trace("SceneController::loadAccessory - id=" + acc.id + " name=" + acc.name);
			var fragmentArr:Array = new Array();
			var frag:AccessoryFragment;
			var fragUrls:FragmentURLs;
			
			for (var i:int = 0; i < acc.getFragments().length; i++) {
				frag = acc.getFragments()[i];
				trace("fragment " + i + " - url=" + frag.url + "  base=" + frag.baseUrl);
				fragUrls = new FragmentURLs();
				fragUrls.setAllURLs(frag.type, frag.url, frag.baseUrl);
				fragmentArr.push(fragUrls);
			}
			
			accToLoad = acc;
			accArr[acc.typeId.toString()] = acc;
			
			var accDesc:AccessoryDescription = new AccessoryDescription(fragmentArr, acc.typeId.toString(), acc.accGroupName, acc.zOrder);
			
			var returnValue:String = hostEditorAPI.loadAccessory(accDesc, acc.typeId.toString(), API_Constant.UNDO_FLAGS_SAVE);
			if (accDesc!=null) {
				accessoryProgressArray = accDesc.getFileProgresss();
				TimerUtil.setInterval(accLoadProgress, 250);
			}
			
			if (numAccessoriesLoading==0) dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, ProcessingEvent.ACCESSORY));
			numAccessoriesLoading++;
		}		
		
		private function accLoadProgress():void {
			trace("SceneController3D:accLoadProgress - percent="+calculatePercent(accessoryProgressArray));
		}
		private function calculatePercent(progressArray:Array):Number {
			if (progressArray == null) return(0);
			var totalBytes:Number = 0;
			var loadedBytes:Number = 0;
			var progress:FileProgress;
			for (var i:int = 0; i < progressArray.length; i++) {
				progress = progressArray[i];
				totalBytes += progress.filesize;
				loadedBytes += progress.filesize*progress.progress;
			}
			if (totalBytes == 0) return(0);
			else return(loadedBytes / totalBytes);
		}
		
		override protected function accLoaded(evt:Event):void {
			TimerUtil.stopInterval(accLoadProgress);
			trace("SceneController3D::accLoaded --  accToLoad="+accToLoad)
			if (accToLoad == null) return;
			numAccessoriesLoading--;
			trace("accArr = " + accArr + "   --  typeId=" + accToLoad.typeId);
			accArr[accToLoad.typeId]=accToLoad;
			if (numAccessoriesLoading==0) dispatchEvent(new SceneEvent(SceneEvent.ACCESSORY_LOADED));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.ACCESSORY));
		}
		
		override protected function accLoadError(evt:Event):void {
			TimerUtil.stopInterval(accLoadProgress);
			trace("SceneController::accLoadError")
			numAccessoriesLoading--;
			dispatchEvent(new SceneEvent(SceneEvent.ACCESSORY_LOAD_ERROR));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.ACCESSORY));
		}
		
		public function removeAccessory(typeId:int):void {
			hostEditorAPI.loadAccessory(null, typeId.toString(), API_Constant.UNDO_FLAGS_SAVE);
			delete accArr[typeId.toString()];
		}
		
		public function removeAllAccessories():int {
			/*var count:int = 0;
			for (var accType:String in accArr) {
				removeAccessory(parseInt(accType));
				count++;
			}
			accArr = new Object();
			return(count);*/
			
			//jake created a new function for this which makes life easier :
			hostEditorAPI.unloadAllAccessories()
			accArr = new Object();
			return(0);
		}
				
		public function getAccessories():Object {
			return(accArr);
		}
		
		private function getAccTypes():Array {
			//this doesn't do anything currently
			return(new Array());
		}
		
		//----------------------------  COLOR FUNCTIONS -------------------------
		
		public function getColors():Array {
			/* check if a model is available */
			if (model && model.has_head_data() )
			{
				var i:int;
				var j:int;
				var colArr:Array = new Array();
				var editColorArr:Array = hostEditorAPI.getEditorList(API_Constant.COLOR);
				var colorVal:uint;
				for (i = 0; i < editColorArr.length; i++) {
					colorVal = hostEditorAPI.getColor2(editColorArr[i]);
					colArr.push(new HostColorData(editColorArr[i], HostColorData.EDITOR_COLOR, colorVal));
				}
				
				var accCtlArr:Array = hostEditorAPI.getAllAccessoryControls();
				var accCtl:AccessoryControlWithTypeID;
				var accValue:AccessoryTween;
				for (i = 0; i < accCtlArr.length; i++) {
					for (j = 0; j < accCtlArr[i].length; j++) {
						accCtl = accCtlArr[i][j];
						if (accCtl.controlType == API_Constant.COLOR) {
							accValue = hostEditorAPI.getAccessoryAnimationValue(accCtl.accessoryTypeID, accCtl.plabel);
							trace("!accValue - label="+[accValue.plabel,accCtl.plabel]+" type=" + accCtl.accessoryTypeID + "  value=" + AccessoryTween.floatToColor(accValue.endValue));
							colArr.push(new HostColorData(accCtl.plabel,accCtl.accessoryTypeID,AccessoryTween.floatToColor(accValue.endValue)));
						}
					}
				}
				return(colArr);
			}
			return []; 	// no colors available
		}
		
		public function setHexColor(grp:HostColorData, hexVal:uint):void {
			if (grp.type == HostColorData.EDITOR_COLOR) {
				hostEditorAPI.setColor2(grp.name, hexVal,API_Constant.UNDO_FLAGS_COLOR_CHOICE);
			}
			else {
				hostEditorAPI.setAccessoryAnimation(grp.type, AccessoryTween.setInstantly(grp.name, AccessoryTween.colorToFloat(grp.value)));
				trace("!acc set type="+grp.type+" name="+grp.name+" : " + AccessoryTween.colorToFloat(grp.value));
			}
			//controller.setHexColor(grp.name,hexVal);
			dispatchEvent(new SceneEvent(SceneEvent.COLOR_UPDATED));
		}

		//----------------------------  SIZING FUNCTIONS -------------------------
		
		public function getRanges():Array {
			var i:int;
			var j:int;
			var rangeArr:Array=new Array();
			var rangeTypes:Array=[API_Constant.BASIC,API_Constant.ADVANCED];
			var typeRangeArr:Array;
			var rangeVal:Number;
			for (i=0;i<rangeTypes.length;i++) {
				typeRangeArr=hostEditorAPI.getEditorList(rangeTypes[i]);
				for (j=0;j<typeRangeArr.length;j++) {
					rangeVal=hostEditorAPI.getEditValue(rangeTypes[i],typeRangeArr[j]);
					rangeArr.push(new RangeData(typeRangeArr[j],rangeTypes[i],rangeVal));
				}
			}
			
			return(rangeArr);
		}
		
		public function setScale(grpName:String,val:Number,grpType:String=""):void {
			//trace("set scale : "+grpName+" - "+val);
			hostEditorAPI.setEditValue(grpType,grpName,val,API_Constant.UNDO_FLAGS_NONE);
			//dispatchEvent(new Event(SIZING_UPDATED));			
		}
		
		public function getScale(grpName:String,grpType:String=""):Number {
			return(hostEditorAPI.getEditValue(grpType,grpName));
		}
		
		//---------------------------- EXPRESSIONS FUNCTIONS -------------------------
		
		public function getExpressions():Array {
			return(hostEditorAPI.getEditorList(API_Constant.EXPRESSION));
		}
		
		public function setExpression(expression:String, amount:Number = 1):void {
			hostAPI.clearExpressionList();
			hostAPI.setExpression(expression, amount, API_Constant.EXPRESSION_PERMENANT,API_Constant.EXPRESSION_PERMENANT);
		}
		
		public function setMorphTargets(moprhInfluenceArr:Array):void
		{
		
		}
		
		//---------------------------- SAVING FUNCTIONS -------------------------
		
		/**
		 * saves the head and full body information
		 * @param	_callbacks	.fin( SceneStruct )
		 */
		public function compile_scene( _callbacks:Callback_Struct ):void
		{
			if (	_callbacks &&
					_callbacks.fin != null
				)
			{
				var scene:SceneStruct = new SceneStruct(	model,
															bg,
															audio, 
															hostMC.transform.matrix,
															getBGMC().bgPosition
														);
				
				// build head file data
				if	(	model &&
						model.is3d &&
						hostEditorAPI
					)
				{
					var hostFileArr:Array	= hostEditorAPI.getFile(API_Constant.OPTIMIZED_HOST);
					var hostFile:FileData 	= hostFileArr[0];
					scene.optimizedHost 	= hostFile;
					scene.ohUrl 			= null;
				}
				
				// add body data
				if (model && model.has_body_data())
				{
					model.full_body_struct.avatar_url 	= ServerInfo.contentURL + full_body.avatar_cached_url();
					scene.body_data.camera_position 	= full_body.get_camera_position();
					scene.body_data.camera_aim			= full_body.get_camera_aim();
					scene.body_data.scene_id			= model.full_body_struct.scene_id
				}
				
				
				
				if (full_body && full_body.is_initialized())
					full_body.save_avatar( new Callback_Struct( save_avatar_fin, save_avatar_progress, save_avatar_error ) );
				else save_avatar_fin();
					
				function save_avatar_fin():void 
				{	
					lastSceneSaved = scene;
					_callbacks.fin( scene );
				}
				function save_avatar_progress( _percent:int ):void 
				{	
				}
				function save_avatar_error( _msg:String ):void 
				{
					if (_callbacks && _callbacks.error != null)
						_callbacks.error(_msg);
				}
			}
		}
		
		public function sceneChangedSinceLastSave():Boolean 
		{
			
			if (lastSceneSaved == null) return true;
			
			var changed		:Boolean = false;
			if 		(!assetCompare(bg, lastSceneSaved.bg)) 									changed = true;
			else if (!assetCompare(audio, lastSceneSaved.audio)) 							changed = true;
			else if (hostEditorAPI && hostEditorAPI.hasHostChangedSinceLastSave())			changed = true;
			else if (!matrixCompare(hostMC.transform.matrix, lastSceneSaved.hostMatrix)) 	changed = true;
			else if (!matrixCompare(getBGMC().bgPosition, lastSceneSaved.bgMatrix)) 		changed = true;
			else if (	full_body_ready() && full_body.has_changed_since_last_save())		changed = true;
			
			return changed;
			
			/*
			// compare all assets JSON style... props to ANASTASAKIS for suggesting this!
			if (lastSceneSaved == null) return true;
			
			var changed		:Boolean = false;
			if (
				!json_compare(bg, lastSceneSaved.bg) ||
				!json_compare(audio, lastSceneSaved.audio) ||
				()
				
			/**
			 * compares two objects via JSON serialization
			 * return true if objects are different
			 /
			function json_compare(_a:Object, _b:Object):Boolean
			{
				return (JSON.encode(_a) == JSON.encode(_b));
			}*/
		}
		
		/*returns true when matrices are identical*/
		private function matrixCompare(m1:Matrix, m2:Matrix):Boolean {
			if (m1 == null && m2 == null) return(true);
			else if (m1 == null && m2 != null) return(false);
			else if (m1 != null && m2 == null) return(false);
			else return(m1.a == m2.a && m1.b == m2.b && m1.c == m2.c && m1.d == m2.d && m1.tx == m2.tx && m1.ty == m2.ty);
		}
		
		private function assetCompare(asset1:*, asset2:*):Boolean {
			if (asset1 == null && asset2 == null) return(true);
			else if (asset1 == null || asset2 == null) return(false);
			else return(asset1.url == asset2.url);
		}
		
		//---------------------------- DESTROY -------------------------
		
		override public function destroy():void {
			super.destroy();
			if (hostAPI!=null) hostAPI.removeEventListener("controlRequireUpdate",controlsUpdate);
			hostMC.destroy();
		}
		
	}
	
}














import com.oddcast.host.api.fullbody.*;
import com.oddcast.workshop.*
import flash.system.*;

class Body_Loader
{
	public function Body_Loader(_callbacks:Callback_Struct, 
								_fb_controller:IBody_Controller, 
								_model:WSModelStruct, 
								_head_engine_api:IHeadPlugin, 
								_talk_started:Function, 
								_talk_ended:Function, 
								_talk_error:Function )
	{
		if (_model && 
			_model.has_body_data() &&
			_fb_controller)
		{
			var fb3d_engine_url	:String					= _model.full_body_struct.engine.url;
			//var fb3d_engine_url	:String					= ServerInfo.default_url + 'swf/Oc3dPlugIn.swf';
			var api_url			:String					= ServerInfo.acceleratedURL + 'php/fb3d/fb3dAPI/doorId=' + ServerInfo.door.toString();
			var content_url		:String					= ServerInfo.full_body_content_url_door;
			var engine_domain	:ApplicationDomain		= ApplicationDomain.currentDomain;
			_fb_controller.init( new Callback_Struct( fin, _callbacks.progress, _callbacks.error ), 
								engine_domain, 
								fb3d_engine_url, 
								api_url, 
								content_url,
								ServerInfo.cache_oh_url, // "http://char.dev.oddcast.com/",
								ServerInfo.contentURL + 'char/fb/',
								_model.full_body_struct.acc_set_id,
								_model.full_body_struct.category_id,
								_head_engine_api);
			function fin():void 
			{	
				initialize_audio_handler( );
				_fb_controller.enable_trucking( true );
				_fb_controller.enable_zooming( true );
				_callbacks.fin();	
				
				function initialize_audio_handler( ):void
				{
					if (_fb_controller &&
						_fb_controller.is_initialized())
					{
						_fb_controller.init_audio( talk_started, talk_ended, talk_error );
						
						function talk_started(  ):void
						{
							_talk_started(null);
						}
						function talk_ended(  ):void
						{
							_talk_ended(null);
						}
						function talk_error(  ):void
						{
							_talk_error(null);
						}
					}
				}
			}
		}
	}
}
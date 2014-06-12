/**
* @author Sam Myer
* This is the scene controller for the 2D host/workshop.
* 
* @see com.oddcast.workshop.ISceneController for documentation
*/
	
package com.oddcast.workshop {
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.host.api.morph.MorphPhotoFace;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.vhost.IVhostConfigController;
	import com.oddcast.vhost.OHUrlParser;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.vhost.ranges.RangeData;
	import com.oddcast.workshop.ISceneController;
	import com.oddcast.workshop.SceneControllerBase;
	import com.oddcast.workshop.throttle.Throttler;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class SceneController2D extends SceneControllerBase implements ISceneController {
		//private var controller:IVhostConfigController;
		private var controller:*;
		protected var accTypes:Array;
		private var isUploadPhoto:Boolean = false;
		private var lastSceneSaved:SceneStruct = null;
		
		public function SceneController2D(in_player:Sprite, _host_mask:Sprite = null, _bg_mask:Sprite = null, _host_loader:HostLoader = null, _bg_loader:IBGLoader = null)
		{	super(in_player, _host_mask, _bg_mask, _host_loader, _bg_loader);
		}
		
		protected function get hostAPI():* {
			if (hostMC == null) return(null);
			else return(hostMC.api);
		}
		
		public function get full_body(  ):IBody_Controller
		{	throw( new Error('FULL BODY ALLOWED FOR 3D ONLY :: com.oddcast.workshop.SceneController2D.full_body()') );
		}
		public function set full_body( _fb_controller:IBody_Controller ):void
		{	throw( new Error('FULL BODY ALLOWED FOR 3D ONLY :: com.oddcast.workshop.SceneController2D.full_body()') );
		}
		public function full_body_ready():Boolean
		{	return false;
		}
		
		//---------------------------- BG FUNCTIONS -------------------------
		public function initUploadPhoto():void {
			//bgManipulate.init(bgMC);
			isUploadPhoto=true;
		}
		
		public function hasUploadPhoto():Boolean {
			return(isUploadPhoto);
		}
		//---------------------------- AUDIO FUNCTIONS -------------------------
		
		override public function previewAudio(in_audio:AudioData):void {
			if (in_audio == null || in_audio.url == null || in_audio.url == "" || hostAPI == null) 
				return;
			trace('(Oo) :: SceneController2D.previewAudio().in_audio.url :', in_audio.url, typeof(in_audio.url));
			hostAPI.stopSpeech();
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, ProcessingEvent.AUDIO));
			
			if (in_audio is TTSAudioData)
			{
				Throttler.tts_request_allowed( in_audio.url, say_audio, no_capacity, no_capacity );
				function say_audio():void
				{
					hostAPI.say(in_audio.url + Throttler.append_tts_limit(), 0);
				}
				function no_capacity():void
				{
					dispatchEvent(new SceneEvent(SceneEvent.TALK_ERROR));
					dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.AUDIO));
				}
			}
			else
				hostAPI.say(in_audio.url, 0);
		}
		
		public function stopAudio() :void
		{	if (hostAPI)
				hostAPI.stopSpeech();
		}
		//----------------------------  MODEL FUNCTIONS -------------------------
		
		public function loadModel(in_model:WSModelStruct, _force_clean_reload:Boolean = false):void {
			trace("SceneController2D::loadModel  -  loading=" + loadingModel);
			if (loadingModel) 
				return;
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,ProcessingEvent.MODEL));
			modelToLoad=in_model;
			loadingModel=true;
			hostMC.loadModel(modelToLoad);
			trace("SceneController2D setting loadModel to true");
		}
		
		override protected function modelLoaded(evt:Event):void 
		{
			controller=hostAPI.getConfigController();
			sceneModel = modelToLoad;
			trace('(Oo) :: SceneController2D.modelLoaded().sceneModel :', sceneModel, typeof(sceneModel));
			
			loadingModel=false;
			dispatchEvent(new SceneEvent(SceneEvent.MODEL_LOADED)); //modelLoaded
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.MODEL));
			accArr=new Object();
			
			//don't call getModelInfo yet
			//var ohStr:String=OHUrlParser.getOHString(OHUrlParser.getOHObject(model.url)).split("/").join("|")
			//var url:String="http://vhost.dev.oddcast.com/vhss_editors/getModelInfo.php?modelId="+model.id.toString()+"&oh="+ohStr;
			//XMLLoader.loadXML(url,gotModelInfo);
		}
		
		private function gotModelInfo(_xml:XML):void {
			var accItem:XML;
			accTypes=new Array();
			var typeId:int;
			for (var i:int=0;i<_xml.ITEM.length();i++) {
				accItem=_xml.ITEM[i];
				if (accItem.@AVAILABLE=="1") {
					typeId=parseInt(accItem.@ID)
					accTypes.push(typeId);
					accArr[typeId]=new AccessoryData(parseInt(accItem.@ACCID),"",typeId,"",parseInt(accItem.@COMP));
				}
			}
			loadingModel=false;
			dispatchEvent(new SceneEvent(SceneEvent.MODEL_LOADED)); //modelLoaded
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,ProcessingEvent.MODEL));
		}

		public function freeze():void {
			hostAPI.freeze();
		}
		
		public function resume():void {
			hostAPI.resume();
		}
		public function resetHost():void {
			//only does something on 3d
		}
				
		//----------------------------  MORPH FUNCTIONALITY -------------------------
		
		public function morph_models( _target_model:WSModelStruct, _back_model:WSModelStruct, _color_dominance:Boolean, _morph_class:Class ):void 
		{
			throw( new Error('MORPHING ALLOWED FOR 3D ONLY :: com.oddcast.workshop.SceneController2D.morph_models()') );
		}
		
		public function change_color_analyzer( _value:Boolean ):void
		{
			throw( new Error('MORPHING ALLOWED FOR 3D ONLY :: com.oddcast.workshop.SceneController2D.change_color_analyzer()') );
		}
				
		//----------------------------  ACCESSORY FUNCTIONS -------------------------
		public function loadAccessory($acc:AccessoryData):void {
			var acc:AccessoryData = $acc;
			trace("SceneController::loadAccessory - id="+acc.id+" name="+acc.name);
			for (var obj:* in acc.getFragments()) trace(obj+":"+acc.getFragments()[obj]);
			if (loadingAccessory) return;
			accToLoad=acc;
			loadingAccessory=true;
			controller.setAccessory(acc);
			//dispatchEvent(new Event("accessoryLoading"));
		}
				
		public function removeAccessory($typeId:int):void {
			throw new Error("removeAccessory is only available for 3d models");
		}
		
		public function removeAllAccessories():int {
			throw new Error("removeAllAccessories is only available for 3d models");
		}
		
		private function getAccTypes():Array {
			//this doesn't do anything currently
			return(accTypes);
		}
		
		public function getAccessories():Object {
			return(accArr);
		}
		
		override protected function accLoaded(evt:Event):void {
			trace("SceneController::accLoaded --  accToLoad="+accToLoad)
			if (accToLoad == null) return;
			loadingAccessory = false;
			trace("accArr = " + accArr + "   --  typeId=" + accToLoad.typeId);
			accArr[accToLoad.typeId]=accToLoad;
			dispatchEvent(new SceneEvent(SceneEvent.ACCESSORY_LOADED));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.ACCESSORY));
		}
		
		override protected function accLoadError(evt:Event):void {
			trace("SceneController::accLoadError")
			loadingAccessory=false;
			dispatchEvent(new SceneEvent(SceneEvent.ACCESSORY_LOAD_ERROR));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.ACCESSORY));
		}
		
		private function get loadingAccessory():Boolean 
		{
			return(numAccessoriesLoading>0);
		}
		private function set loadingAccessory(b:Boolean):void
		{
			numAccessoriesLoading=b?1:0;
		}
		//----------------------------  COLOR FUNCTIONS -------------------------
		
		//color/sizing controller functions
		public function getColors():Array {
			var colArr:Array = new Array();
			trace("hostMC - "+hostMC+" api - "+hostAPI+" - controller - "+hostAPI.getConfigController());
			var colObj:Object=controller.getColorSections() as Object;
			for (var grp:String in colObj) {
				if (colObj[grp] == true) {
					colArr.push(new HostColorData(grp,null,controller.getHexColor(grp)));
				}
			}
			return(colArr);
		}
		
		/*public function setHexColor(grpName:String,hexVal:Number) {
			controller.setHexColor(grpName,hexVal);
			dispatchEvent(new Event(COLOR_UPDATED));
		}*/
		public function setHexColor(grp:HostColorData,hexVal:uint):void {
			controller.setHexColor(grp.name,hexVal);
			dispatchEvent(new SceneEvent(SceneEvent.COLOR_UPDATED));
		}
		
		//----------------------------  SIZING FUNCTIONS -------------------------
		
		public function getRanges():Array {
			var rangeArr:Array=new Array();
			var grpName:String;
			
			var ranges:Object;
			ranges=controller.getScaledSections();
			for (grpName in ranges) rangeArr.push(new RangeData(grpName,"scale",ranges[grpName]));
			ranges=controller.getAlphaSections();
			for (grpName in ranges) rangeArr.push(new RangeData(grpName,"alpha",ranges[grpName]));
			ranges=controller.getAgeSections();
			for (grpName in ranges) rangeArr.push(new RangeData(grpName,"age",ranges[grpName]));
			
			return(rangeArr);
		}
		
		public function getScale(grpName:String,grpType:String=""):Number {
			//return(controller.getRanges()[grpName].val);
			return(controller.getScale(grpName));
		}
		
		public function setScale(grpName:String, val:Number, grpType:String = ""):void {
			if (grpType=="scale") controller.setScale(grpName,val);
			else if (grpType=="alpha") controller.setAlpha(grpName,val);
			else if (grpType == "age") controller.setAge(val);
			dispatchEvent(new SceneEvent(SceneEvent.SIZING_UPDATED));
		}
		
		//----------------------------  SAVING FUNCTIONS -------------------------
		
		public function compile_scene( _callbacks:Callback_Struct ):void
		{
			var scene:SceneStruct = new SceneStruct(model, bg, audio, hostMC.transform.matrix, getBGMC().bgPosition);
			if (hostAPI)
				scene.ohUrl = hostAPI.getOHUrl();
			
			lastSceneSaved = scene;
			_callbacks.fin( scene );
		}
		
		public function sceneChangedSinceLastSave():Boolean {
			if (lastSceneSaved == null) return true;
			
			var changed:Boolean = false;
			if (!assetCompare(bg, lastSceneSaved.bg)) changed = true;
			else if (!assetCompare(audio, lastSceneSaved.audio)) changed = true;
			else if (hostAPI && hostAPI.getOHUrl() != lastSceneSaved.ohUrl) changed = true;
			else if (!matrixCompare(hostMC.transform.matrix, lastSceneSaved.hostMatrix)) changed = true;
			else if (!matrixCompare(getBGMC().bgPosition, lastSceneSaved.bgMatrix)) changed = true;
			
			trace("SceneController2D::sceneChangedSinceLastSave : " + changed);
			
			return changed;
			//return true;  //always return true until this feature has been properly tested
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
		
		//----------------------------  DESTRUCTOR -------------------------
		
		override public function destroy():void {
			super.destroy();
			hostMC.destroy();
		}
	}
	
}
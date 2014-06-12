/**
* ...
* @author Sam
* @version 1.0
* 
* This is the heart of the workshop.  It stores all the data about the current model, bg, and audio.
* It provides methods to change those things all well as color, size, accessories.  It provides
* callbacks when things are loaded or changed as well as speech callbacks.
* 
* ********* PROPERTIES *********
* 
* model : current model loaded - null if none
* bg: current bg loaded - null if none
* audio : current audio selected - null if none
* mc : actual host movieclip
* zoomer : zoomer object for manipulating host
* 
*********** CONSTRUCTOR ********
* 
* SceneController(in_player:Sprite)
* 
* player is the movieclip where the scene (host/bg) will be loaded.
* player.hostMask -> this is the mask for the host.  it will be duplicated to create a mask for the bg. it also specifies the active area of the scene.
* player.hostMC -> this is an empty MC of class HostLoader where the host will be loaded
* player.bgMC -> this is an empty MC of class BGLoader where the bg will be loaded
* 
* For upload photo workshops, also:
* player.bgManipulate -> this is a BGUI movieclip.  it contains zoom controls for the background for upload
* photo purposes
* 
* you can also set the hostMC and bgMC with
* setHostMC($mc) and setBGMC($mc)
* 
*********** FUNCTIONS **********
* Model:
* 
* loadModel(model) - load model
* 
* getColors():Object - returns an associative array of hex color values eg {eyes:0x0000FF, mouth: 0xFF0000}
* setHexColor(name,value) - set color of given item
* 
* getRanges() - returns an array of com.oddcast.vhost.ranges.RangeData objects containing name,type, and value
* 
* getScale(name[,type]) - returns scale of item with given name (eg "mouth") and type.  Type is required for
* 3D controller - but optional for 2D controller - types of each item are returned with getRanges() function
* returns a number between 0-1
* 
* setScale(name,val[,type]) - sets scale of item.  value is a number between 0-1
* 
* getAccTypes():Array - returns an array of numbers representing type ids of available accessory types
* getAccessories():Object - returns an array of Accessory objects, indexed by typeId, of currently selected accessories
* loadAccessory(acc) - load accessory
* 
* BG:
* 
* loadBG(bg) - load bg
* initUploadPhoto() - configures bg mc for upload photo.  i.e. bg can be moved around within a mask area
* hasUploadPhoto() - returns whether background is static or in upload photo mode (can be dragged)
* 
* Audio:
* 
* selectAudio(audio) - save this audio with this scene
* clearAudio() - associate no audio with this scene
* previewAudio(audio) - host speaks this audio, but it is not saved
* playSceneAudio() - plays the audio associated with the scene
* stopAudio() - stop yapping
* 
* Saving:
* 
* getSceneData() - returns a SceneStruct object which contains the selected model,bg,audio, etc. for saving purposes
* 
*************** EVENTS *****************
* 
* ProcessingEvent.STARTED / ProcessingEvent.DONE
* returns these events whenever the scene starts/finishes processing something.  This is so you can block the
* workshop and show a procesing animation.  Usually they accompany another callback.  These events are provided
* just for the convenience of showing procesing bars.
* ProcesingEvent contains a property processName - which tells you what is being processed.
* Processes are:
* ProcessingEvent.MODEL - when model starts/finishes loading - note that the scene also returns a MODEL_LOADED event
* ProcessingEvent.AUDIO - when the host is loading audio to be played.  STARTED coincides with when you call playSceneAudio() or
* previewaudio(), and DONE coincides with talkStarted
* ProcessingEvent.BG - note implemented yet
* "accessory" - not implemented yet
* 
* 
* MODEL_LOADED aka "configDone" - model is loaded
* BG_LOADED - bg is loaded
* AUDIO_UPDATED - a new audio has been selected
* COLOR_UPDATED - not implemented
* SIZING_UPDATED - when you change the sizing
* ACCESSORY_LOADED - not implemented
* ACCESSORY_LOAD_ERROR - not implemented
* 
* These events come directly from the avatar:
* talkStarted
* talkEnded
* talkError
* 
*/

package com.oddcast.workshop {
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.event.AudioEvent;
	import com.oddcast.event.EngineEvent;
	import com.oddcast.event.ModelEvent
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.workshop.WSModelStruct;
	import com.oddcast.utils.MoveZoomUtil;
	import com.oddcast.vhost.ranges.RangeData;
	import com.oddcast.vhost.VHostRemoteController;
	import com.oddcast.workshop.BGLoader;
	import com.oddcast.workshop.HostLoader;
	import com.oddcast.workshop.ProcessingEvent;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.vhost.OHUrlParser;
	import com.oddcast.audio.AudioData;
	import com.oddcast.workshop.ServerInfo;
	//import workshop.uploadphoto.BGUI;

	public class SceneController extends EventDispatcher implements ISceneController {
		protected var sceneModel:WSModelStruct;
		private var sceneBG:WSBackgroundStruct;
		private var sceneAudio:AudioData;

		protected var loadingModel:Boolean=false;
		protected var numAccessoriesLoading:int = 0;
		private var isUploadPhoto:Boolean=false;
		protected var accToLoad:AccessoryData;
		//private var controller:VHostRemoteController;
		private var controller:*;
		protected var accTypes:Array;
		protected var accArr:Object;
		protected var modelToLoad:WSModelStruct;
		private var hostMoveZoom:MoveZoomUtil;
		
		//protected var bgManipulate:BGUI;
		protected var player:Sprite;
		protected var hostMC:HostLoader;
		protected var bgMC:BGLoader;
		protected var hostMask:Sprite;
		protected var bgMask:Sprite;		
		
		public static const MODEL_LOADED:String="configDone";
		public static const BG_LOADED:String="bgUpdated";
		public static const AUDIO_UPDATED:String="audioUpdated";
		public static const COLOR_UPDATED:String="colorUpdated";
		public static const SIZING_UPDATED:String="sizingUpdated";
		public static const ACCESSORY_LOADED:String="accessoryLoaded";
		public static const ACCESSORY_LOAD_ERROR:String="accessoryLoadError";
		public static const TALK_STARTED:String="talkStarted";
		public static const TALK_ENDED:String="talkEnded";
		public static const TALK_ERROR:String="talkError";
		
		public function SceneController(in_player:Sprite) {
			player=in_player;
			hostMask=player.getChildByName("hostMask") as Sprite;
			//bgManipulate=player.getChildByName("bgManipulate");
			hostMC=player.getChildByName("hostHolder") as HostLoader;
			bgMC=player.getChildByName("bgHolder") as BGLoader;
		}
		
		public function setHostMC($mc:HostLoader) {
			hostMC=$mc;
		}
		public function getHostMC():HostLoader {
			return(hostMC);
		}
		public function setBGMC($mc:BGLoader) {
			bgMC=$mc;
		}
		public function setHostMask($mc:Sprite) {
			hostMask = $mc;
		}
		
		public function get full_body(  ):IBody_Controller
		{	throw( new Error('FULL BODY ALLOWED FOR 3D ONLY :: com.oddcast.workshop.SceneController.full_body()') );
		}
		public function set full_body( _fb_controller:IBody_Controller ):void
		{	throw( new Error('FULL BODY ALLOWED FOR 3D ONLY :: com.oddcast.workshop.SceneController.full_body()') );
		}
		public function full_body_ready():Boolean
		{	return false;
		}
		
		public function init() {			
			bgMC.addEventListener(Event.INIT, bgLoaded, false, 0, true);
			bgMC.addEventListener(ErrorEvent.ERROR, bgError, false, 0, true);
			
			hostMC.mask=hostMask;
			bgMask=duplicateMask(hostMask)
			player.addChild(bgMask);
			bgMC.mask=bgMask;
			//player.addChild(bgMC.mask);
			
			hostMoveZoom=new MoveZoomUtil(hostMC);
			hostMoveZoom.setScaleLimits(0.1,3);
			hostMoveZoom.boundBy(hostMask,MoveZoomUtil.MASK_AREA);
			hostMoveZoom.anchorTo(hostMask);
			
			loadingModel=false;
			loadingAccessory=false;
			
			hostMC.addEventListener("talkStarted",talkStarted,false,0,true);
			hostMC.addEventListener("talkEnded",talkEnded,false,0,true);
			hostMC.addEventListener("talkError",talkError,false,0,true);
			hostMC.addEventListener("configDone", modelLoaded,false,0,true);
			hostMC.addEventListener("accessoryLoaded", accLoaded,false,0,true);
			hostMC.addEventListener("accessoryLoadError", accLoadError,false,0,true);
			//hostMC.addEventListener("engineLoaded",hostEvt);
			//hostMC.addEventListener(ProcessingEvent.STARTED,processingEvt,false,0,true);
			//hostMC.addEventListener(ProcessingEvent.DONE,processingEvt,false,0,true);
		}
		
		private function duplicateMask(maskMC:Sprite):Sprite {
			var newMask:Sprite=new Sprite();			
			newMask.graphics.beginFill(0);
			newMask.graphics.lineStyle(0);
			var maskBounds:Rectangle=maskMC.getBounds(player);
			newMask.graphics.drawRect(maskBounds.left,maskBounds.top,maskBounds.width,maskBounds.height);
			newMask.visible=false;
			return(newMask);
		}
		
		
		public function initUploadPhoto() {
			//bgManipulate.init(bgMC);
			isUploadPhoto=true;
		}
		
		public function hasUploadPhoto():Boolean {
			return(isUploadPhoto);
		}
		
		public function loadModel(in_model:WSModelStruct) {
			if (loadingModel) return;
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,ProcessingEvent.MODEL));
			modelToLoad=in_model;
			hostMC.loadModel(modelToLoad);
			loadingModel=true;
		}
		
		protected function modelLoaded(evt:Event) {
			//----//----trace("SceneController::modelLoaded")
			controller=hostMC.api.getConfigController();
			sceneModel=modelToLoad;
			var ohStr:String=OHUrlParser.getOHString(OHUrlParser.getOHObject(model.url)).split("/").join("|")
			var url:String="http://vhost.dev.oddcast.com/vhss_editors/getModelInfo.php?modelId="+model.id.toString()+"&oh="+ohStr;
			XMLLoader.loadXML(url,gotModelInfo);
		}
		
		public function gotModelInfo(_xml:XML) {
			var accItem:XML;
			accTypes=new Array();
			accArr=new Object();
			var typeId:int;
			for (var i=0;i<_xml.ITEM.length();i++) {
				accItem=_xml.ITEM[i];
				if (accItem.@AVAILABLE=="1") {
					typeId=parseInt(accItem.@ID)
					accTypes.push(typeId);
					accArr[typeId]=new AccessoryData(parseInt(accItem.@ACCID),"",typeId,"",parseInt(accItem.@COMP));
				}
			}
			loadingModel=false;
			dispatchEvent(new Event(MODEL_LOADED)); //modelLoaded
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,ProcessingEvent.MODEL));
		}

		public function loadBG(in_bg:WSBackgroundStruct) {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,ProcessingEvent.BG));
			bgMC.loadBG(in_bg);
			sceneBG=in_bg;
		}
		
		public function unloadBG() {
			bgMC.loadBG(null);
			sceneBG = null;
		}
		
		protected function bgLoaded(evt:Event) {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,ProcessingEvent.BG));
			dispatchEvent(new Event(BG_LOADED));
		}
		
		protected function bgError(evt:ErrorEvent) {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,ProcessingEvent.BG));
			dispatchEvent(evt);
		}		
		
		protected function talkStarted(evt:Event) {
			dispatchEvent(new Event(TALK_STARTED));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.AUDIO));			
		}
		protected function talkEnded(evt:Event) {
			dispatchEvent(new Event(TALK_ENDED));
		}
		protected function talkError(evt:Event) {
			dispatchEvent(new Event(TALK_ERROR));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.AUDIO));			
		}
		
		/*protected function processingEvt(evt:ProcessingEvent) {
			//----//----trace("SceneController::processingevt : "+evt.type);
			dispatchEvent(evt);
		}*/
		
		protected function accLoaded(evt:Event) {
			//----//----trace("SceneController::accLoaded --  accToLoad="+accToLoad)
			if (accToLoad == null) return;
			loadingAccessory = false;
			//----//----trace("accArr = " + accArr + "   --  typeId=" + accToLoad.typeId);
			accArr[accToLoad.typeId]=accToLoad;
			dispatchEvent(new Event(ACCESSORY_LOADED));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.ACCESSORY));
		}
		
		protected function accLoadError(evt:Event) {
			//----//----trace("SceneController::accLoadError")
			loadingAccessory=false;
			dispatchEvent(new Event(ACCESSORY_LOAD_ERROR));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.ACCESSORY));
		}
		
		public function loadAccessory($acc:AccessoryData) {
			var acc:AccessoryData = $acc;
			//----//----trace("SceneController::loadAccessory - id="+acc.id+" name="+acc.name);
			for (var obj in acc.getFragments()) //----//----trace(obj+":"+acc.getFragments()[obj]);
			if (loadingAccessory) return;
			accToLoad=acc;
			loadingAccessory=true;
			controller.setAccessory(acc);
			//dispatchEvent(new Event("accessoryLoading"));
		}
		
		private function get loadingAccessory():Boolean {
			return(numAccessoriesLoading > 0);
		}
		
		private function set loadingAccessory(b:Boolean) {
			numAccessoriesLoading = b?1:0;
		}
		
		public function removeAccessory($typeId:int) {
			throw new Error("removeAccessory is only available for 3d models");
		}
		
		public function removeAllAccessories():int {
			throw new Error("removeAllAccessories is only available for 3d models");
		}
		
		public function getAccTypes():Array {
			return(accTypes);
		}
		
		public function getAccessories():Object {
			return(accArr);
		}
		
		public function previewAudio(in_audio:AudioData) {
			if (in_audio==null||in_audio.url==null||in_audio.url=="") return;
			//----//----trace("SceneController say "+in_audio.url)
			if (hostMC &&
				hostMC.api)
				hostMC.api.stopSpeech();
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, ProcessingEvent.AUDIO));
			if (hostMC &&
				hostMC.api)
				hostMC.api.say(in_audio.url);
		}
		public function stopAudio() 
		{	if (hostMC &&
				hostMC.api)
				hostMC.api.stopSpeech();
		}
		public function playSceneAudio() {
			previewAudio(sceneAudio);
		}
		public function selectAudio(in_audio:AudioData) {
			sceneAudio=in_audio;
			dispatchEvent(new Event(AUDIO_UPDATED));
		}
		
		public function clearAudio() {
			sceneAudio=null;
			dispatchEvent(new Event(AUDIO_UPDATED));
		}
		
		public function get model():WSModelStruct {
			return(sceneModel);
		}
		
		public function get audio():AudioData {
			return(sceneAudio);
		}
		
		public function get bg():WSBackgroundStruct {
			return(sceneBG);
		}
		
		/*public function get mc():Sprite {
			return(hostMC);
		}*/
		
		//color/sizing controller functions
		public function getColors():Array {
			var colArr:Array = new Array();
			//----//----trace("hostMC - "+hostMC+" api - "+hostMC.api+" - controller - "+hostMC.api.getConfigController());
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
		public function setHexColor(grp:HostColorData,hexVal:uint) {
			controller.setHexColor(grp.name,hexVal);
			dispatchEvent(new Event(COLOR_UPDATED));
		}
		
		public function getRanges():Array {
			var rangeArr:Array=new Array();
			var grpName:String;
			
			var ranges:Object;
			ranges=controller.getScaledSections();
			for (grpName in ranges) rangeArr.push(new RangeData(grpName,"bg_scale",ranges[grpName]));
			ranges=controller.getAlphaSections();
			for (grpName in ranges) rangeArr.push(new RangeData(grpName,"alpha",ranges[grpName]));
			ranges=controller.getAgeSections();
			for (grpName in ranges) rangeArr.push(new RangeData(grpName,"age",ranges[grpName]));
			
			/*var ranges:Object=controller.getRanges();
			for (grpName in ranges) {
				rangeArr.push(new RangeData(grpName,ranges[grpName].type,ranges[grpName].val));
			}*/
			return(rangeArr);
		}
		
		public function getScale(grpName:String,grpType:String=""):Number {
			return(controller.getRanges()[grpName].val);
		}
		
		public function setScale(grpName:String,val:Number,grpType:String="") {
			controller.setScale(grpName,val);
			dispatchEvent(new Event(SIZING_UPDATED));
		}
				
		public function get zoomer():MoveZoomUtil {
			return(hostMoveZoom);
		}
		public function resetHost() {
			//only does something on 3d
		}
		
		public function getSceneData():SceneStruct {
			var scene:SceneStruct = new SceneStruct(model, bg, audio, hostMC);
			if (hostMC && hostMC.api)
				scene.ohUrl=hostMC.api.getOHUrl();
			return(scene);
		}
		
		public function freeze() {
			
		}
		
		public function resume() {
			
		}
	
		public function destroy() {
			bgMC.removeEventListener(Event.INIT,bgLoaded);			
			hostMC.removeEventListener("talkStarted",talkStarted);
			hostMC.removeEventListener("talkEnded",talkEnded);
			hostMC.removeEventListener("talkError",talkError);
			hostMC.removeEventListener("configDone", modelLoaded);
			hostMC.removeEventListener("accessoryLoaded", accLoaded);
			hostMC.removeEventListener("accessoryLoadError", accLoadError);
			hostMC.destroy();
		}
	}
	
}
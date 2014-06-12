/**
* ...
* @author Sam
* @version 1.0
* 
* This class contains the common functions for bothe 2d and 3d scene controllers
* 
* @see ISceneController for documentation
*/

package com.oddcast.workshop {
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.workshop.throttle.Throttler;
	import com.oddcast.workshop.WSModelStruct;
	import com.oddcast.utils.MoveZoomUtil;
	import com.oddcast.workshop.IBGLoader;
	import com.oddcast.workshop.HostLoader;
	import com.oddcast.workshop.ProcessingEvent;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.oddcast.audio.AudioData;
	import flash.utils.setTimeout;

	public class SceneControllerBase extends EventDispatcher {
		protected var sceneModel:WSModelStruct;
		//private var sceneBG:WSBackgroundStruct;
		private var sceneAudio:AudioData;
		
		protected var loadingModel:Boolean=false;
		protected var modelToLoad:WSModelStruct;
		private var hostMoveZoom:MoveZoomUtil;
		protected var accArr:Object;
		protected var accToLoad:AccessoryData;
		protected var numAccessoriesLoading:int = 0;
				
		protected var player:Sprite;
		protected var hostMC:HostLoader;
		private var bgMC:IBGLoader;
		private var hostMask:Sprite;
		private var bgMask:Sprite;
		
		public function SceneControllerBase(in_player:Sprite, _host_mask:Sprite = null, _bg_mask:Sprite = null, _host_loader:HostLoader = null, _bg_loader:IBGLoader = null)
		{	player		= in_player;
			// use whats specified, else try to get it from the player, else null
			hostMask	= (_host_mask) 		? _host_mask 	: (player ? player.getChildByName("hostMask") as Sprite 		: null);
			bgMask		= (_bg_mask) 		? _bg_mask	 	: (player ? player.getChildByName("bgMask") as Sprite 			: null);
			hostMC		= (_host_loader) 	? _host_loader 	: (player ? player.getChildByName("hostHolder") as HostLoader 	: null);
			bgMC		= (_bg_loader) 		? _bg_loader 	: (player ? player.getChildByName("bgHolder") as IBGLoader 		: null);
		}
		
		//----------------------------  INITIALIZATION -------------------------
		
		public function setHostMC($mc:HostLoader):void {
			hostMC=$mc;
		}
		public function getHostMC():HostLoader {
			return(hostMC);
		}
		public function setBGMC($mc:IBGLoader):void {
			bgMC=$mc;
		}
		public function getBGMC():IBGLoader {
			return(bgMC);
		}
		public function setHostMask($mc:Sprite):void {
			hostMask = $mc;
		}
		public function setBGMask($mc:Sprite):void {
			bgMask = $mc;
		}
		
		/**
		 * initialized after constructor called to set masks and listeners
		 */
		public function init():void
		{			
			if (hostMC && hostMask)		hostMC.mask = hostMask;
			if (bgMC && bgMask)			bgMC.setMask(bgMask);
			
			// set host dragging and zooming
			if (hostMC && hostMask)
			{
				hostMoveZoom = new MoveZoomUtil(hostMC);
				hostMoveZoom.setScaleLimits(0.1, 3);
				hostMoveZoom.boundBy(hostMask, MoveZoomUtil.MASK_AREA);
				hostMoveZoom.anchorTo(hostMask);
			}
			
			loadingModel=false;
			numAccessoriesLoading = 0;
			
			hostMC.addEventListener(SceneEvent.TALK_STARTED,talkStarted,false,0,true);
			hostMC.addEventListener(SceneEvent.TALK_ENDED,talkEnded,false,0,true);
			hostMC.addEventListener(SceneEvent.TALK_ERROR,talkError,false,0,true);
			hostMC.addEventListener(SceneEvent.CONFIG_DONE, modelLoaded, false, 0, true);
			hostMC.addEventListener(SceneEvent.MODEL_LOAD_ERROR, modelLoadError, false, 0, true);
			hostMC.addEventListener(SceneEvent.ACCESSORY_LOADED, accLoaded,false,0,true);
			hostMC.addEventListener(SceneEvent.ACCESSORY_LOAD_ERROR, accLoadError,false,0,true);
			hostMC.addEventListener(ProcessingEvent.PROGRESS, hostProcessingEvt, false, 0, true);
		}
				
		//----------------------------  PROPERTIES -------------------------
		
		public function get model():WSModelStruct 
		{
			trace('(Oo) :: SceneControllerBase.model().sceneModel :', sceneModel, typeof(sceneModel));
			return(sceneModel);
		}
		
		public function get audio():AudioData {
			return(sceneAudio);
		}
		
		public function get bg():WSBackgroundStruct {
			return(bgMC.bg);
		}
				
		public function get zoomer():MoveZoomUtil {
			return(hostMoveZoom);
		}
		
		//----------------------------  BG FUNCTIONS -------------------------
		
		public function loadBG(in_bg:WSBackgroundStruct):void {
			if (bg == in_bg) return;
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,ProcessingEvent.BG));
			bgMC.loadBG(in_bg);
		}
		
		public function unloadBG():void {
			if (bg == null) return;
			bgMC.loadBG(null);
		}
		
		protected function bgLoaded(evt:Event):void {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,ProcessingEvent.BG));
			dispatchEvent(new SceneEvent(SceneEvent.BG_LOADED));
		}
		
		protected function bgError(evt:Event):void {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,ProcessingEvent.BG));
			dispatchEvent(evt);
		}		
		
		//---------------------------- AUDIO FUNCTIONS -------------------------
		
		public function playSceneAudio():void {
			previewAudio(sceneAudio);
		}
		public function previewAudio(in_audio:AudioData):void {
			if (in_audio == null || in_audio.url == null || in_audio.url == "") 
				return;
			trace('(Oo) :: SceneControllerBase.previewAudio().in_audio.url :', in_audio.url, typeof(in_audio.url));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, ProcessingEvent.AUDIO));
		}
		
		public function selectAudio(in_audio:AudioData):void {
			sceneAudio=in_audio;
			dispatchEvent(new SceneEvent(SceneEvent.AUDIO_UPDATED));
		}
		
		public function clearAudio():void {
			sceneAudio=null;
			dispatchEvent(new SceneEvent(SceneEvent.AUDIO_UPDATED));
		}
		
		protected function talkStarted(evt:Event):void
		{	dispatchEvent(new SceneEvent(SceneEvent.TALK_STARTED));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.AUDIO));			
		}
		protected function talkEnded(evt:Event):void {
			dispatchEvent(new SceneEvent(SceneEvent.TALK_ENDED));
		}
		protected function talkError(evt:Event):void {
			dispatchEvent(new SceneEvent(SceneEvent.TALK_ERROR));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.AUDIO));			
		}
		
		protected function hostProcessingEvt(evt:ProcessingEvent) :void
		{
			dispatchEvent(evt);
		}
		
		//----------------------------  MODEL CALLBACKS -------------------------
		
		protected function modelLoaded(evt:Event) :void
		{
			sceneModel = modelToLoad;
			trace('(Oo) :: SceneControllerBase.modelLoaded().sceneModel :', sceneModel, typeof(sceneModel));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.MODEL));
		}
		protected function modelLoadError(evt:SceneEvent):void {
			sceneModel=null;
			loadingModel=false;
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.MODEL));
			dispatchEvent(evt);
		}
		
		protected function accLoaded(evt:Event):void {
			trace("SceneController::accLoaded --  accToLoad="+accToLoad)
			if (accToLoad == null) return;
			numAccessoriesLoading--;
			accArr[accToLoad.typeId]=accToLoad;
			dispatchEvent(new SceneEvent(SceneEvent.ACCESSORY_LOADED));
			if (numAccessoriesLoading == 0) {
				dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.ACCESSORY));
			}
		}
		
		protected function accLoadError(evt:Event):void {
			trace("SceneController::accLoadError")
			numAccessoriesLoading--;
			dispatchEvent(new SceneEvent(SceneEvent.ACCESSORY_LOAD_ERROR));
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.ACCESSORY));
		}
		//----------------------------  DESTRUCTOR -------------------------
		
		public function destroy():void {
			if (bgMC != null) bgMC.removeEventListener(Event.INIT, bgLoaded);			
			if (hostMC!=null) {
				hostMC.removeEventListener(SceneEvent.TALK_STARTED,talkStarted);
				hostMC.removeEventListener(SceneEvent.TALK_ENDED,talkEnded);
				hostMC.removeEventListener(SceneEvent.TALK_ERROR,talkError);
				hostMC.removeEventListener(SceneEvent.CONFIG_DONE, modelLoaded);
				hostMC.removeEventListener(SceneEvent.MODEL_LOAD_ERROR, modelLoadError);
				hostMC.removeEventListener(SceneEvent.ACCESSORY_LOADED, accLoaded);
				hostMC.removeEventListener(SceneEvent.ACCESSORY_LOAD_ERROR, accLoadError);
			}
		}
	}
	
}
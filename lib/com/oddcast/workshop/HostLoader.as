/**
* ...
* @author Sam, Me^
* @version 0.3
* 
* This class is used to load the 2d & 3d hosts.
* 
* FUCNTIONS:
* 
* loadModel(model) - load a 2d or 3d model
* 
* for 3d models things will load in this order:
* 1. if model.engine != current engine, load the engine and the control file
* 2. if model.url != current OA1 head and model.url !=null load the model url (OA1 file)
* 3. if model.charXML !=null load the charXML
* 
* destroy() - release everything from memory so the gc can clean it up
* 
* 
* 
* EVENTS:
* 
* "configDone"
* ProcessingEvent.PROGRESS - dispatched with processType ProcessingEvent.MODEL with the percentage loaded
* 
*/

package com.oddcast.workshop 
{
	import com.oddcast.assets.structures.*;
	import com.oddcast.event.*;
	import com.oddcast.host.api.*;
	import com.oddcast.host.api.events.*;
	import com.oddcast.host.api.fullbody.IHeadPlugin;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.*;

	public class HostLoader extends Sprite 
	{
		private var loader2d:Loader;
		private var loader3d:Loader;
		
		private var holder2d:MovieClip;
		private var modelHolderDict:Dictionary;
		private var curModelHolder:MovieClip;
		
		private var engine3d:MovieClip;
		private var curEngineUrl2d:String=null;
		private var curEngineUrl3d:String=null;
		private var curIs3d:Boolean;
		/** object for adding the head to the full body */
		public var ihead_plugin:IHeadPlugin;
		
		public var api:*;
		private var iv:Number;
		private var completeEvent:String;
		
		private var modelToLoad:WSModelStruct;
		
		private var loadingEngine:Boolean=false;
		private var loadingModel:Boolean=false;
		private var loadingChar:Boolean=false;
		
		private var curModelUrl:String;	
		private var curModelCharXML:String;

		private static var ENGINE_URL:String;
		private static var CONTROL_URL:String;
		//private var urlsInited:Boolean = false;
		
		private var fileProgressArray:Array;
		private var progressPollingIntervalMS:Number = 250;
		
		private static const ENGINE_3D_PROCESSES:int = 3;
		private static const ENGINE_2D_PROCESSES:int = 2;

		/*private function initUrls() 
		{
			var charBaseUrl:String = ServerInfo.staging?"http://char.dev.oddcast.com/":"http://char.oddcast.com/";
			ENGINE_URL = charBaseUrl+"engines/3D/v1/engineE3Dv1.swf";
			
			if (ServerInfo.staging) CONTROL_URL = "http://host.staging.oddcast.com/content2/customhost/3dtemp/ctl/si_salesdemo.ctl";
			else CONTROL_URL = "http://host-d.oddcast.com/ccs6/customhost/3dtemp/ctl/si_salesdemo.ctl";
			urlsInited = true;
		}*/
		
		public function loadModel(model:WSModelStruct):void
		{
			if (model == null)
				throw(new Error("loadModel called with null Model object"));
			/*if (!urlsInited)
				initUrls();*/
			if (loadingEngine)
				return;
			
			modelToLoad=model;
			Tracer.write("HostLoader::loadModel - "+model.url+"   is3d? - "+model.is3d);
			if (model.is3d)
				load3D();
			else
				load2D();
		}
		
		private function load2D():void {
			Tracer.write("HostLoader::load2D");
			if (curEngineUrl2d==null||(modelToLoad.engine!=null&&modelToLoad.engine.url!=curEngineUrl2d)) {
				if (modelToLoad.engine==null) {
					if (curEngineUrl2d == null) {
						throw new Error("HostLoader::load2D  -  Invalid 2D Engine!!!!!!!!!!");
						//modelToLoad.engine=new EngineStruct("http://content.dev.oddcast.com/char/engines/engineV5.swf");
					}
					else modelToLoad.engine=new EngineStruct(curEngineUrl2d);
				}
				load2DEngine();
			}
			else load2DModel();
		}
		
		private function load2DEngine():void {
			Tracer.write("HostLoader::load2DEngine");
			loadingEngine=true;
			var engineUrl:String = modelToLoad.engine.url;
			curEngineUrl2d=engineUrl;
			if (loader2d==null) {
				loader2d=new Loader();
				loader2d.contentLoaderInfo.addEventListener(Event.COMPLETE,engine2DLoaded,false,0,true);
				loader2d.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, engine2DLoadProgress, false, 0, true);
			}
			else loader2d.unload();
			loader2d.load(new URLRequest(engineUrl));
		}
		
		private function engine2DLoadProgress(evt:ProgressEvent):void {
			var progressEvent:ProcessingEvent = new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.MODEL);
			progressEvent.message = "Loading Engine";
			progressEvent.percent = ( evt.bytesLoaded / evt.bytesTotal ) / ENGINE_2D_PROCESSES;
			dispatchEvent(progressEvent);
		}
		
		private function engine2DLoaded(evt:Event):void {
			Tracer.write("HostLoader::engine2DLoaded");
			loadingEngine=false;
			if (loader3d!=null&&loader3d.parent==this) {
				removeChild(loader3d);
			}
			addChild(loader2d);
			curIs3d=false;
			api = loader2d.content;

			api.addEventListener(EngineEvent.CONFIG_DONE, configDone2D, false, 0, true);
			api.addEventListener(EngineEvent.TALK_ENDED, talkEnded, false, 0, true);
			api.addEventListener(EngineEvent.AUDIO_ERROR, talkError, false, 0, true);
			api.addEventListener(EngineEvent.TALK_STARTED, talkStarted, false, 0, true);
			api.addEventListener(EngineEvent.ACCESSORY_LOADED, accLoaded, false, 0, true);
			api.addEventListener(EngineEvent.ACCESSORY_INCOMPATIBLE, accLoadError, false, 0, true);
			api.addEventListener(EngineEvent.MODEL_LOAD_ERROR,onModelLoadError);
			holder2d=new MovieClip();
			modelHolderDict=new Dictionary();
			var engine:*=loader2d.content;
			engine.addChild(holder2d);
			if (modelToLoad!=null) load2DModel();
		}
		
		private function load2DModel():void {
			var url:String = modelToLoad.url;

			Tracer.write("HostLoader::load2DModel : "+url);

			if (curModelHolder!=null) holder2d.removeChild(curModelHolder);
			if (modelHolderDict[url]==null) {
				curModelHolder=new MovieClip();
				modelHolderDict[url]={container:curModelHolder};
				holder2d.addChild(curModelHolder);
				TimerUtil.setInterval(model2DProgress, progressPollingIntervalMS);
				api.loadModel(url, curModelHolder);
			}
			else {
				curModelHolder = modelHolderDict[url].container;
				var curModelPtr:MovieClip=modelHolderDict[url].pointer;
				holder2d.addChild(curModelHolder);
				api.setActiveModel(curModelPtr);
				//Tracer.write("HostLoader::2D setActiveModel (configDone) - "+mcPath(curModelPtr));
				dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
			}
		}
		
/*		private function mcPath(mc:DisplayObjectContainer):String {
			return(mcPathAux(mc).join("."));
		}
		
		private function mcPathAux(mc:DisplayObjectContainer):Array {
			var a:Array;
			if (mc.parent==null) return([mc.name]);
			else return(mcPathAux(mc.parent).concat(mc.name));
		}*/
		
		private function model2DProgress():void {
			var progressEvent:ProcessingEvent = new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.MODEL);
			progressEvent.message = "Loading Host";
			progressEvent.percent = ( api.modelPercentLoaded() / ENGINE_2D_PROCESSES ) + 0.5;
			dispatchEvent(progressEvent);
		}
		
		private function onModelLoadError(evt:EngineEvent):void {
			Tracer.write("HostLoader::2D -- onModelLoadError");
			TimerUtil.stopInterval(model2DProgress);
			stop_processing_notification();
			dispatchEvent(new SceneEvent(SceneEvent.MODEL_LOAD_ERROR,evt.data));
		}
		
		private function configDone2D(evt:*):void {
			Tracer.write("HostLoader::2D -- CONFIG DONE!!");
			TimerUtil.stopInterval(model2DProgress);
			
			var modelPtr:MovieClip = evt.data as MovieClip;
			modelHolderDict[modelToLoad.url].pointer = modelPtr;
			
			api.getConfigController().addEventListener(EngineEvent.ACCESSORY_LOADED,accLoaded,false,0,true);
			api.getConfigController().addEventListener(EngineEvent.ACCESSORY_INCOMPATIBLE,accLoadError,false,0,true);
			
			dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
		}
		
		//-------------------------  THREE DIMENSIONS ------------------------------
		
		private function load3D():void {
			Tracer.write("HostLoader::load3D   curengineUrl3d="+curEngineUrl3d+"  model engine="+modelToLoad.engine);
			//dispatchEvent(new Event("configDone")); - for testing purposes only - dont load anyting
			//return;

			if (curEngineUrl3d==null||(modelToLoad.engine!=null&&modelToLoad.engine.url!=curEngineUrl3d)) {
				if (modelToLoad.engine==null) {
					modelToLoad.engine=new EngineStruct(ENGINE_URL);
					modelToLoad.engine.ctlUrl=CONTROL_URL;
				}
				load3DEngine();
			}
			else load3DModel();
		}
		
		private function load3DEngine():void {
			loadingEngine=true;
			curEngineUrl3d=modelToLoad.engine.url;
			Tracer.write("HostLoader:load3DEngine : "+curEngineUrl3d);

			//if (loader3d==null) {
				//loader3d=new Loader();
				//loader3d.contentLoaderInfo.addEventListener(Event.COMPLETE, engine3DLoaded, false, 0, true);
				//loader3d.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, engine3DLoadProgress, false, 0, true);
			//}
			//else loader3d.unload();
			//loader3d.load(new URLRequest(curEngineUrl3d));
			
			if (loader3d)
				loader3d.unload();
			var engine_ldr_context:LoaderContext = new LoaderContext(true, new ApplicationDomain(this.root.loaderInfo.applicationDomain));
			var request:Gateway_Request = new Gateway_Request( curEngineUrl3d, new Callback_Struct( fin, progress, error )/*, 0, engine_ldr_context*/ );
			request.background = true;
			Gateway.retrieve_Loader(request);
			function fin( _content:Loader ):void 
			{	loader3d = _content;
				engine3DLoaded();
			}
			function progress( _percent:int ):void
			{
				var progressEvent:ProcessingEvent = new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.MODEL);
				progressEvent.message = "Loading Engine";
				progressEvent.percent = (_percent / 100) / ENGINE_3D_PROCESSES;
				dispatchEvent(progressEvent);
			}
			function error( _msg:String ):void 
			{	
				stop_processing_notification();
				dispatchEvent(new SceneEvent(SceneEvent.MODEL_LOAD_ERROR, 'engine load failure: ' + curEngineUrl3d));
			}
			
		}
		
		//private function engine3DLoadProgress(evt:ProgressEvent) {
			//var progressEvent:ProcessingEvent = new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.MODEL);
			//progressEvent.message = "Loading Engine";
			//progressEvent.percent = (evt.bytesLoaded / evt.bytesTotal) / ENGINE_3D_PROCESSES;
			//dispatchEvent(progressEvent);
		//}
		
		private function engine3DLoaded(/*evt:Event*/):void
		{	
			Tracer.write("HostLoader::engine3DLoaded")
			if (loader2d!=null&&loader2d.parent==this) {
				removeChild(loader2d);
			}
			curIs3d=true;
			addChild(loader3d);
			var engine:*=loader3d.content as MovieClip;
			engine.init(engine);
			api = engine.getAPI();
			api.addEventListener(EngineEvent.CONFIG_DONE, engineReady, false, 0, true);
			
			api.addEventListener(EngineEventStrings.TALK_STARTED,talkStarted,false,0,true)
			api.addEventListener(EngineEventStrings.TALK_ENDED,talkEnded,false,0,true)
			api.addEventListener(Event3DFileError.EVENT3D_FILE_ERROR,onEngine3dError,false,0,true)
			api.addEventListener(EngineEventStrings.PROCESSING_STARTED,processingStarted,false,0,true);
			api.addEventListener(EngineEventStrings.PROCESSING_ENDED, processingEnded,false,0,true);
			api.addEventListener(EngineEventStrings.ACCESSORY_ENDED, accLoaded, false, 0, true);
			//api.addEventListener(EngineEvent.ACCESSORY_INCOMPATIBLE, accLoadError,false,0,true);
			loader3d.content.addEventListener(MouseEvent.MOUSE_DOWN,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.MOUSE_UP,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.MOUSE_MOVE,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.CLICK,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.ROLL_OVER,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.ROLL_OUT,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.MOUSE_WHEEL,clickEvent,false,0,true);	
		}
		
		private function engineReady(evt:Event) :void
		{
			// create a plugin for connecting with the full body engine
			if (modelToLoad.has_body_data())
				ihead_plugin = api.createFaceGenHeadPlugIn();
			else
				ihead_plugin = null;
				
			//dispatchEvent(new Event("engineLoaded"));
			var ctlUrl:String = modelToLoad.engine.ctlUrl;
			Tracer.write("HostLoader::engineReady - control url = "+ctlUrl)
			if (ctlUrl == null || ctlUrl == "") controlLoaded(null);
			else {
				api.addEventListener(EngineEvent.PROCESSING_ENDED,controlLoaded,false,0,true);
				fileProgressArray = api.loadURLwithProgress(ctlUrl, EditLabel.U_CTL, API_Constant.UNDO_FLAGS_LOAD_CTL);
				TimerUtil.setInterval(controlProgress, progressPollingIntervalMS);
			}
		}
		
		private function controlProgress():void {
			var progressEvent:ProcessingEvent = new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.MODEL);
			progressEvent.message = "Loading Control File";
			progressEvent.percent = ( calculatePercent(fileProgressArray) / ENGINE_3D_PROCESSES ) + .3;
			dispatchEvent(progressEvent);
		}

		private function controlLoaded(evt:Event):void {
			TimerUtil.stopInterval(controlProgress);
			
			api.removeEventListener(EngineEvent.PROCESSING_ENDED,controlLoaded);
			
			Tracer.write("HostLoader::controlLoaded")
			loadingEngine=false;
		
			if (modelToLoad==null) {
				dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
				//dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,"model"));
			}
			else load3DModel();
		}
		
		private function load3DModel():void {
			var url:String=modelToLoad.url;
			if (url==curModelUrl||url==null) {
				if (modelToLoad.charXml != null) load3DCharacter();
				else dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
				return;
			}
			loadingModel=true;
			
			Tracer.write("HostLoader::Load3DModel url="+url);
			curModelUrl = url;
			curModelCharXML = null;
			fileProgressArray=api.loadURLwithProgress(url,EditLabel.U_HEAD,API_Constant.UNDO_FLAGS_LOAD_ZIP);
		}
		
		private function load3DCharacter():void {	
			var xmlStr:String = modelToLoad.charXml.toXMLString();
			if (xmlStr == curModelCharXML) {
				dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
				return;
			}
			
			Tracer.write("HostLoader::Load3DCharacter xml=" + xmlStr);
			loadingChar = true;
			curModelCharXML = xmlStr;
			fileProgressArray = api.loadXML(xmlStr);
		}
		
		//---------------------------------------- EVENTS ----------------------------

		/**
		 * errors dispatched from the 3D engine
		 * @param	_e	error created by the 3D engine
		 */
		private function onEngine3dError(_e:Event3DFileError):void
		{
			/*if (_e.fileDesc == Event3DFileError.FILE_DESC_MP3) 
				talkError(_e);
			*/
			/*else if (evt.fileDesc.indexOf(Event3DFileError.FILE_DESC_ACC) == 0) {
				//this is caused by a file load error, not incompatilibility
				//accLoadError(evt);
			}
			*/
			
			if (_e.fileDesc.indexOf(Event3DFileError.FILE_DESC_ACC) == 0) 
			{	//this is caused by a file load error, not incompatilibility
				//accLoadError(_e);	-- not using this because this also happens when the network is disconnected
				stop_processing_notification();
				dispatchEvent(new SceneEvent(SceneEvent.MODEL_LOAD_ERROR, _e.fileDesc));
			}
			else
			{	switch (_e.fileDesc)
				{	case Event3DFileError.FILE_DESC_MP3:	talkError( _e );	
															break;
					case Event3DFileError.FILE_DESC_FG:		// error loading model, eg: from morphing
															stop_processing_notification();
															dispatchEvent(new SceneEvent(SceneEvent.MODEL_LOAD_ERROR, _e.fileDesc));
															break;
					default:								// uncaught error from 3d engine
															trace('(Oo) :: HostLoader.onEngine3dError()._e UNHANDLED 3D ERROR :', _e, typeof(_e));
				}
			}
		}
		
		private function clickEvent(evt:MouseEvent):void {
			dispatchEvent(evt);
		}
		private function talkStarted(evt:Event):void {
			Tracer.write("## GOT HOST EVENT : "+evt.type);
			dispatchEvent(new SceneEvent(SceneEvent.TALK_STARTED));
		}
		private function talkEnded(evt:Event):void {
			Tracer.write("## GOT HOST EVENT : "+evt.type);
			dispatchEvent(new SceneEvent(SceneEvent.TALK_ENDED));			
		}
		private function talkError(evt:Event):void {
			Tracer.write("## GOT HOST EVENT : "+evt.type);
			dispatchEvent(new SceneEvent(SceneEvent.TALK_ERROR));
		}
		private function accLoaded(evt:Event):void {
			trace("HostLoader::accLoaded")
			dispatchEvent(new SceneEvent(SceneEvent.ACCESSORY_LOADED));
		}
		private function accLoadError(evt:Event):void {
			//dispatched by 2d workshop when there is incompatibility
			dispatchEvent(new SceneEvent(SceneEvent.ACCESSORY_LOAD_ERROR));
		}
		
		private function processingStarted(evt:Event):void {
			TimerUtil.setInterval(processingProgress,progressPollingIntervalMS);
		}
		private function processingProgress():void {
			var progressEvent:ProcessingEvent = new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.MODEL);
			if (loadingModel)		progressEvent.message = "Loading Head File";
			else if (loadingChar)	progressEvent.message = "Loading Character";
			else 					progressEvent.message = "Loading Host - other process";
			progressEvent.percent = ( calculatePercent(fileProgressArray) / ENGINE_3D_PROCESSES ) + .6;
			dispatchEvent(progressEvent);
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
		
		private function processingEnded(evt:Event):void {
			stop_processing_notification();
			
			Tracer.write("HostLoader::processingEnded - model=" + loadingModel + " char=" + loadingChar);
			
			if (loadingModel) {
				loadingModel=false;
				Tracer.write("HostLoader::processingEnded charXML = "+modelToLoad.charXml);
				if (modelToLoad.charXml==null) {
					Tracer.write("HostLoader::procesingEnded  ## dispatching configdone");
					dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
				}
				else load3DCharacter();
			}
			else if (loadingChar) {
				loadingChar=false;
				Tracer.write("HostLoader::procesingEnded  ## dispatching configdone");
				dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
			}
		}
		
		private function stop_processing_notification(  ):void 
		{	TimerUtil.stopInterval(processingProgress);
		}
		
		public function setMask(in_mask:Sprite):void {
			in_mask.visible=false;
			mask=in_mask;
		}
		
		/* removes and destroys all references to the engine, OA1 and loaders */
		public function destroy():void 
		{
			TimerUtil.stopInterval(controlProgress);
			stop_processing_notification();
			if (api != null) 
			{
				api.removeEventListener(EngineEvent.CONFIG_DONE, configDone2D);
				api.removeEventListener(EngineEvent.TALK_ENDED, talkEnded);
				api.removeEventListener(EngineEvent.AUDIO_ERROR, talkError);
				api.removeEventListener(EngineEvent.TALK_STARTED, talkStarted);
				api.removeEventListener(EngineEvent.ACCESSORY_LOADED, accLoaded);
				api.removeEventListener(EngineEvent.ACCESSORY_INCOMPATIBLE, accLoadError);
				api.removeEventListener(EngineEvent.MODEL_LOAD_ERROR,onModelLoadError);
				api.removeEventListener(EngineEvent.CONFIG_DONE,engineReady)			
				api.removeEventListener(EngineEvent.PROCESSING_ENDED,controlLoaded);
				api.removeEventListener(EngineEventStrings.TALK_STARTED,talkStarted)
				api.removeEventListener(EngineEventStrings.TALK_ENDED,talkEnded)
				api.removeEventListener(EngineEventStrings.PROCESSING_STARTED,processingStarted);
				api.removeEventListener(EngineEventStrings.PROCESSING_ENDED, processingEnded);
				api.removeEventListener(EngineEventStrings.ACCESSORY_ENDED, accLoaded);
				api.removeEventListener(EngineEventStrings.TALK_STARTED,talkStarted)
				api.removeEventListener(EngineEventStrings.TALK_ENDED,talkEnded)
				api.removeEventListener(Event3DFileError.EVENT3D_FILE_ERROR,onEngine3dError)
				api.removeEventListener(EngineEventStrings.PROCESSING_STARTED,processingStarted);
				api.removeEventListener(EngineEventStrings.PROCESSING_ENDED, processingEnded);
				api.removeEventListener(EngineEventStrings.ACCESSORY_ENDED, accLoaded);
				if (api.hasOwnProperty("getConfigController") && api.getConfigController() != null) 
				{
					api.getConfigController().removeEventListener(EngineEvent.ACCESSORY_LOADED,accLoaded);
					api.getConfigController().removeEventListener(EngineEvent.ACCESSORY_INCOMPATIBLE, accLoadError);
				}
				api = null;
			}
			if (loader2d != null)
			{
				loader2d.unload();
				loader2d.contentLoaderInfo.removeEventListener(Event.COMPLETE, engine2DLoaded);
				loader2d.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, engine2DLoadProgress);
				loader2d = null;
			}
			if (loader3d != null && loader3d.contentLoaderInfo != null) 
			{
				loader3d.contentLoaderInfo.removeEventListener(Event.COMPLETE, engine3DLoaded);
				//loader3d.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, engine3DLoadProgress);
			}
			if (loader3d != null && loader3d.content != null) 
			{
				loader3d.content.removeEventListener(MouseEvent.MOUSE_DOWN,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.MOUSE_UP,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.MOUSE_MOVE,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.CLICK,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.ROLL_OVER,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.ROLL_OUT,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.MOUSE_WHEEL, clickEvent);
				(loader3d.content as Object).destroy();
				loader3d.unload();
				loader3d = null
			}
			curEngineUrl3d		= null;		// reload the engine
			curModelCharXML		= null;		// reload the model char
			curModelUrl			= null;		// reload the model 
		}
		
		/*	destroy the current loaded host while keeping the OA1 and engine,
		 * this forces the next load to be able to reload the same hosts xml only */
		public function destroy_host(  ):void 
		{
			curModelCharXML		= null;		// reload the model char
		}
		
	}
	
}
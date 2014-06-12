package com.oddcast.oc3d.shared
{
	import com.oddcast.ascom.ObjectFactory;
	import com.oddcast.host.api.fullbody.IHeadPlugin;
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	import com.oddcast.utils.MemoryTracer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.system.ApplicationDomain;
	import flash.system.System;
	import flash.utils.getTimer;

	public class FB3dAccessorySetWrapper
	{
		private var debug_:Boolean = false;

		private var sprite_:Sprite;
		private var accessorySetId_:uint;
		private var contentProvider_:IContentProvider;
		private var oc3dEngineUrl_:String;
		private var bootScript_:String;
		
		private static const NONE:int 		= 0;
		private static const DISPOSING:int	= 1;
		private static const DISPOSED:int 	= 2;
		private static const LOADING:int 	= 3;
		private static const LOADED:int 	= 4;
		private static const STARTING:int 	= 5;
		private static const STARTED:int 	= 6;
		private var state_:int = NONE;
		
		private var engine_:IEngine3D;
		private var scene_:IScene3D; 
		private var camera_:ICameraObject3D; 
		private var light_:IPointLight3D; 
		private var instance_:IInstance3D; 
		private var view_:IViewport3D; 
		private var viewManip_:ViewportManipulator;
		private var builder_:IAvatarBuilder;
		private var aSet_:IAccessorySet;
		private var model_:IModel;
		private var dropFrames_:Boolean = false;
		private var apiShowFn_:Function = null;
		private var apiDisposeFn_:Function = null; 
		
		// continuationFn:Function<void(FB3dAccessorySetWrapper, IAvatarBuilder, ICameraObject3D, ViewportManipulator, IAccessorySet)>
		public static function Create(sprite:Sprite, accessorySetId:int, modelId:int, contentProvider:IContentProvider, oc3dEngineUrl:String, bootScript:String, head:IHeadPlugin, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			new FB3dAccessorySetWrapper(sprite, accessorySetId, modelId, contentProvider, oc3dEngineUrl, bootScript, head, continuationFn, failedFn, progressedFn);
		}

		public function FB3dAccessorySetWrapper(sprite:Sprite, accessorySetId:int, modelId:int, contentProvider:IContentProvider, oc3dEngineUrl:String, bootScript:String, head:IHeadPlugin, continuationFn:Function, failedFn:Function, progressedFn:Function=null):void
		{
			state_ = LOADING;
			
			failedFn_ = failedFn == null ? failedCallback : failedFn;
			progressedFn_ = progressedFn == null ? progressedCallback : progressedFn;
			messageFn_ = messageCallback;
			
			sprite_ = sprite;
			accessorySetId_ = accessorySetId;
			contentProvider_ = contentProvider;
			oc3dEngineUrl_ = oc3dEngineUrl;
			bootScript_ = bootScript;
			
			var me:FB3dAccessorySetWrapper = this;
			
			// load engine
			ObjectFactory.load(oc3dEngineUrl_, new ApplicationDomain(ApplicationDomain.currentDomain), function(factory:ObjectFactory):void
			{
				factory.createObject("IEngine3D", 1, [contentProvider_, sprite_, function(engine:IEngine3D, showFn:Function, disposeFn:Function):void
				{
					engine_ = engine;
					apiShowFn_ = showFn;
					apiDisposeFn_ = disposeFn;
				
					// accessory stuff
					scene_ = engine_.newScene("mainScene");
					if (head != null)
						scene_.addPlugIn("head", head);
					scene_.setLoadingWireframeColor(Color.createWithComponents(0, 0, 0, 0));
					camera_ = scene_.newCameraObject3D(scene_.root(), "mainCamera");
					camera_.setPosition(0, 5, 40);
					camera_.setAim(0, 5, 0);
					light_ = scene_.light();
					light_.setPosition(40, 5, 0);
					instance_ = scene_.newInstance(scene_.root(), "base");
					
					// view stuff
					view_ = engine_.newViewport("view", sprite_, camera_);
					view_.setBackgroundColor(Color.createWithComponents(0, 0, 0, 0));//(new Color(0x444444));
					viewManip_ = new ViewportManipulator(view_);
					
					builder_ = IAvatarBuilder(factory.createObject("IAvatarBuilder", 1, [contentProvider_, instance_]));
					builder_.kernel().defineRootBoxedObject("app", null);
					builder_.kernel().defineRootBoxedObject("view", view_);
					builder_.kernel().messagedSignal().add(messageFn_);
					builder_.kernel().failedSignal().add(failedFn_);
					builder_.kernel().progressedSignal().add(progressedFn_);
					builder_.kernel().defineRootBoxedObject("cam1", camera_);
					builder_.kernel().defineRootBoxedObject("manip1", viewManip_);
					
					builder_.loadAccessorySet(accessorySetId_, function(aSet:IAccessorySet):void
					{
						aSet_ = aSet;
						state_ = LOADED;
						
						if (modelId > 0)
						{
							builder_.loadModel(modelId, function(model:IModel):void
							{
								model.preload(function():void
								{
									model.select(function():void
									{
										model_ = model;
										continuationFn(me, builder_, scene_, camera_, viewManip_, aSet);
										
									}, failedFn_, progressedFn_);
									
								}, failedFn_, progressedFn_);
								
							}, failedFn_, progressedFn_);
						}
						else
						{
							builder_.setPreloadManifestEnabled(true);
							continuationFn(me, builder_, scene_, camera_, viewManip_, aSet);
						}
						
					}, failedFn_, progressedFn_);
					
				}]);
				
			}, failedFn_, progressedFn_);
		}
		
		
		// PICKERS
		// continuationFn:Function<void(IAccessoryProxy)>
		public function tryPickAccessory(stageX:Number, stageY:Number, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= STARTED)
			{
				var screenPos:Point = view_.sprite().globalToLocal(new Point(stageX, stageY));
				builder_.tryPickAccessory
				(
					view_, 
					screenPos, 
					continuationFn,
					failedFn==null?failedFn_:failedFn,
					progressedFn==null?progressedFn_:progressedFn
				);
			}
		}
		
		public function accessorySet():IAccessorySet
		{
			if (state_ >= LOADED)
				return aSet_;
			else
				throw new Error("wrapper not loaded");				
		}
		
		// START
		// continuationFn:Function<void()>
		public function start(continuationFn:Function):void
		{
			if (state_ != LOADED)
			{
				continuationFn();
				return;
			}
			state_ = STARTING;
			
			aSet_.startup(bootScript_, function():void
			{
				state_ = STARTED;
				
				if (apiShowFn_ != null)
				{
					apiShowFn_();
					apiShowFn_ = null;
				}
				
				continuationFn(aSet_);
				
			}, failedFn_, progressedFn_);
		}
		
		// METHODS
		public function setDebug(b:Boolean):void { debug_ = b; }
		
		
		// CALLBACKS
		private var failedFn_:Function;
		private var progressedFn_:Function;
		private var messageFn_:Function;
		private function failedCallback(e:String):void { if (debug_) trace("[FB3dENGINE] " + e); };
		private function progressedCallback(l:uint, t:uint):void { if (debug_) trace("[FB3dENGINE] progress - " + uint((l/t)*100) + "%"); };
		private function messageCallback(msg:String):void { trace(msg); }
		// function<void(msg:String)>
		public function setFailedCallback(fn:Function):void { failedFn_ = fn; } 
		// function<void(loaded:uint, total:uint)>
		public function setProgressedCallback(fn:Function):void { progressedFn_ = fn; }
		// function<void(msg:String)>
		public function setMessageCallback(fn:Function):void { messageFn_ = fn; }
		// function<void(inst:IAccessoryProxy)>
		private var accessoryMouseUpFn_:Function;
		public function setAccessoryMouseUpCallback(fn:Function):void { accessoryMouseUpFn_ = fn; }
		
		
		// EVENTS
		public function postDoubleClickEvent(e:MouseEvent):void
		{
			if (state_ == STARTED)
			{
			}
		}
		public function postMouseMoveEvent(e:MouseEvent):void { if (state_ == STARTED) builder_.mouseMove(view_, e, failedFn_); }
		public function postMouseDownEvent(e:MouseEvent):void { if (state_ == STARTED) builder_.mousePress(view_, e, failedFn_); }
		public function postMouseUpEvent(e:MouseEvent):void 
		{
			if (state_ == STARTED)
			{
				builder_.mouseRelease(view_, e, failedFn_);

				var screenPos:Point = view_.sprite().globalToLocal(new Point(e.stageX, e.stageY)); 
				builder_.tryPickAccessory(view_, screenPos, function(accessory:IAccessoryProxy):void
				{
					if (accessory != null)
						if (accessoryMouseUpFn_ != null)
							accessoryMouseUpFn_(accessory);
					
				}, failedFn_, progressedFn_);
			} 
		}
		private var isRendering_:Boolean = false;
		private var currentTime_:Number = 0;
		public function postEnterFrameEvent(e:Event):void 
		{
			if (state_ == STARTED)
			{
				if (currentTime_ == 0)
					currentTime_ = getTimer();
				var newTime:Number = getTimer();
				
				isRendering_ = true;
				engine_.render(newTime-currentTime_); 
				isRendering_ = false;
				
				currentTime_ = newTime;
			}
			else if (state_ == DISPOSING)
				deferredDispose();
		}
		public function postKeyDownEvent(e:KeyboardEvent):void {}
		public function postKeyUpEvent(e:KeyboardEvent):void {}
		public function postActivateEvent(e:Event):void { if (state_ == STARTED && !dropFrames_) engine_.setIsFocused(true); }
		public function postDeactivateEvent(e:Event):void { if (state_ == STARTED && !dropFrames_) engine_.setIsFocused(false); }
		
		// disposing stuff
		private var disposeContinuationFn_:Function;
		public function dispose(continuationFn:Function):void
		{
			if (state_ >= LOADED)
			{
				disposeContinuationFn_ = continuationFn;
				if (isRendering_)
					state_ = DISPOSING;
				else
					deferredDispose();
			}
			else
				throw new Error("wrapper not loaded");
		}
		private function deferredDispose():void
		{
			model_ = null;
			aSet_ = null;
			sprite_ = null;
			builder_.dispose();
			builder_ = null;
			viewManip_.dispose();
			viewManip_ = null;
			view_.dispose();
			view_ = null;
			instance_.dispose();
			instance_ = null;
			light_.dispose();
			light_ = null;
			camera_.dispose();
			camera_ = null;
			scene_.dispose();
			scene_ = null;
			engine_.dispose();
			engine_ = null;
			if (apiDisposeFn_ != null)
			{
				apiDisposeFn_();
				apiDisposeFn_ = null;
			}
			System.gc();
			
			state_ = DISPOSED;
			if (disposeContinuationFn_ != null)
			{
				disposeContinuationFn_();
				disposeContinuationFn_ = null;
			}
		}
		
		
		// METHODS
		public function inputConfiguration(xml:XML, continuationFn:Function=null, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= LOADED)
				builder_.inputConfiguration(xml, continuationFn, failedFn=null?failedFn_:failedFn, progressedFn==null?progressedFn_:progressedFn);
			else
				throw new Error("wrapper not loaded");
		}
		public function outputConfiguration():XML
		{
			if (state_ >= LOADED)
				return builder_.outputConfiguration();
			else
				throw new Error("wrapper not loaded");
		}
		// continuationFn:Function<void(IMaterialConfiguration)>
		public function loadMaterialConfiguration(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= STARTED)
				builder_.loadMaterialConfiguration(id, continuationFn, failedFn=null?failedFn_:failedFn, progressedFn==null?progressedFn_:progressedFn)
			else
				throw new Error("wrapper not started");
		}
		// continuationFn:Function<void(IDecalConfiguration)>
		public function loadDecalConfiguration(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= STARTED)
				builder_.loadDecalConfiguration(id, continuationFn, failedFn=null?failedFn_:failedFn, progressedFn==null?progressedFn_:progressedFn)
			else
				throw new Error("wrapper not started");
		}
		// continuationFn:Function<void(IPreset)>
		public function loadPreset(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= STARTED)
				builder_.loadPreset(id, continuationFn, failedFn=null?failedFn_:failedFn, progressedFn==null?progressedFn_:progressedFn)
			else
				throw new Error("wrapper not started");
		}
		public function categories():Vector.<ICategoryProxy>
		{
			if (state_ >= LOADED)
			{
				var cats:Array;
				
				// if the model object is not null we returns the model's categories, else we return the accessory-set's categories
				if (model_ != null)
					cats = model_.children([ICategoryProxy]);
				else
					cats = aSet_.children([ICategoryProxy]);
				
				var result:Vector.<ICategoryProxy> = new Vector.<ICategoryProxy>(cats.length, true);
				for (var i:uint=0; i<cats.length; ++i)
					result[i] = cats[i];
				return result;
			}
			else
				throw new Error("wrapper not loaded");
		}
		public function currentModel():IModel
		{
			if (state_ >= LOADED)
				return model_;
			else
				throw new Error("wrapper not loaded");
		}
		public function models():Vector.<IModel>
		{
			if (state_ >= LOADED)
			{
				var models:Array = aSet_.children([IModel]);
				var result:Vector.<IModel> = new Vector.<IModel>(models.length, true);
				for (var i:uint=0; i<models.length; ++i)
					result[i] = models[i];
				return result;
			}
			else
				throw new Error("wrapper not loaded");
		}
		// continuationFn<void(IAvatar)>
		public function generateAvatar(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= STARTED)
			{
				if (sprite_.stage == null)
					throw new Error("failed to serialize avatar, stage is null"); // stage needed for changing quailty
				builder_.newAvatar("Untitled", sprite_.stage, false, continuationFn, failedFn=null?failedFn_:failedFn, progressedFn==null?progressedFn_:progressedFn);
			}
			else
				throw new Error("wrapper not started");
		}
		public function selectedMaterialConfigurations():Vector.<IMaterialConfiguration>
		{
			if (state_ >= STARTED)
				return builder_.selectedMaterialConfigurations();
			else
				throw new Error("wrapper not started");
		}
		public function setPaused(b:Boolean):void
		{
			if (state_ >= LOADED)
				engine_.setIsPaused(b);
			else
				throw new Error("wrapper not loaded");
		}
		public function paused():Boolean
		{
			if (state_ >= LOADED)
				return engine_.isPaused();
			else
				throw new Error("wrapper not loaded");
		}
		public function enableTrucking(b:Boolean):void
		{
			if (state_ >= LOADED)
				viewManip_.setTruckingEnabled(b);
			else
				throw new Error("wrapper not loaded");
		}
		public function enableZooming(b:Boolean):void
		{
			if (state_ >= LOADED)
				viewManip_.setZoomingEnabled(b);
			else
				throw new Error("wrapper not loaded");
		}
		public function setCameraAim(x:Number, y:Number, z:Number):void
		{
			if (state_ >= LOADED)
				camera_.setAim(x, y, z);
			else
				throw new Error("wrapper not loaded");
		}
		public function cameraAim():Vector3D
		{
			if (state_ >= LOADED)
				return camera_.aim();
			else
				throw new Error("wrapper not loaded");
		}
		public function setCameraPosition(x:Number, y:Number, z:Number):void
		{
			if (state_ >= LOADED)
				camera_.setPosition(x, y, z);
			else
				throw new Error("wrapper not loaded");
		}
		public function cameraPosition():Vector3D
		{
			if (state_ >= LOADED)
				return camera_.position();
			else
				throw new Error("wrapper not loaded");
		}
		public function setLightPosition(x:Number, y:Number, z:Number):void
		{
			if (state_ >= LOADED)
				light_.setPosition(x, y, z);
			else
				throw new Error("wrapper not loaded");
		}
		public function setViewYawLimits(min:Number, max:Number):void
		{
			if (state_ >= LOADED)
				viewManip_.setYawLimits(min, max);
			else
				throw new Error("wrapper not loaded");
		}
		public function setViewPitchLimits(min:Number, max:Number):void
		{
			if (state_ >= LOADED)
				viewManip_.setPitchLimits(min, max);
			else
				throw new Error("wrapper not loaded");
		}
		public function commands():Vector.<ICommandProxy>
		{
			if (state_ >= LOADED)
			{
				var result:Vector.<ICommandProxy> = new Vector.<ICommandProxy>();
				if (model_ == null)
				{
					var cmds:Array = aSet_.children([ICommandProxy]);
					for each (var cmd:ICommandProxy in cmds)
						result.push(cmd);
				}
				else
				{
					var cats:Array = model_.children([ICategoryProxy]);
					for each (var cat:ICategoryProxy in cats)
					{
						var children:Array = cat.children([ICommandProxy]);
						for each (var cmd2:ICommandProxy in children)
							result.push(cmd2);
					}
				}
				return result;
			}
			else
				throw new Error("wrapper not loaded");
		}
		public function executeCommand(commandName:String, arg:Array=null):Object
		{
			if (state_ >= LOADED)
			{
				var cmds:Array = aSet_.children([ICommandProxy]);
				var found:ICommandProxy = null;
				for each (var cmd:ICommandProxy in cmds)
				{
					if (cmd.name() == commandName)
					{
						found = cmd;
						break;
					}
				}
				if (found == null)
					throw new Error("command with name \"" + commandName + "\" not found");
				
				return found.invokeWithArray(arg==null?[]:arg);
			}
			else
				throw new Error("wrapper not loaded");
		}
		
		// continuationFn:Function<void(IModelProxy)>
		public function loadModel(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= STARTED)
			{
				builder_.loadModel(id, function(model:IModel):void
				{
					model_ = model;
					continuationFn(model);
					
				}, failedFn, progressedFn);
			}
			else
				throw new Error("wrapper not started");
		}
		
		// continuationFn:Function<void(IAnimationProxy)>
		public function loadAnimation(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= LOADED)
			{
				builder_.loadAnimation
				(
					id, 
					continuationFn, 
					failedFn==null?failedFn_:failedFn, 
					progressedFn==null?progressedFn_:progressedFn
				);
			}
			else
				throw new Error("wrapper not loaded");
		}
		public function loadSoundAndPlayVisemeOnAllAvailableMorphDeformers(
			url:String, 
			triggerAudio:Boolean,
			offset:Number,
			finishedLoadingCallback:Function=null, // Function<void(Vector.<ITalkChannel>)> 
			finishedPlayingCallback:Function=null, // Function<void()>
			failedFn:Function=null,
			progressedFn:Function=null):void
		{
			if (state_ >= LOADED)
			{
				Utilities.loadSoundAndPlayVisemeOnAllAvailableMorphDeformers
				(
					builder_,
					url,
					triggerAudio,
					offset,
					finishedLoadingCallback,
					finishedPlayingCallback,
					failedFn==null?failedFn_:failedFn, 
					progressedFn==null?progressedFn_:progressedFn
				);
			}
			else
				throw new Error("wrapper not loaded");
		}
		public function setDropFrames(b:Boolean):void 
		{
			if (state_ >= LOADED)
			{
				dropFrames_ = b;
				engine_.setIsFocused(!b);
			}
			else
				throw new Error("wrapper not loaded");
		}
	}
}
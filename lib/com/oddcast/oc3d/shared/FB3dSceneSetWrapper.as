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

	public class FB3dSceneSetWrapper
	{
		private var debug_:Boolean = false;

		private var sprite_:Sprite;
		private var sceneSetId_:uint;
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
		private var builder_:ISceneBuilder;
		private var sSet_:ISceneSet;
		private var dropFrames_:Boolean = false;
		private var apiShowFn_:Function = null;
		private var apiDisposeFn_:Function = null; 
		
		// CONSTRUCTION
		// continuationFn:Function<void(FB3dSceneSetWrapper, ISceneBuilder, ICameraObject3D, ViewportManipulator, ISceneSet)>
		public static function Create(sprite:Sprite, sceneSetId:uint, contentProvider:IContentProvider, oc3dEngineUrl:String, bootScript:String, head:IHeadPlugin, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			new FB3dSceneSetWrapper(sprite, sceneSetId, contentProvider, oc3dEngineUrl, bootScript, head, continuationFn, failedFn, progressedFn);
		}
		public function FB3dSceneSetWrapper(sprite:Sprite, sceneSetId:uint, contentProvider:IContentProvider, oc3dEngineUrl:String, bootScript:String, head:IHeadPlugin, continuationFn:Function, failedFn:Function, progressedFn:Function=null):void
		{
			state_ = LOADING;
			
			failedFn_ = failedFn == null ? failedCallback : failedFn;
			progressedFn_ = progressedFn == null ? progressedCallback : progressedFn;
			messageFn_ = messageCallback;
			
			sprite_ = sprite;
			sceneSetId_ = sceneSetId;
			contentProvider_ = contentProvider;
			oc3dEngineUrl_ = oc3dEngineUrl;
			bootScript_ = bootScript;
			
			var me:FB3dSceneSetWrapper = this;
			
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
					
					builder_ = ISceneBuilder(factory.createObject("ISceneBuilder", 1, [contentProvider_, camera_]));
					builder_.kernel().defineRootBoxedObject("app", null);
					builder_.kernel().defineRootBoxedObject("view", view_);
					builder_.kernel().messagedSignal().add(messageFn_);
					builder_.kernel().failedSignal().add(failedFn_);
					builder_.kernel().progressedSignal().add(progressedFn_);
					builder_.kernel().defineRootBoxedObject("cam1", camera_);
					builder_.kernel().defineRootBoxedObject("manip1", viewManip_);
					
					builder_.loadSceneSet(sceneSetId_, function(sSet:ISceneSet):void
					{
						sSet_ = sSet;
						state_ = LOADED;
						continuationFn(me);
						
					}, failedFn_, progressedFn_);		
				}]);
				
			}, failedFn_, progressedFn_);
		}
		

		// DEBUG
		public function setDebug(b:Boolean):void { debug_ = b; }
		
		public function sceneSet():ISceneSet
		{
			if (state_ >= LOADED)
				return sSet_;
			else
				throw new Error("wrapper not loaded");				
		}

		
		// START
		// continuationFn:Function<void()>
		public function start(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ != LOADED)
				continuationFn();
			else
			{
				state_ = STARTING;
				
				sSet_.startup(bootScript_, function():void
				{
					state_ = STARTED;
					
					if (apiShowFn_ != null)
					{
						apiShowFn_();
						apiShowFn_ = null;
					}

					continuationFn(sSet_);
					
				}, failedFn==null?failedFn_:failedFn, progressedFn==null?progressedFn_:progressedFn);
			}
		}

		
		// DISPOSE
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
			sSet_ = null;
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
			System.gc();
			if (apiDisposeFn_ != null)
			{
				apiDisposeFn_();
				apiDisposeFn_ = null;
			}
			state_ = DISPOSED;
			disposeContinuationFn_();
			disposeContinuationFn_ = null;
		}
		
		
		// PICKERS
		public function tryFindAvatarInstance(instanceName:String):IAvatarInstance
		{
			if (state_ >= STARTED)
				return builder_.tryFindAvatarInstance(instanceName);
			else
				return null;
		}
		public function tryPickAvatarInstance(stageX:Number, stageY:Number):IAvatarInstance
		{
			if (state_ >= STARTED)
			{
				var screenPos:Point = view_.sprite().globalToLocal(new Point(stageX, stageY));
				return builder_.tryPickAvatarInstance(view_, screenPos)
			}
			else
				return null;
		}
		// continuationFn:Function<void(IAccessoryProxy)>
		public function tryPickAccessory(instance:IAvatarInstance, stageX:Number, stageY:Number, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= STARTED)
			{
				var screenPos:Point = view_.sprite().globalToLocal(new Point(stageX, stageY));
				instance.avatarBuilderProxy().tryPickAccessory
				(
					view_, 
					screenPos, 
					continuationFn,
					failedFn==null?failedFn_:failedFn,
					progressedFn==null?progressedFn_:progressedFn
				);
			}
		}
		
		
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
		// function<void(inst:IAvatarInstance)>
		private var instanceMouseUpFn_:Function;
		public function setAvatarInstanceMouseUpCallback(fn:Function):void { instanceMouseUpFn_ = fn; }
		
		
		// EVENTS
		public function postDoubleClickEvent(e:MouseEvent):void { if (state_ == STARTED) { builder_.mouseDoubleClick(view_, e, failedFn_); } }
		public function postMouseMoveEvent(e:MouseEvent):void { if (state_ == STARTED) builder_.mouseMove(view_, e, failedFn_); }
		public function postMouseDownEvent(e:MouseEvent):void { if (state_ == STARTED) builder_.mousePress(view_, e, failedFn_); }
		public function postMouseUpEvent(e:MouseEvent):void 
		{
			if (state_ == STARTED)
			{
				builder_.mouseRelease(view_, e, failedFn_);

				var screenPos:Point = view_.sprite().globalToLocal(new Point(e.stageX, e.stageY)); 
				var instance:IAvatarInstance = builder_.tryPickAvatarInstance(view_, screenPos);
				if (instance != null)
					if (instanceMouseUpFn_ != null)
						instanceMouseUpFn_(instance);
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
		
		//  METHODS
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
		public function loadSoundAndPlayVisemeOnAllAvailableMorphDeformers(
			instanceName:String,
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
				var instance:IAvatarInstance = builder_.tryFindAvatarInstance(instanceName);
				if (instance == null)
				{
					failedFn_("instance not found");
					return;
				}
				Utilities.loadSoundAndPlayVisemeOnAllAvailableMorphDeformers
				(
					instance.avatarBuilderProxy(),
					url,
					triggerAudio,
					offset,
					finishedLoadingCallback,
					finishedPlayingCallback,
					failedFn,
					progressedFn);
			}
			else
				throw new Error("wrapper not loaded");
		}
		public function avatarInstanceNames():Vector.<String>
		{
			if (state_ >= STARTED)
				return builder_.avatarInstanceNames();
			else
				throw new Error("wrapper not started");
		}
		public function avatarParameterNames():Vector.<String>
		{
			if (state_ >= LOADED)
			{
				var result:Vector.<String> = new Vector.<String>();
				var params:Array = sSet_.children([IAvatarParameterProxy]);
				for each (var param:IAvatarParameterProxy in params)
					result.push(param.name());
				return result;
			}
			else
				throw new Error("wrapper not loaded");
		}
		public function setAvatarParameterAvatarId(parameterName:String, avatarId:uint):void
		{
			if (state_ >= LOADED)
			{
				var found:IAvatarParameter = null;
				var params:Array = sSet_.children([IAvatarParameter]);
				for each (var param:IAvatarParameter in params)
				{
					if (param.name() == parameterName)
					{
						found = param;
						break;
					}
				}
				if (found == null)
					throw new Error("avatar parameter with name \"" + parameterName + "\" not found");
				
				found.setAvatarId(avatarId);
			}
			else
				throw new Error("wrapper not loaded");
		}
		// continuationFn:Function<void(IAnimationProxy)>
		public function loadAnimation(instanceName:String, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		{
			if (state_ >= LOADED)
			{
				var instance:IAvatarInstance = builder_.tryFindAvatarInstance(instanceName);
				if (instance == null)
				{
					failedFn_("instance not found");
					return;
				}
				
				instance.avatarBuilderProxy().loadAnimation
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
		public function commands():Vector.<ICommandProxy>
		{
			if (state_ >= LOADED)
			{
				var cmds:Array = sSet_.children([ICommandProxy]);
				var result:Vector.<ICommandProxy> = new Vector.<ICommandProxy>();
				for each (var cmd:ICommandProxy in cmds)
					result.push(cmd);
				return result;
			}
			else
				throw new Error("wrapper not loaded");
		}
		public function executeCommand(commandName:String, arg:Array=null):Object
		{
			if (state_ >= LOADED)
			{
				var cmds:Array = sSet_.children([ICommandProxy]);
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
		public function avatarInstanceCategories(instanceName:String):Vector.<ICategoryProxy>
		{
			if (state_ >= LOADED)
			{
				var instance:IAvatarInstance = builder_.tryFindAvatarInstance(instanceName);
				if (instance == null)
					throw new Error("instance name not found"); 

				var cats:Array = instance.avatarBuilderProxy().accessorySet().children([ICategoryProxy]);
				var result:Vector.<ICategoryProxy> = new Vector.<ICategoryProxy>(cats.length, true);
				for (var i:uint=0; i<cats.length; ++i)
					result[i] = cats[i];
				return result;
			}
			else
				throw new Error("wrapper not loaded");
		}
		public function outputConfiguration(instanceName:String):XML
		{
			if (state_ >= LOADED)
			{
				var instance:IAvatarInstance = builder_.tryFindAvatarInstance(instanceName);
				if (instance == null)
					throw new Error("instance name not found"); 
					
				return instance.avatarBuilderProxy().outputConfiguration();
			}
			else
				throw new Error("wrapper not loaded");
		}
		public function setDropFrames(b:Boolean):void 
		{
			dropFrames_ = b;
			engine_.setIsFocused(!b);
		}
	}
}
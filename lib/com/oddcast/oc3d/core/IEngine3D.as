package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.data.AnimationData;
	
	import flash.display.Sprite;
	import flash.media.Sound;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	public interface IEngine3D
	{
		//function api():IOc3dAPI;
		
		function domain():ApplicationDomain;
		
		function loadPlugIn(plugInUrl:String, objectName:String, version:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function statReportString(column:uint):String;
		
		function setPhysicsEnabled(b:Boolean):void; 
		function setAnimationEnabled(b:Boolean):void; 

		function newAnimationStateMachine(initialState:String):IAnimationStateMachine;
		function newNDAnimationStateMachine(initialState:String):IAnimationStateMachine;
		function animationStateMachines():Dictionary; 
		function clearAllAnimationStateMachines():void;
		
		function flush():void;
		
		function tryExtractAnimationFromSound(name:String, sound:Sound, deformer:IMorphDeformer):AnimationData;
		// nodeFn:Function<node:IDisplayObject3D>
		function forEachNode(node:IDisplayObject3D, nodeFn:Function):void

		function storage():IStorageProvider;
		function resourceManager():IResourceManager;
		function triggerManager():ITriggerManager;
		function newScene(name:String):IScene3D
		function newViewport(name:String, sprite:Sprite, camera:ICameraObject3D=null, directRendering:Boolean=false):IViewport3D;
		
		function setActiveView(view:IViewport3D):void;
		function activeView():IViewport3D;

		function viewports():Dictionary;
		
		function setIsPaused(b:Boolean):void;
		function isPaused():Boolean;

		function render(dt:Number):void; // change in milliseconds
		function isFocused():Boolean;
		function setIsFocused(v:Boolean):void;
		function setConstantFocusingEnabled(v:Boolean):void;
		function constantFocusingEnabled():Boolean;
		
		function setRenderingPaused(b:Boolean):void;

		function requireRenderFromActiveView():void;
		function requireRenderFromAllViews():void;
		
		function dispose():void;
		
		function renderEngine():IRenderEngine;
	}
}
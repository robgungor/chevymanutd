package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.external.IPropertyBag;
	import com.oddcast.oc3d.shared.*;
	
	import flash.media.Sound;
	import flash.utils.Dictionary;
	
	public interface IScene3D
	{
		function registerExternalUpdater(name:String, propertyFn:Function):void;
		function unregisterExternalUpdater(name:String):void;

		function propertyBags():Dictionary;
		function externalPropertyBags():Dictionary;
		function plugIns():Dictionary;
		function tryFindPropertyBag(plugInName:String):PropertyBag;
		function tryFindExternalPropertyBag(plugInName:String):IPropertyBag;
		
		function addPlugIn(name:String, obj:Object):void;
		function removePlugIn(name:String):void;
		function tryFindPlugIn(name:String):Object;

		function nodeAddedSignal():Signal;
		function nodeRemovedSignal():Signal;

		function setPhysicsEnabled(b:Boolean):void;
		function physicsEnabled():Boolean;
		function setAnimationEnabled(b:Boolean):void;
		function animationEnabled():Boolean;

		function alphaCullingEnabled():Boolean
		function setAlphaCullingEnabled(v:Boolean):void;
		function lightingEnabled():Boolean;
		function setLightingEnabled(v:Boolean):void;
		function setJointsShown(v:Boolean):void;
		function jointsShown():Boolean;
		function setLoadingWireframeColor(color:Color):void;
	
		function engine():IEngine3D;
		function root():IDisplayObject3D;
		function materialManager():IMaterialManager;
		
		function newTimetrack():IAnimationTimetrack;
		function newCameraObject3D(parent:IDisplayObject3D, name:String):ICameraObject3D;
		function newInstance(parent:IDisplayObject3D, name:String):IInstance3D;
		// continuationFn<SoundObject3D>
		function newSoundObject3D(parent:IDisplayObject3D, name:String, sound:Sound):ISoundObject3D;
		//function newCube(parent:IDisplayObject3D, name:String, radius:Number):IDisplayObject3D;
		function newGroup(parent:IDisplayObject3D, name:String):IDisplayObject3D;

		function timetrack():IAnimationTimetrack;
		function renderEngine():IRenderEngine;
		function physicsEngine():IPhysicsEngine;
		
		function cameras():Dictionary;
		function light():IPointLight3D;
		
		function render(dt:Number):void;
		
		function dispose():void;
	}
}
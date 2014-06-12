package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public interface IViewport3D
	{
		function engine():IEngine3D;
		
		function backSprite():Sprite;
		function frontSprite():Sprite;
		
		function setContainerBounds(x:Number, y:Number, width:Number, height:Number):void;

		function setRasterPosition(x:Number, y:Number):void; // decprecated
		function flipHorizontal():void;
		function flipVertical():void;

		function cameraChangingSignal():Signal; // Signal<newCam:Camera>
		function cameraChangedSignal():Signal; // Signal<>
		function renderedSignal():Signal; // Signal<>
		
		function makeActive():void;
		function isActive():Boolean;
		
		function setBackgroundColor(color:Color):void;
		function setSprite(s:Sprite):void;
		function sprite():Sprite;
		
		function setCamera(cam:ICameraObject3D):void
		
		function tryGetCamera():ICameraObject3D;
		function tryPickGeometry(screenPos:Point):IGeometryObject3D;
		function tryProjectRay(camera:ICameraObject3D, screenPos:Point, targetGlobalPlane:Plane3D):Vector3D;
		
		function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:uint=0, useWeakReference:Boolean=false):void;
		function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void;

		function dispose():void;
		function requireRender():void;
		
		function name():String;
		
		function width():Number;
		function height():Number;
		
		function refreshRate():uint;
		function setRefreshRate(updatsPerTick:uint):void;
		
		function unfocusedRefreshRate():uint;
		function setUnfocusedRefreshRate(updatsPerTick:uint):void;
	}
}
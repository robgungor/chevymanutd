package com.oddcast.oc3d.external
{
	import com.oddcast.oc3d.core.ICameraObject3D;
	import com.oddcast.oc3d.core.IDisplayObject3D;
	import com.oddcast.oc3d.core.IViewport3D;
	
	import flash.display.Sprite;

	public interface IAugmentedRealityPlugIn extends IPropertyBagExchanger
	{
		function stop():void;
		
		function setThreshold(n:int):void;
		function setAdaptiveThresholdingEnabled(b:Boolean):void;

		function setGlobalScaler(s:Number):void;
		function globalScaler():Number;

		// 2d interface
		function start2d(configXMLUrl:String, sprite:Sprite, continuationFn:Function=null, failedfn:Function=null):void;
		function setMarkerAddedCallback(fn:Function):void; // fn:Function<patternId:int>
		function setMarkerUpdatedCallback(fn:Function):void; // fn:Function<patternId:int, x:Number, y:Number, rotation:Number, scaler:Number>
		function setMarkerRemovedCallback(fn:Function):void; // fn:Function<patternId:int>

		// 3d interface
		function start(configXMLUrl:String, camera:ICameraObject3D, view:IViewport3D, continuationFn:Function=null, failedFn:Function=null):void;
		function attachObject(id:uint, node:IDisplayObject3D, isVisibleFn:Function=null):void;
		function detachObject(id:uint):void;
		
	}
}
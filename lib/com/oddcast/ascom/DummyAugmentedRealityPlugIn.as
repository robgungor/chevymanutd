package com.oddcast.ascom
{
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.external.IAugmentedRealityPlugIn;
	
	import flash.display.Sprite;

	public class DummyAugmentedRealityPlugIn extends DummyPropertyBagExchanger implements IAugmentedRealityPlugIn
	{
		public static function init():void {}
		public function start2d(configXMLUrl:String, sprite:Sprite, continuationFn:Function=null, failedfn:Function=null):void{}
		public function start(configXMLUrl:String, camera:ICameraObject3D, view:IViewport3D, continuationFn:Function=null, failedFn:Function=null):void{}
		public function stop():void{}
		
		public function setThreshold(n:int):void {}
		public function setAdaptiveThresholdingEnabled(b:Boolean):void {}
		
		public function setMarkerAddedCallback(fn:Function):void {} // fn:Function<patternId:int>
		public function setMarkerUpdatedCallback(fn:Function):void {} // fn:Function<patternId:int, x:Number, y:Number, rotation:Number, scaler:Number>
		public function setMarkerRemovedCallback(fn:Function):void {} // fn:Function<patternId:int>
		
		public function attachObject(id:uint, node:IDisplayObject3D, isVisibleFn:Function=null):void {}
		public function detachObject(id:uint):void {}
		
		public function setGlobalScaler(s:Number):void {}
		public function globalScaler():Number{ return 0; }
	}
}
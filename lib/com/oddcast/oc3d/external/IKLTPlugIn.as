package com.oddcast.oc3d.external
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public interface IKLTPlugIn
	{
		function compute(data:BitmapData):void;

		function trackRegion(rect:Rectangle, featureCount:uint=20, minimumDistance:uint=8, debugColor:uint=0x00ff99):uint; // returns markerId
		function disposeRegion(markerId:uint):void;

		function setMarkerAddedCallback(fn:Function):void; // fn:Function<markerId:int>
		function setMarkerUpdatedCallback(fn:Function):void; // fn:Function<markerId:int, x:Number, y:Number, orientationIndegrees:Number, scaler:Number>
		function setMarkerRemovedCallback(fn:Function):void; // fn:Function<markerId:int>
		
		function setWindowSize(width:uint=8, height:uint=8):void;
		function windowSize():Point;
		function setIterationCount(n:uint=10):void;
		function iterationCount():uint;
		
		function setIsRansacEnabled(b:Boolean):void;
		function isRansacEnabled():Boolean;
		function setRansacParameters(threshold:Number=10, iterations:uint=10, minRequiredSamples:uint=5, numOfConsentsTillGoodEnuff:uint=10):void;
		function ransacParameters():Array;

		// debug method to render out the features
		function setOverlay(overlay:Sprite):void;
		
		function dispose():void;
	}
}
package com.oddcast.graphics{
	
	import flash.geom.Point;
	import flash.display.Sprite;
	
	public interface ICurveDrawer {
		function setSprite(s:Sprite):void;
		function setOutlineSprite(s:Sprite):void;
		function setPoints(arr:Array):void;
		function getPointsArr():Array;
		function setBottomLineFlat(b:Boolean):void;
		function addPoint(p:Point):void;
		function drawCurvedShape(closeShape:Boolean = false, curveDetails:int = 100, sizeMultiplier:Number = .5, angleMultiplier:Number = .75):void
	}
}
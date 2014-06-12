package com.oddcast.ui.animation {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public interface IScrollEasing {
		function setStartPos(n:Number):void;
		function setTargetPos(n:Number):void;
		function getTargetPos():Number;
		function getNextPos(percentMoved:Number):Number;
		function getComplete():Boolean;
	}
	
}
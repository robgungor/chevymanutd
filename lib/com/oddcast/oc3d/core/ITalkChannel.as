package com.oddcast.oc3d.core
{
	public interface ITalkChannel
	{
		function volume():Number;
		function setVolume(v:Number):void;
		function pause():void;
		function resume():void;
		function stop():void;
	}
}
package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;

	public interface IAudioProxy extends INodeProxy
	{
		function uri():String;

		// continuationFn:Function<data:Sound>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<>
		function play(startTime:Number=0, loops:int=0, continuationFn:Function=null, failedFn:Function=null, progressedFn:Function=null):void;
		function stop():void;
		function pause():Number;

		function setVolume(volume:Number):void;
		function volume():Number; 
	}
}
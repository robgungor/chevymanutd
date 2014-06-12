package com.oddcast.oc3d.content
{
	public interface ISwfProxy
	{
		function width():int;
		function height():int;
		function byteCount():uint;
		function uri():String;
		
		function colorTransform():Array; // Array<Number>
		
		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<data:BitmapData>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
	}
}
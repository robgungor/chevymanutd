package com.oddcast.oc3d.content
{
	import flash.display.BitmapData;
	
	public interface IThumbnail extends INode
	{
		function uri():String;
		function setUri(uri:String):void;
		
		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<data:BitmapData>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
	}
}
package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;

	public interface IDecalProxy extends INodeProxy
	{
		function uri():String;
		
		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<data:BitmapData>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
	}
}
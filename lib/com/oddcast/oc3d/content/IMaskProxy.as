package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;

	public interface IMaskProxy extends INodeProxy
	{
		function texture():ITextureProxy;
		function uri():String;
		
		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continatuionFn:Function<data:BitmapData>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
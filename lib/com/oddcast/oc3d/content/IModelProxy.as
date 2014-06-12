package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;

	public interface IModelProxy extends INodeProxy
	{
		// continuationFn:Function<void()>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<void()>
		function select(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
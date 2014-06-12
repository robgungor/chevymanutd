package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;

	public interface ICategoryProxy extends INodeProxy
	{
		function preloads():Boolean;
		function hasPreloaded():Boolean;
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
package com.oddcast.oc3d.content
{
	public interface IMaterialConfiguration extends IMaterialConfigurationProxy, INode
	{
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<>
		function select(continuationFn:Function=null, failedFn:Function=null, progressedFn:Function=null):void
	}
}
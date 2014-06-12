package com.oddcast.oc3d.content
{
	public interface IPackageable
	{
		// continuationFn:Function<>
		function pack(continuation:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
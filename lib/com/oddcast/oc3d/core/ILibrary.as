package com.oddcast.oc3d.core
{
	import flash.utils.Dictionary;
	
	public interface ILibrary extends IInstanceBuilder
	{
		function sounds():Dictionary;

		// continuationFn:Function<Sound>
		function newSound(name:String, url:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
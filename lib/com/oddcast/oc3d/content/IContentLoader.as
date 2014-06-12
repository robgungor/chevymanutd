package com.oddcast.oc3d.content
{
	public interface IContentLoader
	{
		function loadCategory(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function loadAccessory(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function loadAnimationBin(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function loadAccessoryBin(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function loadAnimation(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function loadAction(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
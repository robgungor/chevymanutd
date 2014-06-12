package com.oddcast.oc3d.content
{
	public interface IPhonemePlayer
	{
		function preload(url:String, continuationFn:Function, progressedFn:Function=null, failedFn:Function=null):void;
		function play(url:String, triggerSound:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function stop():void;
	}
}
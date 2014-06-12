package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.IAnimationTimetrack;
	import com.oddcast.oc3d.core.INodeProxy;
	
	public interface IAnimationProxy extends INodeProxy
	{
		function timetrack():IAnimationTimetrack;
		function uri():String;
		function isLooping():Boolean;
		function setIsLooping(v:Boolean):void;

		// continuationFn:Function<data:SceneData>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<>
		function play(completedFn:Function=null, failedFn:Function=null, progressedFn:Function=null):Boolean;
		// continuationFn:Function<>
		function gotoAndPlay(frameNum:Number, completedFn:Function=null, failedFn:Function=null, progressedFn:Function=null):Boolean;
		function stop():void;
	}
}
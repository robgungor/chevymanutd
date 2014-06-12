package com.oddcast.oc3d.core
{
	import flash.utils.Dictionary;
	
	public interface IInstanceBuilder
	{
		function dispose():void;

		function geometry():Dictionary;
		function lights():Dictionary;
		function animationClips():Dictionary;
		function slots():Dictionary;
		
		//function appendAnimation(daeXml:XML, animationName:String, tag:int=-1):void;

		//function newAnimationClip(name:String, tag:int=-1):IAnimationClip;

		//function appendMesh(daeXml:XML, tag:int=-1, failedFn:Function=null, progressedFn:Function=null):void;
		function clear():void;
	}
}
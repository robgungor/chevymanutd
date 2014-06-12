package com.oddcast.oc3d.core
{
	import flash.media.SoundTransform;
	
	public interface ISoundObject3D
	{
		function play(startTime:Number=0, loops:int=0, sndTransform:SoundTransform=null):void;
		function stop(startTime:Number=0, loops:int=0, sndTransform:SoundTransform=null):void;
	}
}
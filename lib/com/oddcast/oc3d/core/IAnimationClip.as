package com.oddcast.oc3d.core
{
	import flash.utils.Dictionary;
	
	public interface IAnimationClip
	{
		function id():uint;
		function name():String;
		
		function channels():Dictionary;
	}
}
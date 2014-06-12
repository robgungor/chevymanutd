package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.media.Sound;
	
	public interface IAudio extends IAudioProxy, INode
	{
		function setUri(uri:String):void;
	}
}
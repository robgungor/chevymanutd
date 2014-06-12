package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.shared.BlendingMode;
	
	import flash.display.BitmapData;
	
	public interface IDecal extends IDecalProxy, INode
	{
		function setUri(uri:String):void;
	}
}
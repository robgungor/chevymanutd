package com.oddcast.oc3d.content
{
	import flash.display.BitmapData;
	
	public interface IMask extends IMaskProxy, INode
	{
		function setTexture(texture:ITextureProxy):void;
	}
}
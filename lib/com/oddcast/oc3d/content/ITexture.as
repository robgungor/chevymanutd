package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.shared.BlendingMode;
	
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	
	public interface ITexture extends ITextureProxy, INode
	{
		function setColorTransform(transform:Array):void; // Array<Number>
		function setUri(uri:String):void;
	}
}
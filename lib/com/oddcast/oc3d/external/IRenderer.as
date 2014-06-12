package com.oddcast.oc3d.external
{
	import flash.display.Sprite;
	
	public interface IRenderer
	{
		function zoom():Number;
		function currentSprite():Sprite;
		
		// screenDepthAndRenderCallbackObj:Object<screenDepth:Number, fn:Function>
		function addToRenderList(screenDepthAndRenderCallbackObj:Object):void
	}
}
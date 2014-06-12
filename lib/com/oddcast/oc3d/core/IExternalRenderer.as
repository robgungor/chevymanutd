package com.oddcast.oc3d.core
{
	import flash.display.Sprite;
	
	public interface IExternalRenderer
	{
		// requireRender:Function<>
		function initialize(requireRender:Function):void;
		
		// addToRenderList:Function<screenDepthAndRenderFn:Object<screenDepth:Number, fn:Function>>
		function rendering(sprite:Sprite, addToRenderList:Function):void;
	}
}
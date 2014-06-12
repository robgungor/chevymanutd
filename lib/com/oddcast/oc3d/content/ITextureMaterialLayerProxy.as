package com.oddcast.oc3d.content
{
	public interface ITextureMaterialLayerProxy extends IMaterialLayerProxy
	{
		function tryFindTexture():ITextureProxy
		function uri():String;
		
		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<data:BitmapData>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
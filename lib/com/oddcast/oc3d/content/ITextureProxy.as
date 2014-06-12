package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;
	import com.oddcast.oc3d.shared.Color;
	
	import flash.filters.ColorMatrixFilter;

	public interface ITextureProxy extends INodeProxy
	{
		function width():int;
		function height():int;
		function hasAlpha():Boolean;
		function byteCount():uint;
		function uri():String;
		
		function colorTransform():Array; // Array<Number>
		
		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<data:BitmapData>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
	}
}
package com.oddcast.oc3d.content
{
	public interface IPreset extends INode
	{
		function hasPreloaded():Boolean;
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function hasConfiguration():Boolean;
		function clearConfiguration(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function saveConfiguration(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function isSelected():Boolean;
		function select(continuationFn:Function=null, failedFn:Function=null, progressedFn:Function=null):void
	}
}
package com.oddcast.oc3d.content
{
	public interface IModel extends INode, IModelProxy
	{
		function setSelectedPreset(preset:IPreset, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function tryGetSelectedPreset():IPreset;
	}
}
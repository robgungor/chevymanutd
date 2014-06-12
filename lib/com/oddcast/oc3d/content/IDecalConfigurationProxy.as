package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;
	import com.oddcast.oc3d.shared.BlendingMode;

	public interface IDecalConfigurationProxy extends INodeProxy
	{
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function defaultVisible():Boolean;
		function visible():Boolean;
		
		function blendingMode():BlendingMode;
	}
}
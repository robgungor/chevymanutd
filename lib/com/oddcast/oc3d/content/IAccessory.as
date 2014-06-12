package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.utils.Dictionary;
	
	public interface IAccessory extends ISelectableNode, IAccessoryProxy
	{
		function setZBias(v:Number):void;

		function setMaskMode(v:MaskMode):void;
		function maskMode():MaskMode;

		function decalAndMaskMaterial():IMaterialObject3D;
		
		function setDefaultMaterialConfiguration(v:IMaterialConfigurationProxy, continuationFn:Function=null, failedFn:Function=null, progressedFn:Function=null):void;
		function setSelectedMaterialConfiguration(v:IMaterialConfigurationProxy, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function setUri(uri:String):void;
		// continuationFn:Function<data:SceneData>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function refresh():void;
	}
}
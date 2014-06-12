package com.oddcast.oc3d.content
{
	
	
	public interface IItem extends INode
	{
		function setUri(uri:String):void;
		function uri():String;
		
		function slotNames():Array;

		function materialConfigurations():Array;

		function setDefaultMaterialConfiguration(v:IMaterialConfiguration, continuationFn:Function=null, failedFn:Function=null, progressedFn:Function=null):void;
		function defaultMaterialConfiguration():IMaterialConfiguration;
		
		function setSelectedMaterialConfiguration(v:IMaterialConfiguration, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function selectedMaterialConfiguration():IMaterialConfiguration;

		// continuationFn:Function<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<dae:XML>
		function data(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function newItemInstance(area:IArea, instanceName:String):IItemInstance;
		//function loadItemInstance(area:IArea, instanceName:String, position:Vector3D, orientationDegrees:Vector3D):IItemInstance; 
	}
}
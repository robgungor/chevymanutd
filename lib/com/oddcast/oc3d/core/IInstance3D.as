package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.data.*;
	import com.oddcast.oc3d.shared.Signal;
	
	import flash.media.Sound;
	import flash.utils.Dictionary;
	
	public interface IInstance3D extends IDisplayObject3D
	{
		function geometryInstantiatedSignal():Signal;
		
		function converter():ILODConverter
		
		function forEachVisemeMappingName(fn:Function):void; // fn:Function<String>
		function enterVisemeMappings(morphDeformerName:String, mappings:Dictionary):void;
		function tryFindVisemeMappings(morphDeformerName:String):Dictionary;
		
		function talkAndScaleViseme(sound:Sound, morphDeformerName:String, triggerSound:Boolean, offset:Number, scaler:Number, continuationFn:Function, failedFn:Function=null):ITalkChannel;
		// continuationFn:Function<>
		function talk(sound:Sound, morphDeformerName:String, triggerSound:Boolean, offset:Number, continuationFn:Function, failedFn:Function=null):ITalkChannel;
		
		function applyPlugIn(plugInName:String, plugInType:String, arguments:Array):void;
		function unapplyPlugIn(plugInName:String, plugInType:String):void;
		function appliedPlugIns():Dictionary; // Dictionary<plugInName:String, path:String>

		function deformationManager():IDeformationManager;
		
		function instantiate(sceneData:SceneData, tag:int):void;
		function disposeNodesWithTag(tag:int):void;
		
		function assignMaterialToSlot(slotName:String, material:IMaterialObject3D, tag:int):void;
	}
}
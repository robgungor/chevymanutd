package com.oddcast.oc3d.content
{
	import flash.display.Stage;
	
	
	public interface IMapBuilder extends IContentBuilder
	{
		function areaSelectionManager():ISelectionManager;
		
		function loadItemSet(itemSetId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function itemSet():IItemSet;

		// continuationFn:Function<IMap>
		function newMap(name:String, stage:Stage, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IItem>
		function newItem(parent:IFolder, name:String, uri:String, defaultMaterialConfiguration:IMaterialConfiguration, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IItem>
		function loadItem(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<IArea>
		function newArea(parent:INode, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IArea>
		function loadArea(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function updateArea(area:IArea, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function removeArea(area:IArea, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
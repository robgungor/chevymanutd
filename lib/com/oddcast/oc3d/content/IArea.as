package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.IViewport3D;
	import com.oddcast.oc3d.shared.Signal;
	
	import flash.geom.Point;
	
	public interface IArea extends INode, ISelect
	{
		function uninstantiateAllItems():void;
		function clear():void;

		function itemInstanceAddedSignal():Signal; // Signal<IItemInstance>
		function itemInstanceRemovingSignal():Signal; // Signal<IItemInstance>
		
		function addItemInstance(iinstance:IItemInstance):void;

		function forEachItemInstance(instanceFn:Function):void; // instanceFn:Function<IItemInstance>:void

		function tryFindItemInstance(instanceId:int):IItemInstance;
		function tryFindItemInstanceByName(name:String):IItemInstance;

		function tryPickItemInstance(view:IViewport3D, screenPos:Point):IItemInstance;

		function outputConfiguration():XML;
		function inputConfiguration(xml:XML, continuationFn:Function=null, failedFn:Function=null, progressedFn:Function=null):void;

		function configuration():XML;

		function itemSelectionManager():IMultiSelectionManager;
	}
}
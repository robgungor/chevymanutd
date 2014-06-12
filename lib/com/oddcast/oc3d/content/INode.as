package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;
	import com.oddcast.oc3d.shared.Signal;
	
	public interface INode extends INodeProxy
	{
		function collectPackageIds(results:Vector.<int>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function changedSignal():Signal; // Signal<INode>
		
		function builder():IContentBuilder;

		function setName(n:String):void;

		function needsSaving():Boolean;
		
		function markNeedsSaving():void;
		
		// continuationFn:Function<>
		function save(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function dispose(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
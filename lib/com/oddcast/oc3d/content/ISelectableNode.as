package com.oddcast.oc3d.content
{
	public interface ISelectableNode extends ISelectableNodeProxy, INode
	{
		function select(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void; 
	}
}
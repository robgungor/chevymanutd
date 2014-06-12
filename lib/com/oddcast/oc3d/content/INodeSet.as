package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;

	public interface INodeSet extends INodeSetProxy, INode
	{
		function startup(bootScript:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
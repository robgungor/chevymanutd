package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.shared.MethodInfo;

	public interface IProtocol extends IIdentifiable
	{
		function name():String;
		function methods():Vector.<MethodInfo>;

		function isBound(node:com.oddcast.oc3d.content.INode, act:IAction):Boolean;
		function bind(node:INode, act:IAction, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function unbind(node:INode, act:IAction, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void; 		
	}
}
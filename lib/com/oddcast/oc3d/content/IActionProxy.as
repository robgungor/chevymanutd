package com.oddcast.oc3d.content
{
	public interface IActionProxy extends INode
	{
		function code():String;
		function protocols():Vector.<IProtocol>
		function conformsToProtocol(protocol:IProtocol):Boolean;
	}
}
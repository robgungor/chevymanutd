package com.oddcast.oc3d.content
{
	public interface ISelector extends ISelectorProxy, ISelectableNode
	{
		function setDefaultNode(node:*):void;
		function setSelectedNode(node:ISelectableNode):void;
	}
}
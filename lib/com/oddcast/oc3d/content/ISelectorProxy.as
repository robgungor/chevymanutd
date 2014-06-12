package com.oddcast.oc3d.content
{
	public interface ISelectorProxy extends ISelectableNodeProxy
	{
		function defaultNode():ISelectableNode;
		function selectedNode():ISelectableNode
	}
}
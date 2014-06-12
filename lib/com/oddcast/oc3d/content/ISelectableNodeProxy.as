package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;

	public interface ISelectableNodeProxy extends INodeProxy
	{
		function isSelected():Boolean;
	}
}
package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.shared.Signal;
	
	public interface IMultiSelectionManager extends ISelectionManager
	{
		function forEachSelected(elementFn:Function):void;
		function selectionCount():uint;
	}
}
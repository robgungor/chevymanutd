package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.shared.Signal;
	
	public interface ISelectionManager
	{
		function selectedSignal():Signal;
		function deselectingSignal():Signal;
		function tryFindSelected():ISelect;
		function isSelected(selection:ISelect):Boolean;
		function clear():void;
	}
}
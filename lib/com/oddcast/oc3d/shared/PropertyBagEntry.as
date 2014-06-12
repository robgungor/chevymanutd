package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.shared.Signal;
	
	public class PropertyBagEntry
	{
		public var value:Object = null;
		public var changedSignal:Signal = new Signal(1);
	}
}
package com.oddcast.oc3d.external
{
	public interface IPropertyBag
	{	
		function tryGetProperty(name:String):*; // returns null of the property is not found
	
		// changedFn:Function<Object>
		function registerPropertyWatcher(name:String, changedFn:Function):void;
		// changedFn:Function<Object>
		function unregisterPropertyWatcher(name:String, changedFn:Function):void;
	}
}
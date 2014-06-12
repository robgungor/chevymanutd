package com.oddcast.oc3d.core
{
	public interface IExternalTransformWatcher
	{
		// transform:Array<Number>
		function transforming(nodeName:String, transform:Array, zoom:Number):void;
	}
}
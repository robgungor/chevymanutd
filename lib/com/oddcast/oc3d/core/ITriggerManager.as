package com.oddcast.oc3d.core
{
	public interface ITriggerManager
	{
		function update(triggerName:String, value:Number):void;
		function setCallback(triggerName:String, fn:Function):void; // fn:Function<void(Number)>
		function clearCallback(triggerName:String):void;
	}
}
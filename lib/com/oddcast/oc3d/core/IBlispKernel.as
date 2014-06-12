package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.shared.*;
	
	public interface IBlispKernel
	{
		function messagedSignal():Signal; // Signal<message:String>:void
		function failedSignal():Signal; // Signal<error:String>:void
		function progressedSignal():Signal; // Signal<loaded:Number, total:Number>

		function pushEnv():void;
		function popEnv():void;
		function evaluate(command:String):IBlispNode;

		function defineBoxedObject(name:String, object:Object):void;
		function isSyntaxOk(cmd:String):Boolean;
		function hasStub(code:String, stubName:String):Boolean;
	}
}
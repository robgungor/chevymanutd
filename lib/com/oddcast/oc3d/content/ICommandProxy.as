package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.shared.CommandArgType;
	
	public interface ICommandProxy extends INode
	{
		function description():String;
		function arguments():Array; // Array<CommandArgEntry>
		function returnType():CommandArgType;
		
		function code():String;

		function get invoke():Function;
		
		//function isBound():Boolean;
		function bind(fn:Function):void;
		
		function invokeWithArray(values:Array=null):Object;
		function manualInvokeWithArray(codeStr:String, arguements:Array=null):Object;
	}
}
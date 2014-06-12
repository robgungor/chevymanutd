package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.shared.CommandArgEntry;
	import com.oddcast.oc3d.shared.CommandArgType;
	
	public interface ICommand extends ICommandProxy
	{
		function setCode(code:String):void;

		function setDescription(v:String):void;		
		function setArguments(v:Array):void;
		function setReturnType(type:CommandArgType):void;
	}
}
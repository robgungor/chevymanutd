package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;

	public interface IMap
	{
		function name():String;
		function id():uint;
		function itemSetId():uint;
		function dispose():void;
	}
}
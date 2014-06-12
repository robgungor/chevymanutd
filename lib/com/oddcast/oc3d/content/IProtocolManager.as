package com.oddcast.oc3d.content
{
	public interface IProtocolManager
	{
		function queryProtocolsForObject(obj:Object):Vector.<IProtocol>;
		function forEachProtocol(fn:Function):void // fn:Function<IProtocol>
	}
}
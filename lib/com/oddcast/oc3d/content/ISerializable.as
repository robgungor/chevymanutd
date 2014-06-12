package com.oddcast.oc3d.content
{
	import flash.utils.ByteArray;

	public interface ISerializable
	{
		function serialize(ba:ByteArray, version:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function deserialize(ba:ByteArray, version:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
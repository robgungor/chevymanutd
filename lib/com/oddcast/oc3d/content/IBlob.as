package com.oddcast.oc3d.content
{
	import flash.utils.ByteArray;

	public interface IBlob extends IBlobProxy
	{
		function setData(data:ByteArray):void;
	}
}
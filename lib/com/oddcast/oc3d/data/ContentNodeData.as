package com.oddcast.oc3d.data
{
	import flash.utils.ByteArray;

	public class ContentNodeData
	{
		public var Type:String;
		public var Id:int;
		public var Name:String;
		public var Properties:Vector.<Vector.<String>>; // [["name0", "value0"], ["name1", "value1"] ...]
	}
}
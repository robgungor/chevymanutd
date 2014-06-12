package com.oddcast.oc3d.shared
{
	public class LinkedListNode
	{
		public function LinkedListNode(object:Object=null):void
		{
			this.object = object;
		}
		public var next:LinkedListNode = null;
		public var prev:LinkedListNode = null;
		internal var owner:LinkedList = null;
		public var object:Object = null;
	}
}
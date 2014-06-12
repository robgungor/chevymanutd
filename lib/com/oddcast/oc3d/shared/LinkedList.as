package com.oddcast.oc3d.shared
{
	public class LinkedList
	{
		public function get debug__Length():uint { return length(); }
		public function get debug__Front():LinkedListNode { return front_; }
		
		private var front_:LinkedListNode;
		private var back_:LinkedListNode;
		private var length_:uint;
		
		public function LinkedList()
		{
			front_ = null;
			back_ = null;
			length_ = 0;
		}
		
		public function front():LinkedListNode{ return front_; }
		public function back():LinkedListNode{ return back_;}
		public function length():uint { return length_; }
		
		public function pushBack(node:LinkedListNode):void
		{
			if (node.owner != null)
				throw new Error("node already belongs to a list");
				
			if (front_ == null)
				front_ = back_ = node;
			else
			{ 
				node.prev = back_;
				back_.next = node;
				back_ = node;
			}
			node.owner = this;
			++length_;
		}
		public function insertAfter(node:LinkedListNode, newNode:LinkedListNode):void
		{
			if (node.owner == null)
				throw new Error("node is not in a list");
			if (node.owner != this)
				throw new Error("node is not in this list");
			else if (newNode.owner != null)
				throw new Error("node is already part of a list");
			
			newNode.next = node.next;
			if (newNode.next != null)
				newNode.next.prev = newNode;
			newNode.prev = node;
			if (newNode.prev != null)
				newNode.prev.next = newNode;
			node.next = newNode;
			if (node == back_)
				back_ = newNode;
			newNode.owner = this;
			++length_;
		}
		public function insertBefore(node:LinkedListNode, newNode:LinkedListNode):void
		{
			if (node.owner == null)
				throw new Error("node is not in a list");
			if (node.owner != this)
				throw new Error("node is not in this list");
			else if (newNode.owner != null)
				throw new Error("node is already part of a list");

			newNode.prev = node.prev;
			if (newNode.prev != null)
				newNode.prev.next = newNode;
			newNode.next = node;
			if (newNode.next != null)
				newNode.next.prev = newNode;
			node.prev = newNode;
			if (node == front_)
				front_ = newNode;
			newNode.owner = this;
			++length_;
		}
		public function pushFront(node:LinkedListNode):void
		{
			if (node.owner != null)
				throw new Error("node already belongs to a list");

			if (front_ == null)
				front_ = back_ = node;
			else
			{
				node.next = front_;
				front_.prev = node;
				front_ = node;
			}
			node.owner = this;
			++length_;
		}
		public function remove(node:LinkedListNode):void
		{
			if (node.owner == null)
				return;

			if (node.next != null)
				node.next.prev = node.prev;
			if (node.prev != null)
				node.prev.next = node.next;
			if (node == back_)
				back_ = node.prev;
			if (node == front_)
				front_ = node.next;
			node.prev = null;
			node.next = null;
			node.owner = null;
			--length_;
		}
		public function forEachNode(nodeFn:Function):void
		{
			var curr:LinkedListNode = front_;
			while(curr != null)
			{
				nodeFn(curr);
				curr = curr.next;
			}
		}
		
		public function forEachNodeReverse(nodeFn:Function):void
		{
			var curr:LinkedListNode = back_;
			while (curr != null)
			{
				nodeFn(curr);
				curr = curr.prev;
			}
		}
		
		public function clear():void
		{
			forEachNode(function(n:LinkedListNode):void
			{
				n.owner = null;
				n.next = null;
				n.prev = null;
			});
			front_ = null;
			back_ = null;
			length_ = 0;
		}
	}
}
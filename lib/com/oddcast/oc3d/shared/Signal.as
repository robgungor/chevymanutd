package com.oddcast.oc3d.shared
{
	public class Signal extends Identifiable
	{
		private var count_:uint = 0;
		private var arity_:uint = 0;
		private var head_:SignalNode = null;
		private var current_:SignalNode = null;
		public var invoke:Function;
		private var enabled_:Boolean;
		
		public function dispose():void
		{
			head_ = null;
			current_ = null;
			invoke = null;
		}
		public function enabled():Boolean
		{
			return enabled_;
		}
		
		public function setEnabled(v:Boolean):void
		{
			enabled_ = v;
		}
		
		public function count():uint
		{
			return count_;
		}
		
		public function Signal(arity:uint):void
		{
			super();
			
			enabled_ = true;
			
			if (arity == 0)
				invoke = invoke0;
			else if (arity == 1)
				invoke = invoke1;
			else if (arity == 2)
				invoke = invoke2;
			else if (arity == 3)
				invoke = invoke3;
			else if (arity == 4)
				invoke = invoke4;
			else
				throw new Error("class Signal currently supports only 4 arguments.");
		}
		
		public function add(lambda:Function):void
		{
			if (lambda == null)
				return;
				
			var node:SignalNode = new SignalNode(lambda);
			if (head_ == null)
			{
				head_ = node;
				current_ = node;
			}
			else
			{
				current_.next = node;
				current_ = node;
			}
			++count_;
		}
		
		public function contains(lambda:Function):Boolean
		{
			if (lambda == null)
				return false;
				
			var curr:SignalNode = head_;
			while (curr != null)
			{
				if (curr.lambda == lambda)
					return true;
				curr = curr.next;
			}
			return false;
		}
		
		public function remove(lambda:Function):void
		{
			if (lambda == null)
				return;
				
			var curr:SignalNode = head_;
			while (curr != null)
			{
				if (curr==head_ && curr.lambda==lambda)
				{
					head_ = curr.next;
					--count_;
					break;						
				}
				else if (curr.next && lambda == curr.next.lambda)
				{
					curr.next = curr.next.next;
					--count_;
					break;
				}
				
				curr = curr.next;
			}
		}
		
		public function clear():void
		{
			head_ = null;
			current_ = null;
			count_ = 0;
		}
		
		private function invoke0():void
		{
			if (!enabled_)
				return;
				
			var curr:SignalNode = head_;
			while (curr != null)
			{
				curr.lambda();
				curr = curr.next;
			}
		}
		private function invoke1(arg1:*):void
		{
			if (!enabled_)
				return;
				
			var curr:SignalNode = head_;
			while (curr != null)
			{
				curr.lambda(arg1);
				curr = curr.next;
			}
		}
		private function invoke2(arg1:*, arg2:*):void
		{
			if (!enabled_)
				return;
				
			var curr:SignalNode = head_;
			while (curr != null)
			{
				curr.lambda(arg1, arg2);
				curr = curr.next;
			}
		}
		private function invoke3(arg1:*, arg2:*, arg3:*):void
		{
			if (!enabled_)
				return;
				
			var curr:SignalNode = head_;
			while (curr != null)
			{
				curr.lambda(arg1, arg2, arg3);
				curr = curr.next;
			}
		}
		private function invoke4(arg1:*, arg2:*, arg3:*, arg4:*):void
		{
			if (!enabled_)
				return;
				
			var curr:SignalNode = head_;
			while (curr != null)
			{
				curr.lambda(arg1, arg2, arg3, arg4);
				curr = curr.next;
			}
		}
	}
}

class SignalNode
{
	public var lambda:Function;
	public var next:SignalNode = null;
	
	public function SignalNode(lambda:Function):void
	{
		this.lambda = lambda;
	}
}

package com.oddcast.oc3d.shared
{
	public class RangedNumber
	{
		public function get _debug_():String{ return "{val:" + value_ + ", min:" + minimum_ + ", max:" + maximum_ + "}";  }
		
		private var minimum_:Number;
		private var maximum_:Number;
		private var value_:Number;
		
		public function RangedNumber(value:Number=0, minimum:Number=0, maximum:Number=1)
		{
			minimum_ = minimum;
			maximum_ = maximum < minimum ? minimum : maximum;
			value_ = Math.min(Math.max(value, minimum_), maximum_);
		}
		
		public function assign(other:RangedNumber):void
		{
			minimum_ = other.minimum_;
			maximum_ = other.maximum_;
			value_ = other.value_;
		}
		
		public function setValue(v:Number):void
		{
			value_ = Math.min(Math.max(v, minimum_), maximum_);
		}
		
		public function value():Number
		{
			return value_;
		}
		
		public function setMinimum(v:Number):void
		{
			minimum_ = v > maximum_ ? maximum_ : v;
			if (minimum_ > value_)
				value_ = minimum_;
		}
		
		public function minimum():Number
		{
			return minimum_;
		}
		
		public function setMaximum(v:Number):void
		{
			maximum_ = v < minimum_ ? minimum_ : v;
			if (maximum_ < value_)
				value_ = maximum_;
		}
		
		public function maximum():Number
		{
			return maximum_;
		}
	}
}
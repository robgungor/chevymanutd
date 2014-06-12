package com.oddcast.oc3d.data
{
	public class Mat33
	{
		public var n11:Number; // sx
		public var n12:Number;
		public var n13:Number; // tx
		public var n21:Number;
		public var n22:Number; // sy
		public var n23:Number; // ty
		public var n31:Number;
		public var n32:Number;
		public var n33:Number;
		
		public function Mat33(_11:Number=1, _12:Number=0, _13:Number=0,
											_21:Number=0, _22:Number=1, _23:Number=0,
											_31:Number=0, _32:Number=0, _33:Number=1)
		{
			n11 = _11, n12 = _12, n13 = _13;
			n21 = _21, n22 = _22, n23 = _23;
			n31 = _31, n32 = _32, n33 = _33;
		}
		public function toString():String
		{
			return "(Mat33 " + 
				n11 + " " + n12 + " " + n13 + " " + 
				n21 + " " + n22 + " " + n23 + " " + 
				n31 + " " + n32 + " " + n33 + ")";
		}
		public function clone():Mat33
		{
			return new Mat33(
				n11, n12, n13,
				n21, n22, n23,
				n31, n32, n33);
		}
		public function assign(src:Mat33):void
		{
			n11 = src.n11; n12 = src.n12; n13 = src.n13;
			n21 = src.n21; n22 = src.n22; n23 = src.n23;
			n31 = src.n31; n32 = src.n32; n33 = src.n33;
		}
		public function assignFromElements(
			_11:Number=1, _12:Number=0, _13:Number=0,
			_21:Number=0, _22:Number=1, _23:Number=0,
			_31:Number=0, _32:Number=0, _33:Number=1):void
		{
			n11 = _11; n12 = _12; n13 = _13;
			n21 = _21; n22 = _22; n23 = _23;
			n31 = _31; n32 = _32; n33 = _33;
		}
	}
}
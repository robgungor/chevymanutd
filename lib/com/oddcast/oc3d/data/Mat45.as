package com.oddcast.oc3d.data
{
	public class Mat45
	{
		public var n11:Number;
		public var n12:Number;
		public var n13:Number;
		public var n14:Number;
		public var n15:Number;
		public var n21:Number;
		public var n22:Number;
		public var n23:Number;
		public var n24:Number;
		public var n25:Number;
		public var n31:Number;
		public var n32:Number;
		public var n33:Number;
		public var n34:Number;
		public var n35:Number;
		public var n41:Number;
		public var n42:Number;
		public var n43:Number;
		public var n44:Number;
		public var n45:Number;

		public function Mat45(
			_11:Number=1, _12:Number=0, _13:Number=0, _14:Number=0, _15:Number=0,
			_21:Number=0, _22:Number=1, _23:Number=0, _24:Number=0, _25:Number=0,
			_31:Number=0, _32:Number=0, _33:Number=1, _34:Number=0, _35:Number=0,
			_41:Number=0, _42:Number=0, _43:Number=0, _44:Number=1, _45:Number=0)
		{
			n11 = _11, n12 = _12, n13 = _13, n14 = _14, n15 = _15;
			n21 = _21, n22 = _22, n23 = _23, n24 = _24, n25 = _25;
			n31 = _31, n32 = _32, n33 = _33, n34 = _34, n35 = _35;
			n41 = _41, n42 = _42, n43 = _43, n44 = _44; n45 = _45;
		}
		public function toString():String
		{
			return "(Mat45 " + 
				n11 + " " + n12 + " " + n13 + " " + n14 + " " + n15 + " " +
				n21 + " " + n22 + " " + n23 + " " + n24 + " " + n25 + " " +
				n31 + " " + n32 + " " + n33 + " " + n34 + " " + n35 + " " +
				n41 + " " + n42 + " " + n43 + " " + n44 + " " + n45 + ")";
		}
		public function clone():Mat45
		{
			return new Mat45(
				n11, n12, n13, n14, n15,
				n21, n22, n23, n24, n25,
				n31, n32, n33, n34, n35,
				n41, n42, n43, n44, n45);
		}
		public function assign(src:Mat45):void
		{
			n11 = src.n11; n12 = src.n12; n13 = src.n13; n14 = src.n14; n15 = src.n15;
			n21 = src.n21; n22 = src.n22; n23 = src.n23; n24 = src.n24; n25 = src.n25;
			n31 = src.n31; n32 = src.n32; n33 = src.n33; n34 = src.n34; n35 = src.n35;
			n41 = src.n41; n42 = src.n42; n43 = src.n43; n44 = src.n44; n45 = src.n45;
		}
		public function assignFromElements(
			_11:Number=1, _12:Number=0, _13:Number=0, _14:Number=0, _15:Number=0,
			_21:Number=0, _22:Number=1, _23:Number=0, _24:Number=0, _25:Number=0,
			_31:Number=0, _32:Number=0, _33:Number=1, _34:Number=0, _35:Number=0,
			_41:Number=0, _42:Number=0, _43:Number=0, _44:Number=1, _45:Number=0):void
		{
			n11 = _11, n12 = _12, n13 = _13, n14 = _14, n14 = _15;
			n21 = _21, n22 = _22, n23 = _23, n24 = _24, n14 = _25;
			n31 = _31, n32 = _32, n33 = _33, n34 = _34, n14 = _35;
			n41 = _41, n42 = _42, n43 = _43, n44 = _44, n14 = _45;
		}
	}
}
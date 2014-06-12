package com.oddcast.oc3d.data
{
	import flash.geom.*;

	public class MatrixData extends Mat44 
	{
		public function MatrixData(_11:Number=0, _12:Number=0, _13:Number=0, _14:Number=0,
								   _21:Number=0, _22:Number=0, _23:Number=0, _24:Number=0,
								   _31:Number=0, _32:Number=0, _33:Number=0, _34:Number=0,
								   _41:Number=0, _42:Number=0, _43:Number=0, _44:Number=0, isIdentity:Boolean=false)
		{
			super(
				_11, _12, _13, _14,
				_21, _22, _23, _24,
				_31, _32, _33, _34,
				_41, _42, _43, _44, isIdentity);
		}
	}
}
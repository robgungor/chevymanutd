package com.oddcast.oc3d.data
{
	import com.oddcast.oc3d.shared.Maff;
	
	import flash.geom.Vector3D;
	
	public class Mat44
	{
		public var n11:Number;
		public var n12:Number;
		public var n13:Number;
		public var n14:Number; // tx
		public var n21:Number;
		public var n22:Number;
		public var n23:Number;
		public var n24:Number; // ty
		public var n31:Number;
		public var n32:Number;
		public var n33:Number;
		public var n34:Number; // tz
		public var n41:Number;
		public var n42:Number;
		public var n43:Number;
		public var n44:Number;
		public var flags:int; // used for optimizations

		// Matrix 4x4 stuff ///////////////////////////////////////////////////////////
		public function toString(data:Mat44):String
		{
			return "(Mat44 " + 
				data.n11 + " " + data.n12 + " " + data.n13 + " " + data.n14 + " " +
				data.n21 + " " + data.n22 + " " + data.n23 + " " + data.n24 + " " +
				data.n31 + " " + data.n32 + " " + data.n33 + " " + data.n34 + " " +
				data.n41 + " " + data.n42 + " " + data.n43 + " " + data.n44 + ")";
		}
		public function clone():Mat44
		{
			return new Mat44(n11, n12, n13, n14, n21, n22, n23, n24, n31, n32, n33, n34, n41, n42, n43, n44, flags==1);
		}
		public function Mat44(_11:Number=1, _12:Number=0, _13:Number=0, _14:Number=0,
							  _21:Number=0, _22:Number=1, _23:Number=0, _24:Number=0,
							  _31:Number=0, _32:Number=0, _33:Number=1, _34:Number=0,
							  _41:Number=0, _42:Number=0, _43:Number=0, _44:Number=1, isIdentity:Boolean=true)
		{
			n11 = _11, n12 = _12, n13 = _13, n14 = _14;
			n21 = _21, n22 = _22, n23 = _23, n24 = _24;
			n31 = _31, n32 = _32, n33 = _33, n34 = _34;
			n41 = _41, n42 = _42, n43 = _43, n44 = _44;
			flags = isIdentity?1:0;
		}
		public function assign(src:Mat44):void
		{
			if ((src.flags>0) && (flags>0))
				return;
			
			n11 = src.n11; n12 = src.n12; n13 = src.n13; n14 = src.n14;
			n21 = src.n21; n22 = src.n22; n23 = src.n23; n24 = src.n24;
			n31 = src.n31; n32 = src.n32; n33 = src.n33; n34 = src.n34;
			n41 = src.n41; n42 = src.n42; n43 = src.n43; n44 = src.n44;
			flags = src.flags;
		}
		public function assignFromElements(
			_11:Number, _12:Number, _13:Number, _14:Number,
			_21:Number, _22:Number, _23:Number, _24:Number,
			_31:Number, _32:Number, _33:Number, _34:Number,
			_41:Number, _42:Number, _43:Number, _44:Number, isIdentity:Boolean=false):void
		{
			n11 = _11, n12 = _12, n13 = _13, n14 = _14;
			n21 = _21, n22 = _22, n23 = _23, n24 = _24;
			n31 = _31, n32 = _32, n33 = _33, n34 = _34;
			n41 = _41, n42 = _42, n43 = _43, n44 = _44;
			flags = isIdentity?1:0;
		}
		public function assignIdentity():void
		{
			n11 = 1, n12 = 0, n13 = 0, n14 = 0;
			n21 = 0, n22 = 1, n23 = 0, n24 = 0;
			n31 = 0, n32 = 0, n33 = 1, n34 = 0;
			n41 = 0, n42 = 0, n43 = 0, n44 = 1;
			flags = 1;
		}
		public function mulMatMat(a:Mat44, b:Mat44):void
		{
			var m11:Number = a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31 + a.n14 * b.n41;
			var m12:Number = a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32 + a.n14 * b.n42;
			var m13:Number = a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33 + a.n14 * b.n43;
			var m14:Number = a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14 * b.n44;
			var m21:Number = a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31 + a.n24 * b.n41;
			var m22:Number = a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32 + a.n24 * b.n42;
			var m23:Number = a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33 + a.n24 * b.n43;
			var m24:Number = a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24 * b.n44;
			var m31:Number = a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31 + a.n34 * b.n41;
			var m32:Number = a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32 + a.n34 * b.n42;
			var m33:Number = a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33 + a.n34 * b.n43;
			var m34:Number = a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34 * b.n44;
			var m41:Number = a.n41 * b.n11 + a.n42 * b.n21 + a.n43 * b.n31 + a.n44 * b.n41;
			var m42:Number = a.n41 * b.n12 + a.n42 * b.n22 + a.n43 * b.n32 + a.n44 * b.n42;
			var m43:Number = a.n41 * b.n13 + a.n42 * b.n23 + a.n43 * b.n33 + a.n44 * b.n43;
			var m44:Number = a.n41 * b.n14 + a.n42 * b.n24 + a.n43 * b.n34 + a.n44 * b.n44;
			
			n11 = m11; n12 = m12; n13 = m13; n14 = m14; 
			n21 = m21; n22 = m22; n23 = m23; n24 = m24; 
			n31 = m31; n32 = m32; n33 = m33; n34 = m34; 
			n41 = m41; n42 = m42; n43 = m43; n44 = m44; 
		}
		public function mulMatMatLite(a:Mat44, b:Mat44):void
		{
			if ((a.flags>0) && (b.flags>0))
				assignIdentity();
			else if (a.flags > 0)
				assign(b);
			else if (b.flags > 0)
				assign(a);
			else
			{
				var m11:Number = a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31;
				var m12:Number = a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32;
				var m13:Number = a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33;
				var m14:Number = a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14;
				var m21:Number = a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31;
				var m22:Number = a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32;
				var m23:Number = a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33;
				var m24:Number = a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24;
				var m31:Number = a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31;
				var m32:Number = a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32;
				var m33:Number = a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33;
				var m34:Number = a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34;
				n11 = m11; n12 = m12; n13 = m13; n14 = m14;
				n21 = m21; n22 = m22; n23 = m23; n24 = m24;
				n31 = m31; n32 = m32; n33 = m33; n34 = m34;
				flags = 0;
			}
		}
		public function inverseCopy():Mat44
		{
			var m11:Number = n11; var m12:Number = n12; var m13:Number = n13; var m14:Number = n14;
			var m21:Number = n21; var m22:Number = n22; var m23:Number = n23; var m24:Number = n24;
			var m31:Number = n31; var m32:Number = n32; var m33:Number = n33; var m34:Number = n34;
			var m41:Number = n41; var m42:Number = n42; var m43:Number = n43; var m44:Number = n44;
			
			var det:Number = m14 * m23 * m32 * m41 - m13 * m24 * m32 * m41 - m14 * m22 * m33 * m41 + m12 * m24 * m33 * m41 +
				m13 * m22 * m34 * m41 - m12 * m23 * m34 * m41 - m14 * m23 * m31 * m42 + m13 * m24 * m31 * m42 +
				m14 * m21 * m33 * m42 - m11 * m24 * m33 * m42 - m13 * m21 * m34 * m42 + m11 * m23 * m34 * m42 +
				m14 * m22 * m31 * m43 - m12 * m24 * m31 * m43 - m14 * m21 * m32 * m43 + m11 * m24 * m32 * m43 +
				m12 * m21 * m34 * m43 - m11 * m22 * m34 * m43 - m13 * m22 * m31 * m44 + m12 * m23 * m31 * m44 +
				m13 * m21 * m32 * m44 - m11 * m23 * m32 * m44 - m12 * m21 * m33 * m44 + m11 * m22 * m33 * m44;
			var invDet:Number = det == 1 ? 1 : 1 / det;
			
			return new Mat44(
				(m23 * m34 * m42 - m24 * m33 * m42 + m24 * m32 * m43 - m22 * m34 * m43 - m23 * m32 * m44 + m22 * m33 * m44) * invDet,
				(m14 * m33 * m42 - m13 * m34 * m42 - m14 * m32 * m43 + m12 * m34 * m43 + m13 * m32 * m44 - m12 * m33 * m44) * invDet,
				(m13 * m24 * m42 - m14 * m23 * m42 + m14 * m22 * m43 - m12 * m24 * m43 - m13 * m22 * m44 + m12 * m23 * m44) * invDet,
				(m14 * m23 * m32 - m13 * m24 * m32 - m14 * m22 * m33 + m12 * m24 * m33 + m13 * m22 * m34 - m12 * m23 * m34) * invDet,
				(m24 * m33 * m41 - m23 * m34 * m41 - m24 * m31 * m43 + m21 * m34 * m43 + m23 * m31 * m44 - m21 * m33 * m44) * invDet,
				(m13 * m34 * m41 - m14 * m33 * m41 + m14 * m31 * m43 - m11 * m34 * m43 - m13 * m31 * m44 + m11 * m33 * m44) * invDet,
				(m14 * m23 * m41 - m13 * m24 * m41 - m14 * m21 * m43 + m11 * m24 * m43 + m13 * m21 * m44 - m11 * m23 * m44) * invDet,
				(m13 * m24 * m31 - m14 * m23 * m31 + m14 * m21 * m33 - m11 * m24 * m33 - m13 * m21 * m34 + m11 * m23 * m34) * invDet,
				(m22 * m34 * m41 - m24 * m32 * m41 + m24 * m31 * m42 - m21 * m34 * m42 - m22 * m31 * m44 + m21 * m32 * m44) * invDet,
				(m14 * m32 * m41 - m12 * m34 * m41 - m14 * m31 * m42 + m11 * m34 * m42 + m12 * m31 * m44 - m11 * m32 * m44) * invDet,
				(m12 * m24 * m41 - m14 * m22 * m41 + m14 * m21 * m42 - m11 * m24 * m42 - m12 * m21 * m44 + m11 * m22 * m44) * invDet,
				(m14 * m22 * m31 - m12 * m24 * m31 - m14 * m21 * m32 + m11 * m24 * m32 + m12 * m21 * m34 - m11 * m22 * m34) * invDet,
				(m23 * m32 * m41 - m22 * m33 * m41 - m23 * m31 * m42 + m21 * m33 * m42 + m22 * m31 * m43 - m21 * m32 * m43) * invDet,
				(m12 * m33 * m41 - m13 * m32 * m41 + m13 * m31 * m42 - m11 * m33 * m42 - m12 * m31 * m43 + m11 * m32 * m43) * invDet,
				(m13 * m22 * m41 - m12 * m23 * m41 - m13 * m21 * m42 + m11 * m23 * m42 + m12 * m21 * m43 - m11 * m22 * m43) * invDet,
				(m12 * m23 * m31 - m13 * m22 * m31 + m13 * m21 * m32 - m11 * m23 * m32 - m12 * m21 * m33 + m11 * m22 * m33) * invDet, false);
		}
		public function inverseCopyLite():Mat44
		{
			if (flags > 0)
				return clone();
			else
			{
				var det:Number = 
					(n11 * n22 - n21 * n12) * n33 - 
					(n11 * n32 - n31 * n12) * n23 +
					(n21 * n32 - n31 * n22) * n13;
				var invDet:Number = det == 1 ? 1 : 1 / det;
				
				var m11:Number = n11; var m21:Number = n21; var m31:Number = n31;
				var m12:Number = n12; var m22:Number = n22; var m32:Number = n32;
				var m13:Number = n13; var m23:Number = n23; var m33:Number = n33;
				var m14:Number = n14; var m24:Number = n24; var m34:Number = n34;
				
				return new Mat44(
					invDet * ( m22 * m33 - m32 * m23 ),
					-invDet * ( m12 * m33 - m32 * m13 ),
					invDet * ( m12 * m23 - m22 * m13 ),
					-invDet * ( m12 * (m23*m34 - m33*m24) - m22 * (m13*m34 - m33*m14) + m32 * (m13*m24 - m23*m14) ),
					-invDet * ( m21 * m33 - m31 * m23 ),
					invDet * ( m11 * m33 - m31 * m13 ),
					-invDet * ( m11 * m23 - m21 * m13 ),
					invDet * ( m11 * (m23*m34 - m33*m24) - m21 * (m13*m34 - m33*m14) + m31 * (m13*m24 - m23*m14) ),
					invDet * ( m21 * m32 - m31 * m22 ),
					-invDet * ( m11 * m32 - m31 * m12 ),
					invDet * ( m11 * m22 - m21 * m12 ),
					-invDet * ( m11 * (m22*m34 - m32*m24) - m21 * (m12*m34 - m32*m14) + m31 * (m12*m24 - m22*m14) ),
					0, 0, 0, 1, false);
				return result;
			}
		}
		public static function mulMatMatCopyLite(a:Mat44, b:Mat44):Mat44
		{
			if ((a.flags>0) && (b.flags>0))
				return createIdentity();
			else if (a.flags > 0)
				return b.clone();
			else if (b.flags > 0)
				return b.clone();
			else
			{
				return new Mat44(
					a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31,
					a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32,
					a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33,
					a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14,
					a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31,
					a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32,
					a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33,
					a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24,
					a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31,
					a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32,
					a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33,
					a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34,
					0, 0, 0, 1, false);
			}
		}
		public static function createIdentity():Mat44
		{
			return new Mat44(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, true);
		}		
		public static function createViewport(x:Number, y:Number, width:Number, height:Number):Mat44
		{
			var hw:Number = width * 0.5;
			var hh:Number = height * 0.5;
			return new Mat44(
				hw,  0, 0, x+hw,
				0, hh, 0, y+hh,
				0,  0, 0, 0,
				0,  0, 0, 1,
				false);
		}
		public static function createOrthographic(left:Number, right:Number, bottom:Number, top:Number, nearClip:Number, farClip:Number):Mat44
		{
			var w:Number = right-left;
			var h:Number = top-bottom;
			var d:Number = nearClip-farClip;
			
			return new Mat44(
				2.0/w, 0.0, 			0.0, 		(right+left)/w,
				0.0, 		-2.0/h, 	0.0, 		(top+bottom)/h,
				0.0, 		0.0, 		2.0/d, 		(nearClip+farClip)/d,
				0.0, 		0.0, 		0.0, 		1.0,
				false);
		}
		public static function createPerspective(halfFieldOfViewYDegrees:Number, widthOverHeightRatio:Number, nearClip:Number, farClip:Number):Mat44
		{
			var halfHeight:Number = nearClip * Math.tan(halfFieldOfViewYDegrees * Maff.DEG_TO_RAD);
			var halfWidth:Number = halfHeight * widthOverHeightRatio;
			return createFrustum(-halfWidth, halfWidth, -halfHeight, halfHeight, nearClip, farClip);
		}
		public static function createFrustum(left:Number, right:Number, bottom:Number, top:Number, front:Number, back:Number):Mat44
		{
			var invWidth:Number = 1/(right-left);
			var invHeight:Number = 1/(top-bottom);
			var invDepth:Number = 1/(back-front);
			return new Mat44(
				2*front*invWidth,	0,								(right+left)*invWidth,		0,
				0,						-2*front*invHeight,			(top+bottom)*invHeight,		0,
				0,						0,							(back+front)*invDepth,		2*back*front*invDepth,
				0,						0,							-1,							0,
				false);
		}
		public static function mulMatVecCopyLite(m:Mat44, v:Vector3D):Vector3D
		{
			if (m.flags > 0)
				return new Vector3D(v.x, v.y, v.z);
			else
				return new Vector3D(
					v.x * m.n11 + v.y * m.n12 + v.z * m.n13 + m.n14,
					v.x * m.n21 + v.y * m.n22 + v.z * m.n23 + m.n24,
					v.x * m.n31 + v.y * m.n32 + v.z * m.n33 + m.n34);
		}
		public static function decomposeTransformToRadians(transform:Mat44, position:Vector3D, orientationRadians:Vector3D, scale:Vector3D):void
		{
			if (transform.flags > 0)
			{
				if (position != null)
					Maff.Vector3D_assign(position, 0, 0, 0);
				if (orientationRadians != null)
					Maff.Vector3D_assign(orientationRadians, 0, 0, 0);
				if (scale != null)
					Maff.Vector3D_assign(scale, 1, 1, 1);
			}
			else
			{
				decomposeElementsToRadians(
					transform.n11, transform.n12, transform.n13, transform.n14,
					transform.n21, transform.n22, transform.n23, transform.n24,
					transform.n31, transform.n32, transform.n33, transform.n34,
					position, orientationRadians, scale);
			}
		}
		public static function decomposeElements(
			n11:Number, n12:Number, n13:Number, n14:Number,
			n21:Number, n22:Number, n23:Number, n24:Number,
			n31:Number, n32:Number, n33:Number, n34:Number,
			position:Vector3D, orientation:Vector3D, scale:Vector3D):void
		{
			decomposeElementsToRadians(
				n11, n12, n13, n14,
				n21, n22, n23, n24,
				n31, n32, n33, n34,
				position, orientation, scale);
			
			orientation.x *= Maff.RAD_TO_DEG;
			orientation.y *= Maff.RAD_TO_DEG;
			orientation.z *= Maff.RAD_TO_DEG;
		}
		public static function decomposeElementsToRadians(
			n11:Number, n12:Number, n13:Number, n14:Number,
			n21:Number, n22:Number, n23:Number, n24:Number,
			n31:Number, n32:Number, n33:Number, n34:Number,
			position:Vector3D, orientationRadians:Vector3D, scale:Vector3D):void
		{
			// ouch
			var sx:Number = Math.sqrt(n11*n11 + n12*n12 + n13*n13); 
			var sy:Number = Math.sqrt(n21*n21 + n22*n22 + n23*n23);
			var sz:Number = Math.sqrt(n31*n31 + n32*n32 + n33*n33);
			
			if (scale != null)
			{
				scale.x = sx;
				scale.y = sy;
				scale.z = sz;
			}
			
			if (orientationRadians != null)
			{
				var invSx:Number = 1.0 / sx;
				var invSy:Number = 1.0 / sy;
				var invSz:Number = 1.0 / sz;
				
				var e11:Number = n11 * invSx;
				var e12:Number = n12 * invSx;
				var e13:Number = n13 * invSx;
				var e21:Number = n21 * invSy;
				var e22:Number = n22 * invSy;
				var e23:Number = n23 * invSy;
				var e31:Number = n31 * invSz;
				var e32:Number = n32 * invSz;
				var e33:Number = n33 * invSz;
				
				var cy:Number = Math.sqrt(e22*e22 + e12*e12);
				var rx:Number = Math.atan2(-e32, cy);
				var ry:Number, rz:Number;
				if (cy > 16*Number.MIN_VALUE)
				{
					ry = Math.atan2(e31, e33);
					rz = Math.atan2(e12, e22);
				}
				else
				{
					ry = Math.atan2(-e13, e11);
					rz = 0.0;
				}
				orientationRadians.x = rx;
				orientationRadians.y = ry;
				orientationRadians.z = rz;
			}
			
			if (position != null)
			{
				position.x = n14;
				position.y = n24;
				position.z = n34;
			}
		}
		public static function createTranslate(x:Number, y:Number, z:Number):Mat44
		{
			return new Mat44(1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, z, 0, 0, 0, 1, false);
		}
		public static function createScale(xScale:Number, yScale:Number, zScale:Number):Mat44
		{
			return new Mat44(xScale, 0, 0, 0, 0, yScale, 0, 0, 0, 0, zScale, 0, 0, 0, 0, 1, false);
		}
		public static function createRotateAngleAxisWithRadians(x:Number, y:Number, z:Number, radians:Number):Mat44
		{
			var c:Number = Math.cos(radians);
			var s:Number = Math.sin(radians);
			var scos:Number	= 1-c;
			
			var sxy:Number = x*y*scos;
			var syz:Number = y*z*scos;
			var sxz:Number = x*z*scos;
			var sz:Number = s*z;
			var sy:Number = s*y;
			var sx:Number = s*x;
			
			return new Mat44(
				c+x*x*scos,	sz+sxy,		sy+sxz,		0,
				-sz+sxy, 	c+y*y*scos,	sx+syz, 	0,	
				-sy+sxz,	-sx+syz,	c+z*z*scos,	0,
				0, 			0, 			0, 			1,
				false);
		}
	}
}
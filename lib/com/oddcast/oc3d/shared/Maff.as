package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.data.*;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public class Maff
	{
		public static const RAD360:Number = Math.PI*2;
		public static const RAD270:Number = Math.PI*3*0.5;
		public static const RAD180:Number = Math.PI;
		public static const RAD90:Number = Math.PI*.5;
		public static const RAD45:Number = Math.PI*.25;
		
		public static const HALF_PI:Number = Math.PI*0.5;
		public static const QUATER_PI:Number = Math.PI*0.25;
		public static const INVERSE_HALF_PI:Number = 1/HALF_PI;
		public static const INVERSE_PI:Number = 1/Math.PI;
		public static const TWO_PI:Number = Math.PI*2;
		public static const DEG_TO_RAD:Number = Math.PI/180.0;
		public static const RAD_TO_DEG:Number = 180.0/Math.PI;
		public static const EPSILON:Number = 0.001;
		public static const SQRT_TWO:Number = Math.sqrt(2);
		public static const HALF_SQRT_TWO:Number = Math.sqrt(2)/2;
		public static const QUATER_SQRT_TWO:Number = Math.sqrt(2)/4;
		public static const INVERSE_SQRT_TWO:Number = 1/SQRT_TWO;
		public static const SIN45:Number = Math.sin(RAD45);
		
		public static const ONE_THIRD:Number = 1 / 3;
		
		public static function clamp(value:Number, minimum:Number, maximum:Number):Number
		{
			var result:Number = value > minimum ? value : minimum; 
			return result < maximum ? result : maximum; 
		}
		public static function clampInt(value:int, minimum:int, maximum:int):int { var result:int = value < minimum ? value : minimum; return result < maximum ? result : maximum; }
		public static function clampUInt(value:uint, minimum:uint, maximum:uint):int { var result:uint = value < minimum ? value : minimum; return result < maximum ? result : maximum; }
		public static function maxInt(value1:int, value2:int):int { return value1 > value2 ? value1 : value2; }
		public static function minInt(value1:int, value2:int):int { return value1 < value2 ? value1 : value2; }
		public static function max(v1:*, v2:*):* { return v1 > v2 ? v1 : v2; }
		public static function min(v1:*, v2:*):* { return v1 > v2 ? v2 : v1; }
		
		// ancillary Vector3D methods
		public static const Vector3D_UNIT:Vector3D	= new Vector3D( 1, 1, 1);
		public static const Vector3D_ZERO:Vector3D	= new Vector3D( 0, 0, 0);
		public static const Vector3D_FRONT:Vector3D	= new Vector3D( 0, 0, 1);
		public static const Vector3D_BACK:Vector3D	= new Vector3D( 0, 0,-1);
		public static const Vector3D_LEFT:Vector3D	= new Vector3D(-1, 0, 0);
		public static const Vector3D_RIGHT:Vector3D	= new Vector3D( 1, 0, 0);
		public static const Vector3D_UP:Vector3D	= new Vector3D( 0, 1, 0);
		public static const Vector3D_DOWN:Vector3D	= new Vector3D( 0,-1, 0);
		public static function Vector3D_assign(vec:Vector3D, x:Number, y:Number, z:Number):void { vec.x = x; vec.y = y; vec.z = z; }
		public static function Vector3D_assignVec(vec:Vector3D, src:Vector3D):void { vec.x = src.x; vec.y = src.y; vec.z = src.z; }
		public static function Vector3D_multiplyCopy(vec:Vector3D, scaler:Number):Vector3D { return new Vector3D(vec.x*scaler, vec.y*scaler, vec.z*scaler); }
		public static function Vector3D_clone(vec:Vector3D):Vector3D { return new Vector3D(vec.x, vec.y, vec.z, vec.w); }

		public static function Matrix_mulMatVecCopy(m:MatrixData, v:Vector3D):Vector3D
		{
			if (m.flags > 0)
				return new Vector3D(v.x, v.y, v.z);
			else
				return new Vector3D(
					v.x * m.n11 + v.y * m.n12 + v.z * m.n13 + m.n14,
					v.x * m.n21 + v.y * m.n22 + v.z * m.n23 + m.n24,
					v.x * m.n31 + v.y * m.n32 + v.z * m.n33 + m.n34);
		}
		public static function Matrix_createRotateAngleAxis(x:Number, y:Number, z:Number, degrees:Number):MatrixData
		{
			return Matrix_createRotateAngleAxisWithRadians(x, y, z, Maff.DEG_TO_RAD * degrees);
		}
		public static function Matrix_createRotateAngleAxisWithRadians(x:Number, y:Number, z:Number, radians:Number):MatrixData
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
			
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result,
				c+x*x*scos,	-sz+sxy,	sy+sxz,		0,
				sz+sxy, 	c+y*y*scos,	-sx+syz, 	0,	
				-sy+sxz,	sx+syz,		c+z*z*scos,	0,
				0, 			0, 			0, 			1);
			return result;
		}
		public static function Matrix_assignFromElements(mat:MatrixData,
												  _11:Number=0, _12:Number=0, _13:Number=0, _14:Number=0,
												  _21:Number=0, _22:Number=0, _23:Number=0, _24:Number=0,
												  _31:Number=0, _32:Number=0, _33:Number=0, _34:Number=0,
												  _41:Number=0, _42:Number=0, _43:Number=0, _44:Number=0, isIdentity:Boolean=false):void
		{
			mat.n11 = _11, mat.n12 = _12, mat.n13 = _13, mat.n14 = _14,
			mat.n21 = _21, mat.n22 = _22, mat.n23 = _23, mat.n24 = _24,
			mat.n31 = _31, mat.n32 = _32, mat.n33 = _33, mat.n34 = _34,
			mat.n41 = _41, mat.n42 = _42, mat.n43 = _43, mat.n44 = _44;
			mat.flags = isIdentity?1:0;
		}
		public static function Matrix_createRotateVec(degrees:Vector3D):MatrixData
		{
			return Matrix_createRotate(degrees.x, degrees.y, degrees.z);
		}
		public static function Matrix_createRotate(degreesX:Number, degreesY:Number, degreesZ:Number):MatrixData
		{
			var pitch:Number = degreesX * Maff.DEG_TO_RAD;
			var yaw:Number = degreesY * Maff.DEG_TO_RAD;
			var roll:Number = degreesZ * Maff.DEG_TO_RAD;
			
			var cx:Number = Math.cos(pitch);
			var sx:Number = Math.sin(pitch);
			var cy:Number = Math.cos(yaw);
			var sy:Number = Math.sin(yaw);
			var cz:Number = Math.cos(roll);
			var sz:Number = Math.sin(roll);
			
			//rx->ry->rz
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result,
				cy*cz,	cx*sz-sx*sy*cz,	cx*sy*cz+sx*sz,	0,
				-cy*sz,	sx*sy*sz+cx*cz,	sx*cz-cx*sy*sz,	0,
				-sy,	-sx*cy,			cx*cy,			0,
				0,			0,			0,				1);
			return result;
		}
		public static function Matrix_createRotateVecWithRadians(radians:Vector3D):MatrixData
		{
			return Matrix_createRotateWithRadians(radians.x, radians.y, radians.z);
		}
		public static function Matrix_createRotateWithRadians(radiansX:Number, radiansY:Number, radiansZ:Number):MatrixData
		{
			var pitch:Number = radiansX;
			var yaw:Number = radiansY;
			var roll:Number = radiansZ;
			
			var cx:Number = Math.cos(pitch);
			var sx:Number = Math.sin(pitch);
			var cy:Number = Math.cos(yaw);
			var sy:Number = Math.sin(yaw);
			var cz:Number = Math.cos(roll);
			var sz:Number = Math.sin(roll);
			
			//rx->ry->rz
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result,
				cy*cz,	cx*sz-sx*sy*cz,	cx*sy*cz+sx*sz,	0,
				-cy*sz,	sx*sy*sz+cx*cz,	sx*cz-cx*sy*sz,	0,
				-sy,	-sx*cy,			cx*cy,			0,
				0,			0,			0,				1);
			return result;
		}
		public static function Matrix_mulMatVecCopyWithWDivide(m:MatrixData, v:Vector3D):Vector3D
		{
			var invW:Number = 1.0 / (v.x*m.n41 + v.y*m.n42 + v.z*m.n43 + m.n44);
			return new Vector3D(
				(v.x*m.n11 + v.y*m.n12 + v.z*m.n13 + m.n14)*invW,
				(v.x*m.n21 + v.y*m.n22 + v.z*m.n23 + m.n24)*invW,
				(v.x*m.n31 + v.y*m.n32 + v.z*m.n33 + m.n34)*invW,
				invW);
		}
		public static function Matrix_createTransformMatrix(x:Number, y:Number, z:Number, degX:Number, degY:Number, degZ:Number, sclX:Number, sclY:Number, sclZ:Number):MatrixData
		{
			var result:MatrixData = Matrix_createRotate(degX, degY, degZ);
			Matrix_mulMatMat(result, result, Matrix_createScale(sclX, sclY, sclZ));
			result.n14 = x; result.n24 = y; result.n34 = z;
			return result;
		}
		public static function Matrix_createScale(xScale:Number, yScale:Number, zScale:Number):MatrixData
		{
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result, xScale, 0, 0, 0, 0, yScale, 0, 0, 0, 0, zScale, 0, 0, 0, 0, 1);
			return result;
		}
		public static function Matrix_createIdentity():MatrixData
		{
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, true);
			return result;
		}
		public static const Matrix_STATIC_IDENTITY:MatrixData = Matrix_createIdentity();
		public static function Matrix_mulMatMat(result:MatrixData, a:MatrixData, b:MatrixData):void
		{
			if ((a.flags>0) && (b.flags>0))
			{
				Matrix_assign(result, Matrix_STATIC_IDENTITY);
				result.flags = 1;
			}
			else if (a.flags > 0)
			{
				Matrix_assign(result, b);
				result.flags = 0;
			}
			else if (b.flags > 0)
			{
				Matrix_assign(result, a);
				result.flags = 0;
			}
			else
			{
				var n11:Number = a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31;
				var n12:Number = a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32;
				var n13:Number = a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33;
				var n14:Number = a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14;
				var n21:Number = a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31;
				var n22:Number = a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32;
				var n23:Number = a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33;
				var n24:Number = a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24;
				var n31:Number = a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31;
				var n32:Number = a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32;
				var n33:Number = a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33;
				var n34:Number = a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34;
				result.n11 = n11; result.n12 = n12; result.n13 = n13; result.n14 = n14;
				result.n21 = n21; result.n22 = n22; result.n23 = n23; result.n24 = n24;
				result.n31 = n31; result.n32 = n32; result.n33 = n33; result.n34 = n34;
				result.flags = 0;
			}
		}
		public static function Matrix_assign(mat:MatrixData, src:MatrixData):void
		{
			if ((src.flags>0) && (mat.flags>0))
				return;
			
			mat.n11 = src.n11; mat.n12 = src.n12; mat.n13 = src.n13; mat.n14 = src.n14;
			mat.n21 = src.n21; mat.n22 = src.n22; mat.n23 = src.n23; mat.n24 = src.n24;
			mat.n31 = src.n31; mat.n32 = src.n32; mat.n33 = src.n33; mat.n34 = src.n34;
			mat.n41 = src.n41; mat.n42 = src.n42; mat.n43 = src.n43; mat.n44 = src.n44;
			mat.flags = src.flags;
		}
	}
}
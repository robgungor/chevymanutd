package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.Maff;
	
	import flash.geom.Vector3D;
	
	public class Plane3D
	{
		public static const TOP:Plane3D = new Plane3D(0, 1, 0, 0);
		public static const BOTTOM:Plane3D = new Plane3D(0, -1, 0, 0);
		public static const LEFT:Plane3D = new Plane3D(-1, 0, 0, 0);
		public static const RIGHT:Plane3D = new Plane3D(1, 0, 0, 0);
		public static const FRONT:Plane3D = new Plane3D(0, 0, -1, 0);
		public static const BACK:Plane3D = new Plane3D(0, 0, 1, 0);

		public var normal: Vector3D;
		public var d: Number;
	
		public function Plane3D(a:Number=0, b:Number=0, c:Number=0, d:Number=0)
		{
			this.normal = new Vector3D(a, b, c);
			this.d = d;
		}

		public function distance(pt:Vector3D):Number
		{
			return pt.dotProduct(normal) + d;
		}
		
		public function normalize():void
		{
			var n:Vector3D = this.normal;
			
			//compute the length of the vector
			var invLen:Number = 1 / Math.sqrt(n.x*n.x + n.y*n.y + n.z*n.z);
			
			// normalize
			n.x *= invLen;
			n.y *= invLen;
			n.z *= invLen;
			d *= invLen;
		}

		public function setCoefficients( a:Number, b:Number, c:Number, d:Number ):void
		{
			// set the normal vector
			this.normal.x = a;
			this.normal.y = b;
			this.normal.z = c;
			this.d = d;
			
			normalize();
		}
		
		public static function createFromNormalAndPointVec(normal:Vector3D, point:Vector3D):Plane3D
		{
			return createFromNormalAndPoint(normal.x, normal.y, normal.z, point.x, point.y, point.z);
		}
		public static function createFromNormalAndPoint(normalX:Number, normalY:Number, normalZ:Number, pointX:Number, pointY:Number, pointZ:Number):Plane3D
		{
			var result:Plane3D = new Plane3D();
			result.normal.x = normalX;
			result.normal.y = normalY;
			result.normal.z = normalZ;
			// dot
			result.d = -(normalX * pointX + normalY * pointY + normalZ * pointZ);
			
			return result;
		}
		public static function createFromThreePointsVec(p0:Vector3D, p1:Vector3D, p2:Vector3D):Plane3D
		{
			return createFromThreePoints(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
		}
		public static function createFromThreePoints(p0x:Number, p0y:Number, p0z:Number, p1x:Number, p1y:Number, p1z:Number, p2x:Number, p2y:Number, p2z:Number):Plane3D
		{
			var abX:Number = p1x-p0x;
			var abY:Number = p1y-p0y;
			var abZ:Number = p1z-p0z;
			var acX:Number = p2x-p0x;
			var acY:Number = p2y-p0y;
			var acZ:Number = p2z-p0z;
			
			var result:Plane3D = new Plane3D();
			// cross
			Maff.Vector3D_assign(result.normal, acY * abZ - acZ * abY, acZ * abX - acX * abZ, acY * abY - acY * abX);
			result.normalize();
			// dot
			result.d = -(result.normal.x * p0x + result.normal.y * p0y + result.normal.z * p0z);
			
			return result;
		}
		
		public function tryFindIntersectionWithLine(a:Vector3D, b:Vector3D):Vector3D
		{
			var denom:Number = normal.x*(a.x-b.x) + normal.y*(a.y-b.y) + normal.z*(a.z-b.z);
			
			if (denom == 0)
				return null;
			
			var u:Number = (normal.x*a.x + normal.y*a.y + normal.z*a.z + d) / denom;
			
			return new Vector3D(
				a.x + u*(b.x-a.x),
				a.y + u*(b.y-a.y),
				a.z + u*(b.z-a.z));
		}
		public function toString():String
		{
			return "{a:" + normal.x  +" b:" +normal.y + " c:" +normal.z + " d:" + d + "}";
		}
	}
}
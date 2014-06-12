package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.Maff;
	
	import flash.geom.Vector3D;
	
	public class Rectangle3D
	{
		public static const ZERO:Rectangle3D = new Rectangle3D();
		
		public var min:Vector3D = new Vector3D();
		public var max:Vector3D = new Vector3D();
		
		public function Rectangle3D(minX:Number=0, minY:Number=0, minZ:Number=0, maxX:Number=0, maxY:Number=0, maxZ:Number=0)
		{
			this.min.x = minX;
			this.min.y = minY;
			this.min.z = minZ;
			this.max.x = maxX;
			this.max.y = maxY;
			this.max.z = maxZ;
		}
		public function assign(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):void
		{
			this.min.x = minX;
			this.min.y = minY;
			this.min.z = minZ;
			this.max.x = maxX;
			this.max.y = maxY;
			this.max.z = maxZ;
		}
		public function assignWithMinAndMax(min:Vector3D, max:Vector3D):void
		{
			Maff.Vector3D_assignVec(this.min, min);
			Maff.Vector3D_assignVec(this.max, max);
		}
		public function assignRect(other:Rectangle3D):void
		{
			Maff.Vector3D_assignVec(this.min, other.min);
			Maff.Vector3D_assignVec(this.max, other.max);
		}
		
		public function centroid():Vector3D
		{
			return new Vector3D((max.x + min.x) * .5, (max.y + min.y) * .5, (max.z + min.z) * .5);
		}
		
		public function width():Number
		{
			return max.x - min.x
		}
		public function height():Number
		{
			return max.y - min.y;
		}
		public function depth():Number
		{
			return max.z - min.z;
		}
		
		public function clone():Rectangle3D
		{
			return new Rectangle3D(this.min.x, this.min.y, this.min.z, this.max.x, this.max.y, this.max.z);
		}
		
		public function enclose(other:Rectangle3D):void
		{
			min.x = Math.min(min.x, other.min.x);
			min.y = Math.min(min.y, other.min.y);
			min.z = Math.min(min.z, other.min.z);
			max.x = Math.max(max.x, other.max.x);
			max.y = Math.max(max.y, other.max.y);
			max.z = Math.max(max.z, other.max.z);
		}
	}
}











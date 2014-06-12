package com.oddcast.oc3d.data
{
	import flash.geom.Vector3D;
	
	public class CameraData
	{
		public var Name:String;
		public var NodeIndex:uint;
		public var AspectRatio:Number;
		public var YFieldOfView:Number; // in degrees (if this number is zero, then this camera is orthographic)
		public var Near:Number;
		public var Far:Number;
	}
}
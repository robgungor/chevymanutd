package com.oddcast.oc3d.data
{
	import flash.geom.Vector3D;
	
	public class MeshData
	{
		public var MaskUVSetIndex:int;						// -1 if no mask is used
		public var Name:String;
		public var UVSetNames:Vector.<String>; 				// ("MapName0", "MapName1", ...)
		public var VertexBuffer:Vector.<Vector3D>; 			// ({x0, y0, z0}, {x1, y1, z1}, ...)
		public var NormalBuffer:Vector.<Vector3D>;			// ({nx0, ny0, nz0}, {nx1, ny1, nz1}, ...)
		public var UVSetBuffers:Vector.<Vector.<UVData>>; 	// (({u0, v0}, {u1, v1}, ...) ({u0, v0}, {u1, v1}, ...) ...) 
		public var TriangleBuffer:Vector.<TriangleData>;	// ({vi0 vi1 vi2 ti0 ti1 ti2 m0}, {vi0 vi1 vi2 ti0 ti1 ti2 m0}, ...)
		public var Minimum:Vector3D; 						// minimum local-boundingbox position
		public var Maximum:Vector3D; 						// maximum local-boundingbox position
		public var ZBias:Number;							// zbias factor
	}
}
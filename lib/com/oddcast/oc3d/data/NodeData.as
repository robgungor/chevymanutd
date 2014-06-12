package com.oddcast.oc3d.data
{
	public class NodeData
	{
		public var Name:String;
		public var Type:uint;
		public var ParentIndex:int;
		public var Transform:MatrixData;
		public var MeshIndex:int; // used if 'Type equals 2 (Geometry)
	}
}
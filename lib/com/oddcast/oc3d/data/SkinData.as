package com.oddcast.oc3d.data
{
	public class SkinData
	{
		public var Name:String; // this name is incorrect, use RealName
		public var RealName:String;
		public var MeshIndex:uint;
		public var JointPaths:Vector.<String>;
		public var JointIndices:Vector.<uint>;
		public var BindMatrices:Vector.<MatrixData>; 				// transform at which each joint was bound (Global->Local)
		public var BindMatrix:MatrixData; 						// transform at which the mesh was bound
		public var BlendedVertices:Vector.<BlendedVertexData>;
	}
}
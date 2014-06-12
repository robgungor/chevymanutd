package com.oddcast.oc3d.core
{
	public interface IDeformer
	{
		function geometry():IGeometryObject3D;
		function name():String;
		function id():uint;
	}
}
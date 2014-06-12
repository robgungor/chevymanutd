package com.oddcast.oc3d.core
{
	public interface ICompositeMaterial extends IMaterialObject3D
	{
		function setMaterialAtIndex(index:uint, material:IMaterialObject3D):void;
		function tryGetMaterialAtIndex(index:uint):IMaterialObject3D;
	}
}
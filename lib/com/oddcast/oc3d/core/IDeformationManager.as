package com.oddcast.oc3d.core
{
	public interface IDeformationManager
	{
		function forEachMorphDeformer(deformerFn:Function):void;
		
		function tryFindSkinDeformer(geom:IGeometryObject3D):ISkinDeformer
		function tryFindMorphDeformer(geom:IGeometryObject3D):IMorphDeformer;
		
		function tryFindMorphDeformerByName(name:String):IMorphDeformer;
		function tryFindSkinDeformerByName(name:String):ISkinDeformer;
	}
}
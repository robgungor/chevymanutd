package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.utils.Dictionary;
	
	public interface IAccessoryProxy extends ISelectableNodeProxy
	{
		function zBias():Number;

		function defaultMaterialConfiguration():IMaterialConfigurationProxy;
		function selectedMaterialConfiguration():IMaterialConfigurationProxy;

		function lastPickedGeometryName():String;
		function attachGeometry(geom:IGeometryObject3D):void;
		function tryFindGeometry(name:String):IGeometryObject3D;		
		function attachedGeometries():Dictionary;
		function uri():String;
	}
}
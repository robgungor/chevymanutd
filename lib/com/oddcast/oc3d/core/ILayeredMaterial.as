package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	public interface ILayeredMaterial extends IMaterialObject3D
	{
		function layers():LinkedList;

		function newLayer(name:String):ILayeredMaterialLayer;
		function tryFindLayerByName(name:String):ILayeredMaterialLayer;
		function removeLayer(layer:ILayeredMaterialLayer):void;
	}
}
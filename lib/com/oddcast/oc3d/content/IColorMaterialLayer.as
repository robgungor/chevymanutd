package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.shared.Color;
	
	public interface IColorMaterialLayer extends IColorMaterialLayerProxy, IMaterialLayer
	{
		function setColor(color:Color):void; 
	}
}
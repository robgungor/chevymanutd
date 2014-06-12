package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.shared.*;
	
	public interface ILightObject3D extends IDisplayObject3D
	{
		function setAmbientShade(v:RangedNumber):void;
		function ambientShade():RangedNumber;

		function setColor(v:Color):void;
		function color():Color;
		
		function intensity():RangedNumber;
		function setIntensity(v:RangedNumber):void;
	}
}
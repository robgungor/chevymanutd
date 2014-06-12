package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.shared.BlendingMode;
	import com.oddcast.oc3d.shared.Color;
	import com.oddcast.oc3d.shared.CompositeMode;
	
	import flash.filters.ColorMatrixFilter;
	
	public interface IMaterialAttribute
	{
		function material():IMaterialObject3D;
		
		function compositeMode():CompositeMode;
		function setColor(c:Color):void;
		function color():Color;
		function name():String;
		
		function blendingMode():BlendingMode;
		function setBlendingMode(blendingMode:BlendingMode):void;
	}
}
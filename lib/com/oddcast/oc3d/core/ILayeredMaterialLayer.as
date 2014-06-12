package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.shared.BlendingMode;
	
	public interface ILayeredMaterialLayer
	{
		function name():String;
		function material():ILayeredMaterial;
		
		function dispose():void;
		
		function attributes():Array;

		function setBlendingMode(blendingMode:BlendingMode):void;
		function blendingMode():BlendingMode;
		
		function setAttribute(name:String, attribute:IMaterialAttribute):void;
		function tryFindAttribute(name:String):IMaterialAttribute;
		
		function clearAttribute(name:String):void;
	}
}
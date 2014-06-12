package com.oddcast.oc3d.content
{
	import flash.geom.Vector3D;
	
	public interface IItemInstance extends ISelect
	{
		function id():uint;
		
		function name():String;
		function area():IArea;
		function dispose():void;
		
		function item():IItem;
		
		function setVisible(b:Boolean):void;
		function visible():Boolean;
		
		function overrideMaterialConfiguration():Boolean;
		function overrideAction():Boolean;
		function overrideDecal():Boolean;
		function setOverrideMaterialConfiguration(b:Boolean):void;
		function setOverrideAction(b:Boolean):void;
		function setOverrideDecal(b:Boolean):void;
		
		function tryGetSelectedMaterialConfiguration():IMaterialConfiguration;
		function setSelectedMaterialConfiguration(v:IMaterialConfiguration):void;

		function move(deltaX:Number, deltaY:Number, deltaZ:Number):void
		function moveVec(delta:Vector3D):void
		function rotate(deltaDegreesX:Number, deltaDegreesY:Number, deltaDegreesZ:Number):void
		function rotateVec(deltaDegrees:Vector3D):void
		function position():Vector3D;
		function setPosition(x:Number, y:Number, z:Number):void;
		function setPositionVec(v:Vector3D):void;
		function orientation():Vector3D;
		function setOrientation(degreesX:Number, degreesY:Number, degreesZ:Number):void;
		function setOrientationVec(degrees:Vector3D):void;
		
		function inBackground():Boolean;
		function setInBackground(b:Boolean):void;

		// continuationFn:Function<>
		function instantiate(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
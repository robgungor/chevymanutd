package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.IInstance3D;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public interface IAvatarInstance extends ISelect, ISerializable
	{
		function avatarBuilderProxy():IAvatarBuilderProxy;
		// continuationFn:Function<void()>
		function dispose(continuationFn:Function=null):void;
		
		function name():String;
		function setName(name:String):void;
		
		function attachBehavior(script:IScript):void;
		function detachBehavior(script:IScript):void;
		function attachedBehaviors():Dictionary; // Dictionary<id:int, IScript>
		
		function moveVec(position:Vector3D):void;
		function move(deltaX:Number, deltaY:Number, deltaZ:Number):void;
		
		function rotateVec(degrees:Vector3D):void;
		function rotate(degreesX:Number, degreesY:Number, degreesZ:Number):void;
		function rotateVecWithRadians(radians:Vector3D):void;
		function rotateWithRadians(radX:Number, radY:Number, radZ:Number):void;

		function setPositionVec(position:Vector3D):void;
		function setPosition(positionX:Number, positionY:Number, positionZ:Number):void;
		function position():Vector3D;
		function setOrientationVec(degrees:Vector3D):void;
		function setOrientation(degreesX:Number, degreesY:Number, degreesZ:Number):void;
		function setOrientationVecWithRadians(radians:Vector3D):void;
		function setOrientationWithRadians(rx:Number, ry:Number, rz:Number):void;
		function orientation():Vector3D;
		function orientationInRadians():Vector3D;
		function setScaleVec(scale:Vector3D):void;
		function setScale(scaleX:Number, scaleY:Number, scaleZ:Number):void;
		function scale():Vector3D;
	}
}
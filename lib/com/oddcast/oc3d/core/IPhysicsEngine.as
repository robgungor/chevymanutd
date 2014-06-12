package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.shared.Signal;
	
	import flash.geom.Vector3D;

	public interface IPhysicsEngine
	{
		function tickedSignal():Signal; // Signal<dt:Number>
		
		function start():void;
		function stop():void;
		function isRunning():Boolean;
		
		function setGravity(x:Number, y:Number, z:Number):void;
		function gravity():Vector3D;
	}
}
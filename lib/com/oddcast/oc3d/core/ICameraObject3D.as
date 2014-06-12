package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.data.MatrixData;
	import com.oddcast.oc3d.shared.*;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public interface ICameraObject3D extends IDisplayObject3D
	{
		function pickLowestZ(viewPos:Point):Number;

		function focalLength():Number;

		function setFieldOfViewInDegrees(fov:Number):void;
		function fieldOfViewInDegrees():Number;

		function aim():Vector3D;
		function setAim(localX:Number, localY:Number, localZ:Number):void;
		function setAimVec(local:Vector3D):void;
		
		function globalToScreen(src:Vector3D, dst:Vector3D):Boolean;

		function up():Vector3D;
		function setUp(localX:Number, localY:Number, localZ:Number):void;
		function setUpVec(local:Vector3D):void;
		
		function tryProjectRay(viewPos:Vector3D, targetGlobalPlane:Plane3D):Vector3D;
		
		function setViewport(x:Number, y:Number, width:Number, height:Number):void;
		function overridePerspectiveMatrixWithElements(n11:Number, n12:Number, n13:Number, n14:Number, n21:Number, n22:Number, n23:Number, n24:Number, n31:Number, n32:Number, n33:Number, n34:Number, n41:Number, n42:Number, n43:Number, n44:Number):void;
		function overridePerspectiveMatrix(mat:MatrixData):void;
	}
}
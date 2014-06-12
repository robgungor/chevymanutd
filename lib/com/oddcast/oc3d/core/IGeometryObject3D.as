package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.IIdentifiable;
	import com.oddcast.oc3d.shared.Rectangle3D;
	
	public interface IGeometryObject3D extends IIdentifiable
	{
		function name():String;

		function setUVOffset(tx:Number, ty:Number):void;

		function setVisible(v:Boolean):void;
		function visible():Boolean;
		
		function boundingBox():Rectangle3D
		function globalBoundingBox():Rectangle3D

		function boundingBoxVisible():Boolean;
		function setBoundingBoxVisible(v:Boolean):void;
		
		function inst():IInstance3D;
		
		function owner():IDisplayObject3D;
	}
}
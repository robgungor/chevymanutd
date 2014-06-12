package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.data.MatrixData;
	import com.oddcast.oc3d.shared.*;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.*;
	
	public interface IDisplayObject3D extends IIdentifiable
	{
		function pickCollect(viewPos:Point, result:Vector.<IGeometryObject3D>):void;

		function visibilityChangedSignal():Signal; // Signal<>
		function disposingSignal():Signal; // Signal<>
		function updatedSignal():Signal; // Signal<dt:Number> 
		function transformedSignal():Signal; // Signal<>

		function renderLayer():IRenderLayer;
		
		function tryFindGeometry():IGeometryObject3D; // returns the first visible mesh
		function scene():IScene3D;
		
		function inheritsTransform():Boolean;
		function setInheritsTransform(b:Boolean):void;
		
		function path():String;
		function name():String;
		
		// path:Array<String>
		function tryAccessNode(path:Array):IDisplayObject3D;
		function tryAccessNodeByPathString(path:String):IDisplayObject3D;

		function setVisible(value:Boolean):void;
		function visible():Boolean;

		function moveVec(position:Vector3D):void;
		function move(deltaX:Number, deltaY:Number, deltaZ:Number):void;

		function rotateVec(degrees:Vector3D):void;
		function rotate(degreesX:Number, degreesY:Number, degreesZ:Number):void;
		function rotateVecWithRadians(radians:Vector3D):void;
		function rotateWithRadians(radX:Number, radY:Number, radZ:Number):void;

		function axisRotate(x:Number, y:Number, z:Number, deg:Number):void;
		function axisRotateWithRadians(x:Number, y:Number, z:Number, rad:Number):void;

		function scaleBy(scaleDX:Number, scaleDY:Number, scaleDZ:Number):void;
		function setPositionVec(position:Vector3D):void;
		function setPosition(positionX:Number, positionY:Number, positionZ:Number):void;
		function position():Vector3D;
		function globalPosition():Vector3D;
		
		function setOrientationVec(degrees:Vector3D):void;
		function setOrientation(degreesX:Number, degreesY:Number, degreesZ:Number):void;
		function setOrientationVecWithRadians(radians:Vector3D):void;
		function setOrientationWithRadians(rx:Number, ry:Number, rz:Number):void;
		function orientation():Vector3D;
		function orientationInRadians():Vector3D;
		
		function setScaleVec(scale:Vector3D):void;
		function setScale(scaleX:Number, scaleY:Number, scaleZ:Number):void;
		function scale():Vector3D;
				
		function setParent(newParent:IDisplayObject3D):void;
		function parent():IDisplayObject3D;
		function addChild(child:IDisplayObject3D):void;
		function removeChild(child:IDisplayObject3D):void;
				
		function children():Dictionary;

		function tryFindChildByName(name:String):IDisplayObject3D;
		function tryFindChildById(id:uint):IDisplayObject3D;
		
		function dispose():void;
		
		function lookAt(at:Vector3D, up:Vector3D):void;
		
		function localToGlobal(v:Vector3D):Vector3D;
		function globalToLocal(v:Vector3D):Vector3D;

		function globalMatrix():MatrixData;
		function globalInverseMatrix():MatrixData;

		function setTransformFromArray(t:Array):void;
		function setTransformFromElements(
			n11:Number, n12:Number, n13:Number, n14:Number,
			n21:Number, n22:Number, n23:Number, n24:Number,
			n31:Number, n32:Number, n33:Number, n34:Number,
			n41:Number, n42:Number, n43:Number, n44:Number):void;
			
		function setIsBoundingBoxVisible(b:Boolean):void;
		function isBoundingBoxVisible():Boolean;
	}
}
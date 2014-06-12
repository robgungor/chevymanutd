package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.data.MatrixData;
	import com.oddcast.oc3d.shared.Maff;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	public class ViewportManipulator
	{
		private var savedMouseX_:Number = 0;
		private var savedMouseY_:Number = 0;
		
		private var magnitude_:Number = 0;
		private var yawDegrees_:Number = 0;
		private var pitchDegrees_:Number = 0;
		private var viewAngle_:Number = 89.9;
		private var upperPitchDegreeLimit_:Number = 89.9;
		private var lowerPitchDegreeLimit_:Number = -89.9;
		private var upperYawDegreeLimit_:Number = 0;
		private var lowerYawDegreeLimit_:Number = 0;
		private var nearZoomLimit_:Number = 0;
		private var farZoomLimit_:Number = 0;
		private var truckingEnabled_:Boolean = true;
		private var rotatingEnabled_:Boolean = true;
		private var zoomingEnabled_:Boolean = true;
		private var enabled_:Boolean = true;
		
		private var view_:IViewport3D;

		public function dispose():void
		{
			if (view_.tryGetCamera() != null)
			{
				var cam:ICameraObject3D = view_.tryGetCamera();
				if (cam != null)
					cam.transformedSignal().remove(updateCameraState);
				view_.cameraChangingSignal().remove(cameraChanging);
				view_.cameraChangedSignal().remove(updateCameraState);
				var sprite:Sprite = view_.sprite();
				view_.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				view_.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				view_.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			}
			view_ = null;
		}
		
		public function enabled():Boolean
		{
			return enabled_;
		}
		
		public function setEnabled(b:Boolean):void
		{
			if (b == enabled_)
				return;
				
			enabled_ = b;
			
			var sprite:Sprite = view_.sprite();
			var cam:ICameraObject3D = view_.tryGetCamera();
			if (enabled_)
			{
				view_.cameraChangingSignal().add(cameraChanging);
				view_.cameraChangedSignal().add(updateCameraState);
				if (cam != null)
					cam.transformedSignal().add(updateCameraState);
					
				updateCameraState();

				view_.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				view_.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				view_.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);	
			}
			else
			{
				if (cam != null)
					cam.transformedSignal().add(updateCameraState);
				view_.cameraChangingSignal().remove(cameraChanging);
				view_.cameraChangedSignal().remove(updateCameraState);
				
				view_.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				view_.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				view_.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			}
		}
		
		public function viewport():IViewport3D
		{
			return view_;
		}
		
		private function cameraChanging(newCam:ICameraObject3D):void
		{
			if (view_.tryGetCamera() != null)
				view_.tryGetCamera().transformedSignal().remove(updateCameraState);
			if (newCam != null)
				newCam.transformedSignal().add(updateCameraState);
		}
		
		private var isDragging_:Boolean = false;
		private function mouseDownHandler(e:MouseEvent):void
		{
			savedMouseX_ = e.stageX;
			savedMouseY_ = e.stageY;
			isDragging_ = true;
		}
		
		private function mouseUpHandler(e:MouseEvent):void
		{
			isDragging_ = false;
		}
		private function mouseMoveHandler(e:MouseEvent):void
		{
			if (!isDragging_)
				return;
				
			var mouseDeltaX:Number = e.stageX - savedMouseX_;
			var mouseDeltaY:Number = e.stageY - savedMouseY_;
			savedMouseX_ = e.stageX;
			savedMouseY_ = e.stageY;
			
			if (isControlledCamera_)
				return;
				
			var camera:ICameraObject3D = view_.tryGetCamera();
			if (camera == null)
				return;

			if (!e.buttonDown)
				return;

			camera.transformedSignal().setEnabled(false);

			if (truckingEnabled_ && e.shiftKey) // truck
			{
				var displacement1:Vector3D = Maff.Matrix_mulMatVecCopy(
					Maff.Matrix_createRotateVecWithRadians(camera.orientationInRadians()), 
					new Vector3D(mouseDeltaX*0.125, mouseDeltaY*0.125,0));
					
				camera.moveVec(displacement1);
				
				displacement1.incrementBy(camera.aim());
				camera.setAim(displacement1.x, displacement1.y, displacement1.z);
			}
			else if (zoomingEnabled_ && e.ctrlKey) // zoom
			{
				magnitude_ -= mouseDeltaX;
				if (nearZoomLimit_ + farZoomLimit_ != 0)
					magnitude_ = Math.min(Math.max(magnitude_, nearZoomLimit_), farZoomLimit_);
				
				var displacement:Vector3D = Maff.Matrix_mulMatVecCopy(
					Maff.Matrix_createRotate(pitchDegrees_, yawDegrees_, 0), 
					Maff.Vector3D_BACK);
				
				//var disp:Number = Vector3D.subVecVecCopy(camera.position(), camera.aim()).length();
				//var scaler:Number = disp * .02;
				//trace("disp:" + scaler);
				camera.setPositionVec(camera.aim().add(Maff.Vector3D_multiplyCopy(displacement, magnitude_)))
			}
			else if (rotatingEnabled_) // rotate
			{
				yawDegrees_ -= mouseDeltaX;
				if (lowerYawDegreeLimit_ != upperYawDegreeLimit_)
					yawDegrees_ = Math.min(Math.max(yawDegrees_, lowerYawDegreeLimit_-Maff.EPSILON), upperYawDegreeLimit_-Maff.EPSILON);
				pitchDegrees_ -= mouseDeltaY;
				pitchDegrees_ = Math.min(Math.max(pitchDegrees_, lowerPitchDegreeLimit_-Maff.EPSILON), upperPitchDegreeLimit_-Maff.EPSILON);
				
				var displacement3:Vector3D = Maff.Matrix_mulMatVecCopy(
					Maff.Matrix_createRotate(pitchDegrees_, yawDegrees_, 0), 
					Maff.Vector3D_BACK);
					
				camera.setPositionVec(camera.aim().add(Maff.Vector3D_multiplyCopy(displacement3, magnitude_)))
				
				camera.lookAt(camera.aim(), camera.up());
			}
			
			camera.transformedSignal().setEnabled(true);
		}
		
		public function setYaw(degrees:Number):void
		{
			if (degrees == yawDegrees_)
				return;
				
			yawDegrees_ = degrees;

			var camera:ICameraObject3D = view_.tryGetCamera();
			if (camera == null)
				return;
			
			updateCameraStateHelper(camera);
		}
		
		public function setPitch(degrees:Number):void
		{
			if (degrees == pitchDegrees_)
				return;
				
			pitchDegrees_ = degrees;

			var camera:ICameraObject3D = view_.tryGetCamera();
			if (camera == null)
				return;

			updateCameraStateHelper(camera);
		}
		
		public function yaw():Number
		{
			return yawDegrees_;
		}
		
		public function pitch():Number
		{
			return pitchDegrees_;
		}
		
		public function ViewportManipulator(view:IViewport3D)
		{
			view_ = view;
			
			var sprite:Sprite = view.sprite();
			
			view_.cameraChangingSignal().add(cameraChanging);
			view_.cameraChangedSignal().add(updateCameraState);

			var cam:ICameraObject3D = view_.tryGetCamera();
			if (cam != null)
				cam.transformedSignal().add(updateCameraState);
			updateCameraState();
			
			view_.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			view_.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			view_.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);	
		}

 		public function truckingEnabled():Boolean
 		{
 			return truckingEnabled_;
 		}
 		public function setTruckingEnabled(v:Boolean):void
 		{
 			truckingEnabled_ = v;
 		}
 		public function rotatingEnabled():Boolean
 		{
 			return rotatingEnabled_;
 		}
 		public function setRotatingEnabled(v:Boolean):void
 		{
 			rotatingEnabled_ = v;
 		}
 		public function zoomingEnabled():Boolean
 		{
 			return zoomingEnabled_;
 		}
 		public function setZoomingEnabled(v:Boolean):void
 		{
 			zoomingEnabled_ = v;
 		}
 		
 		public function setYawLimits(lowerDegrees:Number, upperDegrees:Number):void
 		{
 			var upper:Number = -lowerDegrees;
 			var lower:Number=  -upperDegrees;
 			upperYawDegreeLimit_ = Math.max(Math.min(89.9, upper), Math.min(upper, lower)) - 180;
 			lowerYawDegreeLimit_ = Math.min(Math.max(-89.9, lower), Math.max(upper, lower)) - 180;
			var camera:ICameraObject3D = view_.tryGetCamera();
 			updateCameraState();
 		}
 		
		public function setPitchLimits(lowerDegrees:Number, upperDegrees:Number):void
		{
			var upper:Number = -lowerDegrees;
			var lower:Number = -upperDegrees;
			upperPitchDegreeLimit_ = Math.max(Math.min(89.9, upper), Math.min(upper, lower));
			lowerPitchDegreeLimit_ = Math.min(Math.max(-89.9, lower), Math.max(upper, lower));
			updateCameraState();
		}
		public function setZoomLimits(nearZoom:Number, farZoom:Number):void
		{
			if (nearZoom + farZoom == 0)
				nearZoomLimit_ = farZoomLimit_ = 0;
				 
			nearZoomLimit_ = Math.min(Math.max(nearZoom, 10), 1000);
			farZoomLimit_ = Math.min(Math.max(farZoom, 10), 1000);
			if (farZoomLimit_ < nearZoomLimit_)
				farZoomLimit_ = nearZoomLimit_;
			updateCameraState();
		}
		
		private var isControlledCamera_:Boolean = false;	
		
		private function updateCameraState():void
		{
			if (!enabled_)
				return;
				
			var camera:ICameraObject3D = view_.tryGetCamera();
			if (camera == null)
				return;
				
			var distance:Vector3D = camera.position().subtract(camera.aim());
			if (distance.x == 0 && distance.y == 0 && distance.z == 0)
				isControlledCamera_ = true;
			else
			{
				isControlledCamera_ = false;

				magnitude_ = distance.normalize();
				if (nearZoomLimit_ !=0 && farZoomLimit_ != 0)
					magnitude_ = Math.min(Math.max(magnitude_, nearZoomLimit_), farZoomLimit_);
				/*
				magnitude_ = distance.length;
				if (nearZoomLimit_ + farZoomLimit_ != 0)
					magnitude_ = Math.min(Math.max(magnitude_, nearZoomLimit_), farZoomLimit_);
				distance.div(magnitude_);
				*/
	
				pitchDegrees_ = -Math.asin(distance.y) * Maff.RAD_TO_DEG;
				pitchDegrees_ = Math.min(Math.max(pitchDegrees_, lowerPitchDegreeLimit_-Maff.EPSILON), upperPitchDegreeLimit_-Maff.EPSILON);
				yawDegrees_ = -Math.atan2(distance.x, -distance.z) * Maff.RAD_TO_DEG;
				if (yawDegrees_ > 0)
					yawDegrees_ = (yawDegrees_ % 360) - 360; 
				
				updateCameraStateHelper(camera);
			}
		}
		
		private function updateCameraStateHelper(camera:ICameraObject3D):void
		{
			if (upperYawDegreeLimit_ != lowerYawDegreeLimit_)
				yawDegrees_ = Math.min(Math.max(yawDegrees_, lowerYawDegreeLimit_-Maff.EPSILON), upperYawDegreeLimit_-Maff.EPSILON);
			
			var displacement3:Vector3D = Maff.Matrix_mulMatVecCopy(
				Maff.Matrix_createRotate(pitchDegrees_, yawDegrees_, 0), 
				Maff.Vector3D_BACK);
			
			var pos:Vector3D = camera.aim().add(Maff.Vector3D_multiplyCopy(displacement3, magnitude_));
			
			camera.transformedSignal().setEnabled(false);
			
			camera.setPosition(pos.x, pos.y, pos.z);
			camera.lookAt(camera.aim(), camera.up());
			
			camera.transformedSignal().setEnabled(true);

			view_.requireRender();
		}
	}
}
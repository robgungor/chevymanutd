

	/**
	 * ...
	 * @author Jake Lewis
	 * 4/15/2010 5:01 PM
	 */
	package  com.oddcast.cv.util;
	//import com.oddcast.cv.util.RotationConverter;
	
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	//import flash.display.Graphics;
	
	import com.oddcast.util.RectangleTools;					 using com.oddcast.util.RectangleTools;
	
	
	class RotationConverter 
	{
		
		public var invMatrix:Matrix;		//converts from RotatedSpace
		public var rotMatrix:Matrix;  		//converts to   RotatedSpace
		
		var unrotatedRect:	Rectangle;
		var scratchPoint:	Point;
		var bEntirelyWithinUnrotated: Bool;  public function setIsEntirelyWithinUnrotated() { bEntirelyWithinUnrotated = true;}
		
		public function new(
							invMatrix			: Matrix,
							zUnrotatedRect		: Rectangle
							) {
			this.invMatrix = invMatrix.clone();
			rotMatrix = invMatrix.clone();
			rotMatrix.invert();
			unrotatedRect = zUnrotatedRect.clone();
			//unrotatedRect.x += 80; unrotatedRect.width -= 160;	unrotatedRect.y += 60; unrotatedRect.height -= 120;		trace("[ALWAYS] " + unrotatedRect.toString() + "   " + zUnrotatedRect.toString());
			scratchPoint = new Point();
			bEntirelyWithinUnrotated = false;
		}
		
		public function getNonRotatedDeviceRect():Rectangle { return unrotatedRect;}

		public function convertFromRotated(rotatedPoint:Point):Point {
			return invMatrix.transformPoint(rotatedPoint);
		}
		
		//version of above that convertst the incoming point - use with care
		public function convertFromRotatedProvided(rotatedPoint:Point) {
			var x = rotatedPoint.x;
			var y = rotatedPoint.y;
			rotatedPoint.x = invMatrix.a * x + invMatrix.c * y + invMatrix.tx;
			rotatedPoint.y = invMatrix.b * x + invMatrix.d * y + invMatrix.ty;
		}
		
		
		public function convertToRotated(imagePoint:Point):Point {
			return rotMatrix.transformPoint(imagePoint);
		}
		
		
		public function convertRectFromRotated(rotatedRect:Rectangle):Rectangle {
			return rotatedRect.applyMatrix(invMatrix);
		}
		
		public function convertRectToRotated(unrotatedRect:Rectangle):Rectangle {
			return unrotatedRect.applyMatrix(rotMatrix);
		}
		
		
		public function rectIsInUnrotated(rect:Rectangle):Bool {  
			if (bEntirelyWithinUnrotated)
				return true;

		//	invMatrix = new Matrix(0.34, 0.23, 0.45, 0.55, 0.66, 0.77);
			rect.getCenterPointProvided(scratchPoint);
			var unrotatedCenterPoint = convertFromRotated(scratchPoint);
			//convertFromRotatedProvided(scratchPoint);
			return unrotatedRect.containsPoint(unrotatedCenterPoint);
			//return false;
		}
	}


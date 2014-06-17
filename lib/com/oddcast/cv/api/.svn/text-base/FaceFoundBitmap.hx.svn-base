
/**
 * ...
 * @author Jake Lewis
 * copyright Oddcast Inc. 2010  All rights reserved
 * 4/26/2010 12:09 PM
 **/

package  com.oddcast.cv.api;
//import com.oddcast.cv.api.FaceFoundBitmap;

	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	typedef Sections = Array<Array<Point>>
	 
	class FaceFoundBitmap extends Bitmap
	{
		
		
		//set data
		//var bTrans				:Bool;
		public var blurWidth		:Float;  // amount of blur to apply to face  0 = none,  1 = much, default = DEFAULT_BLUR_WIDTH;
		public var faceSize			:Float;  // the relative size of the cutout face. default = DEFAULT_FACE_SIZE;
		public var faceAspect		:Float;	 // the aspect ratio of the cutout face.  default = DEFAULT_FACE_ASPECT;
		
		inline public static var DEFAULT_BLUR_WIDTH  = 0.25;
		inline public static var DEFAULT_FACE_SIZE   = 1.0;
		inline public static var DEFAULT_FACE_ASPECT = 1.25;
		
		//public static var DEFAULT_SECTIONS = FACE_OUTLINE_SECTIONS;
		
		
		//returned data:
		inline public static var ERROR_CODE_NONE  					= 0;
		inline public static var ERROR_CODE_FACE_NOT_FOUND 			= 1;
		
		public var errorCode	:Int;
		public var position		:Point;
		public var sections		:Sections;
		public var applicationString	:String;
		public var bShared		:Bool;
		
		
		public function new(deprecated:Bool=true ) 
		{
			super(new BitmapData(1, 1, true), PixelSnapping.AUTO, true);  //create a temporary placeholder
			//this.bTrans = bTrans;
			position = new Point();
			setSections(FACE_OUTLINE_SECTIONS);
			blurWidth  = DEFAULT_BLUR_WIDTH;
			faceSize   = DEFAULT_FACE_SIZE;
			faceAspect = DEFAULT_FACE_ASPECT;
		}
		
		
		
		public function setSections(sections:Sections) {
			this.sections = sections;
		}
		
		public function setSectionsRectangle(rectangle:Rectangle) {
			setSections(
				[
					[new Point(rectangle.left, rectangle.top)],
					[new Point(rectangle.right, rectangle.top)],
					[new Point(rectangle.right, rectangle.bottom)],
					[new Point(rectangle.left, rectangle.bottom)],
					[new Point(rectangle.left, rectangle.top)],
				]
			);
		}
		
		public static var FACE_OUTLINE_SECTIONS:Sections = [//
					[new Point(0.5, 1.0)],
					[new Point(0.0, 0.45), new Point(0.1, 1.0)],
					[new Point(0.0, 0.3)],
					[new Point(0.45, 0.0), new Point(0.0, 0.0)],		
					[new Point(0.55, 0.0)],		
					[new Point(1.0, 0.3), new Point(1.0, 0.0)],
					[new Point(1.0, 0.45)],
					[new Point(0.5, 1.0), new Point(0.9, 1.0)]
				];
		
		public static var EYES_RECTANGLE:Int = 0;
		public static var SKIN_COLOR_RECTANGLE:Int = 1;
		
		
		public function getPremadeRectangle(index:Int):Rectangle {
			switch index {
				case EYES_RECTANGLE: 		return new Rectangle(0.0, 0.075, 1.0, 0.2);
				case SKIN_COLOR_RECTANGLE:  return new Rectangle(0.4, 0.25,  0.2, 0.2);
				default: throw "Unknown Premade Rectangle:" + index;
			}
		}
		
		
		public function cutOutArea(rect:Rectangle, returnBitmapData:BitmapData=null):BitmapData{
		
			var xScale = bitmapData.width;
			var yScale = bitmapData.height;
			var sourceRect = new Rectangle( rect.x * xScale, 
											rect.y * yScale,
											rect.width * xScale,
											rect.height * yScale);
			if (returnBitmapData == null) {
				returnBitmapData = new BitmapData(Std.int(sourceRect.width), Std.int(sourceRect.height), false, 0);
			}
			
			var scaleX =  returnBitmapData.width / sourceRect.width;
			var scaleY =  returnBitmapData.height / sourceRect.height;
			var matrix = new Matrix(scaleX, 0,
									0, scaleY,
									-sourceRect.x*scaleX,
									-sourceRect.y * scaleY);
									
			returnBitmapData.draw(bitmapData,  
								matrix
								,null  //color transform
								,null  //BlendMode string
								,null 
								,true   //smoothing
								);
			
			return returnBitmapData; 	
		}
		
		
		//------------------------Internal methods and variables - should NOT be called from workshop ---------------------------------
		
		
		
		public function createBitmapData(width:Int, height:Int, bTrans:Bool, color:UInt = 0xFFFFFF) {
			clearCurrent();
			bitmapData = new BitmapData(width, height, bTrans, color);
	
		}
		
		public function cloneBitmapData(inBitmapData:BitmapData) {
			clearCurrent();
			bitmapData = inBitmapData.clone();
		}
		
		public function shareBitmapData(inBitmapData:BitmapData) {
			
			clearCurrent();
			bitmapData = inBitmapData;
			bShared = true;
		}
		
		public function setBitmapData(inBitmapData:BitmapData) {
			
			clearCurrent();
			bitmapData = inBitmapData;
		}
		
		
		public function clearCurrent() {
			if(!bShared){
				if (bitmapData != null)  //destroy the old one.
					bitmapData.dispose();
			}
			bitmapData = null;
			bShared = false;
		}
		
		public function dispose():Void {
			clearCurrent();
		}
		
	}
	

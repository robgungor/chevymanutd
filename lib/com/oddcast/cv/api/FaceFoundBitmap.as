

//----------- THIS FILE IS MACHINE GENERATED (changes will be overwritten) ----------- 


package com.oddcast.cv.api {
	import flash.display.PixelSnapping;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	
	public class FaceFoundBitmap extends flash.display.Bitmap {
		public function FaceFoundBitmap(deprecated : Boolean = true) : void {  {
			super(new flash.display.BitmapData(1,1,true),flash.display.PixelSnapping.AUTO,true);
			this.position = new flash.geom.Point();
			this.setSections(FACE_OUTLINE_SECTIONS);
			this.blurWidth = 0.25;
			this.faceSize = 1.0;
			this.faceAspect = 1.25;
		}}
		
		public var blurWidth : Number;
		public var faceSize : Number;
		public var faceAspect : Number;
		public var errorCode : int;
		public var position : flash.geom.Point;
		public var sections : Array;
		public var applicationString : String;
		public var bShared : Boolean;
		public function setSections(sections : Array) : void {
			this.sections = sections;
		}
		
		public function setSectionsRectangle(rectangle : flash.geom.Rectangle) : void {
			this.setSections([[new flash.geom.Point(rectangle.left,rectangle.top)],[new flash.geom.Point(rectangle.right,rectangle.top)],[new flash.geom.Point(rectangle.right,rectangle.bottom)],[new flash.geom.Point(rectangle.left,rectangle.bottom)],[new flash.geom.Point(rectangle.left,rectangle.top)]]);
		}
		
		public function getPremadeRectangle(index : int) : flash.geom.Rectangle {
			switch(index) {
			case EYES_RECTANGLE:{
				return new flash.geom.Rectangle(0.0,0.075,1.0,0.2);
			}break;
			case SKIN_COLOR_RECTANGLE:{
				return new flash.geom.Rectangle(0.4,0.25,0.2,0.2);
			}break;
			default:{
				throw "Unknown Premade Rectangle:" + index;
			}break;
			}
		}
		
		public function cutOutArea(rect : flash.geom.Rectangle,returnBitmapData : flash.display.BitmapData = null) : flash.display.BitmapData {
			var xScale : int = this.bitmapData.width;
			var yScale : int = this.bitmapData.height;
			var sourceRect : flash.geom.Rectangle = new flash.geom.Rectangle(rect.x * xScale,rect.y * yScale,rect.width * xScale,rect.height * yScale);
			if(returnBitmapData == null) {
				returnBitmapData = new flash.display.BitmapData(int(sourceRect.width),int(sourceRect.height),false,0);
			}
			var scaleX : Number = returnBitmapData.width / sourceRect.width;
			var scaleY : Number = returnBitmapData.height / sourceRect.height;
			var matrix : flash.geom.Matrix = new flash.geom.Matrix(scaleX,0,0,scaleY,-sourceRect.x * scaleX,-sourceRect.y * scaleY);
			returnBitmapData.draw(this.bitmapData,matrix,null,null,null,true);
			return returnBitmapData;
		}
		
		public function createBitmapData(width : int,height : int,bTrans : Boolean,color : uint = 16777215) : void {
			this.clearCurrent();
			this.bitmapData = new flash.display.BitmapData(width,height,bTrans,color);
		}
		
		public function cloneBitmapData(inBitmapData : flash.display.BitmapData) : void {
			this.clearCurrent();
			this.bitmapData = inBitmapData.clone();
		}
		
		public function shareBitmapData(inBitmapData : flash.display.BitmapData) : void {
			this.clearCurrent();
			this.bitmapData = inBitmapData;
			this.bShared = true;
		}
		
		public function setBitmapData(inBitmapData : flash.display.BitmapData) : void {
			this.clearCurrent();
			this.bitmapData = inBitmapData;
		}
		
		public function clearCurrent() : void {
			if(!this.bShared) {
				if(this.bitmapData != null) this.bitmapData.dispose();
			}
			this.bitmapData = null;
			this.bShared = false;
		}
		
		public function dispose() : void {
			this.clearCurrent();
		}
		
		static public var DEFAULT_BLUR_WIDTH : Number = 0.25;
		static public var DEFAULT_FACE_SIZE : Number = 1.0;
		static public var DEFAULT_FACE_ASPECT : Number = 1.25;
		static public var ERROR_CODE_NONE : int = 0;
		static public var ERROR_CODE_FACE_NOT_FOUND : int = 1;
		static public var FACE_OUTLINE_SECTIONS : Array = [[new flash.geom.Point(0.5,1.0)],[new flash.geom.Point(0.0,0.45),new flash.geom.Point(0.1,1.0)],[new flash.geom.Point(0.0,0.3)],[new flash.geom.Point(0.45,0.0),new flash.geom.Point(0.0,0.0)],[new flash.geom.Point(0.55,0.0)],[new flash.geom.Point(1.0,0.3),new flash.geom.Point(1.0,0.0)],[new flash.geom.Point(1.0,0.45)],[new flash.geom.Point(0.5,1.0),new flash.geom.Point(0.9,1.0)]];
		static public var EYES_RECTANGLE : int = 0;
		static public var SKIN_COLOR_RECTANGLE : int = 1;
	}
}

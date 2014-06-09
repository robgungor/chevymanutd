/**
* ...
* @author Sam Myer
* @version 1.0
* 
* This is the dynamic mask class.  There are 3 ways to make an instance of this class:
* 
* 1. Create a new instance of this class using code:
* new BGMask(bounds, numPoints) where
* bounds - is a Rectangle specifying the maximum extent to which the points can be moved
* numPoints - the number of points to be created
* Calling the contructor will generate and place the points in an ellipse shape within the bounds specified
* If you don't specify the bounds, it they will be set to a 225x300 rectangle by default
* 
* 2. Create a movieclip with class BGMask on the stage (without points).
* To do this:
* i. Make a movieclip of class BGMask
* ii. To set the mask size, add a sprite within that movieclip and call it boundsMC.
* The points will be placed in an ellipse centered in the boundsMC clip.  You won't be able to move the points
* past the limits of the boundsMC clip.
* 
* 3. Create a movieclip with class BGMask on the stage with points
* To do this, do everything in step 2
* Add another sprite inside the BGMask clip called "pointsMC"
* Within pointsMC, place a number of sprites which will be the anchor points for the mask.  They can have
* whatever art you want.  Just make sure they are subclasses of Sprite (and not SimpleButton).  You don't
* have to name them anything particular.
* The display tree will look like:
* 
*          /-------boundsMC(a Sprite containing a rectangle)
* myBGMask<                    /----(Sprite - point graphic)
*          \-------pointsMC---<----(Sprite)
*                              \----(Sprite)
*                               \--etc. 
* 
* 
* You can change how the mask outline is drawn in the redrawShape function
* 
* FUNCTIONS:
* getPoints() - returns an array of type Point representing the coordinates of the mask anchor points
* setPoints(ptArr) - where ptArr is an array of Points - sets the coordinates of the mask anchor points
*/

package workshop.uploadphoto {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BGMask extends Sprite {	
		[Inspectable (type = Color, defaultValue=0x000000)]public var outlineColor:uint = 0;
		public var boundsMC:Sprite;
		public var pointsMC:Sprite;
		public var outline:Sprite;
		public var fill:Sprite;
		private var points:Array;
		
		private var bounds:Rectangle;
		
		public function BGMask(in_bounds:Rectangle=null,numPoints:uint=6) {
			addEventListener(Event.ADDED_TO_STAGE, added, false, 0, true);
			
			outline=new Sprite();
			fill=new Sprite();
			addChildAt(outline,0);
			addChildAt(fill,0);
			//fill.visible = false;
			
			bounds = in_bounds;
			if (bounds != null) {
				if (boundsMC != null) removeChild(boundsMC);
				boundsMC = createSpriteWithRect(bounds);
			}
			else if (boundsMC==null) {
				bounds = new Rectangle(0, 0, 225, 300);
				boundsMC = createSpriteWithRect(bounds);
			}
			else {
				bounds = boundsMC.getRect(this);
			}
			boundsMC.visible=false;
			if (pointsMC == null) generatePoints(bounds,numPoints);
			else getPointsFromMC(pointsMC);
			redrawShape();
		}
		
		private function createSpriteWithRect(rect:Rectangle):Sprite {
			var s:Sprite = new Sprite();
			s.graphics.lineStyle(0, 0);
			s.graphics.beginFill(0);
			s.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			return(s);
		}
		
		public function generatePoints(in_bounds:Rectangle=null,numPoints:uint=6):void {
			
			pointsMC=new Sprite();
			addChild(pointsMC);
			
			points=new Array();
			
			for (var i:int=0;i<numPoints;i++) {
				var pt:Sprite=createPoint(defaultPos(i,numPoints));
				points.push(pt);
				pointsMC.addChild(pt);				
			}
			addPointListeners();
		}
		
		private function getPointsFromMC(mc:Sprite):void {
			var avgx:Number = 0;
			var avgy:Number = 0;
			var i:int;
			var child:DisplayObject;
			var ptArr:Array = new Array();
			for (i = 0; i < mc.numChildren; i++) {
				child = mc.getChildAt(i);
				if (!(child is Sprite)) continue;
				avgx += child.x;
				avgy += child.y;
				ptArr.push({mc:child})
			}
			avgx /= mc.numChildren;
			avgy /= mc.numChildren;

			for (i = 0; i < ptArr.length; i++) {
				ptArr[i].angle = Math.atan2(ptArr[i].mc.y - avgy, ptArr[i].mc.x - avgx);
			}
			ptArr.sortOn("angle",Array.NUMERIC);
			points = new Array();
			
			for (i = 0; i < ptArr.length; i++) {
				points.push(ptArr[i].mc);
			}
			addPointListeners();
		}
		
		private function added(evt:Event):void {
			loaderInfo.addEventListener(Event.UNLOAD, destroy,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_UP,stopAllDrag);
		}
		
		private function defaultPos(n:int,total:int):Point {
			var ang:Number = n * Math.PI *2/total;
			var radiusX:Number = bounds.width * 0.35;
			var radiusY:Number = bounds.height * 0.35;
			var posX:Number=bounds.x+bounds.width/2+Math.sin(ang)*radiusX;
			var posY:Number=bounds.y+bounds.height/2+Math.cos(ang)*radiusY;
			return(new Point(posX,posY));
		}
		
		private function createPoint(pos:Point):Sprite {
			var pt:Sprite=new Sprite();
			var ptHit:Sprite=new Sprite();
			pt.graphics.lineStyle(1,0);
			pt.graphics.beginFill(0xCCCCCC);
			pt.graphics.drawCircle(0,0,3);
			pt.graphics.endFill();
			
			pt.addChild(ptHit);
			ptHit.visible=false;
			ptHit.graphics.beginFill(0xCCCCCC);
			ptHit.graphics.drawRect(-6,-6,12,12);
			ptHit.graphics.endFill();
			pt.hitArea = ptHit;
			
			pt.x=pos.x;
			pt.y=pos.y;
			
			return(pt);
		}
		
		private function addPointListeners():void {
			var pt:Sprite;
			for (var i:int = 0; i < points.length; i++) {
				pt = points[i] as Sprite;
				pt.addEventListener(MouseEvent.MOUSE_DOWN,pointStartDrag);
				pt.addEventListener(MouseEvent.MOUSE_UP,pointStopDrag);
				pt.addEventListener(MouseEvent.MOUSE_MOVE,pointMoved);				
			}
		}
		
		public function setPoints(ptArr:Array):void {
			for (var i:int=0;i<points.length;i++) {
				points[i].x=ptArr[i].x;
				points[i].y=ptArr[i].y;
			}
			redrawShape();
		}
		
		public function getPoints():Array {
			var ptArr:Array=new Array();
			for (var i:int=0;i<points.length;i++) ptArr.push(getPos(points[i]));
			return(ptArr);
		}
		
		private function pointStartDrag(evt:MouseEvent):void {
			stopAllDrag();
			evt.currentTarget.startDrag(false, bounds);
			if (stage != null) {
				stage.addEventListener(MouseEvent.MOUSE_UP, stopAllDrag);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, pointMoved);
			}
		}
		private function pointStopDrag(evt:MouseEvent):void {
			evt.currentTarget.stopDrag();
			if (stage != null) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, stopAllDrag);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, pointMoved);
			}
		}
		private function pointMoved(evt:MouseEvent):void {
			redrawShape();
		}
		private function stopAllDrag(evt:MouseEvent=null):void {
			for (var i:int = 0; i < points.length; i++) points[i].stopDrag();
			if (stage != null) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, stopAllDrag);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, pointMoved);
			}
		}
		
		private function redrawShape():void {
			outline.graphics.clear();
			fill.graphics.clear();
			if (points.length==0) return;
			
			outline.graphics.lineStyle(1, outlineColor);
			fill.graphics.lineStyle(0);
			fill.graphics.beginFill(0xCCCCCC);
			
			outline.graphics.moveTo(points[0].x,points[0].y);
			fill.graphics.moveTo(points[0].x,points[0].y);
			
			var midpt:Point;
			var endpt:Point;
			for (var i:int=2;i<points.length+1;i+=2) {
				//outline.graphics.lineTo(points[i%points.length].x,points[i%points.length].y);
				//fill.graphics.lineTo(points[i%points.length].x,points[i%points.length].y);
				midpt=Point.interpolate(getPos(points[i-2]),getPos(points[i%points.length]),0.5);
				endpt=Point.interpolate(midpt,getPos(points[i-1]),-1);
				outline.graphics.curveTo(endpt.x,endpt.y,points[i%points.length].x,points[i%points.length].y);
				fill.graphics.curveTo(endpt.x,endpt.y,points[i%points.length].x,points[i%points.length].y);
			}
			
			fill.graphics.endFill();
		}
		
		private function getPos(s:Sprite):Point {
			return(new Point(s.x,s.y));
		}
		
		private function destroy(evt:Event):void {
			stopAllDrag();
			if (loaderInfo!=null) loaderInfo.removeEventListener(Event.UNLOAD, destroy);
			removeEventListener(Event.ADDED_TO_STAGE, added);
			if (points != null) {
				var pt:Sprite;
				for (var i:int = 0; i < points.length; i++) {
					pt = points[i];
					pt.removeEventListener(MouseEvent.MOUSE_DOWN,pointStartDrag);
					pt.removeEventListener(MouseEvent.MOUSE_UP,pointStopDrag);
					pt.removeEventListener(MouseEvent.MOUSE_MOVE,pointMoved);
				}
			}
		}
	}
	
}
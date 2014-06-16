/**
* ...
* @author Sam
* @version 0.1
* 
* Class to handle move/zoom/rotating a sprite - replaces Zoomer AS2 class
* 
* constructor - MoveZoomUtil(sprite) - pass the sprite that will be controlled by this class
* 
* setScaleLimits(min,max) - set minimum and maximum scale values eg setScaleLimits(0.5,2)
*
* 
* ANCHOR : 
* to do scaling/rotation, the mc must be anchored to a center point around which scaling/rotation happens
* this point can either be a point on the mc itself that gets moved when the mc is moved
* or it can be on the mc's parent, in which case it is fixed even when the mc is moved
* 
* setAnchor(x,y,onParent) - if the point is on the MC, x,y, coords are in the mc's coordinate system
* if onParent is set, the coords are in the parent's coordinate system
* 
* anchorTo(mc) - anchors the target to the center another MC.
* If the mc is within the target sprite, onParent will be set to false; otherwise, onParent will be true
* e.g. hostZoomer.anchorTo(hostMask)
* 
* 
* BOUNDS :
* The bounding box limits the target sprite's movement.  This is useful e.g. to keep host within player mask
* 
* setBounds(rectangle,boundType) - mc is bounded by rectangle
* boundBy(sprite,boundType) - mc is bounded by the getBounds() of the sprite
* 
* There are three boundTypes:
* CONTAINER = "contains" - mc stays completely inside bounding box
* MASK_AREA = "intersects" - mc must be at least partly inside bounding box
* CROP_AREA = "containedBy" - mc must fill entire area of bounding box
* also,
* FREE - disable bounding
* 
* CONTAINER:
* _______   ________
* |GOOD  |  |      B|D     
* |______|  |_______|
* 
* 
* MASK_AREA
* _______   ________    _________
* |GOOD  |  |      G|OD |        | BAD
* |______|  |_______|   |________|
* 
*  
* CROP_AREA
* _______   ________    GGG_____GGG
* |BAD   |  |      B|D  OO|OOOOO|OO
* |______|  |_______|   OO|_____|OO
*                       DDDDDDDDDDD
* 
* DRAGGING:
* enableDragging(b) - enable/disable dragging.  the mouse wheel can be used to scale the image
* getCurrentPos - returns MCTransform
* 
* TRANSFORMATION FUNCTIONS:
* moveTo(x,y)  /  scaleTo(scale)  /  rotateTo(degrees)  - sets absolute xformation values
* moveBy(dx,dy)  /  scaleBy(factor)  /  rotateBy(degrees) - transforms by a relative amount
* 
* PROPERTIES:
* scale,rotation [read-only] - absolute values
* matrix - get/set transformation matrix
* 
*/

package com.oddcast.utils {
	import fl.motion.MatrixTransformer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.casalib.events.RemovableEventDispatcher;

	public class MoveZoomUtil extends RemovableEventDispatcher {
		private var mc:Sprite;
		private var anchorPoint:Point=new Point(0,0);
		private var anchorToParent:Boolean=false;
		private var bounds:Rectangle;
		private var boundType:String="none";
		public var minScale:Number=0.1;
		public var maxScale:Number=3;
		private var checkDragAlpha:Boolean=false;
		
		public static const FREE:String="none";
		public static const CONTAINER:String="contains";
		public static const MASK_AREA:String="intersects";
		public static const CROP_AREA:String = "containedBy";
		
		public static const NEW_ITEM_LOADED	:String = 'NEW_ITEM_LOADED';
		public static const SCALE_CHANGED	:String = 'SCALE_CHANGED';
		public static const ITEM_MOVED		:String = 'ITEM_MOVED';
		public static const SCALE_TO_100	:String = 'SCALE_TO_100';
		
		public function MoveZoomUtil(in_mc:Sprite) {
			setTarget(in_mc);
		}
		
		public function setTarget(in_mc:Sprite) : void {
			if (mc != null) enableDragging(false);
			mc=in_mc;
		}
		
		public function getTarget():Sprite {
			return(mc);
		}
		
		public function setScaleLimits(in_minScale:Number,in_maxScale:Number) : void {
			minScale=in_minScale;
			maxScale=in_maxScale;
		}

		private function applyMatrix(m:Matrix) : void {
			if (mc==null) return;
			var mOrig:Matrix=mc.transform.matrix;
			var mFinal:Matrix=new Matrix();
			
			if (anchorToParent) mFinal.concat(mOrig);
			mFinal.translate(-anchorPoint.x,-anchorPoint.y);
			mFinal.concat(m);
			mFinal.translate(anchorPoint.x,anchorPoint.y);
			if (!anchorToParent) mFinal.concat(mOrig);
			
			mc.transform.matrix=mFinal;
			
			//if (mc.scaleX<minScale||mc.scaleX>maxScale) mc.transform.matrix=mOrig;
			//else {
				forceInBounds();
				if (!checkBounds()) mc.transform.matrix=mOrig;
			//}			
		}
		
		public function boundBy(boundMC:DisplayObject,in_type:String="intersects") : void {
			setBounds(boundMC.getBounds(mc.parent),in_type);
		}
		
		public function setBounds(in_bounds:Rectangle,in_type:String) : void 
		{
			bounds=in_bounds;
			boundType=in_type;
		}
		
		public function anchorTo(anchorMC:DisplayObject) : void 
		{
			anchorToParent=!mc.contains(anchorMC);
			var anchBounds:Rectangle=anchorMC.getBounds(anchorToParent?mc.parent:mc);
			anchorPoint=Point.interpolate(anchBounds.topLeft,anchBounds.bottomRight,0.5);
		}
		
		public function setAnchor(anchX:Number,anchY:Number,onParent:Boolean=false) : void
		{
			anchorPoint=new Point(anchX,anchY);
			anchorToParent=onParent;
		}
		
		private function checkBounds():Boolean {
			var mcBounds:Rectangle=mc.getBounds(mc.parent);
			if (boundType==CONTAINER) return(bounds.containsRect(mcBounds));
			else if (boundType==MASK_AREA) return(bounds.intersects(mcBounds));
			else if (boundType==CROP_AREA) return(mcBounds.containsRect(bounds));
			else return(true);
		}
		
		public function forceInBounds() : void
		{
			if (checkBounds()) return;
			var mcBounds:Rectangle=mc.getBounds(mc.parent);
			mcBounds.left++;
			mcBounds.top++;
			mcBounds.right--;
			mcBounds.bottom--;
			if ( boundType == CONTAINER ) {
				if (mcBounds.bottom-bounds.bottom>0) mc.y-=mcBounds.bottom-bounds.bottom;
				if (mcBounds.right-bounds.right>0) 	mc.x-=mcBounds.right-bounds.right;
				if (mcBounds.top-bounds.top<0) 		mc.y-=mcBounds.top-bounds.top;
				if (mcBounds.left-bounds.left<0) 	mc.x-=mcBounds.left-bounds.left;
			}
			else if (boundType==MASK_AREA) {
				if (mcBounds.top-bounds.bottom>0) mc.y-=mcBounds.top-bounds.bottom;
				if (mcBounds.left-bounds.right>0) mc.x-=mcBounds.left-bounds.right;
				if (mcBounds.bottom-bounds.top<0) mc.y-=mcBounds.bottom-bounds.top;
				if (mcBounds.right-bounds.left<0) mc.x-=mcBounds.right-bounds.left;
			}
			else if (boundType==CROP_AREA) {
				if (mcBounds.bottom-bounds.bottom<0) mc.y+=mcBounds.bottom-bounds.bottom;
				if (mcBounds.right-bounds.right<0) mc.x+=mcBounds.right-bounds.right;
				if (mcBounds.top-bounds.top>0) mc.y-=mcBounds.top-bounds.top;
				if (mcBounds.left-bounds.left>0) mc.x-=mcBounds.left-bounds.left;
			}
		}
		
		private function getMovementBounds():Rectangle {
			var xDiff:Number=mc.x-mc.getBounds(mc.parent).left;
			var yDiff:Number=mc.y-mc.getBounds(mc.parent).top;
			var boundRect:Rectangle;
			if (boundType==CONTAINER) {
				boundRect=new Rectangle(bounds.left,bounds.top,bounds.width-mc.width,bounds.height-mc.height);
			}
			else if (boundType==MASK_AREA) {
				boundRect=new Rectangle(bounds.left-mc.width,bounds.top-mc.height,bounds.width+mc.width,bounds.height+mc.height);
			}
			else if (boundType==CROP_AREA) {
				boundRect=new Rectangle(bounds.left-(mc.width-bounds.width),bounds.top-(mc.height-bounds.height),mc.width-bounds.width,mc.height-bounds.height);
			}
			if (boundRect==null) return(null);
			boundRect.offset(xDiff,yDiff);
			return(boundRect);
		}
		
		public function scaleTo(newScale:Number) : void
		{
			scaleBy(newScale/mc.scaleX);
		}
		
		public function scaleBy(scaleAmt:Number) : void
		{
			var m:Matrix=new Matrix();
			m.scale(scaleAmt,scaleAmt);
			applyMatrix(m);
			dispatchEvent(new Event(SCALE_CHANGED));
		}
		
		public function rotateTo(newRotation:Number) : void
		{
			rotateBy(newRotation-mc.rotation);
		}
		
		public function rotateBy(rotateAmt:Number) : void {
			var m:Matrix=new Matrix();
			m.rotate(rotateAmt*Math.PI/180);
			applyMatrix(m);
		}
		
		public function moveTo(newX:Number,newY:Number) : void {
			mc.x=newX;
			mc.y=newY;
			forceInBounds();
		}
		
		public function moveBy(dx:Number,dy:Number) : void {
			mc.x+=dx;
			mc.y+=dy;
			forceInBounds();
		}
		
		public function enableDragging(b:Boolean=true,doCheckAlpha:Boolean=false) : void {
			if (mc==null) return;
			if (b) {
				if (mc.loaderInfo)
					mc.loaderInfo.addEventListener(Event.UNLOAD, mcUnloaded);
				mc.addEventListener(MouseEvent.MOUSE_DOWN,startDrag);
				mc.addEventListener(MouseEvent.MOUSE_UP, stopDrag);
				try {
					mc.stage.addEventListener(MouseEvent.MOUSE_UP, stopDrag);
				}
				catch (err:Error) {
					//if you can't listen to mouse release events on the stage
					//(because it is loaded in a shell with no allowDomain),
					//stop dragging when the mouse leaves the movieclip
					mc.addEventListener(MouseEvent.MOUSE_OUT, stopDrag);
				}
				mc.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheel);
				checkDragAlpha=doCheckAlpha;
			}
			else {
				mc.removeEventListener(MouseEvent.MOUSE_DOWN,startDrag);
				mc.removeEventListener(MouseEvent.MOUSE_UP,stopDrag);
				try 
				{
					mc.stage.removeEventListener(MouseEvent.MOUSE_UP,stopDrag);
				}
				catch (err:Error) 
				{
					mc.removeEventListener(MouseEvent.MOUSE_OUT, stopDrag);					
				}
				mc.removeEventListener(MouseEvent.MOUSE_WHEEL,mouseWheel);				
			}
		}
		
		private function checkAlpha():Boolean {
			var mcbounds:Rectangle=mc.getRect(mc);
			var bd:BitmapData=new BitmapData(mcbounds.width,mcbounds.height);
			var m:Matrix=new Matrix();
			m.translate(-mcbounds.left,-mcbounds.top);
			//bd.draw(mc,m);
			bd.draw(mc,m,null,BlendMode.ALPHA);
			//mc.stage.addChild(new Bitmap(bd));
			var argb:uint=bd.getPixel32(mc.mouseX-mcbounds.left,mc.mouseY-mcbounds.top);
			//trace("checkAlpha : "+(argb>0)+" -- "+argb.toString(16))
			//trace("mc.rect="+mcbounds+"  bmp mouse="+[mc.mouseX-mcbounds.left,mc.mouseY-mcbounds.top]);
			return(argb>0);
		}
		
		private function startDrag(evt:MouseEvent) : void {
			//trace("checkDragAlpha = "+checkDragAlpha+" - bounds="+mc.getRect(mc));
			if (!checkDragAlpha||checkAlpha()) mc.startDrag(false,getMovementBounds());
		}
		private function stopDrag(evt:Event) : void {
			mc.stopDrag();
			dispatchEvent(new Event(ITEM_MOVED));
		}
		
		private function mouseWheel(evt:MouseEvent) : void {
			if (evt.target!=mc) return;
			
			if (evt.delta<0) scaleBy(1.11);
			else if (evt.delta>0) scaleBy(0.9);
			dispatchEvent(new Event(SCALE_CHANGED));
		}
		
		
		public function set x(n:Number) : void {
			mc.x = n;
		}
		
		public function get x():Number {
			return(mc.x);
		}
		
		public function set y(n:Number) : void {
			mc.y = n;
		}
		
		public function get y():Number {
			return(mc.y);
		}
		
		public function get scale():Number {
			return(mc.scaleX);
		}
		
		public function set scale(n:Number) : void { //use scaleTo instead
			mc.scaleX = mc.scaleY = n;
			dispatchEvent(new Event(SCALE_CHANGED));
		}
		
		public function get rotation():Number {
			return(mc.rotation);
		}
		
		public function set rotation(n:Number) : void { //use rotateTo instead
			mc.rotation = n;
			
		}
		
		public function get matrix():Matrix {
			return(mc.transform.matrix);
		}
		
		public function set matrix(m:Matrix) : void {
			mc.transform.matrix=m;
		}
		
		/*takes a Matrix and transforms it into an object of type {x,y,scaleX,scaleY,rotation};*/
		public static function matrixToObject(m:Matrix) : Object {
			var o:Object = new Object();
			o.x = m.tx;
			o.y = m.ty;
			o.scaleX = MatrixTransformer.getScaleX(m);
			o.scaleY = MatrixTransformer.getScaleY(m);
			o.rotation = MatrixTransformer.getRotation(m);
			return(o);
		}
		
		/*takes an object of type {x,y,scaleX,scaleY,rotation} and transforms it into a Matrix*/
		public static function objectToMatrix(o:Object):Matrix {
			if (o == null) return null;
			if (o.x == null||isNaN(o.x)) o.x = 0;
			if (o.y == null||isNaN(o.y)) o.y = 0;
			if (o.scaleX == null && o.scaleY == null && o.scale != null) {
				o.scaleX = o.scale;
				o.scaleY = o.scale;
			}
			if (o.scaleX == null||isNaN(o.scaleX)) o.scaleX = 1;
			if (o.scaleY == null||isNaN(o.scaleY)) o.scaleY = 1;
			if (o.rotation == null||isNaN(o.rotation)) o.rotation = 0;
			var m:Matrix = new Matrix();
			m.scale(o.scaleX, o.scaleY);
			m.rotate(o.rotation);
			m.translate(o.x, o.y);
			return(m);
		}
		
		public function new_item_loaded():void
		{	dispatchEvent(new Event(NEW_ITEM_LOADED));
		}
		
		public function scale_to_100():void
		{	dispatchEvent(new Event(SCALE_TO_100));
		}
		
		//--------destroy------
		private function mcUnloaded(evt:Event) : void {
			if (mc == null) return;
			if (mc.loaderInfo)
				mc.loaderInfo.removeEventListener(Event.UNLOAD, mcUnloaded);
			mc.removeEventListener(MouseEvent.MOUSE_DOWN,startDrag);
			mc.removeEventListener(MouseEvent.MOUSE_UP, stopDrag);
			mc.removeEventListener(MouseEvent.MOUSE_OUT, stopDrag);
			mc.removeEventListener(MouseEvent.MOUSE_WHEEL,mouseWheel);
			try {
				mc.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDrag);
			}
			catch (err:SecurityError) {}
		}
	}
	
}
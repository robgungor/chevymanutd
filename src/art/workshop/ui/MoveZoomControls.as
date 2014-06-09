/**
* ...
* @author Sam Myer
* @version 0.1
* 
* This class is associated with the move zoom controls UI.  It works with the MoveZoomUtil class.  If you set the
* pressAndHoldEnabled property of the BaseButtons to true, you can press and hold the buttons to have the image
* continuously move/zoom.  
* 
* usage:
* say you want to have these controls affect a Sprite called targetImage
* 
* var zoomer:MoveZoomUtil=new MoveZoomUtil(targetImage);
* myMoveZoomControls.setTarget(zoomer);
* 
* @see com.oddcast.utils.MoveZoomUtil
*/

package workshop.ui {
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.Slider;
	import com.oddcast.utils.MoveZoomUtil;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	//import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;

	public class MoveZoomControls extends MovieClip {
		private static var moveAmt:Number=4;
		private static var zoomSteps:int=50;
		private static var zoomAmt:Number;
		
		public var upBtn:BaseButton;
		public var downBtn:BaseButton;
		public var leftBtn:BaseButton;
		public var rightBtn:BaseButton;
		public var resetBtn:SimpleButton;
		public var zoomInBtn:BaseButton;
		public var zoomOutBtn:BaseButton;
		public var rotateLeftBtn:BaseButton;
		public var rotateRightBtn:BaseButton;
		public var zoomSlider:Slider;
		
		private var zoomer:MoveZoomUtil;
		private var startPos:Matrix;
		private var cur_item_orig_pos:Matrix;
		private var mc:Sprite;
		
		public function MoveZoomControls() {			
			upBtn.addEventListener(MouseEvent.MOUSE_DOWN,moveUp);
			downBtn.addEventListener(MouseEvent.MOUSE_DOWN,moveDown);
			leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,moveLeft);
			rightBtn.addEventListener(MouseEvent.MOUSE_DOWN, moveRight);
			if (rotateLeftBtn != null) {
				rotateLeftBtn.addEventListener(MouseEvent.MOUSE_DOWN, rotateLeft);
				rotateLeftBtn.addEventListener(BaseButton.MOUSE_HOLD,rotateLeft);
			}
			if (rotateRightBtn != null) {
				rotateRightBtn.addEventListener(MouseEvent.MOUSE_DOWN, rotateRight);
				rotateRightBtn.addEventListener(BaseButton.MOUSE_HOLD,rotateRight);
			}
			
			zoomInBtn.addEventListener(MouseEvent.MOUSE_DOWN,zoomIn);
			zoomOutBtn.addEventListener(MouseEvent.MOUSE_DOWN,zoomOut);
			
			upBtn.addEventListener(BaseButton.MOUSE_HOLD,moveUp);
			downBtn.addEventListener(BaseButton.MOUSE_HOLD,moveDown);
			leftBtn.addEventListener(BaseButton.MOUSE_HOLD,moveLeft);
			rightBtn.addEventListener(BaseButton.MOUSE_HOLD,moveRight);
			
			zoomInBtn.addEventListener(BaseButton.MOUSE_HOLD,zoomIn);
			zoomOutBtn.addEventListener(BaseButton.MOUSE_HOLD,zoomOut);
			
			resetBtn.addEventListener(MouseEvent.CLICK,resetPos);
			
			zoomSlider.addEventListener(ScrollEvent.SCROLL,zoomScroll);
		}
		
		public function save_cur_pos(  ):void 
		{	cur_item_orig_pos = zoomer.matrix.clone();
		}
		
		public function setTarget(in_zoomer:MoveZoomUtil):void {
			zoomer=in_zoomer;
			startPos = zoomer.matrix.clone();
			cur_item_orig_pos = zoomer.matrix.clone();
			zoomSlider.percent=scaleToPercent(zoomer.scale);
			zoomer.addEventListener(MoveZoomUtil.SCALE_CHANGED, scaleChanged);
			zoomer.addEventListener(MoveZoomUtil.NEW_ITEM_LOADED, new_item_loaded);
			zoomer.addEventListener(MoveZoomUtil.SCALE_TO_100, scale_to_100);
			zoomAmt=Math.pow(zoomer.maxScale/zoomer.minScale,1/(zoomSteps-1));
		}
		
		//-----------callbacks------------
		
		private function new_item_loaded( _e:Event ):void 
		{	cur_item_orig_pos = zoomer.matrix.clone();
		}
		
		private function scale_to_100( _e:Event ):void
		{	cur_item_orig_pos = startPos.clone();
			zoomer.matrix = startPos.clone();
		}
		
		private function moveUp(evt:MouseEvent):void {
			zoomer.moveBy(0,-moveAmt);
		}
		private function moveDown(evt:MouseEvent):void {
			zoomer.moveBy(0,moveAmt);
		}
		private function moveLeft(evt:MouseEvent):void {
			zoomer.moveBy(-moveAmt,0);
		}
		private function moveRight(evt:MouseEvent):void {
			zoomer.moveBy(moveAmt,0);
		}
		
		private function rotateLeft(evt:MouseEvent):void {
			zoomer.rotateBy( -5);
		}
	
		private function rotateRight(evt:MouseEvent):void {
			zoomer.rotateBy(5);
		}
		
		private function zoomIn(evt:MouseEvent):void {
			zoomer.scaleBy(zoomAmt);
		}
		private function zoomOut(evt:MouseEvent):void {
			zoomer.scaleBy(1/zoomAmt);
		}
		private function zoomScroll(evt:ScrollEvent):void {
			zoomer.scaleTo(percentToScale(evt.percent));
		}
		
		
		public function resetPos(evt:MouseEvent=null):void {
			// zoomer.matrix = startPos;				// reset everything to 100%
			zoomer.matrix = cur_item_orig_pos.clone();	// reset it to the way the image looked when it was first loaded
		}
		
		//-------------------------------
		
		private function scaleChanged(evt:Event):void {
			zoomSlider.percent=scaleToPercent(zoomer.scale);
		}
		
		private function scaleToPercent(n:Number):Number {
			return(Math.log(n/zoomer.minScale)/Math.log(zoomer.maxScale/zoomer.minScale));
		}
		
		private function percentToScale(n:Number):Number {
			return(zoomer.minScale*Math.pow(zoomer.maxScale/zoomer.minScale,n));
		}
	}
	
}
/**
* @author Sam Myer, Me^
* @version 2.0
* 
* This is the new Slider class - a combination of slider and scrollbar
* Some notes about the assets:
* -upBtn and downBtn are optional
* -the dragger is positioned around _mcDragger's registration so make sure the registration point
* is in the center of the art and not the topleft corner
* -the track is set up so that the registration point should be on the left/top end of the track
* 
* @usage
* Movieclips:
* _mcTrack - MovieClip or BaseButton
* _mcDragger - either BaseButton or SimpleButton
* upBtn, downBtn - optional -- either BaseButtons or SimpleButtons
* 
* Static Properties:
* totalSteps - total number of steps - this affects how much the scrollbar moves when you click the down buton
* 
* orientation (component inspector) - whether it is horizontal or vertical.
* when orientation="auto" it sets the direction horizontal is _mcTrack.width>_mcTrack.height
* 
* use_dragger_width (component inspaector) - 
* when false, the center of the dragger is pinned to the track, and edges of the dragger can extend past the track
* when true, the whole dragger MC is pinned to the track
* 
* snapToStep - when this is true, rounds percent value to nearest step (false by default)
* eg if totalSteps=3 returns values 0,0.5,1
*
* mouseWheelEnabled - user can scroll using the mouse wheel (false by default)
* 
* trackSize
* scrollbar_height/setScrollBarHeight(n) - sets entire scrollbar height including up and down buttons
* 
* draggerSize - value from 0 to 1 = size of dragger as percentage of track size
* 
* minDraggerSize = minimum dragger size in pixels
* 
* 
* Dynamic Properties:
* 
* percent - a value between 0 and 1 that represents the position of the dragger along the track
* 
* step - an integer value from 0 to totalSteps-1
* eg if totalSteps=3, track is divided into 3 thirds and step will return values 0,1,2
* NOTE : by default totalSteps=0 and the value of step is always 0
* 
* Events:
* ScrollEvent.SCROLL - contains percent and step, called whenever scroll value is changed
* ScrollEvent.RELEASE - called when scroll dragger is released
*/

package com.oddcast.ui {
	import com.oddcast.event.ScrollEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;

	public class Slider extends MovieClip {
		public var _mcTrack:MovieClip;
		public var _mcDragger:InteractiveObject;
		public var upBtn:InteractiveObject;
		public var downBtn:InteractiveObject;
		
		protected var dragging:Boolean;
		protected var minPos:Number, maxPos:Number
		private var clickPos:Number; //position on the dragger where mouse was clicked
		protected var origX:Number, origY:Number;
		protected var curPercent:Number=0;
		
		protected var _nSteps:uint;
		protected var isHoriz:Boolean=false;
		protected var useDraggerWidth:Boolean=true;
		protected var _nDraggerSize:Number=0;
		[Inspectable(type=Boolean, defaultValue=false)] public var mouseWheelEnabled:Boolean;
		[Inspectable(type=Boolean, defaultValue=false)] public var snapToStep:Boolean;
		[Inspectable (defaultValue=false)]public var disableDraggerResize:Boolean=true;
		[Inspectable (defaultValue = 5)]public var minDraggerSize:Number = 5;

		
		//*************************************************************************************
		//*********************************     INITIALIZE     ********************************
		//*************************************************************************************
		
		public function Slider() : void {
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			
			if (_mcTrack==null||_mcDragger==null) {
				trace("track or dragger missing");
				return;
			}
			
			_mcTrack.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheel,false,0,true);
			_mcDragger.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheel,false,0,true);
			
			_mcDragger.addEventListener(MouseEvent.MOUSE_DOWN,dragPressed,false,0,true);
			_mcDragger.addEventListener(MouseEvent.MOUSE_UP,dragReleased,false,0,true);
			_mcTrack.addEventListener(MouseEvent.MOUSE_DOWN,trackPressed,false,0,true);
			_mcTrack.addEventListener(MouseEvent.MOUSE_UP,trackReleased,false,0,true);
			_mcTrack.useHandCursor=false;			
			_nSteps=0;
			dragging=false;
			origX=_mcDragger.x;
			origY=_mcDragger.y;
			orientation = "auto";
			initMinMax();
			if (hasButtons) {
				(upBtn as BaseButton).pressAndHoldEnable = true;
				(downBtn as BaseButton).pressAndHoldEnable = true;
				upBtn.addEventListener(MouseEvent.MOUSE_DOWN,scrollUp,false,0,true);
				downBtn.addEventListener(MouseEvent.MOUSE_DOWN,scrollDown,false,0,true);
				upBtn.addEventListener(MouseEvent.MOUSE_UP,scrollReleased,false,0,true);
				downBtn.addEventListener(MouseEvent.MOUSE_UP,scrollReleased,false,0,true);
				upBtn.addEventListener(BaseButton.MOUSE_HOLD,scrollUp,false,0,true);
				downBtn.addEventListener(BaseButton.MOUSE_HOLD, scrollDown,false,0,true);
			}
			addEventListener(KeyboardEvent.KEY_UP, onKeyPressed);
		}		
		
		//*************************************************************************************
		//*********************************    PROPERTIES     *********************************
		//*************************************************************************************
		
		public function get step():uint {
			var step_var:uint = percentToStep(getRawPercent()) 
			return step_var;
		}
		
		public function set step(stepNum:uint) : void {
			if (stepNum<0||stepNum>=_nSteps) return;
			else percent=stepToPercent(stepNum);
		}
		
		private function getRawPercent() : Number {
			return(curPercent);
		}
		
		private function setRawPercent(n:Number) : void {
			if (n < 0) n = 0;
			if (n > 1) n = 1;
			curPercent = n;
			setDraggerPerc(curPercent);
		}
		
		public function get percent():Number {
			//if snap to step, find nearest step position
			if (snapToStep) 
				return(stepToPercent(percentToStep(getRawPercent())));
			else 
				return(getRawPercent());
		}
		
		public function set percent(perc:Number) : void {
			setRawPercent(perc);
		}
			
		
		//accessor functions
		/*[Inspectable(type=Number, defaultValue=0)]
		public function set track_size(n:Number) {
			trackSize=n;
		}*/
								

		public function get totalSteps():uint {
			return _nSteps;
		}
		
		[Inspectable(type=uint, defaultValue=0)]
		public function set totalSteps(n:uint) : void {
			_nSteps=n;
		}		
		
		//inspectable properties
		
		[Inspectable(type=Boolean, defaultValue=true)] 
		public function set use_dragger_width(b:Boolean):void{
			//trace("set use_dragger_width - "+b)
			useDraggerWidth = b;
			initMinMax();
			setDraggerPerc(getRawPercent());
		}
		
		[Inspectable(type = String, defaultValue = "auto", enumeration="auto,horizontal,vertical")]
		public function set orientation(s:String) : void {
			if (s == "horizontal") isHoriz = true;
			else if (s == "vertical") isHoriz = false;
			else if (s == "auto") {
				if (_mcTrack.width > _mcTrack.height) isHoriz = true;
				else isHoriz = false;
			}
			
			if (isHoriz) _mcDragger.y=origY;
			else _mcDragger.x=origX;
			initMinMax();
		}
		
		
		/*public function set is_horiz(b:Boolean) : void {
			//var curPos:Number=getDraggerPerc();
			isHoriz=b;
			if (isHoriz) _mcDragger.y=origY;
			else _mcDragger.x=origX;
			initMinMax();
			//setDraggerPerc(curPos);
		}*/
		
/*		public function set total_steps(n:uint) : void {
			totalSteps=n;
		}*/
		
		
		//accessor functions
		public function get draggerPercentSize():Number {
			return(_nDraggerSize);
		}
		
		public function set draggerPercentSize(n:Number) : void {
			if (isNaN(n)) n = 0;
			if (n < 0) n = 0;
			if (n > 1) n = 1;
			_nDraggerSize=n;
			initMinMax();
			setDraggerPerc(getRawPercent());
		}
		
//		[Inspectable(type=Number, defaultValue=0)]
		public function set scrollbarLength(n:Number) : void {
			//if (!isNaN(n)&&n>1) setScrollBarLength(n);
			length = n;
		}
		
		/*public function get scrollbarLength():Number {
			return(isHoriz?(upBtn.width+downBtn.width+trackSize):(upBtn.height+downBtn.height+trackSize));
		}*/
		
		[Inspectable(type=Number, defaultValue=0)]
		public function set length(n:Number) : void {
			if (n>0) setLength(n);
		}
		
		public function get length():Number {
			var n:Number = trackSize;
			if (hasButtons) {
				if (isHoriz) n += upBtn.width + downBtn.width;
				else n += upBtn.height + downBtn.height;
			}
			return(n);
		}
		
		public function get trackSize():Number {
			return(isHoriz?_mcTrack.width:_mcTrack.height);
		}
		
		/*public function set trackSize(n:Number) : void {
			if (isNaN(n)||n==0) return;
			
			setTrackSize(n);
		}*/
		
		
		private function setLength(n:Number) : void {
			if (n == length) return;
			
			//calculate new track size
			var newTrackSize:Number
			if (hasButtons) {
				//btnSize is the average of the up and down button sizes - usually they are the same size so it is equal to button size
				var btnSize:Number=((isHoriz?upBtn.width:upBtn.height)+(isHoriz?downBtn.width:downBtn.height))/2;
				newTrackSize = n - 2 * btnSize;
				//make sure the tracksize can't be smaller than the button (this is arbitrary)
				if (newTrackSize<btnSize) newTrackSize=btnSize;
			}
			else newTrackSize = n;
			
			//adjust track size
			if (isHoriz) _mcTrack.width=newTrackSize;
			else _mcTrack.height=newTrackSize;
			
			//adjust downBtn position
			//if (isHoriz) downBtn.x=upBtn.x+upBtn.width+trackSize;
			//else downBtn.y = upBtn.y + upBtn.height + trackSize;
			//set positions in a way that takes rotation into account
			//otherwise, when a button is rotated 180 degrees, it will not be set in the correct place
			if (hasButtons) {
				if (isHoriz) setX(downBtn, getX(upBtn) + upBtn.width + _mcTrack.width);
				else setY(downBtn, getY(upBtn) + upBtn.height + _mcTrack.height);
			}
			
			
			//update dragger and reapply current position
			initMinMax();
			setDraggerPerc(getRawPercent());
		}
		
		private function get hasButtons():Boolean {
			return(upBtn != null && downBtn != null);
		}
		
		//********************************************************************************
		//********************************    UTILITY     *********************************
		//*********************************************************************************
		
		
		
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** TEXTFIELD SNAPPING */
		/* textfield which the scrollbar is following */
		private var snap_to_textfield:TextField;
		/**
		 * scrollbar will be updated automatically based on the scroll status of this textfield
		 * @param	_textfield	null to dissasociate this scrollbar with any textfield
		 * @param	_size_to_tf	autosizes the scrollbar to the textfield
		 */
		public function init_for_textfield( _textfield:TextField, _size_to_tf:Boolean = true ):void 
		{	remove_previous_textfield_association();
			if (_textfield)
			{	snap_to_textfield		= _textfield;
				recalc_for_tf();
				position_dragger_to_text();
				_textfield.addEventListener(MouseEvent.CLICK, position_dragger_to_text );		// click and drag
				_textfield.addEventListener(KeyboardEvent.KEY_UP, position_dragger_to_text );	// user typing
				addEventListener( ScrollEvent.RELEASE, position_text_to_dragger );				// scrollbar moved
				addEventListener( ScrollEvent.SCROLL, position_text_to_dragger );				// scrollbar moved
				if (_size_to_tf)
					scrollbarLength = _textfield.height;
			}
		}
		/**
		 * user changed the text position by highlighting... we have to update the scrollbar position based on text position
		 * @param	_e
		 */
		private function position_dragger_to_text( _e:Event = null ):void
		{	recalc_for_tf();
			percent = snap_to_textfield.scrollV / snap_to_textfield.maxScrollV;
		}
		/**
		 * user moved the scrollbar so we have to move the text based on the scrollbar
		 * @param	_e
		 */
		private function position_text_to_dragger( _e:ScrollEvent ):void 
		{	var min				:Number		= 1;
			var max				:Number		= snap_to_textfield.maxScrollV;
			var scroll_to		:Number		= Math.round( max * _e.percent ) + min;
			snap_to_textfield.scrollV = scroll_to;
		}
		/**
		 * remove any attachments to the previous textfield to aleviate memory leaks
		 */
		private function remove_previous_textfield_association(  ):void 
		{	if (snap_to_textfield)
			{	snap_to_textfield.removeEventListener(MouseEvent.CLICK, position_dragger_to_text );
				snap_to_textfield.removeEventListener(KeyboardEvent.KEY_UP, position_dragger_to_text );
			}
			removeEventListener( ScrollEvent.RELEASE, position_text_to_dragger );
			removeEventListener( ScrollEvent.SCROLL, position_text_to_dragger );
		}
		private function recalc_for_tf(  ):void 
		{	visible					= snap_to_textfield.maxScrollV > 1;
			var per_page	:int	= snap_to_textfield.bottomScrollV - snap_to_textfield.scrollV + 1;	// how many lines are visible at once
			var total		:int	= snap_to_textfield.maxScrollV + per_page - 1;						// total number of lines in the current text
			totalSteps				= total;												// how many lines there are
			draggerPercentSize		= per_page / total;										// used for calculating page up and down
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		*/
		
		private function setX(mc:DisplayObject, xpos:Number) : void {
			if (mc == null) return;
			var offset:Number = mc.x=mc.getRect(mc.parent).x;
			mc.x = xpos + offset;
		}
		private function setY(mc:DisplayObject, ypos:Number) : void {
			if (mc == null) return;
			var offset:Number = mc.y-mc.getRect(mc.parent).y;
			mc.y = ypos + offset;
		}
		private function getX(mc:DisplayObject):Number {
			if (mc == null) return(0);
			return(mc.getRect(mc.parent).x);
		}
		private function getY(mc:DisplayObject):Number {
			if (mc == null) return(0);
			return(mc.getRect(mc.parent).y);
		}
		
		protected function initMinMax() : void {
			var dispDraggerSize:Number;
			if (_nDraggerSize == 0 || disableDraggerResize) dispDraggerSize=(isHoriz?_mcDragger.width:_mcDragger.height)/trackSize;
			else dispDraggerSize = _nDraggerSize;
			
			var draggerWidth:Number=Math.max(dispDraggerSize*trackSize,minDraggerSize);
			
			if (!disableDraggerResize) {
				if (isHoriz) _mcDragger.width=draggerWidth;
				else _mcDragger.height=draggerWidth;
			}
			
			var trackBounds:Rectangle = _mcTrack.getBounds(this);
			minPos=isHoriz?trackBounds.x:trackBounds.y;
			maxPos=minPos+(isHoriz?_mcTrack.width:_mcTrack.height);
			
			if (useDraggerWidth) {
				minPos+=draggerWidth/2;
				maxPos-=draggerWidth/2;
			}
		}
				
		protected function getDraggerPerc():Number {
			var draggerPos:Number = isHoriz?_mcDragger.x:_mcDragger.y;
			if (minPos==maxPos) return(0);
			else {
				var draggerPerc:Number=(draggerPos-minPos)/(maxPos-minPos);
				if (draggerPerc<0) draggerPerc=0;
				if (draggerPerc>1) draggerPerc=1;
				return(draggerPerc);
			}
		}
		
		protected function setDraggerPerc(perc:Number) : void {
			//trace("setDraggerPerc - " + perc);
			if (perc>1) perc=1;
			if (perc<0) perc=0;
			var draggerPos:Number=minPos+perc*(maxPos-minPos);
			if (isHoriz) _mcDragger.x=draggerPos;
			else _mcDragger.y=draggerPos;
		}
		
		protected function stepToPercent(stepNum:uint):Number {
			if (_nSteps<2) return(0);
			else return(stepNum/(_nSteps-1));			
		}
		
		protected function percentToStep(perc:Number):uint {
			if (perc<0) return(0);
			var stepNum:Number=Math.floor(perc*_nSteps);
			if (stepNum==_nSteps) stepNum--;
			return(stepNum);
		}
		
		protected function moveStepBy(delta:int) : void {
			var oldStep:int=step;
			var newStep:int=oldStep+delta;
			if (newStep<0) newStep=0;
			if (newStep>=_nSteps) newStep=_nSteps-1;
			
			if (oldStep!=newStep) {
				step=newStep;
				dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL,percent,step));
			}
		}
		
		protected function movePageBy(delta:Number) : void {
			var pagePercent:Number = (draggerPercentSize == 1)?0:(draggerPercentSize / (1 - draggerPercentSize));
			if (pagePercent > 1) pagePercent = 1;
			if (draggerPercentSize > 0) {
				var oldPercent:Number = percent;
				percent += delta * pagePercent;
				if (percent != oldPercent) {
					dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL,percent,step));
				}
			}
			//if a dragger percent is not set, move one step instead of one page
			else moveStepBy(Math.round(delta));
		}
		
		//*************************************************************************************
		//*********************************  CALLBACKS   **************************************
		//*************************************************************************************
		
		//callbacks
		protected function trackPressed(evt:MouseEvent) : void {
			if (totalSteps == 0) {
				clickPos = 0;
				//if the slider doesn't have steps, 
				//move dragger to position where track was clicked
				mouseMoved(evt); 
				dragPressed(evt);
			}
			else {
				//if the slider has steps move the slider left or right (up or down) by 1 step;
				var mousePos:Number=isHoriz?mouseX:mouseY;
				var draggerPos:Number=isHoriz?_mcDragger.x:_mcDragger.y;
				//mouse is clicked to the left of the dragger so move the dragger left
				if (mousePos < draggerPos) movePageBy( -1);
				else movePageBy(1);
			}
		}
		
		protected function trackReleased(evt:MouseEvent) : void {
			if (totalSteps == 0) dragReleased(evt);
			else dispatchEvent(new ScrollEvent(ScrollEvent.RELEASE,percent,step));			
		}
				
		protected function dragPressed(evt:MouseEvent) : void {
			//keep track of point on dragger where mouse was clicked, so that it is dragged relative
			//to that point instead of snapping the center of the dragger to the mouse
			clickPos = isHoriz?(mouseX - _mcDragger.x):(mouseY - _mcDragger.y);
			dragging=true;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoved,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_UP, dragReleased,false,0,true);
			addEventListener(MouseEvent.MOUSE_MOVE,mouseMoved,false,0,true);
			addEventListener(MouseEvent.MOUSE_UP,dragReleased,false,0,true);			
			//trace("start drag")
		}

		protected function dragReleased(evt:MouseEvent) : void {
			//trace("stop drag")
			if (!dragging) return;
			dragging=false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoved);
			stage.removeEventListener(MouseEvent.MOUSE_UP,dragReleased);
			removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoved);
			removeEventListener(MouseEvent.MOUSE_UP,dragReleased);			
			dispatchEvent(new ScrollEvent(ScrollEvent.RELEASE,percent,step));
		}
		
		private function mouseMoved(evt:MouseEvent) : void {
			var oldVal:Number=percent;
			var mousePos:Number = (isHoriz?mouseX:mouseY) - clickPos; //-clickPos relative position of dragger
			
			if (maxPos == minPos) setRawPercent(0);
			else setRawPercent((mousePos - minPos) / (maxPos - minPos));
			
			var newVal:Number=percent;
			if (newVal!=oldVal) {
				dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL,percent,step));
			}
		}
		
		protected function mouseWheel(evt:MouseEvent) : void {
			//if (mouseWheelEnabled&&snapToStep) {
			if (mouseWheelEnabled) {
				if (evt.delta<0) moveStepBy(1)
				else if (evt.delta>0) moveStepBy(-1);
			}
		}
		//scrollbar functions
		protected function scrollUp(evt:MouseEvent) : void {
			moveStepBy(-1);
		}

		protected function scrollDown(evt:MouseEvent) : void {
			moveStepBy(1);
		}
		
		protected function scrollReleased(evt:MouseEvent) : void {
			dispatchEvent(new ScrollEvent(ScrollEvent.RELEASE,percent,step));
		}
		
//-------------------------------------------------------------------------------------------------------------------
//---------------------------------------------keyboard selection  --------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------

		private function onKeyPressed(evt:KeyboardEvent):void
		{
			if (evt.keyCode == Keyboard.UP && !isHoriz) moveStepBy(-1);
			else if (evt.keyCode == Keyboard.DOWN && !isHoriz) moveStepBy(1);
			else if (evt.keyCode == Keyboard.LEFT && isHoriz) moveStepBy(-1);
			else if (evt.keyCode == Keyboard.RIGHT && isHoriz) moveStepBy(1);
			else if (evt.keyCode == Keyboard.PAGE_UP) movePageBy(-1);
			else if (evt.keyCode == Keyboard.PAGE_DOWN) movePageBy(1);
			dispatchEvent(new ScrollEvent(ScrollEvent.RELEASE, percent, step)); //assume keyboard button is released and not held
		}
		
		
		//clean-up
		protected function onRemoved(evt:Event) : void {
			dragReleased(null);
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
		}
	}
	
}
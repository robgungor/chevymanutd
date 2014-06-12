/**
* @author Sam Myer / Jon Achai
* @version 0.2
* 
* @usage
* This is the base oddcast button class - it replaces both BaseButton and PlayerButton from AS2 classes
* 
* variables/properties:
* text - button caption
* disabled - toggles disabled state
* 
* inspectable:
* pressAndHoldEnable - when this is set to true, the MOUSE_HOLD event is fired periodically as long as the button is held
* (like in scrollbar buttons)
* press_delay - the delay from the time the button is pressed to the first MOUSE_HOLD event
* hold_interval - the delay between subsequent MOUSE_HOLD events
* 
* events:
* all the MouseEvent events are inherited from the MovieClip class
* e.g. CLICK,MOUSE_UP,MOUSE_DOWN,MOUSE_OVER,MOUSE_OUT, etc.
* 
* (RELEASE_OUTSIDE - "releaseOutside" - equivalent to AS2 onReleaseOutside) --- REMOVED JUN 20 2008
* MOUSE_HOLD - "mouseHold" - when pressAndHold is enabled, this event is fired periodically
* 
* Modification April 25, 2008: ability to assign a filter to the button
*/



package com.oddcast.ui
{
	import flash.display.MovieClip;	
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilter;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;

	public class BaseButton extends MovieClip
	{
		protected var _bDisabled:Boolean
		//public var tf_button:TextField;
		
		private var _sCaption:String = "";
		
		private var pressAndHoldEnabled:Boolean=false;
		private var pressDelay:Number=750;
		private var holdDelay:Number=0; //when this is 0, MOUSE_HOLD is fired on enter frame
		private var holdTimer:Timer;
		
		//button state constants
		public static var ENABLED:String="enable";
		public static var ROLLOVER:String="ro";
		public static var PRESSED:String="press";
		public static var DISABLED:String="disabled";
		
		//event name constants
		public static var RELEASE_OUTSIDE:String="releaseOutside";
		public static var MOUSE_HOLD:String="mouseHold";
		
		//constructor
		function BaseButton() {		
			//trace("BASEBUTTON CONSTRUCTOR");
			gotoFrame(ENABLED);
			if (_tfCaption != null) _sCaption = _tfCaption.text;
			addEventListener(Event.UNLOAD, onUnload);
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			addEventListener(MouseEvent.MOUSE_DOWN,_onPress);
			addEventListener(MouseEvent.MOUSE_UP,_onRelease);
			addEventListener(MouseEvent.MOUSE_OVER,_onRollOver);
			addEventListener(MouseEvent.MOUSE_OUT,_onRollOut);
			buttonMode=true;
			mouseChildren = false;
		}
		
		public function get _tfCaption():TextField {
			return(getChildByName("tf_button") as TextField);
		}
		
		public function setFilter(filterObj:BitmapFilter,appendEffects:Boolean = false):void
		{						
			var myFilters:Array = appendEffects?this.filters:new Array();
			myFilters.push(filterObj);
			this.filters = myFilters;			
		}
		
		//-------------mouse methods	-------------------	
		protected function _onPress(evt:MouseEvent):void {
			gotoFrame(PRESSED);
			try {
				if (stage!=null) {
					stage.addEventListener(MouseEvent.MOUSE_UP,_onReleaseOutside,false,0,true);
					stage.addEventListener(Event.MOUSE_LEAVE, _onReleaseOutside,false,0,true);
					if (pressAndHoldEnabled) 
						startTimer();
				}
			}
			catch (err:SecurityError) {
				
			}
		}
		
		protected function _onRelease(evt:MouseEvent):void	{
			gotoFrame(ROLLOVER);
		}
		
		protected function _onReleaseOutside(evt:Event):void {
			try {
				evt.currentTarget.removeEventListener(MouseEvent.MOUSE_UP,_onReleaseOutside);
				evt.currentTarget.removeEventListener(Event.MOUSE_LEAVE, _onReleaseOutside);
			}
			catch (err:SecurityError) {
				
			}
			if (stage!=null&&!hitTestPoint(stage.mouseX,stage.mouseY)&&!_bDisabled) {
				dispatchEvent(new MouseEvent(RELEASE_OUTSIDE,true));
			}
			if (pressAndHoldEnabled) stopTimer();
		}
		
		protected function _onRollOver(evt:MouseEvent):void {
			if (!_bDisabled) gotoFrame(evt.buttonDown?PRESSED:ROLLOVER);
		}
		
		protected function _onRollOut(evt:MouseEvent):void	{
			if (!_bDisabled) gotoFrame(ENABLED);
		}
		
		private var newFrame:String
		protected function gotoFrame(frameName:String):void {
			newFrame = frameName;
			addEventListener(Event.ENTER_FRAME, changeFrames);
		}
		
		private function changeFrames(evt:Event) : void {
			if (newFrame!=null) {
				if (stage!=null) {
					addEventListener(Event.RENDER, onRender);
					stage.invalidate();
				}
				gotoAndStop(newFrame);
			}
			newFrame = null;
			removeEventListener(Event.ENTER_FRAME, changeFrames);
		}
		
		//----------------------timer methods---------------------------
		
		private function startTimer() : void {
			holdTimer.delay = pressDelay;
			holdTimer.addEventListener(TimerEvent.TIMER, firstTimer);
			holdTimer.reset();
			holdTimer.start();
		}
		
		private function firstTimer(evt:TimerEvent) : void {
			holdTimer.removeEventListener(TimerEvent.TIMER, firstTimer);
			if (holdDelay == 0) {
				holdTimer.stop();
				addEventListener(Event.ENTER_FRAME, timerFire);
			}
			else {
				holdTimer.delay = holdDelay;
				holdTimer.addEventListener(TimerEvent.TIMER, timerFire);
			}
			dispatchEvent(new MouseEvent(MOUSE_HOLD,true));
		}
		
		private function timerFire(evt:Event) : void {
			dispatchEvent(new MouseEvent(MOUSE_HOLD,true));
		}
		
		private function stopTimer() : void {
			holdTimer.removeEventListener(TimerEvent.TIMER, firstTimer);
			holdTimer.removeEventListener(TimerEvent.TIMER, timerFire);
			removeEventListener(Event.ENTER_FRAME, timerFire);
			holdTimer.reset();
		}
				
		//----------------------data methods----------------------------
		
				
		//public access methods
		[Inspectable(defaultValue="", type="String")]
		public function set text(s:String):void		{			
			_sCaption = s;
			if (_tfCaption!=null) _tfCaption.text = _sCaption;		
		}
		
		[Inspectable(defaultValue=false, type="Boolean")]
		public function set disabled(b:Boolean) : void {
			mouseEnabled=!b;
			_bDisabled=b;
			gotoFrame(b?DISABLED:ENABLED);
		}
		
		[Inspectable(defaultValue=false, type="Boolean")]
		public function set doubleClickEnable(b:Boolean):void	{
			doubleClickEnabled = b;
		}
		
		[Inspectable (defaultValue=false, type="Boolean")]
		public function set pressAndHoldEnable(b:Boolean):void {
			pressAndHoldEnabled=b;
			if (pressAndHoldEnabled){
				holdTimer=new Timer(pressDelay);
			}
		}
		
		[Inspectable (defaultValue=0.75, type="Number")]
		public function set press_delay(n:Number) : void {
			pressDelay=n*1000;
		}
		
		[Inspectable (defaultValue=0, type="Number")]
		public function set hold_delay(n:Number) : void {
			holdDelay=n*1000;
		}
		
		public function get disabled():Boolean	{
			return _bDisabled;
		}
		
		public function get text():String
		{
			return _sCaption;
		}
		
		//------------------SPECIAL SAUCE--------------------------
		
		private function onRender(evt:Event):void {
			if (_tfCaption != null) _tfCaption.text = _sCaption;
			removeEventListener(Event.RENDER, onRender);
		}
		
		private function onAdded(evt:Event) : void {
			if (_tfCaption != null) _tfCaption.text = _sCaption;
		}
		
		private function onRemoved(evt:Event) : void {
			//cleanup functions when button is deleted from stage
			if (holdTimer!=null) holdTimer.stop();
			//stage.removeEventListener(MouseEvent.MOUSE_UP,_onReleaseOutside);
			//stage.removeEventListener(Event.MOUSE_LEAVE,_onReleaseOutside);			
		}
		
		private function onUnload(evt:Event) : void {
			destroy();
		}
	
		public function destroy() : void {
			removeEventListener(Event.UNLOAD, onUnload);
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			removeEventListener(Event.RENDER,onRender);
			removeEventListener(MouseEvent.MOUSE_DOWN,_onPress);
			removeEventListener(MouseEvent.MOUSE_UP,_onRelease);
			removeEventListener(MouseEvent.MOUSE_OVER,_onRollOver);
			removeEventListener(MouseEvent.MOUSE_OUT,_onRollOut);
			if (holdTimer != null) stopTimer();
			holdTimer = null;
			if (stage != null) {
				stage.removeEventListener(MouseEvent.MOUSE_UP,_onReleaseOutside);
				stage.removeEventListener(Event.MOUSE_LEAVE, _onReleaseOutside);
			}
		}
	}
	
}
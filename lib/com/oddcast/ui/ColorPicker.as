/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* Color Picker
* 
* The code for converting RGB to HSV is in the ColorData class now.
* 
* Methods:
* selectColor(hex)
* 
* Events:
* ColorEvent.SELECT - new color is selected - e.g. while holding and dragging
* ColorEvent.RELEASE - color is selected - on mouse up - used e.g. for undoing, you can undo to the last mouse up
* returns ColorData object
* 
* @see com.oddcast.utils.ColorData
*/

package com.oddcast.ui {
	import com.oddcast.event.ColorEvent;
	import flash.display.MovieClip;
	import com.oddcast.event.ScrollEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import com.oddcast.utils.ColorData;

	public class ColorPicker extends MovieClip implements IColorPicker {
		public var _mcSquare:MovieClip;
		public var _mcRainbow:Slider;
		public var _mcPreview:MovieClip;
		public var _mcDragger:MovieClip;
		public var _mcColorBase:MovieClip;
		
		private var dragging:Boolean;
		private var color:ColorData;
		
		public function ColorPicker() {
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved, false, 0, true);
			addEventListener(Event.UNLOAD, destroy, false, 0, true);
			_mcDragger=_mcSquare.getChildByName("_mcDragger") as MovieClip;
			_mcColorBase=_mcSquare.getChildByName("_mcColorBase") as MovieClip;
			
			_mcRainbow.addEventListener(ScrollEvent.SCROLL,hueChanged,false,0,true);
			_mcRainbow.addEventListener(ScrollEvent.RELEASE,hueChanged,false,0,true);
			_mcSquare.addEventListener(MouseEvent.MOUSE_DOWN,dragPressed,false,0,true);
			_mcSquare.addEventListener(MouseEvent.MOUSE_UP,dragReleased,false,0,true);
			
			dragging=false;
			color=new ColorData();
			selectColor(0xFF0000);
		}
		
		public function selectColor(hex:uint):void {
			color.hex=hex;
			
			_mcRainbow.percent=1-color.hue;
			_mcDragger.x=_mcColorBase.x+color.sat*_mcColorBase.width;
			_mcDragger.y=_mcColorBase.y+(1-color.bright)*_mcColorBase.height;
			
			var hueColor:ColorData=new ColorData();
			hueColor.setHSB(color.hue,1,1);
			_mcColorBase.transform.colorTransform=hueColor.getTransform();
			
			update();
		}
		
		private function colorChanged(dragging:Boolean=true) {
			var hue:Number=1-_mcRainbow.percent;
			var sat:Number=(_mcDragger.x-_mcColorBase.x)/_mcColorBase.width;
			var bright:Number=1-(_mcDragger.y-_mcColorBase.y)/_mcColorBase.height;
			color.setHSB(hue,sat,bright);
			
			update();
			if (dragging) dispatchEvent(new ColorEvent(ColorEvent.SELECT, color));
			else dispatchEvent(new ColorEvent(ColorEvent.RELEASE, color));
		}
		
		private function f(n:Number):String {
			return(n.toString().slice(0,4));
		}
		private function update() {
			
			_mcPreview.transform.colorTransform=color.getTransform();
		}

		//callbacks
		private function dragPressed(evt:MouseEvent) {
			dragging = true;
			//trace("ColorPicker::dragPressed");
			try {
				stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoved,false,0,true);
				stage.addEventListener(MouseEvent.MOUSE_UP, dragReleased,false,0,true);
			}
			catch (err:SecurityError) {
				//if you can't listen to mouse release events on the stage
				//(because it is loaded in a shell with no allowDomain),
				//stop dragging when the mouse leaves the movieclip
				addEventListener(MouseEvent.MOUSE_OUT, dragReleased,false,0,true);
				trace("ColorPicker::dragPressed - could not add listener");
			}
		}

		private function dragReleased(evt:MouseEvent) {
			//trace("ColorPicker::dragReleased");
			stopDragging();
			colorChanged(false);
		}
		
		private function stopDragging() {
			dragging = false;
			try {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoved);
				stage.removeEventListener(MouseEvent.MOUSE_UP, dragReleased);
			} catch (err:SecurityError) {
				trace("ColorPicker::stopDragging - could not remove listener");
			}
			removeEventListener(MouseEvent.MOUSE_OUT, dragReleased);			
			updateSquarePos();
		}
		
		private function hueChanged(evt:ScrollEvent) {			
			var hueColor:ColorData=new ColorData();
			hueColor.setHSB(1-evt.percent,1,1);
			_mcColorBase.transform.colorTransform=hueColor.getTransform();
			
			colorChanged(evt.type==ScrollEvent.SCROLL);
		}
		
		private function mouseMoved(evt:MouseEvent) {
			updateSquarePos();
			colorChanged(true);
		}
		
		private function updateSquarePos() {
			var xpos=_mcSquare.mouseX;
			var ypos=_mcSquare.mouseY;
			if (xpos<_mcColorBase.x) xpos=_mcColorBase.x;
			if (xpos>_mcColorBase.x+_mcColorBase.width) xpos=_mcColorBase.x+_mcColorBase.width;
			if (ypos<_mcColorBase.y) ypos=_mcColorBase.x;
			if (ypos>_mcColorBase.y+_mcColorBase.height) ypos=_mcColorBase.y+_mcColorBase.height;
			_mcDragger.x=xpos;
			_mcDragger.y=ypos;
		}
		
		//clean-up		
		private function onRemoved(evt:Event) {
			stopDragging();
		}
		
		private function destroy(evt:Event) {
			stopDragging();
			_mcRainbow.removeEventListener(ScrollEvent.SCROLL,hueChanged);
			_mcRainbow.removeEventListener(ScrollEvent.RELEASE,hueChanged);
			_mcSquare.removeEventListener(MouseEvent.MOUSE_DOWN,dragPressed);
			_mcSquare.removeEventListener(MouseEvent.MOUSE_UP,dragReleased);
			removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);						
			removeEventListener(Event.UNLOAD, destroy);
		}
	}
	
}
/**
 * ...
 * @author Mihai
 * -updated by sam feb 2 2009
 * 
 * @see com.oddcast.ui.IColorPicker
 */
package com.oddcast.ui {
	
	import com.oddcast.event.ColorEvent;
	import com.oddcast.utils.ColorData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	public class ColorPickerV2 extends MovieClip implements IColorPicker {
		// stage instances
		private var colorBMPData		:BitmapData;
		public var colorData:BaseButton;
		public var selectedColor			:MovieClip;
		private var currentColor:uint;
		
		public function ColorPickerV2() 	{
			addEventListener(Event.UNLOAD, onUnload);
			// create BitmapData for reading RGB values
			colorBMPData = new BitmapData( colorData.width, colorData.height );
			colorBMPData	.draw ( colorData );
			
			// click actions for the color movieclip
			colorData				.addEventListener(MouseEvent.MOUSE_DOWN	, evtMouseDown);
			colorData				.addEventListener(MouseEvent.MOUSE_UP	, evtMouseUp);
			colorData.addEventListener(BaseButton.RELEASE_OUTSIDE, evtMouseUp);	
			
			displayColor(0);
		}
		
		private function evtMouseDown(evt:MouseEvent) : void {
			colorData.addEventListener(MouseEvent.MOUSE_MOVE, evtMouseMove);
			var newColor:uint = getMouseOverColor();
			if (newColor == currentColor) return;
			displayColor(newColor);
			dispatchEvent(new ColorEvent(ColorEvent.SELECT, new ColorData(newColor)));			
		}
		
		private function evtMouseUp(evt:MouseEvent) : void {
			colorData.removeEventListener(MouseEvent.MOUSE_MOVE, evtMouseMove);
			var newColor:uint = getMouseOverColor();
			displayColor(newColor);
			dispatchEvent(new ColorEvent(ColorEvent.RELEASE, new ColorData(newColor)));
		}
		
		private function evtMouseMove(evt:MouseEvent) : void {
			var newColor:uint = getMouseOverColor();
			if (newColor == currentColor) return;
			displayColor(newColor);
			dispatchEvent(new ColorEvent(ColorEvent.SELECT, new ColorData(newColor)));			
		}
		
		
		private function getMouseOverColor():uint {
			var click_X:int = Math.floor(colorData.mouseX);
			var click_Y:int	= Math.floor(colorData.mouseY);
			if (click_X < 0 || click_Y < 0 || click_X >= colorBMPData.width || click_Y >= colorBMPData.height) return(currentColor);
			else return(colorBMPData.getPixel(click_X, click_Y));
		}
		
		/*	retrieves RGB hex value based on the XY position of the mouse	*/
		private function onColorSelected(e:MouseEvent):void {
			var click_X					:Number			= e.target.mouseX;
			var click_Y 				:Number			= e.target.mouseY;
			var new_color				:uint			= colorBMPData.getPixel(click_X, click_Y);
			displayColor( new_color );
			dispatchEvent(new ColorEvent(ColorEvent.SELECT, new ColorData(new_color) ) );
		}
		
		/*	updates the color for user feedback	*/
		public function selectColor(hex:uint):void {
			displayColor(hex);
		}
		private function displayColor(hex:uint):void {
			currentColor = hex;
			var color_transform:ColorTransform = selectedColor.transform.colorTransform;
			color_transform.color = hex;
			selectedColor.transform.colorTransform	= color_transform;
			//trace('(Oo) :: workshop.panels.color_picker.Color_Picker.display_selectedColor().new_color :',new_color.toString(16));
		}
		
		private function onUnload(evt:Event) : void { destroy(); }
		public function destroy() : void {
			removeEventListener(Event.UNLOAD, onUnload);
			colorData.removeEventListener(MouseEvent.MOUSE_DOWN	, evtMouseDown);
			colorData.removeEventListener(MouseEvent.MOUSE_UP	, evtMouseUp);
			colorData.removeEventListener(BaseButton.RELEASE_OUTSIDE, evtMouseUp);	
			colorData.removeEventListener(MouseEvent.MOUSE_MOVE, evtMouseMove);
		}
	}
	
}
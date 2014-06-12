/**
* @author Sam Myer
* 
* ColorPicker interface - used for:
* com.oddcast.ui.ColorPicker
* com.oddcast.ui.ColorPickerV2
* 
* Methods:
* selectColor(hex)
* 
* Events:
* ColorEvent.SELECT - this event is sent continuously as the mouse is dragged
* ColorEvent.RELEASE - this event is only sent on mouse up - in order e.g. to do undoing
*/
package com.oddcast.ui {
	import flash.events.IEventDispatcher;
	
	public interface IColorPicker extends IEventDispatcher {
		function selectColor(hex:uint):void;
	}
	
}
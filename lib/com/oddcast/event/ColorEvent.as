/**
* ...
* @author Sam Myer
* @version 0.1
* 
* Events:
* SELECT - colour has been selected from ColorSelector
* property:  color
*/
 
package com.oddcast.event {
	import com.oddcast.utils.ColorData;
	import flash.events.Event;
	
	public class ColorEvent extends Event {    
		public var color:ColorData;
		
		public static var SELECT:String="selectColor"; //dispatched on color picker drag
		public static var RELEASE:String="selectColorRelease"; //dispatched on color picker mouse released
		
		public function ColorEvent(type:String,in_color:ColorData) {				
			super(type);
			color=in_color;
		}
					
		public override function clone():Event {
			return new ColorEvent(type,color);
		}
	}
}


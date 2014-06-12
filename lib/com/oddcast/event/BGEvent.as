/**
* ...
* @author Sam Myer
* @version 0.1
* 
* Events:
* SELECT - bg has been selected from BGSelector
* property:  bg
*/
 
package com.oddcast.event {
	import com.oddcast.assets.structures.BackgroundStruct;
	import flash.events.Event;
	
	public class BGEvent extends Event {    
		public var bg:BackgroundStruct;
		
		public static var SELECT:String="selectBG";
		//public static var LOADING:String="bgLoading";
		//public static var LOADED:String="bgLoaded";
		
		public function BGEvent(type:String,in_bg:BackgroundStruct) {				
			super(type);
			bg=in_bg;
		}
					
		public override function clone():Event {
			return new BGEvent(type,bg);
		}
	}
}


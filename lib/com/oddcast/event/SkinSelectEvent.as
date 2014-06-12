/**
* ...
* @author Sam Myer
* @version 0.1
* 
* Events:
* SELECT - skin has been selected from skinSelector
* property:  skin
*/
 
package com.oddcast.event {
	import com.oddcast.assets.structures.SkinStruct;
	import flash.events.Event;
	
	public class SkinSelectEvent extends Event {    
		public var skin:SkinStruct;
		
		public static var SELECT:String="selectSkin";
		
		public function SkinSelectEvent(type:String,in_skin:SkinStruct) {
			super(type);
			skin=in_skin;
		}
					
		public override function clone():Event {
			return new SkinSelectEvent(type,skin);
		}
	}
}


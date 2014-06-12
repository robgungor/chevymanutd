/**
* ...
* @author Sam Myer
* @version 0.1
* 
* Events:
* SELECT - model has been selected from ModelSelector
* property:  model
*/
 
package com.oddcast.event {
	import com.oddcast.assets.structures.HostStruct;
	import flash.events.Event;
	
	public class ModelEvent extends Event {    
		public var model:HostStruct;
		
		public static var SELECT:String="selectModel";
		
		public function ModelEvent(type:String,in_model:HostStruct) {
			super(type);
			model=in_model;
		}
					
		public override function clone():Event {
			return new ModelEvent(type,model);
		}
	}
}


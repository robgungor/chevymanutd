/**
* ...
* @author Sam Myer
* @version 0.1
* 
* Events:
* SELECTED - item is selected
*  - properties id, text, obj from SelectorItem
* 
* DESELECTED - item is deselected
*  - properties id, text, obj from SelectorItem
* 
* isSelected - boolean value = true when selected, false when deselected
*/
 
package com.oddcast.event
{
	import flash.events.Event;
	
	public class SelectorEvent extends flash.events.Event 
	{    
		public static var SELECTED:String = "selected";
		public static var DESELECTED:String = "deselected";
		
		private var _id:int;
		private var _obj:Object;
		private var _text:String;
		
		public function SelectorEvent(type:String,in_id:int=0,in_text:String="",in_obj:Object=null) 
		{				
			super(type);
			_id=in_id;
			_text=in_text;
			_obj=in_obj;
		}
		
		public function get id():int {
			return(_id);
		}
		
		public function get text():String {
			return(_text);
		}
		
		public function get obj():Object {
			return(_obj);
		}
		
		public function get isSelected():Boolean {
			return(type==SELECTED);
		}
				
		public override function clone():Event {
			return new SelectorEvent(type,id,text,obj);
		}
	}
}


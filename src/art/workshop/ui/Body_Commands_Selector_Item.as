/**
* ...
* @author Me^
* @version 0.1
*/

package workshop.ui 
{
	import com.oddcast.event.*;
	import com.oddcast.ui.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

	public class Body_Commands_Selector_Item extends MovieClip implements SelectorItem 
	{
		public var tf_type:TextField;
		public var tf_value:TextField;
		public var btn_apply:SimpleButton;
		private var obj:Object;
		public static const APPLY_COMMAND_EVENT	:String = 'apply command event';
		
		private var _id:int;
		private var oldName:String;
		
		public function Body_Commands_Selector_Item() 
		{
			btn_apply.addEventListener(MouseEvent.CLICK, apply_command);
		}
		
		private function apply_command( _e:MouseEvent ):void 
		{
			dispatchEvent(new SelectorEvent(APPLY_COMMAND_EVENT, id, text, data));
		}
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERFACE */
		public function select():void {
		}
		public function deselect():void {
		}
		public function shown(b:Boolean):void {
		}
		
		public function get id():int {
			return(_id);
		}
		public function set id(in_id:int):void {
			_id=in_id;
		}
		public function get text():String {
			return('');
		}
		public function set text(in_text:String):void {
		}
		public function get data():Object {
			return obj;
		}
		public function set data(in_data:Object):void {
			obj = in_data;
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
	}
	
}
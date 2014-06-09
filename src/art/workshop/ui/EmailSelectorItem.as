/**
* ...
* @author Default
* @version 0.1
*/

package workshop.ui {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.SelectorItem;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class EmailSelectorItem extends MovieClip implements SelectorItem {
		public var removeBtn:BaseButton;
		public var tf_name:TextField;
		public var tf_email:TextField;
		
		private var _id:int;
		private var oldName:String;
		
		public function EmailSelectorItem() {
			removeBtn.addEventListener(MouseEvent.CLICK, removeFromList);
			tf_name.addEventListener(FocusEvent.FOCUS_IN, onFocusName);
			tf_name.addEventListener(FocusEvent.FOCUS_OUT, onUnfocusName);
		}
		
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
			return(tf_email.text);
		}
		public function set text(in_text:String):void {
			tf_email.text=in_text;
		}
		public function get data():Object {
			return(tf_name.text);
		}
		public function set data(in_data:Object):void {
			tf_name.text=in_data as String;
		}
		
		private function removeFromList(evt:MouseEvent):void {
			dispatchEvent(new Event(Event.REMOVED));
		}
		
		private function onFocusName(evt:FocusEvent):void {
			oldName = tf_name.text;
		}
		
		private function onUnfocusName(evt:FocusEvent):void {
			var newName:String = tf_name.text;
			if (newName != oldName) {
				dispatchEvent(new SelectorEvent("nameChanged", id, text, { oldName:oldName, newName:newName } ));
			}
		}
	}
	
}
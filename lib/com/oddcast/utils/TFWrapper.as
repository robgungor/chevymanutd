package com.oddcast.utils {
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class TFWrapper {
		private var tf:TextField;
		private var isBlank:Boolean;
		private var blankText:String;
		
		public function TFWrapper($tf:TextField) {
			tf = $tf;
			isBlank = true;
			blankText = tf.text;
			tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			tf.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			tf.addEventListener(Event.CHANGE, onTextChanged);
		}
		
		private function onFocusIn(evt:FocusEvent) {
			if (tf.type == TextFieldType.INPUT && isBlank) tf.text = "";
		}
		
		private function onFocusOut(evt:FocusEvent) {
			isBlank = (tf.text == "");
			if (tf.type == TextFieldType.INPUT && isBlank) tf.text = blankText;
		}
		
		private function onTextChanged(evt:Event) {
			
		}
		
		public function get text():String {
			return(isBlank?"":tf.text);
		}
		public function set text(s:String) {
			if (s == null) clearText();
			else {
				isBlank = false;
				tf.text = s;
			}
		}
		public function clearText() {
			isBlank = true;
			tf.text = blankText;
		}
	}
	
}
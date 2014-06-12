/**
* ...
* @author Jonathan Achai
* @version 0.1
*/

package com.oddcast.ui{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ModalInputWindow extends ModalWindow
	{				
		public var _tfInput:TextField;
		public var _mcBtnOk:BaseButton
		public var _mcBtnCancel:BaseButton
		public var _tfTitle:TextField;
		public var _tfMessage:TextField;
		
		public static var OK:String = "onOk";
		
		function ModalInputWindow()
		{			
			
		}				
		
		override protected function init(evt:Event):void
		{
			super.init(evt);
			_mcBtnOk.addEventListener(MouseEvent.CLICK, okClicked);
			_mcBtnCancel.addEventListener(MouseEvent.CLICK, closeClicked);
			_tfInput.stage.focus = _tfInput;
			_tfInput.setSelection(0, _tfInput.text.length);
		}
		
		
		public function setTitle(s:String):void
		{
			_tfTitle.text = s;
		}
		
		public function setMessage(s:String):void
		{
			_tfMessage.text = s;
		}
		
		public function setInput(s:String):void
		{
			_tfInput.text = s;
		}
		
		public function setButtonText(ok:String, cancel:String):void
		{
			_mcBtnOk.text = ok;
			_mcBtnCancel.text = cancel;
		}
		
		public function getInput():String
		{
			return _tfInput.text;
		}
		
		private function okClicked(evt:MouseEvent):void
		{
			dispatchEvent(new MouseEvent(ModalInputWindow.OK,true));
		}
	}
	
}
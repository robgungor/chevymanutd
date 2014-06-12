/**
* ...
* @author Jonathan Achai
* @version 0.1
*/

package com.oddcast.ui{
	import flash.text.TextField;

	public class ModalAlertWindow extends ModalWindow
	{		
		public var _tfTitle:TextField;
		public var _tfMessage:TextField;
		
		function ModalAlertWindow()
		{			
		}
		
		public function setTitle(s:String):void
		{
			_tfTitle.text = s;
		}
		
		public function setMessage(s:String):void
		{
			_tfMessage.text = s;
		}
	}
	
}
/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* This is the SelectorItem for the ComboBox.
* It behaves differently from StickyButton used in the AS2 combobox, which it replaces.
* It isn't sticky.  When you open the dropdown box, the selected item is highlighted only until you rollover
* another item.
* 
* It returns an UPDATED event on rollover, so that all the other combo items are unhilighted when this one is rolled over
* @see
* com.oddcast.ui.SelectorItem
* com.oddcast.ui.OComboBox
*/

package com.oddcast.ui {
	import com.oddcast.event.SelectorEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ComboSelectorItem extends BaseButton implements SelectorItem {
		private var _id:int;
		private var _oData:Object; //object to store data
		
		public function ComboSelectorItem() {
			super();
		}
				
		public function select():void {
			gotoFrame(ROLLOVER);
		}
		public function deselect():void {
			gotoFrame(ENABLED);
		}
		public function shown(b:Boolean):void {}
		
		//mouse events
		
		override protected function _onRelease(evt:MouseEvent):void {
			super._onRelease(evt);
			dispatchEvent(new SelectorEvent(SelectorEvent.SELECTED,id,text,data));
		}
		
		public function get id():int {
			return(_id);
		}
		public function set id(in_id:int):void {
			_id=in_id;
		}
		
		public function set data(o:Object):void
		{			
			_oData = o;			
		}
		
		public function get data():Object	{
			return _oData;
		}
	}
	
}
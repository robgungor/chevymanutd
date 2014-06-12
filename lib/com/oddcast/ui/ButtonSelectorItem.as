/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* This is the equivalent of the StickyButton in AS2 classes as used in the context of the ButtonSelector
* @see
* com.oddcast.ui.Selector
* com.oddcast.ui.SelectorItem
* com.oddcast.ui.StickyButton
*/

package com.oddcast.ui {
	import com.oddcast.event.SelectorEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ButtonSelectorItem extends StickyButton implements SelectorItem{
		private var _id:int;
		private var _oData:Object; //object to store data
		
		public function ButtonSelectorItem() {
			super();
		}
						
		override protected function  _onSelect(b:Boolean):void {
			selected=b;
			dispatchEvent(new SelectorEvent(b?SelectorEvent.SELECTED:SelectorEvent.DESELECTED,id,text,data));			
		}
		
		public function get id():int {
			return(_id);
		}
		public function set id(in_id:int):void {
			_id=in_id;
		}
		public function shown(b:Boolean):void {		}
		
		public function set data(o:Object):void
		{			
			_oData = o;			
		}
		
		public function get data():Object	{
			return _oData;
		}
		
		/*public function setData(key:String,val:*):void
		{
			if (_oData===null)
			{
				_oData = new Object();
			}
			_oData[key] = val;
		}
		
		public function getData(key:String):*
		{
			if (_oData===null)
			{
				return undefined;
			}
			return _oData[key];
		}*/
		
	}
}
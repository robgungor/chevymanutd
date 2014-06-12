/**
 * @author Sam Myer
 * @version 0.1
 * @usage
 * properties:
 * text (inherited)
 * disabled (inherited)
 * selected:Boolean - select/deselect button
 * deselectable:Boolean -
 * when false (default), it behaves like a normal StickyButton - once you click it, it always stays selected
 * when true, if it is selected and you click it again, it deselects - ie. it functions like a toggle button
 * 
 * functions
 * select() - alias for selected=true;
 * deselect() - alias for selected=false;
 * 
 * events:
 * -inherits MouseEvents from MovieClip
 * -when selected or disabled mouse events are disabled
 */

package com.oddcast.ui
{	
	import com.oddcast.event.SelectorEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class StickyButton extends BaseButton implements ISelectable
	{
		protected var _bSelected:Boolean;
		protected var _bDeselectable:Boolean;
				
		
		//constructor		
		function StickyButton()	{						
			super();
			addEventListener(MouseEvent.CLICK,_onClick,false,0,true);
		}
						
		protected function _onClick(evt:MouseEvent):void {	
			if (!_bSelected) _onSelect(true);
			else if (_bDeselectable) _onSelect(false);
		}
		
		protected function  _onSelect(b:Boolean):void {
			selected=b;
			dispatchEvent(new SelectorEvent(b?SelectorEvent.SELECTED:SelectorEvent.DESELECTED));			
		}
		
		override protected function _onRollOver(evt:MouseEvent):void {
			if (!_bSelected&&!_bDisabled) gotoFrame(evt.buttonDown?PRESSED:ROLLOVER);
		}
		override protected function _onRollOut(evt:MouseEvent):void	{
			if (!_bSelected&&!_bDisabled) gotoFrame(ENABLED);
		}
		
		public function deselect():void	{
			selected = false;
		}
		
		public function select():void	{
			selected = true
		}

		protected function updateStatus():void {
			if (_bDisabled) gotoFrame(DISABLED);
			else if (_bSelected) gotoFrame(PRESSED);
			else gotoFrame(ENABLED);
			
			if (_bDisabled) mouseEnabled=false;
			else if (_bSelected&&!_bDeselectable) mouseEnabled=false;
			else mouseEnabled=true;
		}
		
		//public access methods
		[Inspectable(defaultValue="false", type="Boolean")]
		public function set selected(b:Boolean):void
		{
			_bSelected = b;
			updateStatus();
		}
		
		public function get selected():Boolean
		{
			return _bSelected;
		}
		
		override public function set disabled(b:Boolean):void {
			_bDisabled=b;
			updateStatus();
		}
		
		[Inspectable(defaultValue="false", type="Boolean")]
		public function set toggle_button(b:Boolean):void {
			deselectable=b;
		}
		
		public function set deselectable(b:Boolean):void
		{
			_bDeselectable = b;
			updateStatus();
		}
		
	}
}
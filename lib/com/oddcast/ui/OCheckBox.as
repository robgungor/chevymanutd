/**
* ...
* @author Sam Myer
* @version 0.1
* 
* Checkbox class - essentially the same as a BaseButton, except when you click it, the checkmark movieclip
* toggles between visible and invisible
* 
* PROPERTIES -
* "selected" to select/deselect
* I also have the property "checked" which does the same thing.  I'm trying to deprecate that in favour of
* selected in order to unify the selection functions with other classes through the ISelectable interface.
* But I have to keep the checked property for backwards compatibility.
* 
*/

package com.oddcast.ui {
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import com.oddcast.event.SelectorEvent;
	import flash.ui.Keyboard;

	public class OCheckBox extends BaseButton implements ISelectable {
		public var checkmark		:MovieClip;
		private var value_locked	:Boolean = false;
		
		public function OCheckBox() 
		{
			super();
			selected = false;
			addEventListener(MouseEvent.CLICK, _onClick, false, 0, true);			
			init_keyboard_shortcuts();
		}
		
		protected function _onClick(evt:MouseEvent) :void
		{
			if (!value_locked)
				selected = !selected;
			dispatchEvent(new SelectorEvent(selected?SelectorEvent.SELECTED:SelectorEvent.DESELECTED));			
		}
		
		/* INTERFACE com.oddcast.ui.ISelectable */
		
		public function get selected():Boolean
		{
			return(checkmark.visible);
		}
		
		public function set selected(b:Boolean) :void
		{
			checkmark.visible=b;
		}
		
		/**
		 * allows or prevents the user from changing the value by clicking on it
		 * @param	_lock if to lock it or not
		 */
		public function lock_checkbox( _lock:Boolean ):void 
		{
			value_locked = _lock;
		}
/*		
		public function get checked():Boolean {
			return(checkmark.visible);
		}
		
		public function set checked(b:Boolean) {
			checkmark.visible=b;
		}*/
		
		/*
		 *
		 *
		 *	KEYBOARD SHORTCUTS
		 *
		 *
		 ****************************************/
		private function init_keyboard_shortcuts(  ):void 
		{	this.addEventListener(KeyboardEvent.KEY_UP, shortcut_toggle_check);
		}
		private function shortcut_toggle_check( _e:KeyboardEvent ):void		
		{	if (_e.keyCode == Keyboard.SPACE)	_onClick(null);	
		}
		/*****************************************
		 *
		 *
		 *
		 *
		 *
		 */
	}
	
}
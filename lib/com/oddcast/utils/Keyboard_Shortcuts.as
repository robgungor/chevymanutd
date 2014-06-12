package com.oddcast.utils 
{
	import flash.events.*;
	
	/**
	 * @about handles function callbacks when an centain event happens
	 * @author Me^
	 */
	public class Keyboard_Shortcuts
	{
		private var shortcut_list		:Array		= new Array();
		private var shortcuts_enabled	:Boolean	= true;
		private const NOT_IN_LIST		:int		= -1;
		private const KEY_EVENT_TYPE	:String		= KeyboardEvent.KEY_UP;
		
		public function Keyboard_Shortcuts() 
		{	}
		
		/**
		 * creates a shortcut for the specified item of any type
		 * @param	_item the item where the listener is attached
		 * eg: SimpleButton, MovieClip, etc
		 * @param	_key_type the type of key were looking for
		 * eg: Keyboard.SPACE
		 * @param	_callback callback when that key is clicked
		 * function needs to accept NO parameters
		 */
		public function api_add_shortcut_to( _item:*, _key_type:int, _callback:Function ):void 
		{	if (!item_exists(_item, _key_type, _callback))
			{	var new_item:Keyboard_Shortcut_Item = new Keyboard_Shortcut_Item( _item, _key_type, _callback );
				
				new_item.item.addEventListener( KEY_EVENT_TYPE, key_pressed );
				shortcut_list.push( new_item );
			}
		}
		/**
		 * destroys a shortcut for the specified item of any type
		 * @param	_item the item where the listener is attached
		 * eg: SimpleButton, MovieClip, etc
		 * @param	_key_type the type of key were looking for
		 * eg: Keyboard.SPACE
		 * @param	_callback callback when that key is clicked
		 * function needs to accept NO parameters
		 */
		public function api_remove_shortcut( _item:*, _key_type:int, _callback:Function ):void 
		{	if (item_exists( _item, _key_type, _callback ))
			{	var index	:int	= item_index( _item, _key_type, _callback );
				var temp	:Array	= shortcut_list.splice( index, 1 );
			}
		}
		private function item_exists( _item:*, _key_type:int, _callback:Function ):Boolean
		{	return item_index( _item, _key_type, _callback ) != NOT_IN_LIST;
		}
		private function item_index( _item:*, _key_type:int, _callback:Function ):int
		{	for (var i:int = 0; i < shortcut_list.length; i++) 
			{	var cur_item:Keyboard_Shortcut_Item = shortcut_list[i];
				if (cur_item.item == _item
					&&
					cur_item.callback == _callback
					&&
					cur_item.key_type == _key_type)
					return i;
			}
			return NOT_IN_LIST;
		}
		/**
		 * keypress from one of the items in the list
		 * @param	_e key event from the item that the event is attached to
		 */
		private function key_pressed( _e:KeyboardEvent ):void 
		{	if (!shortcuts_enabled)	return;	// shortcuts have been suspended
			
			var event_key		:int						= _e.keyCode;
			var event_item		:*							= _e.currentTarget;
			
			// find correct callback out of the list
			for (var i:int = 0; i < shortcut_list.length; i++) 
			{	var cur_item:Keyboard_Shortcut_Item = shortcut_list[i] as Keyboard_Shortcut_Item;
				if (cur_item.item == event_item && cur_item.key_type == event_key)// note we can have multiple items that are the same with different keys looking so we need to match them
					cur_item.callback();
			}
		}
		/**
		 * removes all the listeners on all the items to release dependencies for garbage collection
		 */
		public function api_destroy(  ):void 
		{	for (var i:int = 0; i < shortcut_list.length; i++) 
				( shortcut_list[i] as Keyboard_Shortcut_Item ).item.removeEventListener( KEY_EVENT_TYPE, key_pressed );
		}
		/**
		 * shortcuts can be disabled/enabled without being removed
		 * eg: use during processing
		 * @param	_enabled	true allows shortcuts to notify callbacks
		 */
		public function enable_shortcuts( _enabled:Boolean = true ):void 
		{	shortcuts_enabled = _enabled;
		}
		
	}
}



/**
 * @about private class used to organize all the shortcuts
 * @author Me^
 */	
class Keyboard_Shortcut_Item
{
	/* the item where the listener is attached */
	public var item		:*;
	/* the type of key were looking for */
	public var key_type	:int;
	/* callback when that key is clicked */
	public var callback	:Function;
	
	/**
	 * keyboard shortcut item
	 * @param	_item the item where the listener is attached
	 * @param	_key_type the type of key were looking for
	 * @param	_callback callback when that key is clicked
	 */
	public function Keyboard_Shortcut_Item( _item:*, _key_type:int, _callback:Function ):void 
	{	item 		= _item;
		key_type 	= _key_type;
		callback 	= _callback;
	}
}
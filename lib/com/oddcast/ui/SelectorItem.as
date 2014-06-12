/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* This is the interface used by all SelectorItems (items attached by the Selector)
* Note : it would be nice to merge this with ISelectable somehow
* 
* Properties:
* id - a unique ID
* text - a label for the item
* data - optional, this is any other data required for displaying the item, e.g. thumb URL
* Only set data is required to initialize the item, but you can optionally implement a get also
* 
* Methods:
* select() - what to do when the item is selected
* deselect() - what to do when the item is deselected
* 
* shown(b) - this function is called by the Selector every time the scroll bar is moved or it is updated in any way
* b is true if the item is visible and false if it is outside the selector's mask
* this is used by the ThumbSelectorItem to only load the thumb the first time it is visible
* 
* Events:
* generally should dispatch SelectorEvent.SELECTED event (although this is not strictly required)
* can also dispatch SelectorEvent.DESELECTED event
* 
* @see
* com.oddcast.ui.Selector
*/

package com.oddcast.ui {
	import flash.events.IEventDispatcher;

	public interface SelectorItem extends IEventDispatcher {
		function select():void
		function deselect():void		
		function shown(b:Boolean):void
		function get id():int;
		function set id(in_id:int):void;
		function get text():String;
		function set text(in_text:String):void;
		function get data():Object;
		function set data(in_data:Object):void;
	}
	
}
/**
* ...
* @author Sam
* @version 0.1
* 
* MultiSelector
* 
* Functions like the selector, but you can select more than one item at a time, unlike the regular selector
* which lets you select only one item at a time.  Also, you can optionally set a particular ID to be the "none" id
* Clicking the item with this ID deselects all other buttons, and deselecting all other buttons highlights this item.
* 
* update nov 2008 : most of the functionality to handle multiple selection is in the Selector now
* this class just contains the extra functions which only apply to the multi selector
* 
* FUNCTIONS: 
* getSelectedIdArr - returns an array of the selected IDs
* getSelectedItemArr - returns an array of the selected items
* setNoneId(id) - choose this id to be the id for the "none" button.  -1 by default
* deselectById(id) - deselect item with this id
* selectAll() - selects all items
* allowMultiple - enable/disable multiple selection functionality
* 
* @see com.oddcast.ui.Selector
*/

package com.oddcast.ui {
	import com.oddcast.event.SelectorEvent;

	public class MultiSelector extends Selector {
		
		public function MultiSelector() {
			allowMultiple = true;
			noneIdSet = true;
		}
		public function selectAll( _max_allowed:int = -1 ) 
		{
			selectedIdArr = new Array();
			
			// check for max allowed
			var max_selection:int = (_max_allowed == -1)	? itemArr.length : _max_allowed;
			if (max_selection > itemArr.length)	max_selection = itemArr.length;
			
			for (var i:int = 0; i < max_selection; i++)
			{
				selectedIdArr.push(itemArr[i].id);
			}
			updateSelected();
		}
				
		public function getSelectedIdArr():Array {
			return(selectedIdArr);
		}
		
		public function getSelectedItemArr():Array {
			var selectedItems:Array=new Array();
			for (var i:int=0;i<selectedIdArr.length;i++) {
				selectedItems.push(getItemById(selectedIdArr[i]));
			}
			return(selectedItems);
		}
		
		
		public function setNoneId(in_id:int) {
			noneId = in_id;
			noneIdSet = true;
			updateSelected();
		}
		
		
		public function set allowMultiple(value:Boolean):void {
			_allowMultiple = value;
			if (value == false && selectedIdArr.length > 1) {
				//if more than one item is selected and you disallow multiple selection, force selection of only 1 item
				selectedIdArr = selectedIdArr.slice(0, 1);
				updateSelected();
			}
		}
		public function deselectById(id:Number) {
			setDeselected(id);
		}
		
		
	}
	
}
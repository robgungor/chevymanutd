/**
* ...
* @author Jonathan Achai
* @version 0.1
* @usage
* This extends the ThumbSelectorItem so it would be deselectable
* @see
* com.oddcast.ui.Selector
* com.oddcast.ui.SelectorItem
* com.oddcast.data.ThumbSelectorData
*/

package com.oddcast.ui {	

	public class DeselectableThumbSelectorItem extends ThumbSelectorItem {		
		
		public function DeselectableThumbSelectorItem() {
			_bDeselectable = true;
			super();			
		}
	}
	
}
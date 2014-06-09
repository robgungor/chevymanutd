/**
* ...
* @author Default
* @version 0.1
*/

package workshop.ui {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.ButtonSelectorItem;
	import flash.display.MovieClip;

	public class AccessoryGroupSelectorItem extends ButtonSelectorItem {
		public var icons:MovieClip;
		
		override public function set data(o:Object):void {
			var groupName:String=o as String;
			trace(groupName);
			if (groupName!=null) icons.gotoAndStop(groupName);
		}
		
		override public function set disabled(b:Boolean) {
			super.disabled=b;
			icons.alpha=b?0.5:1;
		}
		
		override protected function  _onSelect(b:Boolean) {
			trace("SELECTEED!!!!!!!!!!!!!!!!!!!!!!!!")
			selected = b;
			dispatchEvent(new SelectorEvent(b?SelectorEvent.SELECTED:SelectorEvent.DESELECTED, id, text, data));
			trace("dispatchEvent(new SelectorEvent(" + [b?SelectorEvent.SELECTED:SelectorEvent.DESELECTED, id, text, data]+"));")
		}

	}
	
}
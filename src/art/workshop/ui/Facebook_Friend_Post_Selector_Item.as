/**
* ...
* @author Me^
* @version 0.1
*/

package workshop.ui 
{
	import com.oddcast.event.*;
	import com.oddcast.ui.*;
	import flash.display.*;
	import flash.events.*;

	public class Facebook_Friend_Post_Selector_Item extends ThumbSelectorItem 
	{
		public var btn_post				:SimpleButton;
        public static const EVENT_POST	:String = "facebook friend post event";
		
		public function Facebook_Friend_Post_Selector_Item() {
			super();
			//buttonMode				= false;
			mouseChildren			= true;
			maintainAspect			= true;
            btn_post.addEventListener(MouseEvent.CLICK, sub_btn_clicked);
		}
		private function sub_btn_clicked( _e:MouseEvent ):void 
		{
			switch (_e.currentTarget)
			{
				case btn_post:		dispatchEvent(new SelectorEvent(EVENT_POST, id, text, data));	break;
			}
		}
	}
	
}
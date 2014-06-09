/**
* ...
* @author Me^
* @version 0.1
*/

package workshop.persistent_image 
{
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.ThumbSelectorItem;
	import com.oddcast.workshop.ServerInfo;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	public class Persistent_Image_Selector_Item extends ThumbSelectorItem 
	{
		public var btn_delete					:SimpleButton;
		public var btn_select					:SimpleButton;
		public static const DELETE_IMAGE_EVENT	:String = 'delete image event';
		public static const SELECT_EVENT		:String = 'select event';
		
		public function Persistent_Image_Selector_Item() {
			super();
			//buttonMode				= false;
			mouseChildren			= true;
			maintainAspect			= true;
			
			btn_delete.addEventListener(MouseEvent.CLICK, sub_btn_clicked);
			btn_select.addEventListener(MouseEvent.CLICK, sub_btn_clicked);
			
			btn_delete.visible = (ServerInfo.persistent_image_access_type == ServerInfo.PERSISTANT_IMAGE_READ_WRITE);
		}
		private function sub_btn_clicked( _e:MouseEvent ):void 
		{
			switch (_e.currentTarget)
			{
				case btn_delete:		dispatchEvent(new SelectorEvent(DELETE_IMAGE_EVENT, id, text, data));	break;
				case btn_select:		dispatchEvent(new SelectorEvent(SELECT_EVENT, id, text, data));			break;
			}
		}
	}
	
}
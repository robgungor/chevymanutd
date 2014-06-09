package code.controllers.accessories
{	
	import code.component.skinners.Custom_CellRenderer_Skinner;
	
	import com.oddcast.ui.ComponentStyle;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ListData;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Accessories_Acc_TileList_CellRenderer extends CellRenderer
	{
		private var ui:Accessories_TileList_Acc_CellRenderer_UI;
		private var cur_image:Loader;
		
		public function Accessories_Acc_TileList_CellRenderer()
		{
			super();
			useHandCursor = false;
			mouseEnabled = false;
			mouseChildren = true;
			
			// skin this cells states
			new Custom_CellRenderer_Skinner(this);
			
			// create a ui for displaying data
			ui = new Accessories_TileList_Acc_CellRenderer_UI();
			ui.tf.mouseEnabled = false;
			addChild(ui);
		}
		
		/**************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ****************************** PRIVATE ***/
		/**
		 * notification when new data is set for this cell
		 * @param	_data	Object containing what was added to the component via addItem
		 */
		private function set_cell_data( _data:Object ):void 
		{
			ui.tf.text = _data.label;
			load_image( _data.thumb );
		}
		/**
		 * notification when the cell is selected or deselected
		 * @param	_selected
		 */
		private function cell_selected( _selected:Boolean ):void 
		{
		}
		private function load_image(_url:String):void
		{
			if (!_url ||
				_url.length <= 0 ||
				!cur_image || 
				!cur_image.contentLoaderInfo || 
				_url != cur_image.contentLoaderInfo.url)// no need to reload same image
			{
				remove_cur_image();
				ui.loading_anim.visible = true;
				Gateway.retrieve_Loader( new Gateway_Request( _url, new Callback_Struct(fin, null, error),0,null,null,true));
				function fin(_ldr:Loader):void
				{
					cur_image = _ldr;
					cur_image.width = ui.image_holder.width;
					cur_image.height = ui.image_holder.height;
					ui.image_holder.addChild(cur_image);
					ui.loading_anim.visible = false;
				}
				function error(_msg:String):void
				{
					
				}
				function remove_cur_image():void
				{
					if (cur_image)
					{
						if (cur_image.parent)
							cur_image.parent.removeChild(cur_image);
						cur_image = null;
					}
				}
			}
		}
		/**************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ****************************** OVERRIDEN METHODS ***/
		override protected function drawLayout():void
		{
			super.drawLayout();
			cell_selected( super.selected );
		}
		override public function set listData(value:ListData):void {
			_listData = value;
			label = '';//_listData.label; // dont use the label
			set_cell_data( super.data );
		}
		
		
		
		
		
		
		
	}
}
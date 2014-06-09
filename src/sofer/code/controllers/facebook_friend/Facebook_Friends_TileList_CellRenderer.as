package code.controllers.facebook_friend
{	
	import code.component.skinners.Custom_CellRenderer_Skinner;
	
	import com.oddcast.ui.ComponentStyle;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ListData;
	
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.casalib.util.RatioUtil;
	
	public class Facebook_Friends_TileList_CellRenderer extends CellRenderer
	{
		private var ui:Facebook_Friends_TileList_CellRenderer_UI;
		private var cur_image:Loader;
		
		public function Facebook_Friends_TileList_CellRenderer()
		{
			super();
			useHandCursor = false;
			mouseEnabled=false;
			mouseChildren=true;
			
			// skin this cells states
			new Custom_CellRenderer_Skinner(this);
			
			// create a ui for displaying data
			ui = new Facebook_Friends_TileList_CellRenderer_UI();
			ui.tf.mouseEnabled = false;
			addChildAt(ui, 0);
			
		
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
			ui.tf.text = _data.label;//ui.tf.text = _listData.label;
			load_image( _data.thumb );
		}
		/**
		 * notification when the cell is selected or deselected
		 * @param	_selected
		 */
		private function cell_selected( _selected:Boolean ):void 
		{
			
		}
		protected var _outline:Shape;
		protected var _mask:Sprite;
		protected var _currentURL:String;
		
		
		private function load_image(_url:String):void
		{
			if (!_url ||
				_url.length <= 0 ||
				!cur_image || 
				!cur_image.contentLoaderInfo || 
				_url != cur_image.contentLoaderInfo.url)// no need to reload same image
			{
				_currentURL = _url;
				remove_cur_image();
				
				ui.loading_anim.visible = true;
				Gateway.retrieve_Loader( new Gateway_Request( _url, new Callback_Struct(fin, null, error),0,null,null,true));
				ui.image_holder.visible = false;
				
				function fin(_ldr:Loader):void
				{
					if(_url != _currentURL) return;
					cur_image = _ldr;
					var scaler:Rectangle = RatioUtil.scaleToFill(new Rectangle(0,0,cur_image.width, cur_image.height), new Rectangle(0,0,84, 84));
					cur_image.width = scaler.width;//ui.image_holder.width;
					cur_image.height = scaler.height//ui.image_holder.height; 
					ui.image_holder.addChild(cur_image);
					ui.image_holder.visible = true; 
					//ui.image_holder.removeChild(ui.image_holder.getChildAt(0));
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
						cur_image.unload();
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
			set_cell_data( this.data );
		}
		
	}
}
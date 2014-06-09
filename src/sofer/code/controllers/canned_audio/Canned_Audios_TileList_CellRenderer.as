package code.controllers.canned_audio
{
	import code.component.skinners.Custom_CellRenderer_Skinner;
	
	import com.oddcast.ui.ComponentStyle;
	
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ListData;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;

	/**
	 * @about http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/fl/controls/listClasses/CellRenderer.html 
	 * @author Me^
	 * 
	 */	
	public class Canned_Audios_TileList_CellRenderer extends CellRenderer
	{
		private var ui:Canned_Audios_TileList_Item_UI;
		
		public function Canned_Audios_TileList_CellRenderer()
		{
			super();
			useHandCursor = false;
			mouseEnabled=false;
			mouseChildren = true;
			
			// skin this cells states
			new Custom_CellRenderer_Skinner(this );
			
			// create a ui for displaying data
			ui = new Canned_Audios_TileList_Item_UI();
			ui.icon.mouseEnabled = false;
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
			ui.tf.text = _data.label;//ui.tf.text = _listData.label;
		}
		/**
		 * notification when the cell is selected or deselected
		 * @param	_selected
		 */
		private function cell_selected( _selected:Boolean ):void 
		{
			var color_transform:ColorTransform = ui.icon.transform.colorTransform;
			color_transform.color = _selected ? 0xff0000 : 0x000000;
			ui.icon.transform.colorTransform = color_transform;
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
		override public function set listData(value:ListData):void 
		{
			_listData = value;
			label = '';//_listData.label; // dont use the label
			set_cell_data( super.data );
		}
		
	}
}
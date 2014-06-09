package code.controllers.accessories
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
	public class Accessories_Group_TileList_CellRenderer extends CellRenderer
	{
		private var ui:Accessories_TileList_Group_CellRenderer_UI;
		
		public function Accessories_Group_TileList_CellRenderer()
		{
			super();
			useHandCursor = true;
			mouseEnabled = true;
			mouseChildren = true;
			
			// skin this cells states
			new Custom_CellRenderer_Skinner(this );
			
			// create a ui that will be used for the display
			ui = new Accessories_TileList_Group_CellRenderer_UI();
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
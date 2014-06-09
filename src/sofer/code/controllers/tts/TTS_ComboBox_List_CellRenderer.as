package code.controllers.tts
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
	public class TTS_ComboBox_List_CellRenderer extends CellRenderer
	{
		private var ui:TTS_List_cellRenderer_UI;
		
		public function TTS_ComboBox_List_CellRenderer()
		{
			super();
			useHandCursor = false;
			mouseEnabled=false;
			mouseChildren=true;
			
			// skin this cells states
			new Custom_CellRenderer_Skinner( this );
			
			// create a ui for displaying data
			ui = new TTS_List_cellRenderer_UI();
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
			label = '';//_listData.label; // dont use the label since we have a custom UI
			set_cell_data( super.data );
		}
		
	}
}
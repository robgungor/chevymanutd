package code.component.skinners
{
	import com.oddcast.ui.ComponentStyle;
	
	import fl.controls.listClasses.CellRenderer;

	public class Custom_CellRenderer_Skinner
	{
		/**
		 * sets the component styles for a cell in a component view
		 * @param	_cell_renderer	specific cell to apply the effects to
		 */
		public function Custom_CellRenderer_Skinner( _cell_renderer:CellRenderer )
		{
			_cell_renderer.setStyle(ComponentStyle.CELL_RENDERER.UpSkin					, Custom_CellRenderer_upSkin);
			_cell_renderer.setStyle(ComponentStyle.CELL_RENDERER.DownSkin				, Custom_CellRenderer_downSkin);
			_cell_renderer.setStyle(ComponentStyle.CELL_RENDERER.OverSkin				, Custom_CellRenderer_overSkin);
			_cell_renderer.setStyle(ComponentStyle.CELL_RENDERER.DisabledSkin			, Custom_CellRenderer_disabledSkin);
			_cell_renderer.setStyle(ComponentStyle.CELL_RENDERER.SelectedUpSkin			, Custom_CellRenderer_selectedUpSkin);
			_cell_renderer.setStyle(ComponentStyle.CELL_RENDERER.SelectedDownSkin		, Custom_CellRenderer_selectedDownSkin);
			_cell_renderer.setStyle(ComponentStyle.CELL_RENDERER.SelectedOverSkin		, Custom_CellRenderer_selectedOverSkin);
			_cell_renderer.setStyle(ComponentStyle.CELL_RENDERER.SelectedDisabledSkin	, Custom_CellRenderer_selectedDisabledSkin);
		}
	}
}
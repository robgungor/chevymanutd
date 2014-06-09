package code.component.skinners
{
	import com.oddcast.ui.ComponentStyle;
	
	import fl.controls.TileList;

	public class Custom_TileList_Skinner
	{
		public function Custom_TileList_Skinner( _tileList:TileList, _cell_renderer_class:Class )
		{
			_tileList.setStyle(ComponentStyle.TILE_LIST.CELL_RENDERER, _cell_renderer_class);
		}
	}
}
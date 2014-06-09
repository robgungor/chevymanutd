package code.component.skinners
{
	import com.oddcast.ui.ComponentStyle;
	
	import fl.controls.List;
	import fl.controls.listClasses.CellRenderer;

	public class Custom_List_Skinner
	{
		public function Custom_List_Skinner( _list:List, _cell_renderer_class:Class )
		{
			_list.setStyle(ComponentStyle.LIST.SKIN						,Custom_List_skin);
			_list.setStyle(ComponentStyle.LIST.CELL_RENDERER			,_cell_renderer_class);// todo check if this works since you might have to access the list directly .dropDown
		}
	}
}
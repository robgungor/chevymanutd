package code.controllers.vhost_back_selection 
{
	import com.oddcast.workshop.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IVhost_Back_Selection
	{
		function open_win():void;
		function close_win():void;
		function get_selected_model(  ):WSModelStruct;
		function select_vhost(_vhost:WSModelStruct):void;
		function populate_vhosts(  ):void;
	}
	
}
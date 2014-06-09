package code.controllers.vhost_selection 
{
	import com.oddcast.workshop.*;
	import flash.events.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IVhost_Selection
	{
		function open_win( _e:MouseEvent = null ):void;
		function close_win( _e:MouseEvent = null ):void;
		function get_selected_vhost(  ):WSModelStruct;
		function select_vhost(_vhost:WSModelStruct):void;
		function populate_vhosts(  ):void;
	}
	
}
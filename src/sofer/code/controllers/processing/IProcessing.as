package code.controllers.processing 
{
	import com.oddcast.utils.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IProcessing
	{
		function processing_start( _process_name:String, _display_process:String = null, _display_percent:int = -1, _time_to_animate:Number = -1, _show_authored_creation:Boolean = false ):void;
		function processing_ended( _process_name:String ):void;
	}
	
	
}
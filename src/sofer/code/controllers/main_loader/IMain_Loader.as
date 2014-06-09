package code.controllers.main_loader 
{
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IMain_Loader 
	{
		/**
		 * hides the main loader window when app is ready
		 */
		function close_win():void;
		/**
		 * updates that processes status for overall calculation in the main loader
		 * @param	_type		process type (eg: Main_Loader.TYPE_BODY or "my custon load")
		 * @param	_percent	process current accurate percentage (eg: 0->100)
		 */
		function process_status_update( _type:String, _percent:int ):void;
	}
	
}
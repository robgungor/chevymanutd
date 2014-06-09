package code.controllers.myspace_connect 
{
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IMyspace_Connect
	{
		function open_win(  ):void;
		function close_win(  ):void;
		function friends_photos_requested( _callback:Function ):void;
		function users_photos_requested( _callback:Function ):void;
	}
	
}
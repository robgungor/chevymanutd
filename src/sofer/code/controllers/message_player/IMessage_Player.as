package code.controllers.message_player 
{
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IMessage_Player
	{
		function load_and_play_message( _mid:String, _edit_state_starter_callback:Function ):void;
		function close_win(  ):void;
	}
	
}
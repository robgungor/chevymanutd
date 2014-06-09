package player 
{
	import flash.display.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class Processing extends MovieClip
	{
		public var load_bar:MovieClip;
		public function Processing() 
		{
			App.loader = this;
			close_win();
		}
		public function open_win(  ):void 
		{
			visible = true;
		}
		public function close_win(  ):void 
		{
			visible = false;
		}
		
	}

}
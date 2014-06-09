package player.holder 
{
	import flash.display.*;
	import player.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class BG_Holder extends MovieClip
	{
		public var bg			:DisplayObject;
		
		public function BG_Holder() 
		{
			App.holder_bg = this;
			bg.visible = false;
		}
		
	}

}
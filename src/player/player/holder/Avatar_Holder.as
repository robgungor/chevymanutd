package player.holder 
{
	import flash.display.*;
	import player.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class Avatar_Holder extends MovieClip
	{
		public var bg			:DisplayObject;
		
		public function Avatar_Holder() 
		{
			App.holder_avatar = this;
			bg.visible = false;
		}
		
	}

}
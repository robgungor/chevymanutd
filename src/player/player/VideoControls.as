package player
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	
	public class VideoControls extends MovieClip
	{
		public var small_pause_button:SimpleButton;
		public var small_play_button:SimpleButton;
		public var progress:MovieClip;
		public var btn_mute:SimpleButton;
		public var btn_unmute:SimpleButton;
		public var btn_replay:SimpleButton;
		
		public function VideoControls()
		{
			super();
			App.controls = this;
		}
	}
}
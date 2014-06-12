package custom
{
	import flash.events.Event;
	
	public class DancePlaybackEvent extends Event
	{
		public function DancePlaybackEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
package player 
{
	import com.oddcast.event.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	/**
	 * when we want to do a video export of a scene mid we load this player on the server
	 * the same as running it locally on your harddisk and playback the message.
	 * recording starts after Loaded Event is called AND at least 50 ms later talk started event
	 * recording stops when talk ended event is called
	 * @author Me^
	 */
	public class APS_Transmitter
	{
		/* starts recording */
		private const EVENT_LOADED_START_REC	:String = 'vh_sceneLoaded';
		/* APS loads the mp3 in folder and starts recording it with the video */
		private const EVENT_TALK_STARTED		:String = 'vh_talkStarted';
		/* stops recording if this is the only scene to be recorded */
		private const EVENT_TALK_ENDED_STOP_REC	:String = 'vh_talkEnded';
		public var is_in_APS_mode				:Boolean = false;
		private var events_queue				:Array = new Array();
		private var queue_timer					:Timer = new Timer( 50 );
		
		public function APS_Transmitter() 
		{
			
		}
		
		public function init( _loader_info:LoaderInfo ):void 
		{
			is_in_APS_mode = _loader_info.parameters.video_export == 'true';
			if ( is_in_APS_mode )
			{
				queue_timer.start();
				App.listener_manager.add(queue_timer, TimerEvent.TIMER, call_everything_in_queue, this );
			}
		}
		
		public function init_listeners(  ):void 
		{
			if (is_in_APS_mode)
			{
				//App.listener_manager.add( App.vhss_player, VHSSEvent.TALK_STARTED, vhss_player_event, this );
				//App.listener_manager.add( App.vhss_player, VHSSEvent.TALK_ENDED, vhss_player_event, this );
				
				App.listener_manager.add( App.scene, VHSSEvent.TALK_STARTED, vhss_player_event, this );
				App.listener_manager.add( App.scene, VHSSEvent.TALK_ENDED, vhss_player_event, this );
			}
		}
		
		public function message_loaded(  ):void 
		{
			if (is_in_APS_mode)
			{
				add_to_calling_queue( EVENT_LOADED_START_REC );
				add_to_calling_queue( EVENT_TALK_STARTED );	
			
			}
		}
		public function message_ended():void
		{
			if (is_in_APS_mode)
			{
				add_to_calling_queue( EVENT_TALK_ENDED_STOP_REC );
			}
		}
		public function vhss_player_event( _e:Event ):void 
		{
			switch (_e.type)
			{
				case VHSSEvent.TALK_STARTED:	add_to_calling_queue( EVENT_TALK_STARTED );				break;
				case VHSSEvent.TALK_ENDED:		add_to_calling_queue( EVENT_TALK_ENDED_STOP_REC );		break;
			}
		}
		
		/**
		 * call events at least 50ms apart to be caught by the player
		 * @param	_event_name
		 */
		private function add_to_calling_queue( _event_name:String ):void 
		{
			events_queue.push( _event_name );
		}
		
		private function call_everything_in_queue( _e:TimerEvent ):void 
		{
			if (events_queue.length > 0)
			{
				trace("APS TRANSMITTER -- call fscommand "+events_queue[0]);
				fscommand( events_queue.shift() )
			}
				
		}
		
	}

}
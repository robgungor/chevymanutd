package player 
{
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.workshop.*;
	
	import flash.events.Event;

	/**
	 * ...
	 * @author Me^
	 */
	public class Tracking_Manager
	{
		public static var EVENT_EVERYTHING_LOADED	:String = 'sv';
		public static var EVENT_TTS_PLAYING			:String = 'aptts';
		public static var EVENT_PHONE_PLAYING		:String = 'apph';
		public static var EVENT_MIC_PLAYING			:String = 'apmic';
		public static var EVENT_CANNED_PLAYING		:String = 'ap';
		public static var EVENT_UPLOADED_PLAYING	:String = 'apup';
		public static var EVENT_SPECIFIC_SCENE		:String = 'pb';
		public static var EVENT_PLAYBACK_FINISHED	:String = 'ae';
		
		public function Tracking_Manager() 
		{
			
		}
		public function init(  ):void 
		{
			if (ServerInfo.hasEventTracking)
				WSEventTracker.init( ServerInfo.trackingURL, { apt:"w", acc:ServerInfo.door, emb:ServerInfo.viralSourceId } );
				
			if (App.vhss_player)
				App.listener_manager.add( App.vhss_player, VHSSEvent.TALK_STARTED, talk_started, this );
		}
		public function track_event( _event_name:String, _scene:String = null, _count:int = 0, _value:String = null ):void 
		{
			WSEventTracker.event( _event_name, _scene, _count, _value );
		}
		private function talk_started( _e:Event ):void 
		{
			if (App.message_data.audio == null)
				return;
				
			var message_audio_type:String = App.message_data.audio.type;
			switch (message_audio_type) 
			{
				case AudioData.MIC:				track_event(EVENT_MIC_PLAYING);			break;
				case AudioData.PHONE:			track_event(EVENT_PHONE_PLAYING);		break;
				case AudioData.PRERECORDED:		track_event(EVENT_CANNED_PLAYING);		break;
				case AudioData.TTS:				track_event(EVENT_TTS_PLAYING);			break;
				case AudioData.UPLOADED:		track_event(EVENT_UPLOADED_PLAYING);	break;
				case AudioData.USER_GENERIC:	track_event(EVENT_CANNED_PLAYING);		break;
				case '':						track_event(EVENT_CANNED_PLAYING);		break;	// this means prerecorded if it has no type
				case null:						/* no audio present */					break;
			}
		}
		
	}

}
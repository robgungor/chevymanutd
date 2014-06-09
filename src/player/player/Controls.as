package player 
{
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class Controls extends MovieClip
	{
		public var play_stop_art		:MovieClip;
		public var btn_play_stop		:SimpleButton;
		public var btn_create_your_own	:SimpleButton;
		public var btn_oddcast			:SimpleButton;
		public var btn_flag_message		:SimpleButton;
		private var message_playing		:Boolean = false;
		private const FLAGGING_SO_NAME	:String = 'flagging';	// value in shared object should be time::mid
		private const FLAGGING_DELIMITER:String = '::';
		private const FLAGGING_BLOCK_MIN:int = 60;
		
		public function Controls() 
		{
			App.controls = this;
			
			play_stop_art.mouseEnabled = false;
			play_stop_art.stop();
		}
		
		public function init(  ):void 
		{
			if (App.aps_transmitter.is_in_APS_mode)
			{
				visible = false;	// controls are not needed when in video recording mode.
			}
			else
			{
				enable_flagging( !user_flagged_this_mid_recently() );
				App.listener_manager.add( App.vhss_player, VHSSEvent.TALK_STARTED, vhss_player_event, this );
				App.listener_manager.add( App.vhss_player, VHSSEvent.TALK_ENDED, vhss_player_event, this );
				App.listener_manager.add( btn_flag_message, MouseEvent.CLICK, flag_message, this );
				App.listener_manager.add( btn_play_stop, MouseEvent.CLICK, play_stop_card, this );
				btn_play_stop.mouseEnabled = App.vhss_player.getAudioUrl() != null; // only if the scene has an audio url
				if (btn_create_your_own)
					App.listener_manager.add( btn_create_your_own, MouseEvent.CLICK, create_your_own, this );
				if (btn_oddcast)
					App.listener_manager.add( btn_oddcast, MouseEvent.CLICK, open_oddcast, this );
			}
		}
		
		public function play_message(  ):void 
		{
			if (!message_playing)
				play_stop_card( );
		}
		
		private function vhss_player_event( _e:Event ):void 
		{
			switch (_e.type)
			{
				case VHSSEvent.TALK_STARTED:	toggle_play_btn( true ); 		
												break;
				case VHSSEvent.TALK_ENDED:		toggle_play_btn( false );
												App.tracking_manager.track_event( Tracking_Manager.EVENT_PLAYBACK_FINISHED );
												break;
			}
		}
		private function toggle_play_btn( _playing:Boolean ):void
		{
			message_playing = _playing;
			play_stop_art.gotoAndStop( _playing ? 2 : 1 );
		}
		private function play_stop_card( _e:MouseEvent = null ):void 
		{
			var audio_url:String = App.vhss_player.getAudioUrl();
			
			// if there is no audio then we consider the playback to finish... 
			if (!audio_url && !message_playing)
				App.tracking_manager.track_event( Tracking_Manager.EVENT_PLAYBACK_FINISHED );
			
			if (message_playing)
				App.vhss_player.stopSpeech();
			else if ( audio_url )
				App.vhss_player.sayByUrl( audio_url );
		}
		public function open_oddcast( _e:Event = null ):void 
		{
			App.alert.alert_user( new AlertEvent( AlertEvent.CONFIRM, '', Alert.MSG_BLOCKED_LINK + 'www.oddcast.com', null, user_responded ));
			URL_Opener.open_oddcast();
			
			function user_responded( _ok:Boolean ):void 
			{
				if (_ok)
				{
					try 
					{	System.setClipboard( 'www.oddcast.com' );	}
					catch (e:Error)
					{	App.alert.alert_user( new AlertEvent( AlertEvent.CONFIRM, '', Alert.MSG_CLIPBOARD_ERROR ))	}
				}
			}
		}
		private function create_your_own( _e:MouseEvent ):void 
		{
			var negative_mid:String = '-'+App.message_data.mid + '.4';// negative to indicate that the workshop was opened from this mid
			var pickup_url:String = ServerInfo.pickup_url + '?mId=' + negative_mid;
			App.alert.alert_user( new AlertEvent( AlertEvent.CONFIRM, '', Alert.MSG_BLOCKED_LINK + pickup_url, null, user_responded ))
			URL_Opener.open_url( pickup_url );
			
			function user_responded( _ok:Boolean ):void 
			{
				if (_ok)
				{
					try 
					{	System.setClipboard( pickup_url );	}
					catch (e:Error)
					{	App.alert.alert_user( new AlertEvent( AlertEvent.CONFIRM, '', Alert.MSG_CLIPBOARD_ERROR ));	}
				}
			}
		}
		
		
		private function flag_message( _e:MouseEvent ):void 
		{	App.alert.alert_user(new AlertEvent(AlertEvent.CONFIRM, 'f9tp524', 'Flag this as inappropriate?', null, user_response));
			
			function user_response( _ok:Boolean ):void 
			{	if (_ok)
				{	// disable button
						enable_flagging( false );
						
					// save flagging time and mid
						var cur_time		:String = new Date().getTime().toString();
						var cur_mid			:String = App.message_data.mid.toString();
						App.shared_object.write_data( FLAGGING_SO_NAME, cur_time + FLAGGING_DELIMITER + cur_mid );
				
					// send data
						if (App.message_data
							&&
							App.message_data.mid > 0)
						{
							var flagging_script_url:String = ServerInfo.localURL + 'api/flagMessage.php';
							// send the value
								var vars:URLVariables = new URLVariables();
								vars.doorId	= ServerInfo.door;
								vars.mId	= App.message_data.mid;
								XMLLoader.sendVars( flagging_script_url, script_response, vars);
								
							function script_response( _response:String ):void 
							{	if (_response && _response.toLowerCase() == 'ok')
								{}
							}
						}
				}
			}
			
		}
		
		/**
		 * turns on or off the flagging buttons ability to be clicked
		 * @param	_enable
		 */
		private function enable_flagging( _enable:Boolean ):void 
		{	btn_flag_message.mouseEnabled	= _enable;
			btn_flag_message.alpha			= _enable ? 1 : 0.5;
		}
		
		/**
		 * umm... read the methods name!!!!
		 * they cannot flag the same MID withing a perdiod of time
		 * @return
		 */
		private function user_flagged_this_mid_recently(  ):Boolean
		{	var saved_flagging_info:String = App.shared_object.read_data( FLAGGING_SO_NAME );
			if (saved_flagging_info
				&&
				saved_flagging_info.lastIndexOf(FLAGGING_DELIMITER) > 0)
			{
				var flagged_mid			:int	= saved_flagging_info.split(FLAGGING_DELIMITER)[1];
				var time_last_flagged	:Number = saved_flagging_info.split(FLAGGING_DELIMITER)[0];
				var now			:Number = new Date().getTime();
				var dif_min		:Number = (now - time_last_flagged) / 1000 / 60;	// 1000 ms and 60 second a minute
				
				var time_failed	:Boolean = dif_min <= FLAGGING_BLOCK_MIN;
				var mid_failed	:Boolean = flagged_mid == App.message_data.mid;
				return ( time_failed && mid_failed );
			}
			return false;
		}
		
	}

}
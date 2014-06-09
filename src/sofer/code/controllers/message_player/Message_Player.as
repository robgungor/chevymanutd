package code.controllers.message_player 
{
	import code.skeleton.App;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.Eval_PHP_Response;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.VHSS_Player_Controller;
	import com.oddcast.workshop.WSEventTracker;
	import com.oddcast.workshop.WorkshopMessage;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLVariables;

	/**
	 * AKA Big Show!
	 * @author Me^
	 */
	public class Message_Player implements IMessage_Player
	{
		private const FLAGGING_SO_NAME	:String = 'flagging';	// value in shared object should be time::mid
		private const FLAGGING_DELIMITER:String = '::';
		
		private var vhss_player_holder:Sprite;
		private var bg_holder:Sprite;
		private var vhost_holder:Sprite;
		
		private var vhss_player_controller:VHSS_Player_Controller;
		private var ui					:Message_Player_UI;
		private var ui_player			:Player_UI;
		/** callback when user requests the editing state of the application */
		private var edit_state_starter_callback			: Function;
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INIT */
		public function Message_Player( _ui:Message_Player_UI, _player_ui:Player_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui = _ui;
			ui_player = _player_ui;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				init();
			}
		}
		private function init(  ):void 
		{	
			App.listener_manager.add_multiple_by_object( [	ui.btn_flag_message,
															ui.btn_create_your_own,
															ui.btn_stop,
															ui.btn_preview ], MouseEvent.CLICK, btn_handler, this );
			enable_flagging( false );
			set_player_audio_state();
			open_win();
			play_message();
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERFACE */
		public function close_win(  ):void 
		{	ui.visible = false;
		}
		private var mid_message:WorkshopMessage;
		public function load_and_play_message( _mid:String, _edit_state_starter_callback:Function ):void
		{
			
			edit_state_starter_callback = _edit_state_starter_callback;
			var doc_query	:String = ServerInfo.acceleratedURL + 'php/api/playScene/doorId=' + ServerInfo.door + '/clientId=' + ServerInfo.client + '/mId=' + _mid;
			
			Gateway.retrieve_XML( doc_query, new Callback_Struct( fin, null, error ) );
			function fin( _xml:XML ):void 
			{	
				mid_message = new WorkshopMessage( parseInt(_mid) );
				mid_message.parseXML( _xml);
				mid_message.extraData.danceIndex;
				
				
				//else App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "", "This message ID is either empty or was created by a previous unsupported version of this application", null, take_us_out_of_bigshow)); 
				//App.mediator.carly.load();
				
			}	
			
			function error( _msg:String ):void 
			{
			}
			edit_state_starter_callback = _edit_state_starter_callback;
			
			// load the vhss player responsible for loading the MID xml and its assets
			var doc_query	:String = '?doc=' + ServerInfo.acceleratedURL + 'php/api/playScene/doorId=' + ServerInfo.door + '/clientId=' + ServerInfo.client + '/mId=' + _mid;
			var player_url	:String = ServerInfo.default_url + 'swf/player_vhss.swf' + doc_query;
			
			// move the scene player from small show to big show
			ui.playerHolder.addChild(ui_player);
			
			// holder for the vhss player
			vhss_player_holder = new Sprite();
			ui.addChild(vhss_player_holder);
			vhss_player_holder.visible = false;	// we dont want to see the vhss player since it has misc art in it
			
			// holder for background 
			bg_holder = new Sprite();
			ui_player.bgHolder.addChild(bg_holder);	// add the bg in the bhholder space
			bg_holder.mask = ui_player.bgMask;
			
			// holder for the vhost
			vhost_holder = new Sprite();	// add the vhost in the player  space
			ui_player.addChild(vhost_holder);
			vhost_holder.mask = ui_player.hostMask;	// mask the vhost
			
			vhss_player_controller = new VHSS_Player_Controller();
			vhss_player_controller.load_and_init(	parseInt(_mid),
													player_url,
													vhss_player_holder,
													vhost_holder,
													bg_holder,
													ui_player.fb_mask,
													new Callback_Struct(fin, null, error),
													talk_started,
													talk_ended,
													App.listener_manager,
													ServerInfo.shared_objects_enabled );
			
			function fin():void
			{
				set_player_audio_state( false, vhss_player_controller.mid_message.audio != null );
				if (! user_flagged_this_mid_recently() )
					enable_flagging( true );
				App.mediator.scene_playback = vhss_player_controller.player_api;
				vhss_player_controller.player_api.stopSpeech();
				big_show_all_loaded();
			}
			function error( _msg:String ):void 
			{	
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t545', 'Unable to playback message', {details:_msg, mId:_mid, mode:'BigShow'}));
				create_your_own();
			}
			function talk_started():void
			{
				set_player_audio_state( false, true );
				playback_finished();
			}
			function talk_ended():void
			{
				set_player_audio_state( true, true );
			}
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERNALS */
		private function create_your_own():void 
		{	
			ServerInfo.set_parent_mId( vhss_player_controller.mid_message.mid.toString() );
			destroy();
			if (edit_state_starter_callback!=null)
			{	
				edit_state_starter_callback();
				edit_state_starter_callback = null;
			}
			close_win();
		}
		private function open_win(  ):void 
		{	ui.visible = true;
		}
		
		private function play_message( ) : void
		{
			if (vhss_player_controller.player_api.getAudioUrl())
			{
				vhss_player_controller.player_api.replay();
				App.mediator.track_audio_playback_type( vhss_player_controller.mid_message.audio );
			}
		}
		
		private function destroy(  ):void
		{
			// remove holders and unmask
			if (vhss_player_holder && vhss_player_holder.parent)
				vhss_player_holder.parent.removeChild(vhss_player_holder);
			vhss_player_holder.mask = null;
			vhss_player_holder = null;
			
			if (bg_holder && bg_holder.parent)
				bg_holder.parent.removeChild(bg_holder);
			bg_holder.mask = null;
			bg_holder = null;
			
			if (vhost_holder && vhost_holder.parent)
				vhost_holder.parent.removeChild(vhost_holder);
			vhost_holder.mask = null;
			vhost_holder = null;
			
			// remove others
			App.mediator.scene_playback = null;
			vhss_player_controller.destroy();
			vhss_player_controller = null;
		}
		
		private function big_show_all_loaded(  ):void 
		{	WSEventTracker.event("ev");
			WSEventTracker.event("pb", vhss_player_controller.mid_message.mid.toString());
			App.mediator.workshop_finished_loading_playback_state();
		}
		
		/**
		 * talk ended is considered the end of the message... so we fire this for tracking
		 * @param	_e
		 */
		private function playback_finished():void
		{
			WSEventTracker.event('ae');
		}
		private function btn_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case ui.btn_create_your_own:	create_your_own();	break;
				case ui.btn_flag_message:		flag_message();		break;
				case ui.btn_preview:			play_message();		break;
				case ui.btn_stop:				vhss_player_controller.player_api.stopSpeech();	 break;
			}
		}
		private function set_player_audio_state( _audio_playing:Boolean = false, _enabled:Boolean = false ):void
		{
			ui.btn_stop.visible		= !_audio_playing;
			ui.btn_preview.visible	= _audio_playing;
			
			ui.btn_preview.mouseEnabled		=
			ui.btn_stop.mouseEnabled		= _enabled;
		}
		/************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 ***************************** MESSAGE FLAGGING AS INNAPROPRIATE */
		/**
		 * umm... read the methods name!!!!
		 * they cannot flag the same MID withing a perdiod of time
		 * @return
		 */
		private function user_flagged_this_mid_recently(  ):Boolean
		{	var saved_flagging_info:String = App.utils.shared_object.read_data( FLAGGING_SO_NAME );
			if (saved_flagging_info
				&&
				saved_flagging_info.lastIndexOf(FLAGGING_DELIMITER) > 0)
			{
				var flagged_mid			:int	= saved_flagging_info.split(FLAGGING_DELIMITER)[1];
				var time_last_flagged	:Number = saved_flagging_info.split(FLAGGING_DELIMITER)[0];
				var now			:Number = new Date().getTime();
				var dif_min		:Number = (now - time_last_flagged) / 1000 / 60;	// 1000 ms and 60 second a minute
				
				var time_failed	:Boolean = dif_min <= App.settings.FLAGGING_BAN_MIN;
				var mid_failed	:Boolean = flagged_mid == vhss_player_controller.mid_message.mid;
				return ( time_failed && mid_failed );
			}
			return false;
		}
		
		private function flag_message():void 
		{	App.mediator.alert_user(new AlertEvent(AlertEvent.CONFIRM, 'f9t524', 'Flag this as inappropriate?', null, user_response));
			
			function user_response( _ok:Boolean ):void 
			{	if (_ok)
				{	// disable button
						enable_flagging( false );
						
					// save flagging time and mid
						var cur_time		:String = new Date().getTime().toString();
						var cur_mid			:String = vhss_player_controller.mid_message.mid.toString()
						App.utils.shared_object.write_data( FLAGGING_SO_NAME, cur_time + FLAGGING_DELIMITER + cur_mid );
				
					// send data
						if (vhss_player_controller.mid_message &&
							vhss_player_controller.mid_message.mid > 0
							)
						{	var flagging_script_url:String = ServerInfo.localURL + 'api/flagMessage.php';
							// send the data
								var vars:URLVariables = new URLVariables();
								vars.doorId	= ServerInfo.door;
								vars.mId	= vhss_player_controller.mid_message.mid;
								Gateway.upload( vars, new Gateway_Request( flagging_script_url, new Callback_Struct( script_response, null, script_error ) ) );
								
							function script_response( _response:String ):void 
							{	if (new Eval_PHP_Response( _response ).is_response_valid())
								{}
								else script_error( _response );
							}
							function script_error( _msg:String ):void 
							{	var error_eval:Eval_PHP_Response = new Eval_PHP_Response( _msg );
								App.mediator.report_error( new AlertEvent( AlertEvent.ERROR, '', 'error flagging mid', {	error:error_eval.error_code, 
																															message:error_eval.error_message, 
																															mId:vhss_player_controller.mid_message.mid } ) );
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
		{	ui.btn_flag_message.mouseEnabled	= _enable;
			ui.btn_flag_message.alpha			= _enable ? 1 : 0.5;
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		*/
		
	}

}
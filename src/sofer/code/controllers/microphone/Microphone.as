package code.controllers.microphone 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.adobe.utils.*;
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.throttle.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.ui.*;
	
	import workshop.ui.AudioControls;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Microphone
	{
		private var btn_open		:InteractiveObject;
		private var ui				:Microphone_UI;
		
		private var orc_engine_ready:Boolean	= false;
		private var orc_engine		:Object;
		private var orc_loader		:Loader;
		/* status of the recording process eg: 0-none  1-recording  2-recorded  3-playback  4-paused*/
		private var status			:int = 0;
		private var orc_events_dispatcher:EventDispatcher;
		
		private const SILENCE_ERROR_EXCERPT:String = 'contains nothing but silence';
		private const NO_SOUND_CARD_ERROR_EXCERPT:String = 'not support microphone';
		
		private const AUDIO_PLAY	:String		= 'play';
		private const AUDIO_STOP	:String		= 'stop';
		private const AUDIO_REC		:String		= 'rec';
		private const AUDIO_STOPREC	:String		= 'stopRec';
		private const AUDIO_SAVE	:String		= 'save';
		
		public function Microphone( _btn_open:InteractiveObject, _ui:Microphone_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui				= _ui;
			btn_open		= _btn_open;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win( false );

			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				init();
			}
		}
		private function init(  ):void 
		{
			App.listener_manager.add( ui.recTimer, TimerEvent.TIMER_COMPLETE, time_up, this);
			App.listener_manager.add_multiple_by_event( ui.audioControls, [	AUDIO_PLAY, 
																			AUDIO_STOP, 
																			AUDIO_REC, 
																			AUDIO_STOPREC, 
																			AUDIO_SAVE ] , audio_callbacks, this);
			App.listener_manager.add_multiple_by_object( [	ui.closeBtn, 
															btn_open ] , MouseEvent.CLICK, mouse_event_handler, this );
			ui.audioControls.setState( AudioControls.PROCESSING );
			ui.recTimer.setTimeLimit( App.settings.MIC_SECONDS_REC_LIMIT );
			init_shortcuts();
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
		 ***************************** INTERFACE API */
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
		private function mouse_event_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{	
				case ui.closeBtn:		close_win( status!=0 );	break;
				case btn_open:			open_win();		break;
			}
		}
		private function audio_callbacks( _e:Event ):void 
		{
			switch(_e.type)
			{
				case AUDIO_PLAY:		ui.audioControls.setState(AudioControls.PROCESSING);
										orc_engine.orc_play();
										WSEventTracker.event("apmic");	
										break;
										
				case AUDIO_STOP:		ui.audioControls.setState(AudioControls.PROCESSING);
										orc_engine.orc_stop();
										break;
				
				case AUDIO_REC:			ui.audioControls.setState(AudioControls.PROCESSING);
										orc_engine.orc_record();
										break;
				
				case AUDIO_STOPREC:		ui.audioControls.setState(AudioControls.PROCESSING);
										orc_engine.orc_recordStop();
										break;
				
				case AUDIO_SAVE:		ui.audioControls.setState(AudioControls.PROCESSING);
										orc_engine.orc_save("micRecordedAudio", 3);
										break;
			}
		}
		
		private function time_up( _e:TimerEvent ):void 
		{
			ui.audioControls.setState(AudioControls.PROCESSING);
			orc_engine.orc_recordStop();
		}
		
		private function open_win( ):void 
		{
			if (ui.visible)
				return;
				
			Throttler.microphone_recording_allowed( allowed, denied );
			function allowed():void 
			{
				ui.visible = true;
				ui.recTimer.resetTimer();
				if (orc_engine_ready)
					ui.audioControls.setState(AudioControls.NOAUDIO);
				else
				{
					ui.audioControls.setState(AudioControls.PROCESSING);
					init_orc();
				}
				set_focus();
			}
			function denied():void 
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, null, "Server capacity surpassed.  Please try again later."));
			}
				
			
		}
		/**
		 * closes the mic window
		 * @param	_prompt_alert	if to prompt the user to really close the window or not
		 */
		private function close_win( _prompt_alert:Boolean = true ):void 
		{
			if ( _prompt_alert )
				App.mediator.alert_user(new AlertEvent(AlertEvent.CONFIRM, "f9t151", "You will lose your changes.  Continue?", null, close_win_response));
			else
				close_win_response( true );
				
			function close_win_response( _ok:Boolean ):void 
			{	
				if (_ok)
				{	
					ui.visible = false;
					switch( status )
					{
						case 1:		audio_callbacks( new Event(AUDIO_STOPREC) );		break;
						case 3:		audio_callbacks( new Event(AUDIO_STOP) );			break;
					}
					status = 0;
					//ui.dispatchEvent(new KaraokeEvent(KaraokeEvent.CLOSE));
					ui.recTimer.resetTimer();
					ui.audioControls.setState(AudioControls.STOPPED);
					unload_orc();
					
					function unload_orc():void
					{
						if (orc_engine)
							orc_engine.orc_disconnect();
						App.listener_manager.remove_all_listeners_on_object( orc_events_dispatcher );
						if (orc_loader)
						{
							App.listener_manager.remove_all_listeners_on_object( orc_loader.contentLoaderInfo );
							orc_loader.unload();
						}
						orc_engine_ready = false;
					}
				}
			}
		}
		
		private function init_orc(  ):void 
		{
			//var orc_set_by_admin:Boolean = false;
			var orc_stem_url:String = ServerInfo.orcURL;
			if (orc_stem_url != null && orc_stem_url != '')	// make sure orc was set
			{
				var app		:String = App.settings.MIC_APP_PARAM;
				var uid		:String = App.settings.MIC_UID_PARAM;
				var format	:String = App.settings.MIC_RECORD_FORMAT;
				var orc_url	:String = 	orc_stem_url + 'ORC_v3.swf' +
										'?app=' + app + 
										'&uid=' + uid + 
										'&pageDomain=' + ServerInfo.contentURL + 
										'&app_params=' + escape('doorId=' + ServerInfo.door + '|FORMAT=' + format + '|js=0');
				// sample url: 
				orc_loader = new Loader();
				App.listener_manager.add( orc_loader.contentLoaderInfo, Event.INIT, orc_engine_loaded, this);
				App.listener_manager.add( orc_loader.contentLoaderInfo, IOErrorEvent.IO_ERROR, orc_engine_load_error, this);
				var orc_context:LoaderContext = new LoaderContext(false, new ApplicationDomain(), SecurityDomain.currentDomain );
				
				try 				
				{	orc_loader.load(new URLRequest(orc_url), orc_context); }
				catch ( _e:Error )
				{	orc_engine_load_error(new ErrorEvent(ErrorEvent.ERROR, false, false, _e.message)); }
				
				function orc_engine_load_error( _e:Event ):void 
				{
					App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t350", "Error Loading ORC."));
				}
				function orc_engine_loaded( _e:Event ):void 
				{
					orc_engine = orc_loader.content as Object;
					orc_loader.visible = false;	// why? i dont know!
					orc_events_dispatcher = orc_loader.contentLoaderInfo.sharedEvents;
					App.listener_manager.add( orc_events_dispatcher, MicRecorderEvent.SILENCE_WARNING, orc_silence_detected, this);
					App.listener_manager.add( orc_events_dispatcher, MicRecorderEvent.READY_STATE, orc_ready, this);
					App.listener_manager.add( orc_events_dispatcher, MicRecorderEvent.SAVE_DONE, orc_save_done, this);
					App.listener_manager.add( orc_events_dispatcher, MicRecorderEvent.STREAM_STATUS, orc_stream_status, this);
					App.listener_manager.add( orc_events_dispatcher, MicRecorderEvent.ERROR, orc_error, this);
					orc_engine_ready = true;
				}
				
			}
			else
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR,"","Microphone recording is not available."));
		}
		private function orc_ready( _e:Event ):void 
		{
			var ready:Boolean = (_e as Object).readyState;
			if (ready) 
			{
				ui.audioControls.setState(AudioControls.NOAUDIO);
				orc_engine_ready = true;
				orc_engine.orc_setSilenceLevel(0);
			}
			else 
				ui.audioControls.setState(AudioControls.PROCESSING);
		}
		private function orc_stream_status( _e:Event ):void 
		{
			var oldStatus:int=(_e as Object).oldStatus;
			var newStatus:int=(_e as Object).newStatus;
			status=newStatus;
			if (newStatus==1&&oldStatus!=1) {
				ui.audioControls.setState(AudioControls.RECORDING);
				ui.recTimer.startTimer();
				//ui.dispatchEvent(new KaraokeEvent(KaraokeEvent.START));
			}
			else if (newStatus==2||newStatus==4) { //playback or recording finished
				if (oldStatus==1) { //stop recording
					ui.recTimer.stopTimer();
				}
				//else if (oldStatus==3) {} //stop playing
				ui.audioControls.setState(AudioControls.STOPPED);
				//ui.dispatchEvent(new KaraokeEvent(KaraokeEvent.STOP));
			}
			else if (newStatus==3) { //start playing
				ui.audioControls.setState(AudioControls.PLAYING);
				//ui.dispatchEvent(new KaraokeEvent(KaraokeEvent.START));
			}
		}
		/**
		 * error messages mostly come directly from the FMS server
		 * @param	_e
		 */
		private function orc_error( _e:Event ):void 
		{
			var msg:String = (_e as Object).message;
			
			if ( msg && msg.toLowerCase().indexOf( SILENCE_ERROR_EXCERPT ) >= 0 )	// silence
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t538', msg));
				ui.audioControls.setState(AudioControls.NOAUDIO);
			}
			else if ( msg && msg.toLowerCase().indexOf( NO_SOUND_CARD_ERROR_EXCERPT ) >= 0 )	// no sound card
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t544', msg));
				close_win( false );
			}
			else	// all other errors
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, null, msg)); //orc error
				ui.audioControls.setState(AudioControls.NOAUDIO);
			}
		}
		private function orc_save_done( _e:Event ):void 
		{
			var saveUrl:String=(_e as Object).message;
			saveUrl=StringUtil.trim(saveUrl);
			ui.audioControls.setState(AudioControls.STOPPED);
			var audio:AudioData = new AudioData(saveUrl, -1, AudioData.MIC);
			close_win( false );
			App.mediator.scene_editing.selectAudio(audio);
			App.mediator.scene_editing.playSceneAudio();
			WSEventTracker.event("acmic");
			WSEventTracker.event("apmic");
		}
		private function orc_silence_detected( _e:MicRecorderEvent ):void 
		{
			App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t538', 'There was no audio in the recording.  Please check your microphone settings and try again'));
		}
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close ); 
		}
		private function shortcut_close(  ):void
		{	close_win( status!=0 );
		}
		 /*******************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
	}
	
}
package code.controllers.tts 
{
	import code.component.skinners.Custom_Scrollbar_Skinner;
	import code.models.*;
	import code.models.items.List_TTS_Voices;
	import code.skeleton.*;
	
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.*;
	
	import fl.controls.Button;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.ui.*;
	
	
	/**
	 * ...
	 * @author Me^
	 */
	public class TTS
	{
		/** button that will open the this panel */
		private var btn_open_tts			:InteractiveObject;
		/** relevant UI for this controller */
		private var ui						:TTS_UI;
		/** data struct containg data for all the tts voices and languages */
		private var list_tts_voices			:List_TTS_Voices;
		/** controller for the 2 combo boxes of the language and voices */
		private var voice_selector			:TTS_Voice_Selector;
		
		/** flag to know if to download the xml data */
		private var tts_server_xml_loaded	:Boolean	= false;
		/** to know if audio has changed we keep the old url for comparisson */
		private var last_audio_played_url	:String;
		/** string of parameters that cannot be used alone */
		private const BLANK_TEST			:RegExp = /[^.,;:?\-!'*() \t\n\r"\\\^\/]/;
		
		public function TTS( _btn_open:InteractiveObject, _ui:TTS_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui				= _ui;
			btn_open_tts	= _btn_open;
			list_tts_voices = App.asset_bucket.model_store.list_tts_voices;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();

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
			voice_selector = new TTS_Voice_Selector(ui.cb_lang, ui.cb_voice, App.listener_manager);
			
			App.listener_manager.add_multiple_by_object( [	btn_open_tts, 
															ui.btn_preview, 
															ui.btn_stop, 
															ui.btn_save, 
															ui.closeBtn ] , MouseEvent.CLICK, btn_handler, this);
			App.listener_manager.add_multiple_by_event( ui.tf_text, [	FocusEvent.FOCUS_IN, 
																		FocusEvent.FOCUS_OUT ] , tf_focus_handler, this);
			App.listener_manager.add_multiple_by_event( App.mediator.scene_editing, [	SceneEvent.TALK_STARTED,
																						SceneEvent.TALK_ENDED ] , scene_event_handler, this);
			App.listener_manager.add( voice_selector, TTS_Voice_Selector.EVENT_VOICE_SELECTED, voice_selected, this);
			init_shortcuts();
			
			ui.tf_text.restrict	= App.settings.TTS_RESTRICT_TEXT;
			ui.tf_text.text		= App.settings.TTS_DEFAULT_TEXT;
			set_player_audio_state();
						
			new Custom_Scrollbar_Skinner( ui.tf_scrollbar );
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
		private function init_tts_server_data(  ):void
		{
			if (!tts_server_xml_loaded)
			{
				list_tts_voices.load(null, new Callback_Struct(fin, null, error));
				function fin():void
				{
					tts_server_xml_loaded	= true;	// avoid reloading
					voice_selector.set_model( list_tts_voices.model_languages, list_tts_voices.model_voices );
					voice_selector.selectLanguageByName( App.settings.TTS_DEFAULT_LANG );// default language should be english in most cases
					if (App.settings.TTS_DEFAULT_VOICE)
						voice_selector.selectVoiceByName( App.settings.TTS_DEFAULT_VOICE );
					else	
						voice_selector.selectRandomVoice( voice_selector.getCurrentLanguage() );
					set_max_input_limit();
				}
				function error(_e:AlertEvent):void
				{
					App.mediator.alert_user(_e);
					close_win();
				}
			}
		}
		private function btn_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case ui.btn_preview:	preview_audio(); break;
				case ui.btn_stop:		App.mediator.scene_editing.stopAudio(); break;
				case ui.btn_save:		save_audio(); break;
				case ui.closeBtn:		close_win(); break;
				case btn_open_tts:		open_win();	break;
			}
		}
		private function scene_event_handler( _e:SceneEvent ):void
		{
			switch ( _e.type )
			{	
				case SceneEvent.TALK_STARTED:	set_player_audio_state( true); break;
				case SceneEvent.TALK_ENDED:		set_player_audio_state( false); break;
			}
		}
		private function set_player_audio_state( _audio_playing:Boolean = false ):void
		{
			ui.btn_stop.visible		= _audio_playing;
			ui.btn_preview.visible	= !_audio_playing;
		}
		private function set_max_input_limit(  ):void 
		{
			var voice:TTSVoice = voice_selector.getCurrentVoice();
			if (voice)
			{
				var lang:TTSLanguage = list_tts_voices.get_language_by_id(voice.langId);
				if (lang && lang.charLimitPercent > 0)
					ui.tf_text.maxChars = Math.ceil(ServerInfo.ttsCharLimit * lang.charLimitPercent);
			}
		}
		
		private function open_win(  ):void 
		{
			ui.visible		= true;
			set_focus();	// for capturing shortcuts
			init_tts_server_data();
		}
		private function close_win(  ):void 
		{
			ui.visible = false;
			if (App.mediator.scene_editing != null)	// its null when the constructor first loads
				App.mediator.scene_editing.stopAudio();
		}
		private function build_audio(  ):TTSAudioData
		{
			var cur_voice:TTSVoice		= voice_selector.getCurrentVoice();
			var user_text:String		= ui.tf_text.text;
			
			if (no_user_text(user_text))
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t330", "Please enter some text."));
				return null;// audio will not speak
			}
			
			//add space after period
			user_text	= user_text.split(".").join(". ");
			//remove apostrophe and quotes
//			user_text	= user_text.split("'").join(""); // requested by Erez/Sergey to allow this to be sent
			user_text	= user_text.split("\"").join("");
			
			if (App.asset_bucket.profanity_validator.is_loaded)
			{
				if (App.settings.TTS_REPLACE_BAD_WORD)	// replace bad words
					user_text =  App.asset_bucket.profanity_validator.replaceBadWords(user_text);
				else	// alert on a bad word
				{
					var bad_word:String = App.asset_bucket.profanity_validator.validate( user_text )
					if (bad_word != '')
					{	
						App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t331", "You cannot use the word " + bad_word + ". Please try with a different word.", { badWord:bad_word } ));
						return null;// audio will not speak
					}
				}
			}
				
			var audio:TTSAudioData = new TTSAudioData( user_text, cur_voice);
			return audio;
		}
		private function no_user_text( _text:String ):Boolean
		{	
			if (_text == null || _text == App.settings.TTS_DEFAULT_TEXT)
				return true;
			return (!(BLANK_TEST.test( _text )));
		}
		private function track_audio_creation( _audio:AudioData ):void 
		{
			var cur_audio_url:String	= _audio.url;
			if (cur_audio_url != last_audio_played_url)
			{
				WSEventTracker.event('actts');
				last_audio_played_url = cur_audio_url;
			}
		}
		private function preview_audio():void 
		{
			var audio:TTSAudioData = build_audio();
			if (audio == null)
				return;
			track_audio_creation( audio );
			
			App.mediator.scene_editing.previewAudio(audio);
			WSEventTracker.event('aptts');
		}
		private function save_audio(  ):void 
		{
			var audio:TTSAudioData = build_audio();
			if (audio == null)
				return;
			track_audio_creation( audio );
			close_win();
			App.mediator.scene_editing.selectAudio(audio);
			App.mediator.scene_editing.playSceneAudio();
			WSEventTracker.event('aptts');
		}
		private function tf_focus_handler( _e:FocusEvent ):void 
		{
			switch(_e.type)
			{
				case FocusEvent.FOCUS_IN:	if (ui.tf_text.text == App.settings.TTS_DEFAULT_TEXT)
												ui.tf_text.text = '';
											break;
											
				case FocusEvent.FOCUS_OUT:	if (ui.tf_text.text == '')
												ui.tf_text.text = App.settings.TTS_DEFAULT_TEXT;
											break;
			}
		}
		private function voice_selected( _e:Event ):void 
		{
			set_max_input_limit();
		}
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus	= ui.tf_text;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, close_win );
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
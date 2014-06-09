package code.controllers.tts
{
	import code.component.skinners.Custom_ComboBox_Skinner;
	import code.component.skinners.Custom_List_Skinner;
	import code.component.skinners.Custom_Scrollbar_Skinner;
	import code.models.Model_Item;
	
	import com.oddcast.audio.TTSLanguage;
	import com.oddcast.audio.TTSVoice;
	import com.oddcast.utils.Listener_Manager;
	
	import fl.controls.ComboBox;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	

	public class TTS_Voice_Selector extends EventDispatcher
	{
		public static const EVENT_LANG_SELECTED:String = 'EVENT_LANG_SELECTED';
		public static const EVENT_VOICE_SELECTED:String = 'EVENT_VOICE_SELECTED';
		
		private var lang_model:Model_Item;
		private var voice_model:Model_Item;
		private var lang_cb:ComboBox;
		private var voice_cb:ComboBox;
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ********************************** INIT ****/
		public function TTS_Voice_Selector(_cb_lang:ComboBox, _cb_voice:ComboBox, _listener_manager:Listener_Manager)
		{
			lang_cb = _cb_lang;
			voice_cb = _cb_voice;
			skin_comboBox( lang_cb );
			skin_comboBox( voice_cb );
			
			
			_listener_manager.add( lang_cb, Event.CHANGE, language_selected, this );
			_listener_manager.add( voice_cb, Event.CHANGE, voice_selected, this );
			
			function skin_comboBox(_cb:ComboBox):void
			{
				new Custom_ComboBox_Skinner(_cb);
				new Custom_List_Skinner( _cb.dropdown, TTS_ComboBox_List_CellRenderer );
				new Custom_Scrollbar_Skinner( _cb );
			}
		}
		public function set_model(_lang_model:Model_Item, _voice_model:Model_Item):void
		{
			// save cur models
			lang_model = _lang_model;
			voice_model = _voice_model;
			
			// populate lists
			populate_languages();
			populate_voices( getCurrentLanguage() );
		}
		/**********************************************
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
		 * ********************************** INTERFACE *****/
		public function selectLanguageByName( _name:String ) : void
		{
			var langs:Array = lang_cb.dataProvider.toArray();//lang_model.get_all_items();
			LANG_LOOP: for (var i:int = 0, n:int = langs.length; i<n; i++ )
			{
				var lang:String = langs[ i ].label;
				if (lang.toLowerCase().indexOf( _name.toLowerCase() ) >= 0)
				{	
					lang_cb.selectedIndex = i;
					populate_voices( getCurrentLanguage() );
					break LANG_LOOP;
				}
			}
		}
		public function selectVoiceByName( _name:String ) : void
		{
			// find the ttsvoice object
			var voices:Array = voice_model.get_all_items();
			VOICE_LOOP: for (var i:int = 0, n:int = voices.length; i<n; i++ )
			{
				var voice:TTSVoice = voices[ i ];
				if (voice.name.toLowerCase().indexOf( _name.toLowerCase() ) >= 0)
				{
					selectLanguageByName( voice.langName );// select that voices language
					
					// find and select specific voice in the populated list
					var voices_in_cb:Array = voice_cb.dataProvider.toArray();
					LOOP_CB_VOICES: for (var ii:int = 0, nn:int = voices_in_cb.length; ii<nn; ii++ )
					{
						var voice_label:String = voices_in_cb[ ii ].label;
						if (voice_label.toLowerCase() == voice.name.toLowerCase() )
						{	
							voice_cb.selectedItem = voices_in_cb[ ii ];
							break LOOP_CB_VOICES;
						}
					}
					break VOICE_LOOP;
				}
			}
		}
		public function selectRandomVoice( _language:TTSLanguage ) : void
		{
			var ran_voice_index:int = Math.floor(Math.random()*_language.voiceArr.length)
			var voice:TTSVoice = _language.voiceArr[ ran_voice_index ];
			selectVoiceByName( voice.name );
		}
		public function getCurrentVoice(  ) : TTSVoice
		{
			var selected_voice_label:String = voice_cb.selectedLabel;
			var cur_voices:Array = voice_model.get_items_by_property('name', selected_voice_label );
			if (cur_voices && cur_voices.length > 0)
				return cur_voices[0];
			return null;
		}
		public function getCurrentLanguage( ) : TTSLanguage
		{
			var item:Object = lang_cb.selectedItem;
			var selected_lang_label:String = lang_cb.selectedLabel;
			var cur_langs:Array = lang_model.get_items_by_property('name', selected_lang_label );
			if (cur_langs && cur_langs.length > 0)
				return cur_langs[0];
			return null;
		}
		/**********************************************
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
		 * ********************************** PRIVATE *****/
		private function populate_languages():void
		{
			lang_cb.removeAll();
			LANG_LOOP: for (var i:int = 0, n:int = lang_model.get_all_items().length; i<n; i++ )
			{
				var lang:TTSLanguage = lang_model.get_all_items()[ i ];
				lang_cb.addItem({label:lang.name, data:lang.name});// add language
				// break LANG_LOOP;
			}
		}
		private function populate_voices( _tts_lang:TTSLanguage ):void
		{
			voice_cb.removeAll();
			if (_tts_lang)
			{
				VOICES_LOOP: for (var i:int = 0, n:int = _tts_lang.voiceArr.length; i<n; i++ )
				{
					var voice:TTSVoice = _tts_lang.voiceArr[ i ];
					voice_cb.addItem({label:voice.name, data:voice.name});// add voice
					// break VOICES_LOOP;
				}
			}
		}
		
		private function language_selected(_e:Event):void
		{
			dispatchEvent( new Event(EVENT_LANG_SELECTED));
			var curSelectedLang:TTSLanguage = getCurrentLanguage();
			if (curSelectedLang)
				populate_voices( curSelectedLang );
		}
		private function voice_selected(_e:Event):void
		{
			dispatchEvent( new Event(EVENT_VOICE_SELECTED));
		}
		/**********************************************
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
		 */
		
		
	}
}
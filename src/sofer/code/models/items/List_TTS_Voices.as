package code.models.items
{
	import code.models.*;
	import code.skeleton.App;
	
	import com.oddcast.audio.*;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.*;

	public class List_TTS_Voices
	{
		public var is_loaded:Boolean;
		public var model_voices:Model_Item=new Model_Item();
		public var model_languages:Model_Item=new Model_Item();
		
		private const ERROR_LOADING_CODE:String='f9t548';
		private const ERROR_LOADING_MSG:String='Cannot load TTS information';
		
		public function List_TTS_Voices()
		{}
		
		/**
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
		 * ****************************** PUBLIC *****************/
		public function load(_url:String=null, _callbacks:Callback_Struct=null):void
		{
			if (is_loaded)
				model_loaded();
			else
			{
				var url:String = _url ? _url : ServerInfo.acceleratedURL + App.settings.API_TTS_INIT + ServerInfo.door;
				
				Gateway.retrieve_XML( url, new Callback_Struct(fin, progress, error), response_eval);
				function response_eval(_xml:XML):Boolean
				{
					return (_xml && _xml.LANGUAGE && _xml.LANGUAGE.length() > 0 );
				}
				function fin(_content:XML):void
				{
					parse(_content);
					model_loaded();
				}
				function progress(_percent:int):void
				{
					if (_callbacks&&_callbacks.progress!=null)
						_callbacks.progress(_percent);
				}
				function error(_msg:String):void
				{
					if (_callbacks&&_callbacks.error!=null)
						_callbacks.error(new AlertEvent(AlertEvent.ERROR,ERROR_LOADING_CODE,ERROR_LOADING_MSG));
				}
			}
			
			function model_loaded():void
			{
				is_loaded=true;
				if (_callbacks&&_callbacks.fin!=null)
					_callbacks.fin();
			}
		}
		public function get_language_by_id(_id:int):TTSLanguage
		{
			var langs:Array = model_languages.get_items_by_property('id',_id);
			if (langs && langs.length > 0 )
				return langs[0];
			return null;
		}
		/***************************************
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
		 */
		private function parse( _xml:XML ):void
		{
			var lang_node:XML, new_lang:TTSLanguage, lang_id:Number, lang_name:String, lang_sample_text:String, lang_char_limit_percent:Number;// language params
			var voice_node:XML, new_voice:TTSVoice, voice_id:Number, voice_engine:Number, voice_lang:Number, voice_name:String, voice_gender:String;// voice params
			// nested... parse each language... and in each language parse each voice
			for (var i:int = 0, n:int = _xml.LANGUAGE.length(); i<n; i++)
			{
				lang_node = _xml.LANGUAGE[i];
				lang_id = parseFloat(lang_node.@ID.toString());
				lang_name = lang_node.@NAME.toString();
				lang_sample_text = unescape(lang_node.@TXT.toString());
				lang_char_limit_percent = parseFloat(lang_node.@PRCLMT.toString()) / 100;
				
				// parse each voice for this language
				var lang_voices:Array=new Array()
				for (var ii:int=0, nn:int=lang_node.VOICE.length(); ii<nn; ii++)
				{
					voice_node = lang_node.VOICE[ii];
					if (voice_node.@ENGINE.toString().length > 0) 
						voice_engine = parseFloat(voice_node.@ENGINE.toString());
					voice_id = parseFloat(voice_node.@ID.toString());
					voice_name = voice_node.@NAME.toString();
					voice_gender = voice_node.@GENDER.toString();
					new_voice = new TTSVoice(voice_id, voice_engine, lang_id, voice_name, lang_name, voice_gender);
					lang_voices.push(new_voice);
					model_voices.add_item(new_voice);
				}
				new_lang=new TTSLanguage(lang_id,lang_name,lang_sample_text,lang_voices,lang_char_limit_percent);
				model_languages.add_item(new_lang);
			}
		}
	}
}
/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* xml parser for tts voice xml -
*/

package com.oddcast.audio {
	import com.oddcast.utils.XMLLoader;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class TTSVoiceList extends EventDispatcher {
		private var voiceLangArr:Array;
		private var _isInited:Boolean = false;
		public var url:String;
		
		public function TTSVoiceList() {}
		
		public function init($url:String = null):void 
		{
			if ($url != null) url = $url;
			XMLLoader.loadXML(url, gotXML);
		}
		private function gotXML(_xml:XML) : void {
			parseXML(_xml);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * builds array from xml data
		 * @param	_xml tts xml
		 * @param	_alphabetically_sort if to sort the list or not
		 */
		public function parseXML(_xml:XML, _alphabetically_sort:Boolean = true):void
		{
			var i:int, j:int;
			var voiceArr:Array;
			voiceLangArr = new Array();
			//var voice:TTSVoice;
			//var language:TTSLanguage;
			var langXML:XML
			var voiceXML:XML;
			
			var xid:int, xeng:int, xlang:int;
			var xchars:Number;
			var xname:String, xlangname:String, xtext:String, xgender:String;
			
			for (i = 0; i < _xml.LANGUAGE.length(); i++) 
			{
				voiceArr = new Array();
				langXML = _xml.LANGUAGE[i];
				xlang = parseInt(langXML.@ID.toString());
				xlangname = langXML.@NAME.toString();
				if (langXML.@ENGINE.toString().length > 0) xeng = parseInt(langXML.@ENGINE.toString());
				xtext = unescape(langXML.@TXT.toString());
				//xchars = parseInt(langXML.@CHARS.toString())/600;
				xchars = parseFloat(langXML.@PRCLMT.toString()) / 100;
				for (j = 0; j < langXML.VOICE.length(); j++) 
				{
					voiceXML = langXML.VOICE[j];
					xid = parseInt(voiceXML.@ID.toString());
					xname = voiceXML.@NAME.toString();
					if (voiceXML.@ENGINE.toString().length > 0) xeng = parseInt(voiceXML.@ENGINE.toString());
					xgender = voiceXML.@GENDER.toString();
					voiceArr.push(new TTSVoice(xid, xeng, xlang, xname, xlangname, xgender));
				}
				if (voiceArr.length > 0)
					voiceLangArr.push(new TTSLanguage(xlang, xlangname, xtext, voiceArr, xchars));
			}
			
			// sorting
			if (_alphabetically_sort)
			{
				sort_list_by_name( voiceLangArr );						// sort languages
				for (i = 0; i < voiceLangArr.length; i++) 
					sort_list_by_name( TTSLanguage(voiceLangArr[i]).voiceArr );		// sort voices per language
			}
			
			_isInited = true;
			
			/** sort an array by each elements *.name property */
			function sort_list_by_name( _list:Array ):void 
			{
				// sort list
					for (var i:int = 0; i < _list.length; i++) 
					{
						for (var j:int = 0; j < _list.length - 1; j++) 
						{
							var cur	:* = _list[j];		// can be TTSVoice or TTSLanguage
							var next:* = _list[j + 1];	// can be TTSVoice or TTSLanguage
							if (cur.name > next.name)
								swap_with_next_item( j );
						}
					}
					
				/** swap 2 array elements */
				function swap_with_next_item( _index:int ):void
				{
					var temp:Array = _list.splice( _index, 2 );		// remove 2 elements to temp
					temp.unshift( temp.pop() );						// swap the 2 elements in temp
					_list.splice( _index, 0, temp[0], temp[1] ); 	// add back into main list from temp
				}
			}
		}
		
		public function get isInited():Boolean {
			return(_isInited);
		}
		
		public function get langArr():Array { //deprecated
			return(voiceLangArr);
		}
		
		public function getAllVoices():Array {
			var voiceArr:Array = new Array();
			for (var i:int = 0; i < langArr.length; i++) {
				voiceArr = voiceArr.concat(langArr[i].voiceArr);
			}
			return(voiceArr);
		}
		
		public function getLanguages():Array {
			return(voiceLangArr);
		}
		
		public function getLanguageById(langId:int):TTSLanguage {
			var language:TTSLanguage;
			for (var i:int = 0; i < langArr.length; i++) {
				language = langArr[i];
				if (language.id == langId) return(language);
			}
			return(null);
		}
		
		public function getLanguageByName(langName:String):TTSLanguage {
			var language:TTSLanguage;
			for (var i:int = 0; i < langArr.length; i++) {
				language = langArr[i];
				if (language.name == langName) return(language);
			}
			return(null);
		}
		
		public function getVoicesByLanguageId(langId:int):Array {
			var language:TTSLanguage = getLanguageById(langId);
			if (language == null) return(new Array())
			else return(language.voiceArr);
		}
		
		public function getVoicesByLanguageName(langName:String):Array {
			var language:TTSLanguage = getLanguageByName(langName);
			if (language == null) return(new Array())
			else return(language.voiceArr);
		}
		
		public function getVoiceByIds(langId:int, voiceId:int):TTSVoice {
			var voiceArr:Array = getVoicesByLanguageId(langId);
			var voice:TTSVoice;
			for (var i:int = 0; i < voiceArr.length; i++) {
				voice = voiceArr[i];
				if (voice.voiceId == voiceId) return(voice);
			}
			return(null);
		}
	}
	
}
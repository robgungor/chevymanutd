/**
* ...
* @author Sam, Me^
* @version 0.5
*/

package workshop.ui 
{
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.ui.*;
	import com.oddcast.workshop.*;
	import flash.display.*;
	import flash.events.*;

	public class TTSVoiceSelector extends MovieClip
	{
		public var langSelector		:OComboBox;
		public var voiceSelector	:OComboBox;
		private var langArr			:Array;
		private var voiceList		:TTSVoiceList;
		private var selectedLang	:int;
		private var selectedVoice	:int;
		
		public function TTSVoiceSelector()
		{	langSelector.addEventListener(SelectorEvent.SELECTED,langSelected);
			voiceSelector.addEventListener(SelectorEvent.SELECTED,voiceSelected);
		}
		
		public function init($voiceList:TTSVoiceList):void
		{	voiceList = $voiceList;
			langArr=voiceList.getLanguages();
			
			selectedLang=0;
			selectedVoice=0;
			populateLangs();
		}
		
		private function populateLangs():void
		{	langSelector.clear();
			for (var i:int=0;i<langArr.length;i++)
				langSelector.add(i,langArr[i].name,null,false);
			
			langSelector.update();
			langSelector.selectById(selectedLang);
			
			populateVoices();
		}
		
		private function populateVoices():void
		{	var voiceArr:Array=langArr[selectedLang].voiceArr;
			
			voiceSelector.clear();
			for (var j:int=0;j<voiceArr.length;j++) {
				voiceSelector.add(j,voiceArr[j].name,null,false);
			}
			voiceSelector.update();
			voiceSelector.selectById(selectedVoice);
		}
		
		private function langSelected(evt:SelectorEvent):void
		{	selectedLang=evt.id;
			langSelector.selectById(selectedLang);
			
			selectedVoice=0;
			populateVoices();
			dispatchEvent(new Event(Event.SELECT));
		}
		
		private function voiceSelected(evt:SelectorEvent):void
		{	selectedVoice=evt.id;
			voiceSelector.selectById(selectedVoice);
			dispatchEvent(new Event(Event.SELECT));
		}
		
		public function selectVoice(voice:TTSVoice):void
		{	if (voice==null) 
				return;
			
			var i:int,j:int;
			for (i=0;i<langArr.length;i++) {
				if (langArr[i].id==voice.langId) {
					selectedLang=i;
					for (j=0;j<langArr[i].voiceArr.length;j++) {
						if (langArr[i].voiceArr[j].voiceId==voice.voiceId) {
							selectedVoice=j;
							break;
						}
					}
					break;
				}
			}
			
			langSelector.selectById(selectedLang);
			populateVoices();			
		}
		
		public function selectRandom():void
		{	selectedLang=Math.floor(Math.random()*langArr.length);
			selectedVoice=Math.floor(Math.random()*langArr[selectedLang].voiceArr.length);
			
			langSelector.selectById(selectedLang);
			populateVoices();			
		}
		
		public function selectLanguageByName( _lang_name:String ):void 
		{	lang_search: for (var i:int = 0; i < langArr.length; i++) 
			{	var cur_lang:TTSLanguage = langArr[i];
				if (cur_lang.name.toLowerCase().indexOf(_lang_name.toLowerCase()) >= 0)
				{	selectedLang = i;
					langSelector.selectById(selectedLang);
					populateVoices();
					break lang_search;
				}
			}
		}
		
		public function selectVoiceByName( _voice_name:String ):void 
		{	if (langArr && langArr[selectedLang] && langArr[selectedLang].voiceArr)
			{	var arr_voice:Array = langArr[selectedLang].voiceArr;
				voice_search: for (var i:int = 0; i < arr_voice.length; i++) 
				{	var cur_voice:TTSVoice = arr_voice[i];
					if (cur_voice.name.toLowerCase().indexOf( _voice_name.toLowerCase() ) >= 0)
					{	selectedVoice = i;
						populateVoices();
						break voice_search;
					}
				}
			}
		}
		
		public function selectRandomVoice():void
		{	selectedVoice=Math.floor(Math.random()*langArr[selectedLang].voiceArr.length);
			populateVoices();			
		}
		
		public function getCurrentVoice():TTSVoice
		{
			return(langArr[selectedLang].voiceArr[selectedVoice]);
		}
	}
	
}
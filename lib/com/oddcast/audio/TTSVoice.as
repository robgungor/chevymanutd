/**
* ...
* @author Sam Myer, Me^
* @version 0.2
* 
* @usage
* Data structure for TTS voice to be selected from a list
* required: voice, engine, language IDs 
* optional: voice name, language name, prosody (pitch/rate)
* 
* functions: 
* names are often sent from the backend with country name in parantheses - eg. Esperanza (mexico)
* To strip this data:
* getNameNoCountry() - returns just the name eg. Esperanza
* getCountry() - returns ust the country - eg. Mexico
*/

package com.oddcast.audio {

	public class TTSVoice {
		public var voiceId	:int;
		public var engineId	:int;
		public var langId	:int;
		public var name		:String;
		public var langName	:String;
		public var prosody	:TTSProsody;
		public var gender	:String;
		
		public function TTSVoice(in_voice:int = -1, in_engine:int = -1, in_lang:int = -1, in_name:String = "", in_langName:String = "", in_gender:String = null) 
		{
			voiceId		= in_voice;
			engineId	= in_engine;
			langId		= in_lang;
			name		= in_name;
			langName	= in_langName;
			gender 		= in_gender;
			prosody 	= null;
		}
		
		/**
		 * a complete new reference/copy of this object
		 * @return
		 */
		public function clone(  ):TTSVoice 
		{
			var cloned_voice:TTSVoice = new TTSVoice( voiceId, engineId, langId, name, langName, gender );
			if (prosody)
				cloned_voice.prosody = prosody.clone();
			return cloned_voice;
		}
		
		public function setFromWorkshopCode(codeStr:String):void {
			var code:int=parseInt(codeStr);
			engineId = Math.floor(code/100000);
			langId = Math.floor((code%100000)/1000);
			voiceId = Math.floor(code%100);
		}
		
		public function getWorkshopCode():String {
			if (voiceId==-1) return("-1");
			var code:int=voiceId+langId*1000+engineId*100000;
			return(code.toString());
		}
		
		public function getNameNoCountry():String {
			if (name.indexOf("(") == -1) return name;
			else return(name.slice(0,name.indexOf("(")));
		}
		
		public function getCountry():String {
			if (name.indexOf("(")==-1) return("")
			else return(name.slice(name.indexOf("(")));
		}
		
	}
	
}
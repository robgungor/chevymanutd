/**
* ...
* @author Sam Myer, Me^
* @version 0.2
* @usage
* data structure for TTS audio - includes additional tts text, voice, prosody information
* required: text, voice
* optional: id, fx, name
* type and url are automatically determined
* 
* ttsMode - when this is true audio url is automatically determined from the tts text and voice variables
* when false, audioUrl must be manually set
* 
* Modified by Dave Segal 05.08.08
* 	- removed extraction of 'invalid' characters from string ('\"<>&)
* @udate Me^, 090715 added throttling functionality
* 
*/

package com.oddcast.audio 
{

	public class TTSAudioData extends AudioData 
	{
		private var ttsText					:String;
		private var ttsVoice				:TTSVoice;
		private var prosody					:TTSProsody;
		
		//true by default.  when this is false, you can set the url manually.  when true, it automatically
		//builds the url from the voice and text
		public var ttsMode					:Boolean = true;
		
		/**
		 * constructor for an tts version of AudioData class
		 * @param	in_text user text
		 * @param	in_voice voice
		 * @param	in_id id if any
		 * @param	in_name name if any
		 */
		public function TTSAudioData(in_text:String, in_voice:TTSVoice, in_id:Number = -1, in_name:String = "")
		{
			super("", in_id, TTS, in_name);
			text				= in_text;
			voice				= in_voice;
		}
		
		/**
		 * a complete new reference/copy of this object
		 * @return
		 */
		override public function clone():AudioData
		{
			var cloned_audio:TTSAudioData	= new TTSAudioData( text, ttsVoice.clone(), id, name );
			if (fx)
				cloned_audio.fx = fx.clone();
			return cloned_audio;
		}
		
		public function get text():String {
			if (ttsText != null && ttsText.indexOf("<prosody") >= 0) {
				return(new XML(ttsText).text());
			}
			else return(ttsText);
		}
		public function set text(s:String):void {
			//add prosody tag if it exists and hasn't already been added
			if (s!=null&&s.indexOf("<prosody")>=0) {
				prosody=new TTSProsody();
				var prosodyTag:XMLList=new XMLList(s);
				prosody.setFromXML(prosodyTag);
			}
			
			//remove invalid characters
			//var invalid:String="'\"<>&";
			
			ttsText=s;
		}
		
		public function get textWithProsody():String {
			if (prosody==null) return(ttsText);
			else {
				//temporarily turn off pretty printing
				var prettyPrint:Boolean = XML.prettyPrinting;
				XML.prettyPrinting = false;
				var prosodyStr:String = prosody.getXML(ttsText).toXMLString(); //not pretty
				XML.prettyPrinting = prettyPrint;
				
				return(prosodyStr);
			}
		}
		
		public function get voice():TTSVoice {
			return(ttsVoice);
		}
		
		public function set voice(in_voice:TTSVoice):void {
			ttsVoice=in_voice;
			if (ttsVoice!=null&&ttsVoice.prosody!=null) prosody=ttsVoice.prosody;
		}
		
		override public function get url():String {
			if (!ttsMode) 
				return audioUrl;
			
			var ttsUrl:String;
			if (fx == null) 
				ttsUrl = CachedTTS.getTTSURL(textWithProsody, ttsVoice.voiceId, ttsVoice.langId, ttsVoice.engineId);
			else 
				ttsUrl = CachedTTS.getTTSURL(textWithProsody, ttsVoice.voiceId, ttsVoice.langId, ttsVoice.engineId, fx.type, fx.level);
				
			return ttsUrl;
		}

		override public function set url(s:String):void {
			super.url = s;
			ttsMode = false; //use custom url
		}
	}
	
}
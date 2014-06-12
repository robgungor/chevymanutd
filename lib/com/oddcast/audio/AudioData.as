/**
* ...
* @author Sam Myer, Me^
* @version 0.2
* @usage
* data structure for audio
* required: url
* optional: id, type, fx, name
* 
*/

package com.oddcast.audio 
{

	public class AudioData 
	{
		public static const TTS			:String = "tts";
		public static const PHONE		:String = "phone";
		public static const MIC			:String = "mic"; //in workshops, record by mic is "mic"
		public static const MIC_SITEPAL	:String = "record"; //record by mic is called "record" on the back end in sitepal
		public static const UPLOADED	:String = "upload";
		public static const PRERECORDED	:String = "prerec";
		public static const USER_GENERIC:String = "user";
		
		protected static var tempCounter:int = 1;
		
		public var playOnLoad			:Boolean;
		public var type					:String;
		public var name					:String;
		public var catId				:int;
		public var isPrivate			:Boolean=false;
		private var audioFx				:AudioEffect;
		private var audioId				:int;
		private var _tempId				:int = -1;
		protected var audioUrl			:String;
		
		public function AudioData(in_url:String, in_id:int = -1, in_type:String = null, in_name:String = "")
		{
			_tempId		= tempCounter;
			tempCounter++;
			
			audioUrl	= in_url;
			id			= in_id;
			type		= in_type;
			name		= in_name;
			fx			= null;
			playOnLoad	= false;			
		}
		
		/**
		 * a complete new reference/copy of this object
		 * @return
		 */
		public function clone(  ):AudioData
		{
			var cloned_audio:AudioData	= new AudioData( audioUrl, id, type, name);
			if (fx)
				cloned_audio.fx			= fx.clone();
			cloned_audio.playOnLoad		= playOnLoad;
			cloned_audio.catId			= catId;
			cloned_audio.isPrivate		= isPrivate;
			return cloned_audio;
		}
		
		public function hasFX():Boolean {
			return(fx!=null);
		}
			
		public function get fx():AudioEffect {
			return(audioFx);
		}
		
		public function set fx(in_effect:AudioEffect) : void {
			audioFx=in_effect;
		}		
		
		public function removeFX() : void {
			fx=null;
		}
		
			
		public function get url():String {
			//trace("AUDIO DATA ::: get url : "+url);
			return audioUrl;
		}
		
		public function set url(s:String) : void { 
			audioUrl=s;
		}
		
/*		public function getPostKey():String {
			if (is_tts) return(tts_text+getVoiceId().toString());
			else return(id.toString());
		}*/
		
		public function get id():int {
			return(audioId);
		}
		
		public function set id(n:int) : void {
			audioId=n;
		}
		
		public function get hasId():Boolean {
			return(audioId>0);
		}
		
		public function get tempId():int {
			if (hasId) return(-1);
			else return(_tempId);
		}
		
		/*public function get saveId():String {
			//returns id string for the purpose of saving xml
			if (hasId) return("temp"+_tempId.toString());
			else return(audioId.toString())
		}*/
	}
	
}
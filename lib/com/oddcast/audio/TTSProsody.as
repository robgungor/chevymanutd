/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* data structure for TTS prosody information
* optional vars: rate, pitch
* 
* the TTS engines can accept additional prosody variables
* this is passed to the engines as an XML string
* eg instead of passing 'hello', pass '<prosody rate="80%" pitch="500Hz">hello</prosody>'
* this class saves that rate/pitch infromation
* 
* usage example
* var prosody=new TTSProsody();
* prosody.setFromXML(new XMLNode('<prosody rate="slow" pitch="high">hello</prosody>')) - extracts rate and pitch from XML string
* newStr=prosody.getXML('new string').toString()
* trace(newStr) - <prosody rate="slow" pitch="high">new string</prosody>
*/

package com.oddcast.audio {

	public class TTSProsody {
		public var rate:String;
		public var pitch:String;
		
		public function TTSProsody(in_rate:String="",in_pitch:String="") {
			rate=in_rate;
			pitch=in_pitch;
		}
		
		/**
		 * a complete new reference/copy of this object
		 * @return
		 */
		public function clone(  ):TTSProsody
		{
			var cloned_prosody:TTSProsody = new TTSProsody( rate, pitch );
			return cloned_prosody;
		}
/*
	public function setProsodyVars(prosodyVars:Object) {
		//takes an object e.g. {rate:"fast", pitch:200} - creates xmlnode: rate="fast" pitch="200Hz"
		prosody=new XMLNode(1,"prosody")
		var fname, fval:String;
		for (var fname in prosodyVars) {
			if (typeof prosodyVars[fname]=="number") {
				fval=prosodyVars[fname].toString();
				if (fname=="rate") fval+="%";
				if (fname=="pitch") fval+="Hz";
			}
			else fval=prosodyVars[fname];
			prosody.attributes[fname]=fval;
		}
	}

 */
		public function setFromXML(node:XMLList):void {
			rate=node.@rate.toString();
			pitch=node.@pitch.toString();
		}
		
		public function getXML(text:String = ""):XML {
			var node:XML;
			if (text.indexOf("<prosody") == 0) node = new XML(text);
			else {
				node=new XML("<prosody/>");
				if (text != null && text.length > 0) node.appendChild(text)
			}
			if (rate!=null&&rate.length>0) node.@rate=rate;
			if (pitch!=null&&pitch.length>0) node.@pitch=pitch;
			
			return(node);
		}
	}
	
}
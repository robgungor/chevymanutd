package com.oddcast.audio {
	
	public class ID3comment {
		public function ID3comment(id3Comment : String = null) : void {  {
			this.id3Comment = StringTools.replace(id3Comment,FALSE_ITEM_DELIMITER,ITEM_DELIMITER);
		}}
		
		public function extract(sectionName : String) : String {
			try {
				var chunks : Array = this.id3Comment.split(ITEM_DELIMITER);
				null;
				{
					var _g : int = 0;
					while(_g < chunks.length) {
						var ch : String = chunks[_g];
						++_g;
						var firstEquels : int = ch.indexOf("=");
						if(firstEquels > 0) {
							var id3section : String = StringTools.trim(ch.substr(0,firstEquels - 1));
							var str : String = StringTools.trim(ch.substr(firstEquels + 1));
							var data : String = str.substr(1,str.length - 2);
							if(id3section == sectionName) {
								null;
								return data;
							}
						}
					}
				}
			}
			catch( e : * ){
				null;
			}
			return null;
		}
		
		protected var id3Comment : String;
		static public var AUDIO_DURATION : String = "audio_duration";
		static public var LIP_STRING : String = "lip_string";
		static public var TIMED_PHONEMES : String = "timed_phonemes";
		static public var TIMED_BEATS : String = "timed_beats";
		static public var DATA_DELIMITER : String = String.fromCharCode(9);
		static public var ITEM_DELIMITER : String = ";" + String.fromCharCode(10);
		static public var FALSE_ITEM_DELIMITER : String = ";" + String.fromCharCode(13) + String.fromCharCode(10);
	}
}

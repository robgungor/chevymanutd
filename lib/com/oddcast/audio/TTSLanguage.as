package com.oddcast.audio {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class TTSLanguage {
		public var id:int;
		public var name:String;
		public var sampleText:String;
		public var voiceArr:Array;
		public var charLimitPercent:Number;
		
		public function TTSLanguage($id:int, $name:String, $sampleText:String,$voiceArr:Array,$charLimitPercent:Number=1) {
			id = $id;
			name = $name;
			sampleText = $sampleText;
			voiceArr = $voiceArr;
			charLimitPercent = $charLimitPercent;
		}
	}
	
}
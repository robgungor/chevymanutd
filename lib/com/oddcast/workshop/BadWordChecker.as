/**
* ...
* @author Sam
* @version 0.1
* 
* Adapted from the as2 version of this class
* 
* Constructor:
* BadWordChecker($xml) - if xml is provided, it will get the list of bad words from this xml
* If the $xml parameter is not provided, it will call the php script to get the list of bad words
* 
* validate(str) - if the string passes, an empty string "" will be returned
* - if there is a naughty word in the string, it will return that word
* e.g.
* validate("harmless fun") returns ""
* validate("no shit sherlock") returns "shit"
* 
* replaceBadWords(str) - replaces bad words with their replacements
* e.g. in the XML : <WORD REPLACE="hello" LANG="1">bitch</WORD>
* replaceBadWords("let's test this bitch") returns "let's test this hello"
*/

package com.oddcast.workshop {

	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.events.*;
	
	public class BadWordChecker extends EventDispatcher
	{
		private var badWordXml:XML;
		private var words:Array;
		private var replacements:Object
		/* true indicates the list is already loaded */
		public var is_loaded:Boolean = false;

		public function BadWordChecker() 
		{
			words = new Array();
			replacements = new Object();
		}
		
		private function load_list($xml:XML = null, $door:int = -1):void
		{
			if ($xml != null) 
				gotBadWords($xml);
			else 
			{
				var doorId:int = ($door == -1)?ServerInfo.door:$door;
				var url:String;
				url = ServerInfo.acceleratedURL + "php/ttsAPI/getBadWords/doorId=" + doorId;
				XMLLoader.loadXML(url,gotBadWords);
			}
		}
		
		
		/**
		 * 
		 * @param _callbacks fin(), error(AlertEvent)
		 * 
		 */		
		public function load( _callbacks:Callback_Struct ):void 
		{
			if (!is_loaded)
			{	add_listeners();
				load_list();
				
				function loaded( _e:Event ):void
				{	is_loaded=true;
					remove_listeners();
					_callbacks.fin();
				}
				function error( _e:AlertEvent ):void 
				{	remove_listeners();
					_callbacks.error( _e );
				}
				function add_listeners():void
				{	addEventListener( Event.COMPLETE, loaded );
					addEventListener( AlertEvent.EVENT, error );
				}
				function remove_listeners():void
				{	removeEventListener( Event.COMPLETE, loaded );
					removeEventListener( AlertEvent.EVENT, error );
				}
			}
			else
				_callbacks.fin();
		}
		
		private function gotBadWords(_xml:XML) : void
		{
			var mode:int = 0;
			if (_xml == null) mode=0;
			else if (_xml.hasOwnProperty("ITEM")) mode = 1;  //for backwords compatilibility
			else if (_xml.hasOwnProperty("WORD")) mode = 2;
			
			var alertEvt:AlertEvent = XMLLoader.checkForAlertEvent();
			if (mode == 0 || alertEvt != null)
			{
				is_loaded = false;
				dispatchEvent(alertEvt);
				return;
			}
			else if (mode == 1) parseBadWordsV1(_xml);
			else if (mode == 2) parseBadWordsV2(_xml);
			is_loaded = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function parseBadWordsV1(_xml:XML)  : void
		{	words = new Array();
			replacements = new Object();
			for (var i:int = 0; i < _xml.ITEM.length(); i++) 
			{	words.push(_xml.ITEM[i].@W.toString())
			}
		}
		
		private function parseBadWordsV2(_xml:XML)  : void
		{	words = new Array();
			replacements = new Object();
			var word:String;
			var rword:String;
			for (var i:int = 0; i < _xml.WORD.length(); i++) {
				word = _xml.WORD[i].text().toString();
				rword = _xml.WORD[i].@REPLACE.toString();
				words.push(word);
				if (rword != null && rword.length > 0) replacements[word] = rword;
			}
		}

		private function isPunctuation(code:int):Boolean {
			if ((code<48)||(code>57&&code<65)||(code>90&&code<97)||(code>122&&code<128)||(code>154&&code<160)) {
				return(true);
			}
			else return(false);
		}
		
		private function testIdeograph(s:String):Boolean {
			//returns true if this contains ideographic (east asian) characters or mixed
			//returns false if this contains only alphabetic characters
			
			for (var i:int = 0; i < s.length; i++) {
				if (s.charCodeAt(i) >= 0x4e00 && s.charCodeAt(i) < 0xa000) return(true);
			}
			return(false);
		}
		
		public function validate(str:String):String {
			//check if each word exists in the string
			str=str.toLowerCase();
			var pos:int;
			var endpos:int;
			
			var isIdeograph:Boolean = testIdeograph(str);
			
			for (var i:int=0;i<words.length;i++) {
				pos = str.indexOf(words[i]);
				if (isIdeograph) {
					//in case of east asian languages don't worry about spaces or punctuation
					if (pos != -1) return(words[i]);
				}
				else {
					while (pos!=-1) {
						endpos=pos+words[i].length;
						//check the characers immediately preceding and following the word to make sure they are not alphabetic
						if ((pos==0||isPunctuation(str.charCodeAt(pos-1)))&&(endpos==str.length||isPunctuation(str.charCodeAt(endpos)))) {
							return(words[i]);
						}
						pos=str.indexOf(words[i],pos+1);					
					}
				}
			}
			return("");
		}
		
		public function replaceBadWords(str:String):String {
			//check if each word exists in the string
			var pos:int;
			var endpos:int;
			
			var isIdeograph:Boolean = testIdeograph(str);
			var regexp:RegExp;
			
			var word:String;
			for (word in replacements) {
				regexp = new RegExp(word, "gi"); //case-insensitive search
				if (isIdeograph) {
					//in case of east asian languages don't worry about spaces or punctuation
					str.replace(regexp, replacements[word]);
				}
				else {
					while (regexp.test(str)) {
						endpos = regexp.lastIndex;
						pos=endpos-word.length;
						//check the characers immediately preceding and following the word to make sure they are not alphabetic
						if ((pos==0||isPunctuation(str.charCodeAt(pos-1)))&&(endpos==str.length||isPunctuation(str.charCodeAt(endpos)))) {
							str = str.slice(0, pos) + replacements[word] + str.slice(endpos);
						}
					}
				}
			}
			return(str);
		}
	}
}
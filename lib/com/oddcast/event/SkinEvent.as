/**
* ...
* @author Default
* @version 0.1
* 
* obj contains extra data sent for with the following event:
* VOLUME - obj is a Number from 0 to 1
* SAY_FAQ, LEAD_SUCCESS, LEAD_ERROR - obj is a String representing audio url
* SAY_AI - obj is Object {text:text, voice:voice, lang:lang, engine:engine, bot:bot}
* SEND_LEAD - obj is Object {xml:fieldsXml, tf1:text1, tf2:text2, ... }
*/

package com.oddcast.event {
	import flash.events.Event;

	public class SkinEvent extends Event {
		public static var PLAY:String="play";
		public static var STOP:String="stop";
		public static var PAUSE:String="pause";
		public static var MUTE:String="mute";
		public static var UNMUTE:String="unmute";
		public static var PREV:String="prev";
		public static var NEXT:String="next";
		public static var VOLUME_CHANGE:String="volumeChange";
		
		public static var SAY_AI:String="sayAI";
		public static var SAY_FAQ:String="sayFAQ";
		public static var SEND_LEAD:String="sendLead";
		public static var LEAD_SUCCESS:String="leadSuccess";
		public static var LEAD_ERROR:String="leadError";
		
		public var obj:Object;
		
		public function SkinEvent(type:String,$obj:Object=null,bubbles:Boolean=false) {
			super(type,bubbles);
			obj=$obj;
		}
					
		public override function clone():Event {
			return new SkinEvent(type,obj);
		}
		
	}
	
}
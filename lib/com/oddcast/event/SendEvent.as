/**
* ...
* @author Sam Myer, Me^
* @version 0.1
* 
* messageXML - an xml node containing name, email, message, etc.
* 
*/

package com.oddcast.event {
	import flash.events.Event;

	public class SendEvent extends Event {
		public var sendMode:String;
		public var messageXML:XML;
		public var responseStr:String;
		
		//modes:
		public static const EMAIL				:String = "email";
		public static const POST				:String = "post";
		public static const EMBED_CODE			:String = "embed";
		public static const GET_PLAYER_URL		:String = "getUrl";
		public static const MOBILE				:String = "mobile";
		public static const MYSPACE				:String = "myspace";
		public static const FACEBOOK			:String = "facebook";
		public static const SAVE				:String = "save";
		public static const DOWNLOAD_VIDEO		:String = "downloadVideo";
		public static const DOWNLOAD_IMAGE		:String = "downloadImage";
		public static const GIGYA				:String = "sending mode gigya";
		public static const BITLY				:String = "sending mode bitly";
		
		//event types:
		public static const SEND				:String = "sendMessage";
		public static const DONE				:String = "sendDone";
		
		public function SendEvent(type:String,in_sendMode:String,in_messageXML:XML=null) {
			super(type);
			sendMode=in_sendMode;
			messageXML=in_messageXML;
		}
		
		public override function clone():Event {
			return new SendEvent(type,sendMode,messageXML);
		}
		
	}
	
}
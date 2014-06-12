/**
* ...
* @author Sam
* @version 0.1
* 
* constructors:
* PhoneRecordedEvent(SAVEDONE,url,extension)
* PhoneRecordedEvent(LOADED,passCode,phoneNum)
* PhoneRecordedEvent(MESSAGE_RECEIVED,msg)
* PhoneRecordedEvent([any other event type])
* 
*/

package com.oddcast.event {
	import flash.events.Event;
		
	public class PhoneRecorderEvent extends Event {		
		private var str1:String;
		private var str2:String;
		private var arr:Array;
		private var _data:Object;

		public static const LOADED:String = "otc_onLoaded";
		public static const MESSAGE_RECEIVED:String = "otc_onMessageReceived";
		public static const DISCONNECTED:String = "otc_onPhoneDisconnect";
		public static const CONNECTED:String = "otc_onPhoneConnect";
		public static const PROCESSING:String = "otc_onAudioProcessing";
		public static const RECORDING:String = "otc_onAudioStartRecord";
		public static const RECORDED:String = "otc_onAudioRecorded";
		public static const SAVING:String = "otc_onAudioSaving";
		public static const SAVEDONE:String = "otc_onAudioReady";
		public static const IDLE:String = "otc_onIdle";
		public static const CAPTCHA:String = "otc_onCaptcha";
		public static const CAPTCHA_FAILED:String = "otc_onCaptchaFailed";
		public static const INTERMEDIATE_AUDIO_READY:String = "otc_onIntermediateAudioReady";
		
		
	
		public function PhoneRecorderEvent(in_type:String,data:Object=null){//,in_str1:String=null,in_str2:String=null) {
			super(in_type);
			if (data != null)
			{
				if (!(data is String))
				{
					arr = data.arr;
					str1 =  data.str1; //in_str1;
					str2 =  data.str2;  //in_str2;
				}
			}
			_data = data;
		}

		public function get msg():String {
			if (type==MESSAGE_RECEIVED) return str1
			else return null;
		}
		
		public function get passCode():String {
			if (type==LOADED) return str1;
			else return null;
		}
		public function get phoneNum():String {
			if (type==LOADED) return str2;
			else return null;
		}
		public function get url():String {
			if (type==SAVEDONE) return str1
			else return null;
		}
		public function get urls():Array
		{
			if (type==SAVEDONE) return arr
			else return null;
		}
		public function get extension():String {
			if (type==SAVEDONE) return str2
			else return null;
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public override function clone():Event {
			return new PhoneRecorderEvent(type,_data);
		}
		
	}
	
}
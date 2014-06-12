/**
* ...
* @author Sam Myer, Jon Achai
* @version 2.0
* 
* adapted from AS2 original written by Jon
* @see o:\audioComponents\OTC\as\config.as
* 
*/

package com.oddcast.audio {

	public class PhoneConfig {
		public static const DEFAULT_POLLING_RATE:uint = 2000;
		public static const MIN_POLLING_RATE:uint = 250;
		public static const TIMEOUT_IDLE:uint = 180000; //3 minutes
		public static const TIMEOUT_ERROR:uint = 30000; //30 seconds
		public static const TIMEOUT_INFO_MISSING:uint = 10000 // 10 seconds
		public static const PHPURL:String = "";
		public static var URL_GET_INFO:String = "getCallInfo.php";
		public static var URL_GET_STATUS:String = "getCallStatus.php";
		public static var URL_CLICK_TO_CONNECT:String = "initPhoneSession.php";
		public static var URL_CLICK_TO_CONF:String = "initConfSession.php";
		public static var URL_IVR_REQUEST:String = "sendIVRrequest.php";
		private static var BASE_URL:String=""
		
		public static function setBaseUrl(url:String) {
			//public static var MY_URL:String = this._url.substr(0,this._url.lastIndexOf("/")+1);		
			BASE_URL=url;
			URL_GET_INFO = BASE_URL+"getCallInfo.php";
			URL_GET_STATUS = BASE_URL+"getCallStatus.php";
			URL_CLICK_TO_CONNECT = BASE_URL+"initPhoneSession.php";
			URL_CLICK_TO_CONF = BASE_URL + "initConfSession.php";	
			URL_IVR_REQUEST = BASE_URL + "sendIVRrequest.php";
		}
		
	}
	
}
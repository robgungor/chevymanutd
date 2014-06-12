/**
* ...
* @author Sam Myer, Jon Achai
* @version 2.0
* 
* adapted from AS2 original written by Jon
* @see o:\audioComponents\OTC\classes\otc.as - original file
* 
* o:\audioComponents\OTCv3\OTC.as - contains documentation
*/

package com.oddcast.audio {
	import com.adobe.crypto.MD5;
	import com.oddcast.event.PhoneRecorderEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.oddcast.audio.PhoneConfig;
	import com.oddcast.utils.XMLLoader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.TimerEvent;

	public class PhoneRecorder extends EventDispatcher {
		//private var url_phoneStatus:String;
		//private var url_audio:String;
		private var phoneData:PhoneData;
		//private var statusXML:XML;
		private var checkStatusInterval:uint;
		private var pollingTimer:Timer;
		private var phoneConnected:Boolean;
		private var idleTimeout:Number;
		private var errorTimeout:Number;
		private var errorStart:Number;
		private var idleStart:int;
		private var idleState:String;
		private var paramStr:String;	
		private var _sExternalPasscode:String;
		private var _sMode:String;
		private var _sOrigMode:String;
		private var _sApp:String;
		private var _sAcc:String;
		private var permissions:XML;
		private var _sNumToCall:String;
		private var _sCaptchaUserInput:String;
		private var _sCaptchaImgUrl:String;
		private var xmlTimeout:Timer;
		
		private var _bIdleTimeout:Boolean = true;
		private var _bWaitForResponse:Boolean;
		private var _bMissedPoll:Boolean;
		
		//private var accountInfoStr:String;
		
		public function PhoneRecorder(checkStatusRate:uint,in_paramStr:String,in_app:String,in_acc:String,in_passCode:String,in_idleTimeout:uint,in_mode:String,in_numToCall:String){
			if (in_mode==null||in_mode.length==0) _sMode="you_call";
			else _sMode=in_mode;
			_sOrigMode = _sMode;
			
			_sNumToCall = in_numToCall;
			
			if (in_passCode!=null&&in_passCode.length>0) _sExternalPasscode = in_passCode;
			else _sExternalPasscode="";

			phoneData = new PhoneData();
			phoneConnected = false;
			_sCaptchaUserInput = "";
			idleTimeout = in_idleTimeout; // 180000;
			errorTimeout = PhoneConfig.TIMEOUT_ERROR; //30000; 
			errorStart = 0;
			
			paramStr = in_paramStr;
			_sApp = in_app;
			_sAcc=in_acc;
			
			//some applications (like mastercard) don't need idle timeout		
			if (_sAcc!=null&&_sAcc.indexOf("123")==0) {//temp condition for mastercard
				//trace("idleTimeout=300000");			
				//_bIdleTimeout = false; // CHARLES DID THIS!
				idleTimeout = 300000; // default value for MasterCard... CHARLES DID THIS!
			}
			
			checkStatusInterval = Math.max(checkStatusRate,PhoneConfig.MIN_POLLING_RATE);
			pollingTimer=new Timer(checkStatusInterval);
			pollingTimer.addEventListener(TimerEvent.TIMER,checkPhoneStatus,false,0,true);
			
			setPhoneInfo();
		}
		
		public function restart(pc:String="")	{
			_sMode = _sOrigMode;
			_sCaptchaUserInput = "";
			//trace("in restart dave");
			if (pc.length>0) {			
				_sExternalPasscode = pc;
			}
			stopPolling();
			errorStart = 0;
			//idleStart = getTimer();
			phoneData = new PhoneData();
			setPhoneInfo();	
		}
		
		private function setPhoneInfo()	{
			//trace("OTC::setPhoneInfo")

			xmlTimeout=new Timer(PhoneConfig.TIMEOUT_INFO_MISSING,1);
			xmlTimeout.addEventListener(TimerEvent.TIMER,xmlTimeoutError,false,0,true);
			xmlTimeout.start();
			
			//trace ("getPhoneInfo: "+_global.PHPURL+'getPhoneInfo.php?len='+ad_length+_global.g_devQuery);
			var url:String=PhoneConfig.PHPURL+PhoneConfig.URL_GET_INFO+"?app="+_sApp+"&acc="+_sAcc+'&extparam='+paramStr+"&pc="+_sExternalPasscode+"&rand="+getTimer();
			XMLLoader.loadXML(url,gotPhoneInfo);
			
		}
		
		private function xmlTimeoutError(evt:TimerEvent) {			
			onError("can not retrieve call info");
		}
		
		public function gotPhoneInfo(_xml:XML) {
			xmlTimeout.removeEventListener(TimerEvent.TIMER,xmlTimeoutError);
			xmlTimeout.reset();
			
			//trace("OTC::gotPhoneInfo : "+_xml.toXMLString());
			//trace("this.firstChild.attributes.ACTIVE=>"+this.firstChild.attributes.ACTIVE+"<");
			
			if (_xml.@ACTIVE.length>0&&_xml.@ACTIVE=="0") {
				//changed to silent error
				//self.phoneData.addCallback("onError");
				//_global.OTC_Parent.otc_onError('Record by Phone functionality is not supported for this application');
				dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.LOADED,{str1:"Not Supported",str2:"Not Supported"}));	
			}
			else if (parseInt(_xml.@ERROR)==1)	{
				onError(_xml.@STR);
			}
			else if (checkEnabledOptions(_xml)) {
				phoneData.passCode=_xml.@PASSCODE;
				phoneData.phoneNum=unescape(_xml.@PHONE);
				phoneData.useCaptcha = String(_xml.@CAPTCHA) == "1";
				phoneData.appId = int(_xml.@APPID);
				if (phoneData.useCaptcha)
				{
					_sCaptchaImgUrl = String(_xml.@CAPTCHAIMG);
					dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.CAPTCHA));
				}
				if (phoneData.passCode.length>0) {
					//url_phoneStatus = _global.PHPURL+_global.URL_GET_STATUS+accountInfoStr+'&extparam='+paramStr+'&passcode='+phoneData.getPasscode();//'getPhoneStatus.php?'+_global.g_devQuery;
					ready();
				}				
				else onError("Phone info not available");
				
			}
			else onError("Permission error "+_sMode);
		}

		private function checkEnabledOptions(_xml:XML=null)	{
			if (_xml!=null) permissions = _xml;

			if (_sMode=="you_call" && parseInt(permissions.@YOUCALL)==0) return false;
			else if (_sMode=="click_to_connect" && parseInt(permissions.@CLICKCONNECT)==0) return false;
			else if (_sMode=="click_to_conference" && parseInt(permissions.@CLICKCONF)==0) return false;
			else return true;
		}

		private function ready()	{
			//trace("OTC::ready")
			dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.LOADED,{str1:phoneData.passCode,str2:phoneData.phoneNum}))
			
			//trace("_sMode="+_sMode);
			if (_sMode=="you_call")	{
				idleStart = getTimer();
				startPolling();
			}
			else if (_sMode=="click_to_connect" && _sNumToCall.length>0) {
				if (!phoneData.useCaptcha)
				{
					callConnect(_sNumToCall);
				}
			}
			else if (_sMode=="click_to_conference" && _sNumToCall.length>0)	{
				if (!phoneData.useCaptcha)
				{				
					callConference(_sNumToCall);
				}
			}
			
		}
		
		public function callConnect(n:String) {		
			_sMode = "click_to_connect";	
			_sNumToCall = n;
			if (checkEnabledOptions())	{
				//get the secret phrase based on passcode
				//trace("MD5("+String(phoneData.passCode)+_sApp+n+(_sCaptchaUserInput.length>0?MD5.hash(_sCaptchaUserInput):'')+getCSPC()+")");
				var cs:String;
				if (phoneData.useCaptcha)
				{
					cs = MD5.hash(String(phoneData.passCode) + _sApp + n + (_sCaptchaUserInput.length>0?MD5.hash(_sCaptchaUserInput):'') + getCSPC());
				}
				else
				{
					cs = MD5.hash(String(phoneData.passCode) + _sApp + n + getCSPC());
				}
				var url:String=PhoneConfig.PHPURL+PhoneConfig.URL_CLICK_TO_CONNECT+"?passcode="+phoneData.passCode+"&appName="+_sApp+"&phonenumber="+n+"&chsm="+cs + (phoneData.useCaptcha?("&cInput="+(_sCaptchaUserInput.length>0?MD5.hash(_sCaptchaUserInput):'')):"");
				//trace("OTC::callConnect "+url);
				XMLLoader.loadXML(url,callSessionConnected);
			}
			else {
				onError("permission error "+_sMode);
			}
		}
		
		public function setCaptchaInput(s:String):void
		{
			if (phoneData.useCaptcha)
			{
				_sCaptchaUserInput = s;
			}
		}
		
		public function getCaptchaImageURL():String
		{
			return _sCaptchaImgUrl += "?rnd=" + Math.random() * 1000000;// getTimer();
		}
		
		private function getCSPC():String
		{
			var s:String = String(phoneData.passCode);
			var ml:Number = 1;//multiplcation
			var sm:Number = 0;//sum
			var charVal:int;
			//trace("s.length="+s.length)
			for (var i:int = 0; i < s.length;++i)
			{
				charVal = int(s.charAt(i));
				if (charVal > 0)
				{
					sm += charVal;
					ml *= charVal;
				}
			}
			return String(sm * ml);
		}
		
		public function callSessionConnected(_xml:XML) {
			//trace("callSessionConnected phoneData.useCaptcha="+phoneData.useCaptcha+" _xml.@RES.toString()="+_xml.@RES.toString());
			if (_xml.@RES.toString()=="OK") {				
				startPolling();		
				idleStart = getTimer();
				if (phoneData.useCaptcha)
				{
					dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.CAPTCHA_OK));
				}
			}
			else 
			{
				if (_xml.child("TEST")!=null)
				{
					if (String(_xml.child("TEST").@RES).toLowerCase().indexOf("auth") >= 0)
					{
						dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.CAPTCHA_FAILED));
					}
					else
					{
						onError("click to call init failed " + _xml.child("TEST").@RES);
					}
				}
				else
				{
					onError("click to call init failed " + _xml.child("TEST").@RES);
				}
			}
			
		}
		
		
		public function callConference(n:String) {		
			_sMode = "click_to_conference";	 
			if (checkEnabledOptions()) {
				var cs:String;
				if (phoneData.useCaptcha)
				{
					cs = MD5.hash(String(phoneData.passCode) + _sApp + n + (_sCaptchaUserInput.length>0?MD5.hash(_sCaptchaUserInput):'') + getCSPC());
				}
				else
				{
					cs = MD5.hash(String(phoneData.passCode) + _sApp + n + getCSPC());
				}
				var url:String = PhoneConfig.PHPURL+PhoneConfig.URL_CLICK_TO_CONF+"?passcode="+phoneData.passCode+"&appName="+_sApp+"&phonenumber="+n+"&chsm="+cs + (phoneData.useCaptcha?("&cInput="+(_sCaptchaUserInput.length>0?MD5.hash(_sCaptchaUserInput):'')):"");
				//trace("OTC::callConference "+url);
				XMLLoader.loadXML(url,conferenceSessionConnected);
			}
			else {
				onError('permission error '+_sMode);
			}
		}
		
		public function conferenceSessionConnected(_xml:XML) {
			if (_xml.@RES.toString()=="OK") {
				//self.startPolling();		
				//self.idleStart = self.getTimer();
			}
			else {
				onError("click to conference init failed");
			}
		}		

		public function startPolling() {
			//trace("startPolling...");
			if (phoneData.hasCallback(PhoneRecorderEvent.CONNECTED)) pollingTimer.delay=checkStatusInterval;
			else pollingTimer.delay=2*checkStatusInterval; //if not connected check slower than while call is active
				
			pollingTimer.start();
		}		
		
		public function stopPolling()	{
			//trace("stopPolling...");
			pollingTimer.reset();
		}
		
		private function restartPolling() {
			//trace("restartPolling...");
			stopPolling();
			startPolling();
		}
		
		private function checkPhoneStatus(evt:TimerEvent) {
			var url:String=PhoneConfig.PHPURL+PhoneConfig.URL_GET_STATUS+"?app="+_sApp+"&acc="+_sAcc+"&extparam="+paramStr+"&passcode="+phoneData.passCode+"&rand="+getTimer();
			//trace("OTC::checkPhoneStatus url="+url);
			if (!_bWaitForResponse)
			{
				XMLLoader.loadXML(url, processStatusXML);
				_bWaitForResponse = true;
			}
			else
			{
				_bMissedPoll = true;
			}
		}
				
		public function processStatusXML(_xml:XML) {
			if (_bMissedPoll)
			{
				restartPolling();
				_bMissedPoll = false;
			}
			_bWaitForResponse = false;		
			if (_xml == null) throw new Error(XMLLoader.lastError);
			//trace(_xml.toXMLString());
			var status:int = parseInt(_xml.@PHONESTATUS.toString());
			var state:int = parseInt(_xml.@STATE.toString());
			var tempAudio:String = _xml.@TEMP_AUDIO != null? String(_xml.@TEMP_AUDIO) : '';
			if (tempAudio.length > 0)
			{
				dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.INTERMEDIATE_AUDIO_READY,unescape(tempAudio)));
			}
			
			var audioStatus:int = _xml.children().length()>0?parseInt(_xml.children()[0].@STATUS.toString()):-1;
			var audioUrl:String;
			var audioExt:String;
			var audioArr:Array;
			var item:XML;
			
			if (_xml.@RES.toString().indexOf("ERROR")==0) {
				onError(_xml.@RES.toString());
				return;
			}
		
			if (_xml.@CHECKINT.length()>0) {
				//trace("got a checkInt = "+obj.attribtues.CHECKINT)
				var newInt:int = parseInt(_xml.@CHECKINT.toString())*1000;
				
				if (newInt<PhoneConfig.MIN_POLLING_RATE) newInt=PhoneConfig.MIN_POLLING_RATE;
				
				if (checkStatusInterval!=newInt) {
					//trace("new interval:"+newInt);
					checkStatusInterval=newInt;
					startPolling();
				}
			}
			
			var newIdleState:String = status.toString()+"_"+state.toString();
			//trace(newIdleState)
			if (idleState!=newIdleState) {
				idleStart=getTimer();
				idleState = newIdleState;
			}
			
			if (overTimeLimit(idleStart,idleTimeout)) {
				//trace("overTimeLimit returned true!!!")
				idleError()
				return;
			}
			
			if (overTimeLimit(errorStart,errorTimeout))	{
				//condition added to avoid false reporting with problem with disconnect indication
				if (!phoneData.hasCallback(PhoneRecorderEvent.PROCESSING)) {
					//trace("overTimeLimit returned true (processing)!!!")
					processingError();
				}
				else {
					//disconnect and stop polling
					dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.DISCONNECTED));
					phoneConnected = false;
					stopPolling();
				}
				return;
			}	
			
			if (status==1) {//is connected
				//new code added ag - 09/05/06					
				if (!phoneData.hasCallback(PhoneRecorderEvent.CONNECTED)) {
					dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.CONNECTED));
					phoneConnected = true;
					restartPolling();
				}	
						
				switch (state) {		
					
					case 0:
					case 1:
						/*if (obj.childNodes.length==0)//just connected
							if (!phoneData.hasCallback("onPhoneConnect")) {
								_global.OTC_Parent.otc_onPhoneConnect();
								phoneData.addCallback("onPhoneConnect");
								restartPolling();
							}
						*/
						
						if (_xml.children().length()>0) {//there's audio and/or it's still processing
						
							//var audioStatus:int = parseInt(_xml.children()[0].@STATUS.toString());
							if (audioStatus<=7) {//still processing
								//make callback
								if (!phoneData.hasCallback(PhoneRecorderEvent.PROCESSING)) {
									errorStart = getTimer();
									dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.PROCESSING));
								}
							}
							else if (audioStatus>=9) {
								if (!phoneData.hasCallback(PhoneRecorderEvent.SAVING)) {
									dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.SAVING));
								}	
							}
						}
						break;
					
					case 2:
						if (!phoneData.hasCallback(PhoneRecorderEvent.RECORDING)) {
							dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.RECORDING));
							phoneData.removeCallback(PhoneRecorderEvent.RECORDED);
						}
						break;
					case 3:
						if (!phoneData.hasCallback(PhoneRecorderEvent.RECORDED)) {
							dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.RECORDED));
							phoneData.removeCallback(PhoneRecorderEvent.RECORDING);
						}						
						break;
					case 4:
					case 5:
					case 6:
						if (!phoneData.hasCallback(PhoneRecorderEvent.PROCESSING)) {
							dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.PROCESSING));
						}											
						break;
					case 7:
					case 8:
					case 9:
					case 10:
					case 11:
					case 12:
						if (!phoneData.hasCallback(PhoneRecorderEvent.SAVING)) {
							dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.SAVING));
						}											
						break;						
				}
			}
			else if (status==2 && phoneData.hasCallback(PhoneRecorderEvent.CONNECTED)) {//phone disconnected
			
				if (_xml.children().length()>0) {//there's audio and/or it's still processing 

					//var audioStatus:int = parseInt(_xml.children()[0].@STATUS.toString());
					if (audioStatus<9) {//still processing
					
						errorStart = getTimer();
						//make callback
						if (!phoneData.hasCallback(PhoneRecorderEvent.PROCESSING)) {
							dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.PROCESSING));
						}
					}
					else if (audioStatus>=9) {												
						if (!phoneData.hasCallback(PhoneRecorderEvent.SAVEDONE)) {
							if (_xml.children().length() > 1)
							{
								audioArr = new Array();								
								for each(item in _xml.children())
								{
									audioArr.push(item.@URL);
								}
								dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.SAVEDONE, {arr:audioArr}));
							}
							else
							{
								audioUrl=_xml.children()[0].@URL.toString();
								audioExt=_xml.children()[0].@EXT.toString()							
								dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.SAVEDONE, {str1:audioUrl,str2:audioExt}));
							}
							stopPolling();
						}	
					}


				}
				//trace("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! - "+phoneData.hasCallback(PhoneRecorderEvent.DISCONNECTED));
				if (!phoneData.hasCallback(PhoneRecorderEvent.DISCONNECTED)) {
					dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.DISCONNECTED));
					phoneConnected = false;
				}
			}
			
			//audio is ready before hangup
			//trace("OTCv3::audio is ready before hangup _xml.children().length=" + _xml.children().length()+" xmlString="+_xml.toXMLString());
			if (_xml.children().length()>0 && audioStatus>=9 && !phoneData.hasCallback(PhoneRecorderEvent.SAVEDONE)) {//there's audio and/or it's still processing 
				if (_xml.children().length() > 1)
				{
					audioArr = new Array();					
					for each(item in _xml.children())
					{
						audioArr.push(item.@URL);
					}
					dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.SAVEDONE, {arr:audioArr}));
				}
				else
				{
					audioUrl=_xml.children()[0].@URL.toString();
					audioExt=_xml.children()[0].@EXT.toString()							
					dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.SAVEDONE, {str1:audioUrl,str2:audioExt}));
				}				
			}
			
			//added to support messaging (mastercard project)
			if (_xml.@MSG.length()>0)	{ //if has attribute MSG
				//trace("calling otc_onMessageReceived"+_xml.@MSG);
				dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.MESSAGE_RECEIVED,{str1:_xml.@MSG.toString()}))
				idleStart=getTimer();
			}
			
			if (phoneData.hasCallback(PhoneRecorderEvent.CONNECTED) && !phoneConnected && (phoneData.hasCallback(PhoneRecorderEvent.SAVEDONE) || !phoneData.hasCallback(PhoneRecorderEvent.PROCESSING))) {
				//trace("phoneConnected="+phoneConnected+', phoneData.hasCallback("onAudioReady")='+phoneData.hasCallback(PhoneRecorderEvent.SAVEDONE)+', phoneData.hasCallback("onAudioProcessing")'+phoneData.hasCallback(PhoneRecorderEvent.PROCESSING) )
				stopPolling();
			}
			
		}
		
		public function sendIVRCommand(cmd:String, params:String = ""):void
		{
			if (phoneData.hasCallback(PhoneRecorderEvent.CONNECTED) && !phoneData.hasCallback(PhoneRecorderEvent.DISCONNECTED))
			{				
				var urlLoader:URLLoader = new URLLoader(new URLRequest(PhoneConfig.URL_IVR_REQUEST + "?appId=" + phoneData.appId + "&pc=" + phoneData.passCode + "&ph=" + _sNumToCall + "&act="+cmd+"&"+params+"&rnd="+Math.random()*1000000));								
			}
		}
		
		/*
		public function sendStartRecord():void
		{
			if (phoneData.hasCallback(PhoneRecorderEvent.CONNECTED) && !phoneData.hasCallback(PhoneRecorderEvent.DISCONNECTED))
			{				
				var urlLoader:URLLoader = new URLLoader(new URLRequest(PhoneConfig.URL_IVR_REQUEST + "?appId=" + phoneData.appId + "&pc=" + phoneData.passCode + "&ph=" + _sNumToCall + "&act=startRecording"));								
			}
		}
		
		public function sendTerminateCall():void
		{
			if (phoneData.hasCallback(PhoneRecorderEvent.CONNECTED) && !phoneData.hasCallback(PhoneRecorderEvent.DISCONNECTED))
			{
				var urlLoader:URLLoader = new URLLoader(new URLRequest(PhoneConfig.URL_IVR_REQUEST + "?appId=" + phoneData.appId + "&pc=" + phoneData.passCode + "&ph=" + _sNumToCall + "&act=terminateCall"));								
			}
		}
		*/
		
		private function overTimeLimit(startTime:int,limit:uint):Boolean {
			if (!_bIdleTimeout) return false;  //do not use idle timeout when this is set
			
			var curTime:int = getTimer();

			if (((curTime-startTime)>limit) && startTime>0)	return true;
			else return false;
		}

		private function idleError() {
			//trace("idleError");
			stopPolling();
			dispatchOTCEvent(new PhoneRecorderEvent(PhoneRecorderEvent.IDLE));
		}
		
		private function processingError() {
			//trace("processingError");
			stopPolling();
			onError("processing error");			
		}
		
		private function onError(errorStr:String) 
		{
			stopPolling();
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,errorStr));
		}
		
		private function dispatchOTCEvent(evt:PhoneRecorderEvent) {
			phoneData.addCallback(evt.type);
			dispatchEvent(evt);
		}
		
		public function destroy() {
			pollingTimer.stop();
			xmlTimeout.stop();
			pollingTimer.removeEventListener(TimerEvent.TIMER,checkPhoneStatus);
			xmlTimeout.removeEventListener(TimerEvent.TIMER,xmlTimeoutError);
		}
	}
	
}
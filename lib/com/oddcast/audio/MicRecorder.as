/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* This is the ORC recorder object - it handles all the communication between the microphone and FMS
* 
* variables:
* errorReportingURI - URI of php file to POST error log info to
* 
* functions:
* playStart - start playback
* playStop - stop playback
* pause - pause playback
* playStartPause - toggles between play and pause states
* recordStart - start record
* recordStop - stop recording
* save(audioName[, normalization])
* 
* events:
* MicRecorderEvent.READY_STATE - changes when privacy settings are allowed/denied or mic is muted/unmuted
* newState = 1 if mic is ready, 0 is mic isn't ready
* 
* MicRecorderEvent.SAVE_DONE - save done
* message = id/url returned by FMS
* 
* MicRecorderEvent.ERROR
* message - error message returned by FMS
* 
* MicRecorderEvent.STREAM_STATUS - when state (playing/recording/stopped/paused) changes	
* oldState= previous state ID
* newState = new state ID
*/

package com.oddcast.audio {
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.events.ActivityEvent;
	import flash.events.StatusEvent;
	import flash.events.NetStatusEvent;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.system.Capabilities;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.sendToURL;
	import com.oddcast.event.MicRecorderEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import flash.utils.setInterval;

	public class MicRecorder extends EventDispatcher {
		private var server_uri:String,uid:String,app:String,app_params:String,connID:String;
		private var micRateKHz:Number;
		private var sErrorReportingURI:String; /// where to report errors
		
		private var streamStatus:int;
		private var streamName:String;
		
		private var mic:Microphone;
		private var net_con:NetConnection;
		private var lastNetConnection:NetConnection;
		private var net_str:NetStream;
		private var _nMicActivityLevel:Number;
		private var _bMicActivityDetected:Boolean;
		private var _timerMicActivity:Timer;
		
		public static var NOAUDIO:int=0;
		public static var RECORDING:int=1;
		public static var STOPPED:int=2;
		public static var PLAYING:int=3;
		public static var PAUSED:int = 4;		
		
		public static const CHECK_MIC_INTERVAL:int = 1000; 
				
		private var _oConstructorParams:Object;
		private var _bConnectionClosedByServer:Boolean;
		private var _iLastUserAction:int;
		
		public function MicRecorder(_uri:String, _uid:String, _app:String, _app_params:String, _micRateKHz:Number=22 ,connectionId:Number=0){
			trace("AudioRecorder created:   _uri="+_uri+"  _uid="+_uid+"  _app="+_app+"  _app_params="+_app_params+"  _micRateKHz="+_micRateKHz+",connectionId="+connectionId );
			_oConstructorParams = { uri:_uri, uid:_uid, app:_app, app_params:_app_params, micRate:_micRateKHz, conId:connectionId };
			init();
			
		}
		
		private function init():void
		{
			
			streamStatus = 0;
			server_uri = _oConstructorParams.uri;// _uri;
			uid = _oConstructorParams.uid;// _uid;
			app = _oConstructorParams.app;// _app;
			app_params = _oConstructorParams.app_params;// _app_params;
			connID = _oConstructorParams.conId.toString();// connectionId.toString();
			micRateKHz = _oConstructorParams.micRate;// _micRateKHz;
			initMic();
		}
		
		public function disconnectClient():void
		{
			if (lastNetConnection!=null)
			{
				trace("ORC::AudioRecorder::disconnectClient call disconnect");
				lastNetConnection.call("DisconnectMe",null);
				lastNetConnection = null;
				
			}
		}
		
		public function micLevel() {
			trace("mic level: "+mic.activityLevel);
		}
		
		private function initMic(){
			mic = Microphone.getMicrophone();
			if (mic==null) {
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.ERROR, "Your computer does not support microphone capability."));
				trace("Microphone not found");
				return;
			}
			mic.addEventListener(ActivityEvent.ACTIVITY,micActivity);
			mic.addEventListener(StatusEvent.STATUS,micStatus);
			//setInterval(micLevel,2500);
			
			mic.rate=micRateKHz;
			//mic.gain=75;
			mic.setLoopBack(false);
			
			if (mic.muted) Security.showSettings(SecurityPanel.PRIVACY);
			else 
			{
				trace("initMic _iLastUserAction=" + _iLastUserAction);
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.READY_STATE,"",1,0));
				if (_iLastUserAction == RECORDING)
				{
					recordStart();
					_iLastUserAction = 0;
				}
				
			}
		}
		
		public function checkReadyState() {
			trace("CHECK READY STATE!!!!!")
			if (mic != null)
			{
				if (!mic.muted) dispatchEvent(new MicRecorderEvent(MicRecorderEvent.READY_STATE, "", 1, 0));			
			}
			else
			{
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.READY_STATE, "", 0, 0));
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.ERROR, "Your computer does not support microphone capability."));
				trace("Microphone not found");
			}
		}
		
		public function destroy() {
			if (net_str != null)
			{
				net_str.close();
				net_str.removeEventListener(NetStatusEvent.NET_STATUS,netStreamStatus);
			}
			if (net_con != null) 
			{
				net_con.close();
				net_con.removeEventListener(NetStatusEvent.NET_STATUS,netConnStatus);
				net_con.removeEventListener(IOErrorEvent.IO_ERROR,netConnectionError);
				net_con.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,netConnectionError);
				net_con.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, netConnectionError);
			}
			if (mic != null)
			{
				mic.removeEventListener(ActivityEvent.ACTIVITY,micActivity);
				mic.removeEventListener(StatusEvent.STATUS,micStatus);
			}
			if (_timerMicActivity != null)
			{
				_timerMicActivity.removeEventListener(TimerEvent.TIMER, onMicCheck);
			}
			
			net_str=null;
			net_con=null;
			mic = null;
			_timerMicActivity = null;
			lastNetConnection = null;
		}
		
		//microphone callbacks
		private function micActivity(evt:ActivityEvent){
			trace("mic activity " + evt.activating);			
		}
		private function micStatus(evt:StatusEvent) {
			trace("mic event : "+evt.code);
			if (evt.code=="Microphone.Unmuted") {
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.READY_STATE,"",1,0));			
			}
			else if (evt.code=="Microphone.Muted") {
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.READY_STATE,"",0,1));
			}
		}
		
		//****************************set mic params*****************************
		
		public function setSilenceLevel(_lvl:Number){
			mic.setSilenceLevel(_lvl);
		}

		public function set gain(_lvl:Number){
			//trace("set Gain : "+_lvl);
			mic.gain=_lvl;
		}
		
		public function get gain():Number {
			return(mic.gain);
		}
		
		public function set errorReportingURI(s:String) {
			sErrorReportingURI=s;
		}
				
		//***********************record functions***********************
		
		public function recordStart() { //record step 1 - initialize			
			trace("recordStart in MicRecorder _bConnectionClosedByServer="+_bConnectionClosedByServer);
			if (_bConnectionClosedByServer)
			{
				_iLastUserAction = RECORDING;
				resetNetConnection();								
				return;
			}
			if (!(streamStatus==NOAUDIO||streamStatus==STOPPED)) return;			
			if (net_con==null){
				net_con = new NetConnection();
				net_con.objectEncoding=ObjectEncoding.AMF0;
				net_con.client=new Object();
				net_con.client.setId = function(_id:Number) {
					trace("setId "+_id);
					netConnSetID(_id);
				}
				net_con.client.SaveResponse = netConnSaveResponse;
				net_con.addEventListener(NetStatusEvent.NET_STATUS,netConnStatus);
				net_con.addEventListener(IOErrorEvent.IO_ERROR,netConnectionError);
				net_con.addEventListener(SecurityErrorEvent.SECURITY_ERROR,netConnectionError);
				net_con.addEventListener(AsyncErrorEvent.ASYNC_ERROR,netConnectionError);
				lastNetConnection = net_con;
			}
			if (net_con.connected) startPublishing();
			else {
				var fullURI:String = "rtmp://"+server_uri;
				trace("Conencting to "+fullURI);
				try {
					net_con.connect(fullURI, connID);
				}
				catch (e:Error) {
					trace("catching error.........................");
					onError(e.message);
				}
				// startPublishing will be called after connID is set on callback
			}			
			//trace("recordStart in audioRecorder.as connection")
		}
		
		private function netConnSetID(_id:Number):void { //record step 2 - callback from net connection
			trace("netConnSetID in MicRecorder - "+_id);
			connID = _id.toString();
			startPublishing();
		}

		private function startPublishing(){ //record step 3
			trace("startPublishing in MicRecorder");
			recordStop();
			net_con.call("SetIdentifiers", null, app, app_params, uid);
			
			net_str = new NetStream(net_con);
			net_str.addEventListener(NetStatusEvent.NET_STATUS,netStreamStatus);
			net_str.client=new Object();
			net_str.client.onPlayStatus=function(_info:Object) {
				//as3 has no event listener for onPlayStatus, so it has to implemented in a hacky way
				netStreamStatus(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,_info));
			}
			net_str.attachAudio(mic);
			//net_str.setBufferTime(1);
				
			//streamName = "content/mic_rec_"+uid+"_"+connID+"_"+(++session_ctr);
			var resp:Responder=new Responder(gotStreamName);
			net_con.call("GetStreamName", resp);
		}
		
		private function startCheckingMicActivity():void
		{
			trace("ORCv3::startChckingMicActivity _bMicActivityDetected="+_bMicActivityDetected);
			if (!_bMicActivityDetected)
			{
				
				_nMicActivityLevel = mic.activityLevel;
				trace("ORCv3::startChckingMicActivity _nMicActivityLevel=" + _nMicActivityLevel);
				if (_timerMicActivity == null)
				{
					_timerMicActivity = new Timer(CHECK_MIC_INTERVAL);
					_timerMicActivity.addEventListener(TimerEvent.TIMER, onMicCheck);
				}				
				_timerMicActivity.start();
			}
			
		}
		
		private function stopCheckingMicActivity():void
		{
			trace("ORCv3::stopCheckingMicActivity _timerMicActivity != null ? "+(_timerMicActivity != null));
			if (_timerMicActivity != null)
			{				
				_timerMicActivity.stop();				
			}
			if (!_bMicActivityDetected)
			{
				trace("ORCv3::SILENCE_WARNING");
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.SILENCE_WARNING,"No microphone activity detected"));
			}
		}
		
		private function onMicCheck(evt:TimerEvent):void
		{
			trace("ORCv3::onMicCheck mic.activityLevel="+mic.activityLevel+", _nMicActivityLevel="+_nMicActivityLevel);
			if (mic.activityLevel != _nMicActivityLevel)
			{
				_bMicActivityDetected = true;
				if (_timerMicActivity != null)
				{
					if (_timerMicActivity.running)
					{
						_timerMicActivity.stop();
					}
				}
			}			
		}
		
		private function gotStreamName(res:Object) { //record step 4 - callback from net connection
			streamName = res.toString();
			trace("gotStreamName in MicRecorder: "+streamName);
			net_str.publish(streamName, "record");
		}
		
		private function netConnectionError(evt:ErrorEvent) {
			trace("net connection error in MicRecorder : type="+evt.type+"  message="+evt.text);
		}
		
		//************************************stop/playback functions*************************************
		
		public function recordStop() {			
			if (net_str!=null&&streamStatus==RECORDING)	{
				net_str.close();				
			}			
		}

		public function playStart() {
			if (_bConnectionClosedByServer)
			{
				resetNetConnection();								
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.ERROR,"The connection was reset. The previous audio is no longer available for playback or saving"));
				return;
			}
			if(streamStatus == STOPPED){
				net_str.close();
				trace("playStart - streamName="+streamName);
				net_str.play(streamName);
			}
			else if (streamStatus == PAUSED) net_str.resume();
		}
		
		public function playStop() {
			if (_bConnectionClosedByServer)
			{
				resetNetConnection();
				return;
			}
			if (net_str!=null&&streamStatus==PLAYING)	{
				net_str.close();
				setStatus(STOPPED); //set status to stopped immediately
			}
		}
		
		public function pause() {
			if (_bConnectionClosedByServer)
			{
				resetNetConnection();				
				return;
			}
			trace("AUDIORECORDER --- PAUSE");
			if (streamStatus==PLAYING) net_str.pause();
		}
		
		public function playStartPause() {
			if (streamStatus==PLAYING) pause();
			else if (streamStatus==STOPPED||streamStatus==PAUSED) playStart();
		}

		//******************************save functions*********************************
		
		public function save(sAudioName:String, normalization:Number=3) {
			if (_bConnectionClosedByServer)
			{
				resetNetConnection();								
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.ERROR,"The connection was reset. The previous audio is no longer available for playback or saving"));
				return;
			}
			var session_ctr:String = "0";
			trace("net_con.call(SaveStream, null, "+[streamName, uid, session_ctr, normalization, sAudioName].toString()+");")
			net_con.call("SaveStream", null, streamName, uid, session_ctr, normalization, sAudioName);
		}
		
		private function netConnSaveResponse(_response:String):String {
			trace("Net conn save response = " +_response);
			saveDone(_response);
			return("Save_OK");
		}
		
		private function saveDone(sResponse:String){
			var resVars = new URLVariables(sResponse);
			trace("ORC -- AudioRecorder class --- SAVE DONE");
			for (var i:String in resVars) trace("		ORC res - "+i+" = "+resVars[i]+"<<<");
			
			var iIDpos:int = resVars.result.indexOf("OK_");
			if(iIDpos!=-1){
				var aid:String = resVars.result.substring(iIDpos+3);
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.SAVE_DONE,aid));
				if (resVars.error!=undefined) {
					dispatchEvent(new MicRecorderEvent(MicRecorderEvent.ERROR,resVars.error));
				}
			}
			else if (resVars.result.indexOf("http") == 0){
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.SAVE_DONE,resVars.result));
				if (resVars.error!=undefined) {
					dispatchEvent(new MicRecorderEvent(MicRecorderEvent.ERROR,resVars.error));
				}
			}
			else {
				onError(resVars.result+" - "+resVars.error);
			}
		}
		
		//*****************************************************************************
		
		
		private function netConnStatus(evt:NetStatusEvent) {
			trace("net connection status="+evt.info.code+"  - in ORC lastNetConnection="+lastNetConnection);
			//we want NetConnection.Connect.Success
			
			if(evt.info.level=="error") {
				onError(evt.info.code,evt.info);
			}
			else if (evt.info.code.indexOf("Connect.Closed") >= 0 && lastNetConnection!=null)
			{
				trace("detected net connection reset ")
				dispatchEvent(new MicRecorderEvent(MicRecorderEvent.RESET, null));
				_bConnectionClosedByServer = true;				
				
				//dispatchEvent(new MicRecorderEvent(MicRecorderEvent.ERROR,evt.info.code));
			}			
		}
		
		private function resetNetConnection():void
		{
			trace("resetNetConnection ")
			streamStatus = 0;
			destroy();
			//_oConstructorParams = { uri:_uri, uid:_uid, app:_app, app_params:_app_params, micRate:_micRateKHz, conId:connectionId };
			_bConnectionClosedByServer = false;
			init();		
			
			/*
			net_con.removeEventListener(NetStatusEvent.NET_STATUS,netConnStatus);
			net_con.removeEventListener(IOErrorEvent.IO_ERROR,netConnectionError);
			net_con.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,netConnectionError);
			net_con.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, netConnectionError);
			net_con = null;			
			net_str.removeEventListener(NetStatusEvent.NET_STATUS, netStreamStatus);
			net_str = null;
			streamStatus = 0;
			*/
		}
		
		private function netStreamStatus(evt:NetStatusEvent) {
			
			var code:String=evt.info.code;
			trace("netStreamStatus: "+evt.info.code+"  - in ORC")
			
			if (code == "NetStream.Record.Start" || code == "NetStream.Publish.Start") { // recording				
				setStatus(1);
				startCheckingMicActivity();	
			}
			else if (code=="NetStream.Record.Stop") { // recorded
				setStatus(2);
				stopCheckingMicActivity();
			}
			else if (code=="NetStream.Play.Start") {
				setStatus(3);
			}
			else if (code=="NetStream.Pause.Notify") {
				setStatus(4);
			}
			else if (code=="NetStream.Play.Stop") {}
			else if (code=="NetStream.Play.Complete") {
				setStatus(2);
			}
			else if (code=="NetStream.Buffer.Flush") {} // done playback
			
			if(evt.info.level=="error")	onError(code,evt.info);
		}
		
		private function setStatus(iNewStatus:int) {
			var iOldStatus:int = streamStatus;
			streamStatus = iNewStatus;
			dispatchEvent(new MicRecorderEvent(MicRecorderEvent.STREAM_STATUS,"",iNewStatus,iOldStatus));
		}
		
		public function onError(_errorString:String,errorObj:Object=null){
			trace("onError in MicRecorder : "+_errorString);

			// report the error first
			if(sErrorReportingURI != null && sErrorReportingURI != "") {
				var sendVars:URLVariables=new URLVariables();

				sendVars.FlashVersion=Capabilities.version;
				sendVars.FMSurl = server_uri;
				sendVars.app = app;
				sendVars.app_params = app_params;
				sendVars.errorString = _errorString;
				if(errorObj != null){
					for (var i:String in errorObj) {
						sendVars[i] = errorObj[i];
					}
				}
				
				var req:URLRequest=new URLRequest(sErrorReportingURI);
				req.data=sendVars;
				/*try {
					sendToURL(req);
				}
				catch (e:Error) {
					trace("Error sending error in onError in ORC");
				}*/
			}
			// then pass it on to the UI 
			dispatchEvent(new MicRecorderEvent(MicRecorderEvent.ERROR,_errorString));
		}
		
	}
	
}
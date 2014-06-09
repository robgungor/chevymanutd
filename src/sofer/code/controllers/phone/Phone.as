package code.controllers.phone 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.ui.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.ui.*;
	
	import workshop.ui.AudioControls;

	/**
	 * ...
	 * @author Me^
	 */
	public class Phone
	{
		private var ui					:Phone_UI;
		private var btn_open_regular	:InteractiveObject;
		private var btn_open_c2c		:InteractiveObject;
		
		/** in case of multiple audios, this contains an array of AudioData objects e.g. phoneAudioArr[0] = audio for question #1 */
		private var phoneAudioArr		:Array;
		private var requiresCaptcha		:Boolean = false;
		/** current captcha number */
		private var cur_captcha			: Loader;
		private var otcLoader			:Loader;
		private var otc					:Object;
		private var clickToConnect		:Boolean;
		private var phoneAudio			:AudioData;
		private var processingStatus	:Boolean;
		private var multipleAudios		:Boolean;
		private var phone_num_to_dial	:String;
		
		private const STEP_LOADING		:String = "loading";
		private const STEP_CAPTCHA		:String = "captcha";
		private const STEP_CONNECTED	:String = "connected";
		private const STEP_DIAL			:String = "dial";
		private const STEP_C2C			:String = "c2c";
		private const STEP_CONNECTING	:String = "connecting";
		private const STEP_RECORDING	:String = "recording";
		private const STEP_RECORDED		:String = "recorded";
		private const STEP_PROCESSING	:String = "processing";
		private const STEP_READY		:String = "ready";
				
		public function Phone( _btn_open_c2c:InteractiveObject, _btn_open_regular:InteractiveObject, _ui:Phone_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui					= _ui;
			btn_open_regular	= _btn_open_regular;
			btn_open_c2c		= _btn_open_c2c;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();

			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				init();
			}
		}
		private function init(  ):void 
		{	App.listener_manager.add_multiple_by_object( [	btn_open_regular,
															btn_open_c2c ], MouseEvent.CLICK, open_win, this);
			ui.c2cWin.tf_phoneNum.restrict = "0-9";
			(ui.c2cWin.countrySelector as OComboBox).add(1, "U.S./Canada  (+1)");
			(ui.c2cWin.countrySelector as OComboBox).add(44, "United Kingdom  (+44)");
			(ui.c2cWin.countrySelector as OComboBox).selectById(1);
			init_shortcuts();
		}
		/************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 ***************************** INTERFACE API */
		/************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 ***************************** INTERNALS */
		private function open_win( _e:MouseEvent ):void 
		{	if (ui.visible)	return;
			switch (_e.target)
			{	case btn_open_regular:		clickToConnect = false;		break;
				case btn_open_c2c:			clickToConnect = true;		break;
			}
			ui.visible = true;
			clear_all_tf();
			initOTC();
			add_listeners();
			set_focus();
		}
		private function initOTC():void
		{	
			gotoStep(STEP_LOADING);
			ui.c2cWin.connectBtn.disabled = true;
			ui.audioControls.setState(AudioControls.PROCESSING);
			phoneAudio = null;
			processingStatus = false;
			var otcUrl:String;
			
			if (otc)
			{
				try
				{
					otc.otc_restart();
				}
				catch ( e : Error )
				{
					trace('error ... calling otc_restart before the number is retrieved from the server');
				}
			}
			else
			{
				var appName:String = ServerInfo.otcAppName;
				
				otcUrl = ServerInfo.otcURL + "OTCv3.swf?acc=" + ServerInfo.door + "&app=" + ServerInfo.otcAppName;
				if (clickToConnect) 
					otcUrl += "&mode=click_to_connect";
				
				Gateway.retrieve_Loader( new Gateway_Request( otcUrl, new Callback_Struct(fin, null, error) ) );
				function fin(_ldr:Loader):void
				{
					otcLoader = _ldr;
					set_otc_listeners();
				}
				function error(_msg:String):void
				{	
					App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR,'f9t343','Error loading OTC',{details:_msg}));
					close_win();
				}
				
				function set_otc_listeners():void
				{
					otc = otcLoader.content as Object;
					ui.addChild(otcLoader);
					
					var otcEvents:EventDispatcher = otcLoader.contentLoaderInfo.sharedEvents;
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.CAPTCHA				, otc_onCaptcha 			, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.CAPTCHA_FAILED		, otc_onCaptchaFailed 		, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.LOADED				, otc_onLoaded 				, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.PROCESSING			, otc_onAudioProcessing 	, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.SAVEDONE			, otc_onAudioReady 			, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.RECORDED			, otc_onAudioRecorded 		, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.RECORDING			, otc_onAudioStartRecord 	, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.CONNECTED			, otc_onPhoneConnect 		, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.DISCONNECTED		, otc_onPhoneDisconnect 	, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.IDLE				, otc_onIdle 				, this );
					App.listener_manager.add( otcEvents, PhoneRecorderEvent.MESSAGE_RECEIVED	, otc_onMessageReceived 	, this );
					App.listener_manager.add( otcEvents, ErrorEvent.ERROR						, otc_onError 				, this );
				}
			}
		}
		private function user_wants_close( _e:MouseEvent = null ):void 
		{	if (ui.visible)
			{	App.mediator.alert_user( new AlertEvent(AlertEvent.CONFIRM, "f9t151", "You will lose your changes.  That cool?", null, user_response));
			
				function user_response( _ok:Boolean ):void 
				{	if (_ok)
						close_win();
				}
			}
		}
		private function close_win(  ):void 
		{	if (ui.visible)
			{	ui.visible = false;
				remove_listeners();
				if (App.mediator.scene_editing)
					App.mediator.scene_editing.stopAudio();
				unload_otc();
			}
		}
		/**
		 * unloads the OTC component and removes all listeners to it
		 */
		private function unload_otc(  ):void 
		{	if (otc != null) 
			{	
				try
				{
					otc.otc_stop();
				}
				catch ( e : Error )
				{
					trace('otc crashed earlier');
				}
				otc = null;
			}
			if (otcLoader != null) 
				otcLoader.unload();
			if (otcLoader != null && otcLoader.contentLoaderInfo != null)
			{	var otcEvents:EventDispatcher = otcLoader.contentLoaderInfo.sharedEvents;
				App.listener_manager.remove_all_listeners_on_object( otcEvents );
				if (otcLoader.parent)
					otcLoader.parent.removeChild(otcLoader);
			}
		}
		private function add_listeners(  ):void 
		{	
			App.listener_manager.add_multiple_by_event( ui.audioControls, [
				AudioControls.EVENT_PLAY, 
				AudioControls.EVENT_STOP, 
				AudioControls.EVENT_REC, 
				AudioControls.EVENT_SAVE ] , audio_controls_handler, this );
			App.listener_manager.add( ui.c2cWin.connectBtn, MouseEvent.CLICK, request_c2c_connect, this );
			App.listener_manager.add( ui.captchaWin.connectBtn, MouseEvent.CLICK, request_captcha_connect, this );
			App.listener_manager.add( ui.captchaWin.btn_refresh, MouseEvent.CLICK, reload_captcha, this );
			App.listener_manager.add( ui.closeBtn, MouseEvent.CLICK, user_wants_close, this );
			App.listener_manager.add( App.mediator.scene_editing, SceneEvent.TALK_ENDED, talk_ended, this );
		}
		private function remove_listeners(  ):void 
		{	App.listener_manager.remove( ui.audioControls, AudioControls.EVENT_PLAY, audio_controls_handler );
			App.listener_manager.remove( ui.audioControls, AudioControls.EVENT_STOP, audio_controls_handler );
			App.listener_manager.remove( ui.audioControls, AudioControls.EVENT_REC, audio_controls_handler );
			App.listener_manager.remove( ui.audioControls, AudioControls.EVENT_SAVE, audio_controls_handler );
			App.listener_manager.remove( ui.c2cWin.connectBtn, MouseEvent.CLICK, request_c2c_connect );
			App.listener_manager.remove( ui.captchaWin.connectBtn, MouseEvent.CLICK, request_captcha_connect );
			App.listener_manager.remove( ui.captchaWin.btn_refresh, MouseEvent.CLICK, reload_captcha );
			App.listener_manager.remove( ui.closeBtn, MouseEvent.CLICK, user_wants_close );
			if (App.mediator.scene_editing)
				App.listener_manager.remove( App.mediator.scene_editing, SceneEvent.TALK_ENDED, talk_ended );
		}
		private function talk_ended( _e:Event ):void 
		{	ui.audioControls.setState(AudioControls.STOPPED);
		}
		private function clear_all_tf(  ):void 
		{	ui.captchaWin.tf_captcha.text	= '';
			ui.c2cWin.tf_phoneNum.text	= '';
		}
		private function audio_controls_handler( _e:Event ):void 
		{	switch (_e.type)
			{	case AudioControls.EVENT_PLAY:	App.mediator.scene_editing.previewAudio(phoneAudio);
												WSEventTracker.event("apph");
												break;
			
				case AudioControls.EVENT_STOP:	App.mediator.scene_editing.stopAudio();
												break;
				
				case AudioControls.EVENT_REC:	initOTC();	 break;
				
				case AudioControls.EVENT_SAVE:	close_win();	
												App.mediator.scene_editing.selectAudio(phoneAudio);
												App.mediator.scene_editing.playSceneAudio();
												WSEventTracker.event("apph");
												break;
			}
		}
		private function request_captcha_connect( _e:MouseEvent ):void 
		{	otc.otc_set_captcha_input(ui.captchaWin.tf_captcha.text);
			doConnect();
		}
		private function request_c2c_connect( _e:MouseEvent ):void 
		{	if (ui.c2cWin.tf_phoneNum.text.length == 0) 
			{	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t340", "Please enter a phone number."));
				return;
			}
			else	phone_num_to_dial = ui.c2cWin.tf_phoneNum.text;	// store number since TF can get cleared out in the meantime
			if (requiresCaptcha) 
			{	reload_captcha();
				gotoStep(STEP_CAPTCHA);
			}
			else doConnect();
		}
		private function reload_captcha( e:MouseEvent = null ):void
		{	
			clear_all_tf();
			
			var url:String = otc.otc_get_captcha_url();
			var loader_context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			var callbacks:Callback_Struct = new Callback_Struct(fin, null, error);
			Gateway.retrieve_Loader(new Gateway_Request(url, callbacks, 0, loader_context ));
			
			function fin(_ldr:Loader):void
			{
				remove_prev_captcha();
				// add new ldr
				_ldr.x = ui.captchaWin.placeholder.x;
				_ldr.y = ui.captchaWin.placeholder.y;
				ui.captchaWin.placeholder.visible = false;
				ui.captchaWin.addChild(_ldr);
			}
			function error(_msg:String):void
			{
				remove_prev_captcha();
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR,'f9t550','Error loading captcha',{details:_msg}));
				close_win();
			}
			function remove_prev_captcha():void
			{
				if (cur_captcha)
				{
					if (cur_captcha.parent)
						cur_captcha.parent.removeChild(cur_captcha);
					cur_captcha.unload();
					cur_captcha = null;
				}
			}
		}
		private function doConnect():void {
			var countryCode:int = (ui.c2cWin.countrySelector as OComboBox).getSelectedId();
			var countryStr:String
			if (countryCode == 1) countryStr = "1";
			else countryStr = "011" + countryCode.toString();
			var phoneNum:String = countryStr + phone_num_to_dial;
			otc.otc_callConnect(phoneNum);
			WSEventTracker.event("edcc");
			
			//you can't stop the recording by pressing stop - must be done by hanging up
			ui.audioControls.setState(AudioControls.RECORDING);
			gotoStep(STEP_CONNECTED);			
		}
		private function gotoStep(stepName:String):void
		{	ui.audioControls.visible 	= (stepName == STEP_READY);
			ui.dialWin.visible			= (stepName == STEP_DIAL);
			ui.c2cWin.visible			= (stepName == STEP_C2C);
			ui.captchaWin.visible		= (stepName == STEP_CAPTCHA);
			ui.tf_status.visible 		= (stepName == STEP_CONNECTING || stepName == STEP_CONNECTED || stepName == STEP_RECORDING || stepName == STEP_RECORDED || stepName == STEP_PROCESSING);
			
			var status_text:String;
			switch (stepName)
			{	case STEP_CONNECTING:	status_text = 'Connecting ... Please Stand By';break;
				case STEP_CONNECTED:	status_text = 'Get Ready .....';break;
				case STEP_RECORDING:	status_text = 'You May Press 1 at Anytime to Stop Phone Recording.  Then Listen to the Instructions on the Phone to Save.';break;
				case STEP_RECORDED:		status_text = 'Please Press 2 to Save Your Performance, or Follow the Instructions on the Phone for Other Options.';break;
				case STEP_PROCESSING:	status_text = 'Processing ...'; break;
				default:				status_text = '';
			}
			ui.tf_status.text = status_text;
		}
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* ************************************ OTC CALLBACKS  */
		private function otc_onCaptcha(evt:Event):void {
			trace("PhonePanel::otc_onCaptcha");
			requiresCaptcha = true;
		}
		private function otc_onCaptchaFailed(evt:Event):void {
			trace("PhonePanel::otc_onCaptchaFailed");
			App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t344", "Authentication failed."));
			gotoStep(STEP_CAPTCHA);
		}
		
		//STEP_1:
		private function otc_onLoaded(evt:Event):void{ //passcode, telephone
			trace("PhonePanel::otc_onLoaded");
			trace("otc step1");
			
			ui.c2cWin.connectBtn.disabled = false;
			ui.audioControls.setState(AudioControls.RECORDING);
			//you can't stop the recording by pressing stop - must be done by hanging up
			ui.audioControls.recBtn.disabled=true; 
			
			var pcode:String=(evt as Object).passCode;
			var pcDisplay:String = pcode.substring(0,3)+"-"+pcode.substring(3,5)+"-"+pcode.substring(5);
			var phoneNum:String = unescape((evt as Object).phoneNum);
			
			ui.dialWin.tf_phoneNum.text = phoneNum;
			ui.dialWin.tf_passcode.text = pcode;
			if (clickToConnect) 
				gotoStep(STEP_C2C);
			else 
				gotoStep(STEP_DIAL);
		}
		//STEP_2:
		private function otc_onPhoneConnect(evt:Event):void {
			trace("PhonePanel::otc_onPhoneConnect");
			WSEventTracker.event("edivr");
			gotoStep(STEP_CONNECTED);
		}	
		//STEP_3:
		private function otc_onAudioStartRecord(evt:Event):void{
			trace("PhonePanel::otc_onAudioStartRecord");
			gotoStep(STEP_RECORDING);
			//dispatchEvent(new KaraokeEvent(KaraokeEvent.START));
		}
		//STEP_4:
		private function otc_onAudioRecorded(evt:Event):void{
			trace("PhonePanel::otc_onAudioRecorded");
			gotoStep(STEP_RECORDED);
			//dispatchEvent(new KaraokeEvent(KaraokeEvent.STOP));
		}
		//STEP_5:
		private function otc_onAudioProcessing(evt:Event):void{
			trace("PhonePanel::otc_onAudioProcessing");
			gotoStep(STEP_PROCESSING);
			processingStatus=true;
		}
		//STEP_6:
		private function otc_onAudioReady(evt:Event):void{
			WSEventTracker.event("acph");
			if (clickToConnect) 
				WSEventTracker.event("edccd");
			var url:String = unescape((evt as Object).url);
			trace("PhonePanel::otc_onAudioReady : "+url);
			
			
			/* Single audio:
			 * http://host.dev.oddcast.com/content2/tmp/mp3/1211480585354001_239.mp3
			 * 
			 * In case of multiple audios:
			 * "http://host.oddcast.com/ccs2/temporary/swf/13700010014816_5_5_627227.swf";
			 * will be split into
			 * "http://host.oddcast.com/ccs2/temporary/swf/13700010014816_1_5_627227.swf";   (1 of 5)
			 * "http://host.oddcast.com/ccs2/temporary/swf/13700010014816_2_5_627227.swf";   (2 of 5)
			 *  etc...
			 * "http://host.oddcast.com/ccs2/temporary/swf/13700010014816_5_5_627227.swf";   (5 of 5)
			 */
			
			/*var urlArr:Array=url.split("_");
			if (urlArr.length==4) multipleAudios=true;
			else multipleAudios=false;
			 
			if (multipleAudios) {
				phoneAudioArr=new Array();
				var audioUrl:String;
				var totalAudios:int=parseInt(urlArr[2]);
				for (var i:int=1;i<=totalAudios;i++) {
					audioUrl=urlArr[0]+"_"+i.toString()+"_"+totalAudios.toString()+"_"+urlArr[3];
					phoneAudioArr.push(new AudioData(audioUrl,0,"phone"));
				}
				phoneAudio = phoneAudioArr[0];
			}*/
			
			var audioUrlArr:Array = (evt as Object).urls;
			if (audioUrlArr != null && audioUrlArr.length > 1) multipleAudios = true;
			else multipleAudios = false;
			
			if (multipleAudios) 
			{
				trace("audioUrlArr = " + audioUrlArr);
				trace("audioUrlArr.length = " + audioUrlArr.length);
				
				phoneAudioArr=new Array();
				for (var i:int = 0; i < audioUrlArr.length; i++) 
				{
				   phoneAudioArr.push(new AudioData(audioUrlArr[i],0,AudioData.PHONE));
				}
				phoneAudio = phoneAudioArr[0];                          
			}				
			else {
				//url=url.slice(0,url.lastIndexOf("."));
				phoneAudio=new AudioData(url,0,AudioData.PHONE);
			}

			ui.audioControls.setState(AudioControls.STOPPED);
			gotoStep(STEP_READY);
		}
		
		//STEP_7:
		
		private function otc_onPhoneDisconnect(evt:Event):void {
			trace("PhonePanel::otc_onPhoneDisconnect");
			
			if (processingStatus==false && phoneAudio==null) {
				App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "f9t342", "You Have Not Saved Your Phone Recording Properly. Please Try Again."));
				initOTC();
			}
		}
		
		//TIMEOUT:
		private function otc_onIdle(evt:Event):void {
			trace("PhonePanel::otc_onIdle");
			App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "f9t341", "The phone session has timed out.  Hit ok to restart."));
			close_win();
		}
		
		//ERROR:
		private function otc_onError(evt:ErrorEvent):void {
			App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR,"",evt.text));
		}
		
		//JADUKA:
		private function otc_onMessageReceived(evt:Event):void {
			var msgStr:String=(evt as Object).msg;
			trace("PhonePanel::otc_onMessageReceived : "+msgStr);
			
			//parse message, e.g.
			//q1_start  - questionStarted(1)
			//q1_end  - questionEnded(1)
			//q2_start  - questionStarted(2)
			//etc.
			//review_end - reviewEnded();
			
			var msgArr:Array=msgStr.split("_");
			if (msgArr[0]=="review") {
				if (msgArr[1]=="start") {
					reviewStarted();
				}
				else if (msgArr[1]=="end") {
					reviewEnded();
				}				
			}
			else if (msgArr[0].slice(0,1)=="q") {
				var qnum:int=parseInt(msgArr[0].slice(1));
				if (msgArr[1]=="start") {
					questionStarted(qnum);
				}
				else if (msgArr[1]=="end") {
					questionEnded(qnum);
				}
			}
		}
		private function questionStarted(questionNum:int):void { //called when user starts recording a question
		}
		private function questionEnded(questionNum:int):void { //called when user is done recording a question
		}
		private function reviewStarted():void {
		}
		private function reviewEnded():void {
		}
		/******************************************
		* 
		* 
		* 
		* 
		* 
		* 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}	
		private function shortcut_close_win(  ):void 		
		{	if (ui.visible)
				user_wants_close();
		}
		 /*******************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
	}

}
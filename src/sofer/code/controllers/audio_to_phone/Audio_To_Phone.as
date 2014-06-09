package code.controllers.audio_to_phone
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.adobe.crypto.*;
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.ui.*;

	/**
	 * ...
	 * @author Me^
	 */
	public class Audio_To_Phone
	{
		private var ui						:Audio_To_Phone_UI;
		private var btn_open				:InteractiveObject;
		private var current_captcha			:Loader;
		private var isInited				:Boolean = false;
		private var audio					:AudioData;
		private var sessionId				:String;
		
		public function Audio_To_Phone( _btn_open:InteractiveObject, _ui:Audio_To_Phone_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui						= _ui;
			btn_open				= _btn_open;
			
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
		{	
			ui.countrySelector.add(1, "U.S./Canada  (+1)");
			ui.countrySelector.add(44, "United Kingdom  (+44)");
			ui.countrySelector.selectById(1);
			
			ui.tf_phoneNum.restrict	= "0-9";
			
			ui.loadingBar.visible = false;
			
			App.listener_manager.add( btn_open, MouseEvent.CLICK, user_requested_open, this );
			init_shortcuts();
		}
		private function user_requested_open( _e:MouseEvent ):void 
		{	if (App.mediator.checkHasAudio()) 
			{	audio = App.mediator.scene_editing.audio;
				open_win();
			}
		}
		private function open_win(  ):void 
		{	if (ui.visible)
				return;
				
			App.mediator.scene_editing.stopAudio();
			if (!isInited) 
				resetCaptcha();
			ui.visible = true;
			App.utils.tab_order.set_order( [	ui.tf_phoneNum,ui.tf_captcha,ui.connectBtn ] );
			clear_all_tf();
			add_listeners();
			set_focus();
		}
		private function close_win( _e:MouseEvent = null ):void 
		{	ui.visible = false;
			remove_listeners();
		}
		private function clear_all_tf(  ):void 
		{	ui.tf_phoneNum.text	= '';
			ui.tf_captcha.text	= '';
		}
		private function resetCaptcha( _e:MouseEvent = null ):void
		{	
			ui.tf_captcha.text = "";
			
			sessionId = MD5.hash(new Date().time.toString() + Math.floor(Math.random() * 1000000).toString());
			var url:String = ServerInfo.localURL + "api/startCap.php?doorId=" + ServerInfo.door.toString() + "&sessId=" + sessionId;
			
			var context:LoaderContext=new LoaderContext(false, ApplicationDomain.currentDomain);
			Gateway.retrieve_Loader(new Gateway_Request(url,new Callback_Struct(fin,null,error),0,context));
			function fin(_content:Loader):void
			{
				// remove previous captcha
				if (current_captcha && 
					current_captcha.parent==ui.placeholder)
						ui.placeholder.removeChild(current_captcha);
				// add new captcha... BOOM BABY
				current_captcha=_content;
				ui.placeholder.addChild(_content);
				isInited=true;
			}
			function error(_msg:String):void
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR,'f9t550','Error loading captcha',{details:_msg}));
				close_win();
			}
		}
		private function onConnect(evt:MouseEvent):void
		{	if (ui.tf_phoneNum.text.length == 0) 
			{	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t340", "Please enter a phone number."));
				return;
			}
			else sendAudio();
		}
		private function sendAudio():void
		{	var countryCode:int = ui.countrySelector.getSelectedId();
			var countryStr:String
			if (countryCode == 1) countryStr = "1";
			else countryStr = "011" + countryCode.toString();
			
			var postVars:URLVariables = new URLVariables();
			postVars.phoneNum	= countryStr + ui.tf_phoneNum.text;
			postVars.doorId		= ServerInfo.door.toString();
			postVars.otcApp		= ServerInfo.otcAppName;
			postVars.cap		= MD5.hash(ui.tf_captcha.text);
			postVars.sessId		= sessionId;
			
			if (audio is TTSAudioData) 
			{	var ttsAudio:TTSAudioData	= audio as TTSAudioData;
				postVars.engineId			= ttsAudio.voice.engineId;
				postVars.voiceId			= ttsAudio.voice.voiceId;
				postVars.languageId			= ttsAudio.voice.langId;
				postVars.phrase				= ttsAudio.text;
			}
			else postVars.audioURL = audio.url;
			
			var url:String = ServerInfo.localURL + "mobile/sendAudioToJaduka.php";
			ui.loadingBar.visible = true;
			
			Gateway.upload( postVars, new Gateway_Request( url, new Callback_Struct( fin, null, error ) ));
			function fin( _content:String ):void 
			{	
				ui.loadingBar.visible = false;
				if (new Eval_PHP_Response( _content ).is_response_valid() )
				{	
					App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "f9t115", "Your audio has been successfully sent"));
					WSEventTracker.event("edphs");
					close_win();
				}
				else	
					error( _content );
				resetCaptcha();
			}
			function error( _msg:String ):void 
			{	
				var error_eval:Eval_PHP_Response = new Eval_PHP_Response( _msg );
				App.mediator.alert_user( new AlertEvent( AlertEvent.ERROR, 'f9t551', 'Error sending data to jaduka', { error:error_eval.error_code, message:error_eval.error_message } ));
			}
		}
		private function add_listeners(  ):void 
		{	App.listener_manager.add( ui.closeBtn, MouseEvent.CLICK, close_win, this );
			App.listener_manager.add( ui.btn_refresh, MouseEvent.CLICK, resetCaptcha, this );
			App.listener_manager.add( ui.connectBtn, MouseEvent.CLICK, onConnect, this );
		}
		private function remove_listeners(  ):void 
		{	App.listener_manager.remove( ui.closeBtn, MouseEvent.CLICK, close_win );
			App.listener_manager.remove( ui.btn_refresh, MouseEvent.CLICK, resetCaptcha );
			App.listener_manager.remove( ui.connectBtn, MouseEvent.CLICK, onConnect );
		}
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui.tf_phoneNum;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}	
		private function shortcut_close_win(  ):void 		
		{	close_win();	
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
package code.controllers.email 
{
	import code.controllers.popular_media.Popular_Media_Contact_Item;
	import code.models.*;
	import code.skeleton.*;
	
	import com.adobe.utils.*;
	import com.oddcast.event.*;
	import com.oddcast.ui.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLVariables;
	import flash.text.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Email implements IEmail
	{
		private var ui					:Email_UI;
		private var btn_open			:InteractiveObject;
		
		private var unique_email_id		:int = 0;
		protected var _emailSuccessWindow:EmailSuccessWindowUI;
		
		public function Email( _btn_open:InteractiveObject, _ui:Email_UI, successWindow:EmailSuccessWindowUI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			App.listener_manager.add(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE, app_initialized, this);
			
			// reference to controllers UI
			ui				= _ui;
			btn_open		= _btn_open;
			_emailSuccessWindow = successWindow;
			_emailSuccessWindow.visible = false;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				//App.listener_manager.remove_caught_event_listener( _e, arguments );
				App.listener_manager.remove(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE, app_initialized);
				App.listener_manager.remove(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE, app_initialized);
				// init this after the application has been inaugurated
				init();
				
			}
		}
		private function init(  ):void 
		{
			init_shortcuts();
			init_oddcast_fan();
			App.listener_manager.add_multiple_by_object( [_emailSuccessWindow.btn_ok], MouseEvent.CLICK, _emailSuccessWindowClose, this );
			App.listener_manager.add_multiple_by_object( [btn_open, App.ws_art.preview.email_btn, ui.btn_send], MouseEvent.CLICK, mouse_click_handler, this );
//			Bridge_Engine.listener_manager.add( ui.btn_popular_media, MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add_multiple_by_object( [ui.tf_fromEmail, ui.tf_toEmail, ui.tf_toEmail2, ui.tf_toEmail3], Event.CHANGE, change_characters_for_international_keyboards, this );
			_fields = [	ui.tf_fromEmail, 
						ui.tf_toEmail, 
						ui.tf_toEmail2, 
						ui.tf_toEmail3,
						ui.tf_fromName,
						ui.tf_toName,
						ui.tf_toName2,
						ui.tf_toName3];
			_defaults = [];
			for(var i:Number = 0; i<_fields.length; i++)
			{
				_defaults[i] = _fields[i].text;
			}
			App.listener_manager.add_multiple_by_object(_fields, FocusEvent.FOCUS_IN, _onTfFocus, this );
			App.listener_manager.add_multiple_by_object(_fields, FocusEvent.FOCUS_OUT, _onTfFocusOut, this );
			
			// RESTORE THIS AFTER ALPHA
			//App.listener_manager.add( ui.btn_add, MouseEvent.CLICK, add_user_typed_email, this );
			
			
			App.listener_manager.add( ui.closeBtn, MouseEvent.CLICK, close_win, this );
			App.listener_manager.add( ui.tf_fromEmail, Event.CHANGE, validate_from_email, this );
			App.listener_manager.add( ui.tf_toEmail, Event.CHANGE, validate_to_email, this );
			App.listener_manager.add( ui.tf_toEmail2, Event.CHANGE, validate_to_email2, this );
			App.listener_manager.add( ui.tf_toEmail3, Event.CHANGE, validate_to_email3, this );
			ui.emailSelector.addItemEventListener( Event.REMOVED, remove_email );
			ui.scrollbar_msg.init_for_textfield( ui.tf_msg );
				
			// text input restrictions
				ui.tf_fromEmail.restrict			= App.settings.EMAIL_SINGLE_TF_RESTRICT;
				if (App.settings.EMAIL_ALLOW_MULTIPLE_EMAILS)
				{
					ui.tf_toEmail.restrict			= App.settings.EMAIL_MULTIPLE_TF_RESTRICT;
					ui.tf_toEmail2.restrict			= App.settings.EMAIL_MULTIPLE_TF_RESTRICT;
					ui.tf_toEmail3.restrict			= App.settings.EMAIL_MULTIPLE_TF_RESTRICT;
				}
				else
				{
					ui.tf_toEmail.restrict			= App.settings.EMAIL_SINGLE_TF_RESTRICT;
					ui.tf_toEmail2.restrict			= App.settings.EMAIL_SINGLE_TF_RESTRICT;
					ui.tf_toEmail3.restrict			= App.settings.EMAIL_SINGLE_TF_RESTRICT;
				}
				ui.cb_optIn_email.selected			= App.settings.EMAIL_DEFAULT_OPTIN_VALUE;
				
			ui.emailSelector.addScrollBar( ui.scrollbar, true );
				
			// max input lengths
				ui.tf_fromEmail.maxChars	= 50;
				ui.tf_fromName.maxChars		= 50;
				ui.tf_toEmail.maxChars		= 50;
				ui.tf_toName.maxChars		= 50;
				ui.tf_toEmail2.maxChars		= 50;
				ui.tf_toName2.maxChars		= 50;
				ui.tf_toEmail3.maxChars		= 50;
				ui.tf_toName3.maxChars		= 50;
				ui.tf_msg.maxChars			= 1000;
		}
		
		protected function _emailSuccessWindowClose(e:MouseEvent = null):void
		{
			_emailSuccessWindow.visible = false;
		}
		protected var _fields:Array;
		protected var _defaults:Array;
		protected function _onTfFocus(e:FocusEvent):void
		{
			var defaultText:String = _defaults[_fields.indexOf(e.currentTarget)];
			if((e.currentTarget as TextField).text == defaultText) (e.currentTarget as TextField).text = "";	
		}
		protected function _onTfFocusOut(e:FocusEvent):void
		{
			var defaultText:String = _defaults[_fields.indexOf(e.currentTarget)];
			if((e.currentTarget as TextField).text == "") (e.currentTarget as TextField).text = defaultText;	
		}
		protected function _resetDefaultTexts():void
		{
			for(var i:Number = 0; i<_fields.length; i++)
			{
				_fields[i].text = _defaults[i];
			}
		}
		
		/*****************************************************
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
		 * ******************************** INTERFACE ********/
		public function add_recipient(_contact:Popular_Media_Contact_Item):Boolean
		{
			var all_selected_contacts:Array=ui.emailSelector.getItemArray();
			var max_recipients:Number=App.settings.MAX_EMAIL_RECIPIENTS
			if (all_selected_contacts.length>=max_recipients)
			{	
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR,'f9t114','you have reached the limit of '+max_recipients,{maxEmails:max_recipients}));
				return false;
			}
			else
			{	
				if (ui.emailSelector.getItemByName( _contact.email )==null)// email is NOT in the list already
					ui.emailSelector.add(++unique_email_id,_contact.email,_contact.name);
				return true;
			}
			return false;
		}
		public function remove_recipient(_contact:Popular_Media_Contact_Item):void
		{
			var item:SelectorItem = ui.emailSelector.getItemByName( _contact.email );
			if (item != null)
				ui.emailSelector.remove(item.id);
		}
		public function get_recipient_list():Array
		{
			var current_recipients:Array=[];
			var all_selected_contacts:Array=ui.emailSelector.getItemArray();
			for (var i:int=0, n:int=all_selected_contacts.length; i<n; i++)
			{
				var email:String=all_selected_contacts[i].text;
				current_recipients.push(email);
			}
			return current_recipients;
		}
		/*****************************************************
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
		 * ******************************** PRIVATE ********/
		private function remove_email( _e:Event ):void 
		{
			var item:SelectorItem = _e.target as SelectorItem;
			ui.emailSelector.remove(item.id);
		}
		private function mouse_click_handler(_e:MouseEvent):void
		{
			switch (_e.currentTarget)
			{
				case btn_open:
					//App.mediator.checkOptIn(open_win);
					open_win();
					break;
				case  App.ws_art.preview.email_btn:
					WSEventTracker.event("gce4");
					WSEventTracker.event("ce11");
					//App.mediator.checkOptIn(open_win);
					open_win();
					break;
				case ui.btn_send:
					trace("SEND");
					send();
					break;
//				case ui.btn_popular_media:
//					Bridge_Engine.mediator.popular_media_login();
//					break;
			}
		}
		private function validate_from_email( _e:Event = null ):void 
		{
			validate(ui.tf_fromEmail, ui.mc_from_correct, ui.mc_from_wrong);
		}
		private function validate_to_email( _e:Event = null ):void 
		{
			validate(ui.tf_toEmail, ui.mc_to_correct, ui.mc_to_wrong);
		}
		
		private function validate_to_email2( _e:Event = null ):void 
		{
			validate(ui.tf_toEmail2, ui.mc_to_correct2, ui.mc_to_wrong2);
		}
		
		private function validate_to_email3( _e:Event = null ):void 
		{
			validate(ui.tf_toEmail3, ui.mc_to_correct3, ui.mc_to_wrong3);
		}
		private function validate(_tf:TextField, _correct_mc:InteractiveObject, _wrong_mc:InteractiveObject):void
		{
			if (_tf.text.length > 0)
			{ 
				_correct_mc.visible = EmailValidator.validate(_tf.text);
				_wrong_mc.visible = !_correct_mc.visible;
			}
			else 
				_wrong_mc.visible = _correct_mc.visible = false;
		}
		private function open_win():void 
		{
			App.localizer.localize(this.ui, "email");
			if (App.mediator.checkPhotoExpired())
			{
				//App.mediator.scene_editing.stopAudio();
				App.mediator.stopScene();
				ui.visible = true;
			
				/*ui.tf_toName.text	= 
				ui.tf_toEmail.text	=
				ui.tf_toName2.text	= 
				ui.tf_toEmail2.text	=
				ui.tf_toName3.text	= 
				ui.tf_toEmail3.text	=
				ui.tf_msg.text		= '';*/
				_resetDefaultTexts();
				validate_from_email();
				validate_to_email();
				validate_to_email2();
				validate_to_email3();

				// set tab order
				var tab_oder:Array = 	[	ui.tf_fromName,
					ui.tf_fromEmail,
					//ui.tf_msg,
					ui.tf_toName,
					ui.tf_toEmail,
					ui.tf_toName2,
					ui.tf_toEmail2,
					ui.tf_toName3,
					ui.tf_toEmail3,
					ui.btn_add,
					ui.btn_send	];
				App.utils.tab_order.set_order( tab_oder, 100 );
				
				ui.cb_optIn_email.selected = true;
				//set_focus();
			}
			_emailSuccessWindow.visible = false;
			
			
		}
		private function close_win( _e:MouseEvent = null ):void 
		{
			ui.visible = false;
		}
		private function send():void 
		{
			if (email_form_valid() && 
				bad_words_passed( App.settings.EMAIL_REPLACE_BAD_WORDS ))
			{
				build_and_send();
				oddcast_fan_send_data( ui.tf_fromEmail.text, ui.tf_fromName.text );
			}
			
			/** validates if all the neccessary fields have been filed in by the user */
			function email_form_valid(  ):Boolean
			{
				ui.tf_fromEmail.text = StringUtil.trim(ui.tf_fromEmail.text);
				if (!EmailValidator.validate(ui.tf_fromEmail.text))
				{
					App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t106", "Invalid from e-mail address"));
					return false;
				}
/*				if (ui.tf_fromName.text == '')
				{
					Bridge_Engine.logic_mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t534", "Please enter your name"));
					return false;
				}*/
				ui.emailSelector.clear();
				if (ui.emailSelector.getItemArray().length == 0) 
				{
					if (ui.tf_toEmail.text.length > 0 || ui.tf_toEmail2.text.length > 0 || ui.tf_toEmail3.text.length > 0) 
					{
						var success:Boolean = add_user_typed_email();
						return success;
					}
					else 
					{
						App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t111", "You must specify an address to send the message to."));
						return false;
					}
				}
				return true;
			}
			
			/** checks specific fields if they contain bad words */
			function bad_words_passed( _replace_badwords:Boolean ):Boolean 
			{
				var textFields_to_check:Array = [ui.tf_msg, ui.tf_fromName];
				
				for (var i:int = 0; i < textFields_to_check.length; i++) 
				{
					var tf:TextField	= textFields_to_check[i];
					var check:String	= check_for_badwords( tf.text, _replace_badwords );
					if (check == null)	// bad word found
						return false;
					else
						tf.text			= check;
				}
				return true;
			}
			/** build and send the message xml */
			function build_and_send(  ):void 
			{
				var messageXML:XML		= new XML("<message />");
				messageXML.from			= new XML();
				messageXML.body			= ui.tf_msg.text;
				messageXML.from.name	= ui.tf_fromName.text;			
				messageXML.from.email	= ui.tf_fromEmail.text;
				
				var toXML:XML;
				var item:SelectorItem;
				var num_of_recepients:int = ui.emailSelector.getItemArray().length
				for (var i:int = 0; i < num_of_recepients; i++) 
				{
					item		= ui.emailSelector.getItemArray()[i];
					toXML		= new XML("<to />");
					toXML.name	= item.data as String;
					toXML.email	= item.text;
					messageXML.appendChild(toXML);				
				}
				
		
				
					/*messageXML.appendChild(makeToXML(ui.tf_toName, ui.tf_toName);	
				function makeToXML(name:String, email:String):XML
				{
					var xml:XML		= new XML("<to />");
					xml.name	= item.data as String;
					xml.email	= item.text;
					return xml;
				}*/
				
				messageXML.optin = ui.cb_optIn_email.selected ? "1":"0";
				
				App.utils.mid_saver.save_message(new SendEvent(SendEvent.SEND, SendEvent.EMAIL, messageXML), new Callback_Struct(fin, null,error));
				
				function fin():void 
				{	close_win();
					WSEventTracker.event("edems");
					WSEventTracker.event("evrcpt", null, num_of_recepients);
					//App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "f9t104", "Email sent successfully."));
					_emailSuccessWindow.visible = true;
					ui.tf_toName.text	= ui.tf_toEmail.text	= ui.tf_toName2.text	= ui.tf_toEmail2.text	= ui.tf_toName3.text	= ui.tf_toEmail3.text	= '';					
				}
				function error(_e:AlertEvent):void
				{	
				}
			}
		}
		
		/**
		 * checks if a string has a bad word or not
		 * @param	_s	string that might contain a badword
		 * @param	_replace_bad_words	if to replace the bad words or leave
		 * @return	returns null if an error is thrown, otherwise returns converted/orignal string
		 */
		private function check_for_badwords( _s:String, _replace_bad_words:Boolean ):String 
		{
			if (App.asset_bucket.profanity_validator.is_loaded) 
			{
				if (_replace_bad_words) 
					return(App.asset_bucket.profanity_validator.replaceBadWords(_s));
				else 
				{
					var badWord:String = App.asset_bucket.profanity_validator.validate(_s);
					if (badWord == "") 
						return(_s);
					else 
					{
						App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t331", "You cannot use the word " + badWord + ". Please try with a different word.", { badWord:badWord } ));
						return(null);
					}
				}
			}
			else return(_s);
		}
		/**
		 * certain international keyboards conflict with US keyboards so we adjust it here
		 * @param	_e event
		 */
		private function change_characters_for_international_keyboards( _e:Event ):void 
		{
			_e.target.text = String(_e.target.text).split('\"').join('@');	// british " is english @
		}
		
		private function add_user_typed_email( _e:MouseEvent = null ):Boolean 
		{			
			ui.tf_toEmail.text = StringUtil.trim(ui.tf_toEmail.text);
			ui.tf_toEmail2.text = StringUtil.trim(ui.tf_toEmail2.text);
			ui.tf_toEmail3.text = StringUtil.trim(ui.tf_toEmail3.text);
			// go through all three to see if any are true
			var boo:Boolean;
			boo = EmailValidator.validate(ui.tf_toEmail.text);
			if(!boo) boo = EmailValidator.validate(ui.tf_toEmail2.text);
			if(!boo) boo = EmailValidator.validate(ui.tf_toEmail3.text);
			if (!boo) {
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR,"f9t107","Invalid e-mail address(es)"));
				return false;				
			}
			var success:Boolean = true;
			var check:String = check_for_badwords( ui.tf_toName.text, false);
			if (check == null) 
				success = false;
			else
				ui.tf_toName.text = check;
			
			if(success) success = add_recipient(new Popular_Media_Contact_Item(ui.tf_toName.text, ui.tf_toEmail.text));
			// clear out user input only if the email was added.
			if (success)
			{
			//	ui.tf_toName.text	= 
			//		ui.tf_toEmail.text	= '';
				validate_to_email();
			}
			if(EmailValidator.validate(ui.tf_toEmail2.text))
			{
				check = check_for_badwords( ui.tf_toName2.text, false);
				var success2:Boolean = true;
				if (check == null) 
					success2 = false;
				else
					ui.tf_toName2.text = check;
				
				if(success2) success2 = add_recipient(new Popular_Media_Contact_Item(ui.tf_toName2.text, ui.tf_toEmail2.text));
				// clear out user input only if the email was added.
				if (success2)
				{
				//	ui.tf_toName2.text	= 
				//		ui.tf_toEmail2.text	= '';
					validate_to_email2();
				}
			}
			if(EmailValidator.validate(ui.tf_toEmail3.text))
			{
				check = check_for_badwords( ui.tf_toName3.text, false);
				var success3:Boolean = true;
				if (check == null) 
					success3 = false;
				else
					ui.tf_toName3.text = check;
				
				if(success3) success3 = add_recipient(new Popular_Media_Contact_Item(ui.tf_toName3.text, ui.tf_toEmail3.text));
				// clear out user input only if the email was added.
				if (success3)
				{
				//	ui.tf_toName3.text	= 
				//		ui.tf_toEmail3.text	= '';
					validate_to_email3();
				}
			}
			
			
				
			return success || success2 || success3;
		}
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui.tf_fromName;
		}
		private function init_shortcuts():void
		{	
			App.shortcut_manager.api_add_shortcut_to( ui				, Keyboard.ENTER	, shortcut_enter_handler );
			App.shortcut_manager.api_add_shortcut_to( ui				, Keyboard.ESCAPE	, shortcut_close_win );
		}	
		private function shortcut_close_win(  ):void 		{	close_win();	}
		private function shortcut_enter_handler(  ):void
		{
			switch ( ui.stage.focus )
			{	
				case ui.tf_toEmail:
					ui.btn_send.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					break;
				case ui.tf_toEmail2:
					ui.btn_send.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					break;
				case ui.tf_toEmail3:
						ui.btn_send.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					break;
			}
		}
		 /*******************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** ODDCAST FAN SECTION */
		private function init_oddcast_fan(  ) : void
		{
			ui.cb_optIn_oddcast.selected = App.settings.ODDCAST_FAN_DEFAULT;
		}
		/**
		 * sends the user default/selected value to the server
		 * @param	_user_email email to be stored, DB entries are searched by this
		 * @param	_user_name the name for the DB, this is saved only once per email
		 */
		private function oddcast_fan_send_data( _user_email:String, _user_name:String ):void
		{
			// send only if user opted in
			if (!ui.cb_optIn_oddcast.selected)	return;
			// set the value to be sent
			var optin_value:String;
			if (ui.cb_optIn_oddcast.selected)		optin_value = '1';
			// send the value
			var vars:URLVariables = new URLVariables();
			vars.eml	= _user_email;
			vars.opt	= optin_value;
			vars.name	= _user_name;
			//				vars.DBG	= 1;
			var server_script_url:String = ServerInfo.localURL + App.settings.API_ODDCAST_FAN;
			
			Gateway.upload( vars, new Gateway_Request(server_script_url,new Callback_Struct(fin)));
			function fin( _response:String ) : void
			{
				trace ( '(Oo) Email.as :: response from oddcast optin :  _response =',_response );
			}
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
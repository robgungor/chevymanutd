package code.controllers.download
{
	import code.skeleton.App;
	
	import com.adobe.utils.StringUtil;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.utils.EmailValidator;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.WSEventTracker;
	import com.oddcast.workshop.WorkshopMessage;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Download
	{
	
		/** user interface for this controller */
		private var ui					:Download_UI;
		/** button, generally outside of the UI which opens this view */
		private var btn_open			:DisplayObject;
		
		/*******************************************************
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
		 * ******************************** INIT */
		/**
		 * Constructor
		 */
		public function Download( _btn_open:DisplayObject, _ui:Download_UI	) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			//			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE;
			//			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to the controllers UI
			ui			= _ui;
			btn_open	= _btn_open;
			
			// provide the mediator a reference to communicate with this controller
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
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	
			init_shortcuts();
			set_ui_listeners();
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
		 ***************************** PUBLIC INTERFACE */
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
		 ***************************** PRIVATE */
		/*******************************************************
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
		 * ******************************** VIEW MANIPULATION - PRIVATE */
		/**
		 * displays the UI
		 * @param	_e
		 */
		private function open_win(  ):void 
		{	
			
			App.utils.mid_saver.save_message(new SendEvent(SendEvent.SEND, SendEvent.DOWNLOAD_VIDEO), new Callback_Struct( fin, null, null ) );
			
			function fin():void 
			{
				ui.visible = true;
				ui.accept_Cb.selected = true;
				set_tab_order();
				set_focus();
				WSEventTracker.event("edvdx");	
			}	
			
			
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		private function close_win(  ):void 
		{	
			ui.visible = false;
			
		}
		/**
		 * adds listeners to the UI
		 */
		private function set_ui_listeners():void 
		{
			App.listener_manager.add_multiple_by_object( 
				[
					btn_open, 
					ui.btn_close, ui.btn_confirm,App.ws_art.mainPlayer.end_screen.btn_download
				], MouseEvent.CLICK, mouse_click_handler, this );
			ui.accept_Cb.addEventListener(MouseEvent.CLICK, _onCbClicked);
			ui.tf_email.addEventListener(FocusEvent.FOCUS_IN, _onTfFocus);
			ui.tf_email.addEventListener(FocusEvent.FOCUS_OUT, _onTfFocusOut);
		}
		protected function _onCbClicked(e:MouseEvent):void
		{
			
		}
		/**
		 * handler for Click MouseEvents from the UI
		 * @param	_e
		 */
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case btn_open:
					WSEventTracker.event("ce14");
					open_win();		
					break;
				case App.ws_art.mainPlayer.end_screen.btn_download:
					WSEventTracker.event("ce14");
					open_win();		
					break;
				case ui.btn_confirm:
					send();
					break;
				case ui.btn_close:	
					close_win();	
					break;
			}
		}
		/**
		 *sets the tab order of ui elements 
		 * 
		 */		
		private function set_tab_order():void
		{
			App.utils.tab_order.set_order( [ ui.tf_one, ui.tf_two, ui.btn ] );// SAMPLE
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
		 ***************************** KEYBOARD SHORTCUTS */
		/**
		 * sets stage focus to the UI
		 */
		private function set_focus():void
		{	
			ui.stage.focus = ui;
		}
		/**
		 * initializes keyboard shortcuts
		 */
		private function init_shortcuts():void
		{	
			App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}
		protected function _onTfFocus(e:FocusEvent):void
		{
			if(ui.tf_email.text == "Your Email") ui.tf_email.text = "";
		}
		protected function _onTfFocusOut(e:FocusEvent):void
		{
			if(ui.tf_email.text == "") ui.tf_email.text = "Your Email";
		}
		/**
		 * hides the UI
		 */
		private function shortcut_close_win(  ):void 		
		{	
			if (ui.visible)		
				close_win();	
		}
		private function _download(e:Event = null):void
		{
			var url:String = "http://host.oddcast.com/api_misc/1083/checkout.php?mId="
							+App.asset_bucket.last_mid_saved
							+"&email="
							+ui.tf_email.text
							+"&optin="
							+(ui.accept_Cb.selected ? "1" : "0");
			
			
			App.mediator.open_hyperlink(url, "_blank");
			close_win();
		}
		
		private function send():void 
		{
			if (email_form_valid() && 
				bad_words_passed( App.settings.EMAIL_REPLACE_BAD_WORDS ))
			{
				_download();
			
			}
			
			/** validates if all the neccessary fields have been filed in by the user */
			function email_form_valid(  ):Boolean
			{
				ui.tf_email.text = StringUtil.trim(ui.tf_email.text);
				if (!EmailValidator.validate(ui.tf_email.text))
				{
					App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "badEmailAddress", "Please enter your email address to continue."));
					return false;
				}
				return true;
			}
			
			/** checks specific fields if they contain bad words */
			function bad_words_passed( _replace_badwords:Boolean ):Boolean 
			{
				var textFields_to_check:Array = [ui.tf_email];
				
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
		
		/************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
	
	}
}
package code.controllers.popular_media
{
	import code.models.Model_Item;
	import code.models.Model_Store;
	import code.models.items.List_Popular_Media_Contacts;
	import code.skeleton.*;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.EmailValidator;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ServerInfo;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.ui.*;
	import flash.xml.XMLDocument;
	
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Popular_Media_Login implements IPopular_Media_Login
	{
		private var ui					:Popular_Media_Login_UI;
		
		/* current provider selected */
		private var cur_provider		:String;
		private var list_contacts		:List_Popular_Media_Contacts;
		
		private const PROVIDER_GMAIL 	:String = 'GMAIL';
		private const PROVIDER_HOTMAIL 	:String = 'HOTMAIL';
		private const PROVIDER_YAHOO 	:String = 'YAHOO';
		
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INIT */
		/**
		 * Constructor
		 */
		public function Popular_Media_Login() 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui				= Bridge.views.popular_media_login_UI;
			list_contacts	= App.asset_bucket.model_store.list_popular_media_contacts;
			
			// provide the mediator a reference to send data to this controller
			App.mediator.set_controller_interface(this);
			
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
			init_shortcuts();
			set_focus();
			
			App.listener_manager.add_multiple_by_object( [
				ui.btn_close, 
				ui.btn_cancel, 
				ui.btn_submit, 
				ui.btn_gmail, 
				ui.btn_hotmail,
				ui.btn_yahoo
			], MouseEvent.CLICK, mouse_click_handler, this );
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
		/**
		 * displays the UI
		 * @param	_e
		 */
		public function open_win(  ):void 
		{	
			ui.visible = true;
			set_focus();
			ui.tf_password.text = '';
			ui.tf_username.text = '';
			App.utils.tab_order.set_order( [ ui.tf_username, ui.tf_password ] );
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
		***************************** INTERNALS */
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case ui.btn_close:
				case ui.btn_cancel:	
					close_win();	
					break;
				case ui.btn_submit:
					submit_form( ui.tf_username.text, ui.tf_password.text, cur_provider );
					break;
				case ui.btn_gmail:
					update_username_by_provider(PROVIDER_GMAIL);
					break;
				case ui.btn_hotmail:
					update_username_by_provider(PROVIDER_HOTMAIL);
					break;
				case ui.btn_yahoo:
					update_username_by_provider(PROVIDER_YAHOO);
					break;
			}
		}
		/**
		 *updates the username domain based on the provider selected
		 * @param _provider
		 * 
		 */		
		private function update_username_by_provider( _provider:String ):void
		{
			cur_provider = _provider;
			
			var tf:TextField = ui.tf_username;
			var delimiter:String = '@';
			var post_fix:String = '.com';
			var domain:String = delimiter + cur_provider.toLowerCase() + post_fix;
				
			if (tf.text.indexOf(delimiter)>=0)
				tf.text = tf.text.split(delimiter).shift() + domain;
			else
				tf.appendText(domain);
				
			ui.stage.focus = tf;
			var at_index:int=tf.text.indexOf(delimiter);
			tf.setSelection(0,at_index);
		}
		private function submit_form( _username:String, _password:String, _provider:String ) : void
		{
			if (form_data_is_valid( _username, _password, _provider ))
			{
				list_contacts.load(_username,_password,_provider,new Callback_Struct(fin,null,error));
				function fin(  ):void
				{
					close_win();
					App.mediator.popular_media_contact_list();
				}
				function error( _e:AlertEvent ):void
				{
					App.mediator.alert_user(_e);
				}
			}
		}
		
		private function form_data_is_valid( _username:String, _password:String, _provider:String ) : Boolean
		{
			var alert:AlertEvent;
			if ( !_username || !EmailValidator.validate(_username) )
				alert = new AlertEvent(AlertEvent.ERROR, 'f9t120', 'Please enter a valid email address');
			else if ( !_password || _password.length==0 )
				alert = new AlertEvent(AlertEvent.ERROR, 'f9t121', 'Your password is invalid');
			else if ( _username.slice(_username.lastIndexOf(".")).toLowerCase() != '.com' )
				alert = new AlertEvent(AlertEvent.ERROR, 'f9t122', 'International domains are not yet supported');
			else if ( _provider!=PROVIDER_GMAIL && _provider!=PROVIDER_HOTMAIL && _provider!=PROVIDER_YAHOO )
				alert = new AlertEvent(AlertEvent.ERROR, 'f9t126', 'please select a provider');
			
			if (alert)
			{
				App.mediator.alert_user( alert );
				return false;
			}
			return true;
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		private function close_win(  ):void 
		{	
			ui.visible = false;
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
		***************************** KEYBOARD SHORTCUTS */
		/**
		 * sets stage focus to the UI
		 */
		private function set_focus():void
		{	
			ui.stage.focus = ui.tf_username;
		}
		/**
		 * initializes keyboard shortcuts
		 */
		private function init_shortcuts():void
		{	
			App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
			App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ENTER, shortcut_submit_form );
		}
		private function shortcut_close_win(  ):void 		
		{	
			if (ui.visible)
				close_win();	
		}
		private function shortcut_submit_form( ):void
		{
			if (ui.visible)
				submit_form( ui.tf_username.text, ui.tf_password.text, cur_provider );
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
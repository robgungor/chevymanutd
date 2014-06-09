package code.controllers.youtube 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Youtube
	{
		private var ui					:Youtube_UI;
		private var btn_open			:InteractiveObject;
		private var youtube_token		:String;
		private var last_mid_posted		:String;
		private var last_token_posted	:String;
		
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
		public function Youtube( _btn_open:InteractiveObject, _ui:Youtube_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui				= _ui;
			btn_open		= _btn_open;
			
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
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	init_shortcuts();
			App.listener_manager.add_multiple_by_object( [
															btn_open, 
															ui.btn_close, 
															ui.btn_submit ], MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add( ui.tf_email, Event.CHANGE, validate_user_email, this );
			
			if (ExternalInterface_Proxy.available)
			{	
				try
				{
					ExternalInterface_Proxy.addCallback('flashSetSessionToken', javascript_response);
				}
				catch ( e : Error )
				{
					
				}
				
			}
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
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{	
				case btn_open:			open_win(); break;
				case ui.btn_close:		close_win(); break;
				case ui.btn_submit:		submit_new_user(); break;
			}
		}
		/**
		 * displays the UI
		 * @param	_e
		 */
		private function open_win():void 
		{	
			App.mediator.scene_editing.stopAudio();
			if ( !ExternalInterface_Proxy.available )	// this wont work without javascript access
				App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t525', 'Posting to YouTube cannot open' ));
			else if ( !App.mediator.checkHasAudio() )
			{}
			else
			{	ui.visible = true;
				validate_user_email();
				set_focus();
			}
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		private function close_win():void 
		{	ui.visible = false;
		}
		private function submit_new_user():void 
		{	if (
					ui.tf_email.text.length > 0 &&
					!EmailValidator.validate(ui.tf_email.text)
				) 
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t526', 'Please enter a valid email or leave blank'));
			else	ExternalInterface_Proxy.call('startYoutube', 1);	// 1 for new user, 0 for same user
		}
		private function submit_same_user():void 
		{	
			/* ALLOW THE SAME CONTENT TO BE POSTED MULTIPLE TIMES ACCORDING TO BUG #7964
			if ( 
					!Bridge_Engine.logic_mediator.active_scene().sceneChangedSinceLastSave() && // no changes to the scene
					last_mid_posted == Bridge_Engine.asset_bucket.last_mid_saved &&	// same mid is attempted to be posted
					last_token_posted == youtube_token	// same token is attempted to be posted
				)
				Bridge_Engine.logic_mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t529', 'The message has not changed.  This scene has already been scheduled for posting'));
			else*/
			{
				App.utils.mid_saver.save_message( null, new Callback_Struct( submit_to_scheduler ) );
				
				function submit_to_scheduler(  ):void 
				{	var post_vars:URLVariables = new URLVariables();
					post_vars.mId		= App.asset_bucket.last_mid_saved;
					post_vars.yt_token	= youtube_token;
					post_vars.doorId	= ServerInfo.door;
					post_vars.taskName	= App.settings.SCHEDULER_TASK_NAME;
					if (EmailValidator.validate(ui.tf_email.text))	// submit the email if the user provides one
						post_vars.email	= ui.tf_email.text;
					
					var api_url:String = ServerInfo.localURL + App.settings.SCHEDULER_URL;
					Gateway.upload( post_vars, new Gateway_Request( api_url, new Callback_Struct( php_response, null, php_error ) ));
					function php_response( _response:String ):void 
					{	
						if (new Eval_PHP_Response( _response ).is_response_valid() )
						{	
							App.mediator.alert_user( new AlertEvent( AlertEvent.ERROR, 'f9t527', 'Thank you for posting.  Your video will be posted withing 48 hours.  You will be notified by email if one was provided'));
							last_mid_posted = App.asset_bucket.last_mid_saved;	// meant to prevent duplicate postings
							last_token_posted = youtube_token;	// meant to prevent duplicate postings
							WSEventTracker.event('uiebyt');
							close_win();
						}
						else	php_error( _response );
					}
					function php_error( _msg:String ):void 
					{	var error_eval:Eval_PHP_Response = new Eval_PHP_Response( _msg );
						App.mediator.alert_user( new AlertEvent( AlertEvent.ERROR, 'f9t528', 'Error posting', { error:error_eval.error_code, message:error_eval.error_message } ));
					}
				}
			}
		}
		private function validate_user_email( _e:Event = null ):void 
		{	if (ui.tf_email.text.length > 0)
			{	EmailValidator.validate(ui.tf_email.text) ? display_indicator( ui.mc_correct ) : display_indicator( ui.mc_wrong );
			}
			else display_indicator();
			
			/**
			 * shows none, wrong or correct
			 * @param	_indicator	MovieClip to display
			 */
			function display_indicator( _indicator:MovieClip = null ):void 
			{	ui.mc_correct.visible 	= _indicator == ui.mc_correct;
				ui.mc_wrong.visible 	= _indicator == ui.mc_wrong;
			}
		}
		private function javascript_response( _key:String = null ):void 
		{	youtube_token = _key;
			submit_same_user();	// we have the user info now so submit the request
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
		{	ui.stage.focus = ui.tf_email;
		}
		/**
		 * initializes keyboard shortcuts
		 */
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
			App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ENTER, shortcut_submit );
		}
		private function shortcut_close_win(  ):void 		
		{	if (ui.visible)		close_win();	
		}
		private function shortcut_submit(  ):void 
		{	if (ui.visible)		submit_new_user();
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
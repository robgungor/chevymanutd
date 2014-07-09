package code.controllers.share_facebook
{
	
	import code.skeleton.App;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.Event_Expiration;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ExternalInterface_Proxy;
	import com.oddcast.workshop.WSEventTracker;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Rob
	 */
	public class Share_Facebook
	{		
		/** user interface for this controller */
		private var ui					:ShareFacebookUI;
		/** button, generally outside of the UI which opens this view */
		private var btn_open			:DisplayObject;
		private var event_expiration		:Event_Expiration = new Event_Expiration();
		
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
		public function Share_Facebook( _btn_open:DisplayObject, _ui:ShareFacebookUI) 
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
		private const POSTING_TO_FACEBOOK	:String = 'LOGGING_INTO_FACEBOOK';
		private const POSTING_MSG			:String = 'Posting your scene.';
		
		private function open_win(  ):void 
		{	
			App.localizer.localize(this.ui, "fb_share");
			
			set_tab_order();
			set_focus();
			//App.mediator.processing_start(POSTING_TO_FACEBOOK, POSTING_MSG);
			//event_expiration.add_event( 'fblogin', App.settings.EVENT_TIMEOUT_MS, get_friends_timedout );
					
			
			function get_friends_timedout(  ):void 
			{	
				App.mediator.processing_ended(POSTING_TO_FACEBOOK);
				App.mediator.alert_user(new AlertEvent('didntlogin', 'fb123'));				// indicate there was an error
			}
			App.mediator.facebook_connect_login(_onFacebookLogin);
		}
		private function _onFacebookLogin(e:* = null):void
		{
			//event_expiration.remove_event('fblogin');
					
			App.utils.mid_saver.save_message( null, new Callback_Struct(fin_message_saved, null, error_message) );
			function fin_message_saved():void
			{
				trace("MESSAGE SAVED");
				App.mediator.processing_ended(POSTING_TO_FACEBOOK);
				end_processing();						
				ui.visible = true;
			}
			function error_message( _e:AlertEvent ):void
			{	end_processing();
			}
			function end_processing(  ):void 
			{	App.mediator.processing_ended(POSTING_TO_FACEBOOK);
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
					ui.btn_close,
					ui.btn_post,
					ui.btn_profile
				], MouseEvent.CLICK, mouse_click_handler, this );
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
					open_win();		
					break;				
				case ui.btn_profile:
					WSEventTracker.event("ce12");
					ExternalInterface_Proxy.call('fbTrackGMApp','upload-photo-video');
					App.mediator.facebook_post_profile_image();	
					break;
				case ui.btn_post:
					WSEventTracker.event("ce11");
					App.mediator.postToOwnWall();	
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
		/**
		 * hides the UI
		 */
		private function shortcut_close_win(  ):void 		
		{	
			if (ui.visible)		
				close_win();	
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
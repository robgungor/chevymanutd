
package code.controllers 
{
		import code.skeleton.App;
		
		import com.oddcast.event.AlertEvent;
		import com.oddcast.event.SendEvent;
		import com.oddcast.utils.gateway.Gateway;
		import com.oddcast.workshop.Callback_Struct;
		import com.oddcast.workshop.ServerInfo;
		
		import flash.display.DisplayObject;
		import flash.events.Event;
		import flash.events.MouseEvent;
		import flash.system.System;
		import flash.ui.Keyboard;
		
		/**
		 * ...
		 * @author Me^
		 */
		public class Embed
		{
			/** user interface for this controller */
			private var ui					:Embed_UI
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
			public function Embed( _btn_open:DisplayObject, _ui:Embed_UI) 
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
				
				embed_code()
				set_tab_order();
				set_focus();
			}
			
			private function embed_code( ):void 
			{	if (!App.mediator.checkPhotoExpired()) 	return;
				// App.mediator.scene_editing.stopAudio();
				ui.tf_embed.text = "";
				App.utils.mid_saver.save_message(new SendEvent(SendEvent.SEND, SendEvent.EMBED_CODE), new Callback_Struct( fin, null, null ) );
				
				function fin():void 
				{	var url:String = ServerInfo.acceleratedURL + "php/api/getEmbed/doorId=" + ServerInfo.door + "/clientId=" + ServerInfo.client + "/mId=" + App.asset_bucket.last_mid_saved + "/type=myspace";
					Gateway.retrieve_XML( url, new Callback_Struct( fin, null, error ));
					function fin( _content:XML ):void 
					{	var result:String = unescape(_content.toString().split("+").join(" "));
						//App.mediator.alert_user( new AlertEvent(null,'f9t553',result, {embed:result}, embed_user_response, false) );
						//WSEventTracker.event("uieb");
						ui.tf_embed.text = result;
						ui.visible = true;
					}
					function error( _msg:String ):void 
					{	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t113', 'Unable to retrieve embed code'));
					}
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
						ui.btn_ok, 
						ui.btn_close,
						ui.btn_copy
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
					case ui.btn_ok:	
						System.setClipboard( ui.tf_embed.text );
						close_win();	
						break;
					case ui.btn_close:	
						close_win();	
						break;
					case ui.btn_copy:	
						System.setClipboard( ui.tf_embed.text );	
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
	
	

	
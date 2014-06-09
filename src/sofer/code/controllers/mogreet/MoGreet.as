package code.controllers.mogreet 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSEventTracker;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.URLVariables;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class MoGreet
	{
		private var ui					:MoGreet_UI;
		private var btn_open			:InteractiveObject;
		
		private const PHONE_NUMS_DELIMITER:String = '-';
		private const PROCESSING_SAVING:String = 'PROCESSING_SAVING';
		private const PROCESSING_SAVING_MESSAGE:String = 'saving message';
		
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
		public function MoGreet( _btn_open:InteractiveObject, _ui:MoGreet_UI) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
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
		{	
			init_shortcuts();
			App.listener_manager.add_multiple_by_object( [	btn_open, 
															ui.btn_close, 
															ui.btn_send_photo,
															ui.btn_send_video] , MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add( ui.tf_phone, Event.CHANGE, beautify_phone_num, this );
			ui.tf_phone.restrict = "0-9";
			ui.tf_phone.maxChars = 12;
			ui.tf_phone.setSelection(ui.tf_phone.text.length, ui.tf_phone.text.length);
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
		 ***************************** PRIVATE */
		private function send_photo():void
		{
			if (phone_num_valid())
				App.mediator.screenshot_host(new Callback_Struct(fin_thumb, null, error_thumb));
			
			function fin_thumb( _url:String ):void
			{
				// sample https://host-vd.oddcast.com/mogreet/sendImageToMogreet.php?doorId=239&clientId=86&imgURL=http://autophoto.oddcast.com/ccs7/AF/tmp/94/cc/94ccc757ada194715a4e01132338ac50.jpg&phone=1231231234
				var url_vars:URLVariables = new URLVariables();
				var url:String		= ServerInfo.localURL + 'mogreet/sendImageToMogreet.php';
				url_vars.doorId		= ServerInfo.door;
				url_vars.clientId	= ServerInfo.client;
				url_vars.phone		= get_formatted_numer();
				url_vars.imgURL		= _url;
				
				var request:Gateway_Request = new Gateway_Request( url, new Callback_Struct( mogreet_fin, null, mogreet_error))
				request.response_eval_method = function(_response:String):Boolean { return _response && _response.toLowerCase() == 'ok'; }
				Gateway.upload( url_vars, request);
				function mogreet_fin( _php_response:String ):void 
				{
					WSEventTracker.event('edmbls');
					close_win();
					App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, 'f9t539', 'MoGreet data has been posted'));
				}
				function mogreet_error( _msg:String ):void 
				{
					App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, 'f9t540', 'Error posting to MoGreet', { details:_msg } ));
				}
			}
			function error_thumb( _e:AlertEvent ):void
			{
			}
		}
		private function send_video( _generate_thumb:Boolean = false ):void 
		{
			if (!App.mediator.checkHasAudio())	// need audio for video export
				return;
			
			var thumb_url:String;	// url to be saved
			
			if (phone_num_valid())
			{
				_generate_thumb ? create_thumbnail() : create_mid();
			}
			
			function create_thumbnail():void 
			{
				App.mediator.processing_start( PROCESSING_SAVING, PROCESSING_SAVING_MESSAGE );
				var dimensions:Point = new Point( 240, 180 );
				var offset:Point = new Point( -50, -65 );
				App.mediator.screenshot_host( new Callback_Struct( fin_thumb, null, error_thumb ), Number.NaN, dimensions, offset );
				function fin_thumb( _url:String ):void 
				{
					thumb_url = _url;
					create_mid();
				}
				function error_thumb( _e:AlertEvent ):void 
				{
					end_processing();
				}
			}
			function create_mid():void 
			{
				App.utils.mid_saver.save_message( null, new Callback_Struct(submit_to_server, null, error_creating_mid));
				function submit_to_server():void 
				{
					var url_vars:URLVariables = new URLVariables();
					var url:String		= ServerInfo.localURL + 'mogreet/saveMogreet.php';
					url_vars.doorId		= ServerInfo.door;
					url_vars.mId		= App.asset_bucket.last_mid_saved;
					url_vars.phone		= get_formatted_numer();
					if (_generate_thumb)
						url_vars.thumb	= thumb_url;
					
					var request:Gateway_Request = new Gateway_Request( url, new Callback_Struct( mogreet_fin, null, mogreet_error))
					request.response_eval_method = function(_response:String):Boolean { return _response && _response.toLowerCase() == 'ok'; }
					Gateway.upload( url_vars, request);
					function mogreet_fin( _php_response:String ):void 
					{
						WSEventTracker.event('edmbls');
						end_processing();
						close_win();
						App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, 'f9t539', 'MoGreet data has been posted'));
					}
					function mogreet_error( _msg:String ):void 
					{
						end_processing();
						App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, 'f9t540', 'Error posting to MoGreet', { details:_msg } ));
					}
				}
				function error_creating_mid( _e:AlertEvent ):void 
				{
					// error is already presented to the user so dont do anything
					end_processing();
				}
			}
			
			function end_processing():void
			{
				App.mediator.processing_ended( PROCESSING_SAVING );
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
		 ***************************** VIEW INTERACTION - PRIVATE */
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case btn_open:		
					open_win();		
					break;
				case ui.btn_close:	
					close_win();	
					break;
				case ui.btn_send_video:	
					send_video(ui.cb_thumb.selected);	
					break;
				case ui.btn_send_photo: 
					send_photo();	
					break;
			}
		}
		private function phone_num_valid():Boolean
		{
			var is_valid:Boolean = ui.tf_phone.text.length == 12;
			if (!is_valid)
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t541", "Please enter a valid phone number to post to MoGreet"));
			return is_valid;
		}
		private function get_formatted_numer():String
		{
			return ui.tf_phone.text.split(PHONE_NUMS_DELIMITER).join('');
		}
		
		private function beautify_phone_num( _e:Event ):void 
		{
			var nums:String = ui.tf_phone.text.split(PHONE_NUMS_DELIMITER).join('');
			if (nums.length <= 3)
				ui.tf_phone.text = nums;
			else if (nums.length <= 6)
				ui.tf_phone.text = nums.substr(0, 3) + PHONE_NUMS_DELIMITER + nums.substr(3, 3);
			else
				ui.tf_phone.text = nums.substr(0, 3) + PHONE_NUMS_DELIMITER + nums.substr(3, 3) + PHONE_NUMS_DELIMITER + nums.substr(6, 4);
			ui.tf_phone.setSelection(ui.tf_phone.text.length, ui.tf_phone.text.length);
		}
		/**
		 * displays the UI
		 * @param	_e
		 */
		private function open_win(  ):void 
		{	
			App.mediator.scene_editing.stopAudio();
			ui.visible = true;
			set_focus();
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
			ui.stage.focus = ui;
		}
		/**
		 * initializes keyboard shortcuts
		 */
		private function init_shortcuts():void
		{	
			App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
			App.shortcut_manager.api_add_shortcut_to( ui.tf_phone, Keyboard.ENTER, shortcut_submit );
		}
		private function shortcut_submit():void 
		{
			send_video();
		}
		private function shortcut_close_win(  ):void 		
		{	
			if (ui.visible)		close_win();	
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
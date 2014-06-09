package code.controllers.alert 
{
	import code.component.skinners.Custom_Scrollbar_Skinner;
	import code.models.*;
	import code.models.items.List_Errors;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import fl.controls.Button;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Alert implements IAlert
	{
		private var ui				:Alert_UI;
		/** callback to the originator of the alert if the user accepted or rejected the alert */
		private var callback		:Function;
		/** if to show the alert code before the message */
		private var show_alert_code	:Boolean=false;
		/** error text and code structs */
		private var model_errors			: List_Errors;
		
		/** default alert panel title if one is not provided */
		private const DEFAULT_TITLE			:String = 'ALERT:';
		private const ALERT_PRETEXT			:String = 'ALERT ';
		private const ALERT_POSTTEXT		:String = ': ';
		
		public function Alert( _ui:Alert_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui = _ui;
			model_errors = App.asset_bucket.model_store.list_errors;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// init this immediately not when the app is initialized since this is needed for the inauguration process
			init();
			
			// calls made before the initialization starts
			close_win();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
			}
		}
		/**
		 * initialize this module
		 */
		private function init(  ):void 
		{	
			ui.btn_ok.tabEnabled = true;
			ui.btn_cancel.tabEnabled = true;
			
			init_shortcuts();
			
			App.listener_manager.add_multiple_by_object( [ui.btn_ok, ui.btn_cancel], 	MouseEvent.CLICK, btn_handler, this );
			App.listener_manager.add( ui.tf_msg, MouseEvent.CLICK, highlight_text, this);
			
			new Custom_Scrollbar_Skinner(ui.tf_scrollbar);
			show_alert_code = false;
		}	
		
		public function set_properties( _show_alert_code:Boolean ):void
		{
			_show_alert_code = false;
			show_alert_code=_show_alert_code;
		}
		
		private function open_win(  ):void 
		{	if (ui.visible)	// dont re-add listeners if panel is already open
				return;
			ui.visible = true;
			App.utils.tab_order.set_order( [	ui.btn_ok, ui.btn_cancel	] );
			set_focus();
		}
		
		private function close_win(  ):void 
		{	
			ui.visible = false;
		}
		
		private function btn_handler( _e:MouseEvent ):void 
		{	close_win();
		
			/* example for your convenience
			switch (_e.target) 
			{	case btn_ok:		break;
				case btn_cancel:	break;
				case btn_close:		break;
			}
			*/
			
			if (callback != null)
			{	
				var temp_callback:Function = callback;
				callback = null;
				temp_callback( _e.target == ui.btn_ok );
			}
		}
		
		/**
		 * display message to the user and report the alert to the server api
		 * @param	_e	alert data
		 */
		public function alert(_e:AlertEvent):void
		{	
			// hardcode value
			var alertText:String;
			
			// translate value from errors.xml if available
			if (model_errors.has_error_code(_e.code))
			{
				alertText			= model_errors.get_error_text( _e.code, _e.text, _e.moreInfo );
				ui.tf_title.text	= model_errors.get_error_title( _e.code ).split("Alert").join("ALERT");
			}
			else	// default values
			{
				alertText 			= _e.text;
				ui.tf_title.text 	= DEFAULT_TITLE;
			}
			ui.titleFacebookShare.visible 	= _e.alertType == AlertEvent.FACEBOOK_CONFIRM;
			ui.title_alert.visible 			= !ui.titleFacebookShare.visible;
			ui.btn_cancel.visible = _e.code == "startOver";
			// show message
			ui.tf_msg.text = alert_pretext(_e.code) + alertText.split("Alert").join("ALERT");
			if(_e.alertType == AlertEvent.FACEBOOK_CONFIRM) ui.tf_msg.text = 	'Press OK to share on Facebook.';
			// save callback
			callback = _e.callback;
			
			//report error
			if (_e.report_error)	
				report_error( _e, alertText );
			
			// button status
			ui.btn_cancel.visible 	= ui.btn_ok.visible 		= !_e.block_user_feedback;
			//ui.btn_close.visible 	= 
			
			
			// kazaaaam
			reset_tf();
			open_win();
			
			function alert_pretext(_error_code:String):String
			{
				var pretext:String='';
				if (show_alert_code)
					pretext=ALERT_PRETEXT+_error_code+ALERT_POSTTEXT;
				return pretext;
			}
			
			ui.tf_msg.dispatchEvent(new Event(Event.CHANGE));// make sure the scrollbar is enabled... sometimes its not enabled or disabled...
		}
		
		/**
		 * reports an error to the backend
		 * @param	_alert		error information
		 * @param	_alert_text	error text (optional, this overwrites the one from the alert if present )
		 */
		public function report_error( _alert:AlertEvent, _alert_text:String = null ):void 
		{	ErrorReporter.report(_alert, _alert_text, App.settings.BUILD_TIMESTAMP );
		}
		
		/**
		 * positions the texfield
		 */
		private function reset_tf(  ):void 
		{	//ui.tf_msg.scrollV				= 1;
		}
		
		private function highlight_text( _e:MouseEvent ):void 
		{	//ui.tf_msg.setSelection(0, ui.tf_msg.text.length);
		}
		
		/**
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
		{	App.shortcut_manager.api_add_shortcut_to( ui	, Keyboard.ENTER	, shortcut_ok );
			App.shortcut_manager.api_add_shortcut_to( ui	, Keyboard.ESCAPE	, shortcut_cancel );
		}	
		private function shortcut_ok(  ):void 		{	ui.btn_ok.dispatchEvent(new MouseEvent(MouseEvent.CLICK));		}
		private function shortcut_cancel(  ):void 	{	ui.btn_cancel.dispatchEvent(new MouseEvent(MouseEvent.CLICK));	}
		 /*******************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
	}

}
package code.controllers.paypal 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ServerInfo;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLVariables;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Paypal
	{
		private var ui					:Paypal_UI;
		private var btn_open			:InteractiveObject;
		
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
		public function Paypal( _btn_open:InteractiveObject, _ui:Paypal_UI ) 
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
		{	
			init_shortcuts();
			App.listener_manager.add_multiple_by_object( [	btn_open, 
															ui.btn_close, 
															ui.btn_direct, 
															ui.btn_confirmation ] , MouseEvent.CLICK, btn_handler, this );
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
		private function btn_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{	
				case btn_open:					open_win();		break;
				case ui.btn_close:				close_win();	break;
				case ui.btn_confirmation:		request_paypal(true);	break;
				case ui.btn_direct:				request_paypal(false);	break;
				default:
			}
		}
		/**
		 * displays the UI
		 */
		private function open_win(  ):void 
		{	
			if (App.mediator.checkHasAudio())
			{
				App.mediator.scene_editing.stopAudio();
				ui.visible = true;
				set_focus();
			}
		}
		/**
		 * hides the UI
		 */
		private function close_win(  ):void 
		{	ui.visible = false;
		}
		private function request_paypal( _with_confirmation:Boolean ):void
		{
			close_win();
			App.utils.mid_saver.save_message( null, new Callback_Struct( fin ) )
			function fin():void 
			{	
				var mid			:String	= App.asset_bucket.last_mid_saved;
				var confirmation:String	= _with_confirmation ? '0' : '1';
				var sku_list	:String	= build_php_array( ServerInfo.arr_paypal_product_sku );
				var url			:String	= ServerInfo.localURL + 'paypal/startPaypal.php?doorId=' + ServerInfo.door + '&mId=' + mid + '&skpConf=' + confirmation +'&' + sku_list;
				
				var alert:AlertEvent = new AlertEvent(AlertEvent.CONFIRM, '', 'Click OK to continue', null, user_response);
				alert.report_error = false;
				App.mediator.alert_user( alert );
				
				function user_response( _ok:Boolean ):void
				{
					if (_ok)
						App.mediator.open_hyperlink( url );
				}
				
				/**
				 * builds a php/http friendly array
				 * @param	_xml array which should be saved
				 * @param	_vars the object the associative array will be added to
				 * @return (eg: 'file[photoface]=URLLLL&file[lux]=URLLLL&....' )
				 */
				function build_php_array( _arr:Array ):String 
				{	
					var vars:URLVariables = new URLVariables();
					for (var n:int = _arr.length, i:int = 0; i < n; i++)
					{
						var sku_name:String = _arr[i];
						vars['SKUs[' + i + ']'] = sku_name;
					}
					return vars.toString();
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
		***************************** KEYBOARD SHORTCUTS */
		/**
		 * sets stage focus to the UI
		 */
		private function set_focus():void
		{	ui.stage.focus = ui;
		}
		/**
		 * initializes keyboard shortcuts
		 */
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}
		private function shortcut_close_win(  ):void 		
		{	if (ui.visible)		close_win();	
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
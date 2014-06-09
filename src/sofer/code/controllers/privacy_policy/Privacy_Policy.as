package code.controllers.privacy_policy 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	
	import flash.display.*;
	import flash.events.*;

	/**
	 * ...
	 * @author Me^
	 */
	public class Privacy_Policy
	{
		private var btn_open:InteractiveObject;
		
		public function Privacy_Policy( _btn_open:InteractiveObject ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			btn_open		= _btn_open;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
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
			App.listener_manager.add( btn_open, MouseEvent.CLICK, show_privacy, this );
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
		private function show_privacy( _e:MouseEvent ):void 
		{
			var alert:AlertEvent = new AlertEvent( AlertEvent.CONFIRM, '', App.settings.PRIVACY_POLICY_TEXT, null, privacy_response );
			alert.report_error = false;
			App.mediator.alert_user( alert );
			
			function privacy_response( _ok:Boolean ):void 
			{
				if (_ok)
				{
					// do something for accept
				}
				else
				{
					// do something for deny
				}
			}
		}
	}

}
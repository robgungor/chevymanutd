package code.controllers.expiration 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.workshop.*;
	
	import flash.events.*;
	/**
	 * controller shows a view which blocks the user from using the app with an expired message
	 * if the back end determines that this application is expired
	 * 
	 * @author Me^
	 */
	public class Expiration
	{
		private var ui:Expiration_UI;
		
		public function Expiration( _ui:Expiration_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui = _ui;
			
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
		private function init(  ):void 
		{	
			if (ServerInfo.isExpired)
			{	
				App.listener_manager.add( ui.btn_close, MouseEvent.CLICK, close_win, this );
				App.listener_manager.add( ui.btn_oddcast, MouseEvent.CLICK, App.mediator.open_hyperlink_oddcast, this );
				open_win();
			}
		}
		private function close_win( _e:MouseEvent = null ):void 
		{	ui.visible = false;
		}
		private function open_win(  ):void 
		{	ui.visible = true;
		}
		
	}

}
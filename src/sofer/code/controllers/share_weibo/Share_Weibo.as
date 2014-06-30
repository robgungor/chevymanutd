package code.controllers.share_weibo 
{
	import code.skeleton.App;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSEventTracker;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Share_Weibo
	{
		private var btn_open			:InteractiveObject;
		private var ui					:ShareWeiboUI;
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
		public function Share_Weibo( _btn_open:InteractiveObject, _ui:ShareWeiboUI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			btn_open		= _btn_open;
			ui 				= _ui;
			ui.visible 		= false;
			
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
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	
			App.listener_manager.add( btn_open, MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add( ui.btn_profile, MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add( ui.btn_close, MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add( ui.btn_tweet, MouseEvent.CLICK, mouse_click_handler, this );
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
			switch ( _e.currentTarget )
			{	
				case btn_open:					
					open_win();
					break;
				case  ui.btn_tweet:					
					App.mediator.weiboUpdateStatus();
					break;
				case  ui.btn_profile:					
					App.mediator.weiboPostProfileImage();
					break;
				case  ui.btn_close:					
					close_win();
					break;
			}
		}
		private function open_win():void
		{
			App.localizer.localize(this.ui, "twitter_share");
			//ui.visible = true;
			App.mediator.weibo_connect_login(_onLogin);
		}
		private function _onLogin(e:* = null):void
		{			
			
			App.utils.mid_saver.save_message( null, new Callback_Struct(fin_message_saved, null, error_message) );
			function fin_message_saved():void
			{
				trace("MESSAGE SAVED");
				//App.mediator.processing_ended(POSTING_TO_FACEBOOK);
				end_processing();						
				ui.visible = true;
			}
			function error_message( _e:AlertEvent ):void
			{	end_processing();
			}
			function end_processing(  ):void 
			{	
			}
		}
		private function close_win():void
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
		*/
		
	}

}
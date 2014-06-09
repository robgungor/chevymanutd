package code.controllers.share_delicious 
{	
	import code.skeleton.App;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ExternalInterface_Proxy;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSEventTracker;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * ...
	 * @author Me^
	 */
	public class Share_Delicious
	{
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
		public function Share_Delicious( _btn_open:InteractiveObject ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			btn_open = _btn_open;
			
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
		{	App.listener_manager.add( btn_open, MouseEvent.CLICK, share_workshop, this);
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
		private function share_workshop( _e:MouseEvent ):void 
		{	
			App.mediator.scene_editing.stopAudio();
			App.utils.mid_saver.save_message( null, new Callback_Struct( share_to_destination ) );
			function share_to_destination(  ):void
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "f9t150", "Click OK to continue...", null, open_link));
				function open_link( _ok:Boolean ):void
				{
					if (_ok)
					{
						var url:String;
						var workshop_url	:String = ServerInfo.pickup_url + '?mId=' + App.asset_bucket.last_mid_saved + '.3';
						var workshop_name	:String = App.settings.SHARE_APP_TITLE;	// "Template 3D";
						
						url = "http://delicious.com/save?v=5&noui&jump=close&url=" + escape(workshop_url) + "&title=" + escape(workshop_name);
						ExternalInterface_Proxy.call("window.open", url, "delicious", "toolbar=no,width=550,height=550");
						
						WSEventTracker.event("edbmk");
					}
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
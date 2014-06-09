package code.controllers.share_twitter 
{
	import code.skeleton.App;
	
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
	public class Share_Twitter
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
		public function Share_Twitter( _btn_open:InteractiveObject ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
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
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	
			App.listener_manager.add( btn_open, MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add( App.ws_art.mainPlayer.twitter_btn, MouseEvent.CLICK, mouse_click_handler, this );
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
					WSEventTracker.event("ce10");
					//App.mediator.checkOptIn(share_to_twitter);
					share_to_twitter();
					break;
				case  App.ws_art.mainPlayer.twitter_btn:
					WSEventTracker.event("ce10");
					WSEventTracker.event("gce5");
					//App.mediator.checkOptIn(share_to_twitter);
					share_to_twitter();
					break;
			}
		}
		private function share_to_twitter(  ) : void
		{
			
			if (!App.mediator.checkPhotoExpired()) return;
			//App.mediator.scene_editing.stopAudio();
			App.utils.mid_saver.save_message(null, new Callback_Struct( fin ) );
			
			function fin():void 
			{
				/**
				 * NOTE NOTE NOTE
				 * if you need multiple parameters in your url, eg
				 * 		url=http://host.oddcast.com/template/?mId=124&asd=asd&dsa=dsa
				 * then you need to use bit.ly to shorten the url since twitter will only save the first param
				 */
				/**
				 * Example
				 * http://twitter.com/share?url=http://host-d-vd.oddcast.com/php/application_UI/doorId=860/clientId=317/?mId=203509.3&text=Check%20out%20my%20Monk-E-Mail!
				 */
				var message_id		:String =  App.asset_bucket.last_mid_saved ? '?mId=' + App.asset_bucket.last_mid_saved + '.3' : "";
				var embed_url 		:String = ServerInfo.pickup_url + message_id;
				var twitter_base	:String = "http://twitter.com/share";
				var default_message	:String = escape(App.settings.TWITTER_DEFAULT_TEXT);//"Default message goes here with a link."
				var twitter_link	:String = twitter_base+'?url='+embed_url+'&text='+default_message;
				WSEventTracker.event("edbmk");
				App.mediator.open_hyperlink(twitter_link);
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
		*/
		
	}

}
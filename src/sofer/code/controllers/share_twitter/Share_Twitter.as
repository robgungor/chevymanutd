package code.controllers.share_twitter 
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
	public class Share_Twitter
	{
		private var btn_open			:InteractiveObject;
		private var ui					:ShareTwitterUI;
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
		public function Share_Twitter( _btn_open:InteractiveObject, _ui:ShareTwitterUI ) 
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
			//App.listener_manager.add( ui.btn_profile, MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add( ui.btn_close, MouseEvent.CLICK, mouse_click_handler, this );
			//App.listener_manager.add( ui.btn_tweet, MouseEvent.CLICK, mouse_click_handler, this );
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
					WSEventTracker.event("ce13");
					share_to_twitter();
					break;
				case  ui.btn_profile:			
					WSEventTracker.event("ce14");
					App.mediator.twitterPostProfileImage();
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
				 * 		url=http://host.oddcast.com/template/&mId=124&asd=asd&dsa=dsa
				 * then you need to use bit.ly to shorten the url since twitter will only save the first param
				 */
				/**
				 * Example
				 * http://twitter.com/share?url=http://host-d-vd.oddcast.com/php/application_UI/doorId=860/clientId=317/&mId=203509.3&text=Check%20out%20my%20Monk-E-Mail!
				 */
				var asset:* = App.asset_bucket;
				
				var mid:String = App.asset_bucket.last_mid_saved;
				var message_id		:String =  App.asset_bucket.last_mid_saved ? '&mId=' + App.asset_bucket.last_mid_saved + '.3' : "";
				trace("Share_Twitter::fin::"+message_id);
				var embed_url 		:String = ServerInfo.pickup_url + message_id;
				var twitter_base	:String = "http://twitter.com/share";
				var default_message	:String = escape(App.settings.TWITTER_DEFAULT_TEXT);//"Default message goes here with a link."
				var twitter_link	:String = twitter_base+'?url='+escape(embed_url)+'&text='+default_message;
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
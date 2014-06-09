package code.controllers.myspace_connect
{
	import code.models.Model_Store;
	import code.skeleton.App;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.Eval_PHP_Response;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ExternalInterface_Proxy;
	import com.oddcast.workshop.ServerInfo;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class MySpace_Connect implements IMyspace_Connect
	{	
		/* user data struct */
		private var user_struct				:Myspace_User = new Myspace_User();
		/* list of all the user images */
		private var user_images_list		:User_Images_List;
		/* list of friends images */
		private var friends_images_list		:User_Friends_Images_List;
		private var ui						:Myspace_Connect_Status_UI;
		/** current user thumb */
		private var cur_thumb				: Loader;
		private var on_logged_in_callback	:Function;
		
		public function MySpace_Connect( _ui:Myspace_Connect_Status_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui = _ui;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// init this immediately not when the app is initialized since this is needed for the inauguration process
			init();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
			}
		}
		/**
		 * initialize interface and data structs
		 */
		private function init(  ):void 
		{	// try connecting to javascript
			if (ExternalInterface_Proxy.available)
			{	try 
				{	ExternalInterface_Proxy.addCallback('js_user_logged_in',	js_user_logged_in);
					ExternalInterface_Proxy.call('msiSetFlashCallbackFunction', 'js_user_logged_in');
				}
				catch (e:Error)
				{	error_connecting_to_js();
				}
			}
			else
				error_connecting_to_js();
			
			function error_connecting_to_js():void
			{	trace ('error setting js');
				ui.visible				= false;	// since javascript is not available we hide it
			}
			
			ui.status_dialogue.tf_username.text = '';
			App.listener_manager.add(ui.btn_login, MouseEvent.CLICK, click_event_handler, this);
			App.listener_manager.add(ui.status_dialogue.btn_logout, MouseEvent.CLICK, click_event_handler, this);
			status_display( false );
		}
		private function click_event_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{	
				case ui.btn_login:	
					open_login_win();			
					break;
				case ui.status_dialogue.btn_logout:	
					logout_user();	
					break;
			}
		}
		public function open_win(  ):void 
		{	ui.visible = true;
		}
		public function close_win(  ):void 
		{	ui.visible = false;
		}
		/**
		 * sets the display of the status window as logged in or out
		 * @param	_logged_in_mode if the user is logged in or out
		 */
		private function status_display( _logged_in_mode:Boolean ):void 
		{
			ui.art_login.mouseEnabled	= false;
			ui.art_login.mouseChildren	= false;
			
			ui.btn_login.visible		= 
			ui.art_login.visible		= !_logged_in_mode;
			ui.status_dialogue.visible	= _logged_in_mode;
		}
		/**
		 * calls js function to open the myspace login win
		 */
		private function open_login_win( _on_logged_in_callback:Function = null ):void 
		{
			on_logged_in_callback = _on_logged_in_callback;
			ExternalInterface_Proxy.call('msiLogin');
		}
		/**
		 * retrieves the users friends photos
		 * @param	_e
		 */
		public function friends_photos_requested( _callback:Function ):void
		{
			if (user_struct.is_logged_in)
				retrieve_photos();
			else
			{
				//alert_user(new AlertEvent(AlertEvent.ALERT, "", "You must be logged in to MySpace to import your images.  Please log in, then press OK.", null, user_logged_in));
				open_login_win( user_logged_in );
			}
			
			/** we have to wait until the user logs in before we can allow them to download photos */
			function user_logged_in( _ok:Boolean = true ):void
			{
				if (user_struct.is_logged_in)
					retrieve_photos();
			}
			/** user is logged in so start retrieving photos */
			function retrieve_photos():void
			{
				get_myspace_friends( images_ready, error );
			}
			/** ERROR in the proccess */
			function error():void
			{
				alert_user(new AlertEvent(AlertEvent.ERROR, '', 'Error retrieving photos from MySpace.  Please try again.'));
			}
			/** images are ready for usage */
			function images_ready():void
			{
				if (_callback != null)	_callback( friends_images_list.images );
			}
		}
		/**
		 * retrieves the users photos
		 * @param	_e
		 */
		public function users_photos_requested( _callback:Function ):void 
		{
			if (user_struct.is_logged_in)
				retrieve_photos();
			else
			{
				//alert_user(new AlertEvent(AlertEvent.ALERT, "", "You must be logged in to MySpace to import your images.  Please log in, then press OK.", null, user_logged_in));
				open_login_win( user_logged_in );
			}
			
			/** we have to wait until the user logs in before we can allow them to download photos */
			function user_logged_in( _ok:Boolean = true ):void
			{
				if (user_struct.is_logged_in)
					retrieve_photos();
			}
			/** user is logged in so start retrieving photos */
			function retrieve_photos():void
			{
				get_myspace_photos( images_ready, error );
			}
			/** ERROR in the proccess */
			function error():void
			{
				alert_user(new AlertEvent(AlertEvent.ERROR, '', 'Error retrieving photos from MySpace.  Please try again.'));
			}
			/** images are ready for usage */
			function images_ready():void
			{
				if (_callback != null)	_callback ( user_images_list.images );
			}
		}
		/**
		 * error handling
		 * @param	_alert specif alert in question
		 */
		private function alert_user( _alert:AlertEvent ):void 
		{
			App.mediator.alert_user( _alert );
		}
		
		/**
		 * callback from the javascript when the user has logged in
		 * @param	_token	token used for requests
		 * @param	_token_secret	token secret used for requests
		 */
		private function js_user_logged_in( _token:String, _token_secret:String ):void 
		{
			user_struct.token			= escape(_token);
			user_struct.token_secret	= escape(_token_secret);
			get_myspace_user( done, fail );
			function done():void 
			{
				status_display( true );
				ui.status_dialogue.tf_username.text = user_struct.name.toUpperCase();
				notify_caller();
			}
			function fail():void 
			{
				status_display(false);
				notify_caller();
			}
			
			/** if there is a callback someone wants to know then that user is logged in... tell them please... be nice */
			function notify_caller():void
			{
				if (on_logged_in_callback != null)
				{
					on_logged_in_callback();
					on_logged_in_callback = null;
				}
			}
		}
		
		private function logout_user(  ):void 
		{
			remove_prev_thumb();
			user_struct = new Myspace_User();
			status_display( false );
			App.mediator.open_hyperlink( 'http://www.myspace.com/index.cfm?fuseaction=signout' ); // URL_Opener.open_url('http://www.myspace.com/index.cfm?fuseaction=signout', URL_Opener.BLANK);
		}
		
		/**
		 * download data for a logged in user
		 * _completed function to be called once the process is complete
		 * _fail function to be called if the user didnt log in correctly
		 */
		private function get_myspace_user( _completed:Function, _fail:Function ):void 
		{
			var func		:String	= '?fnc=GetUser';
			var token		:String = '&Token=' + user_struct.token;
			var token_secret:String = '&TokenSecret=' + user_struct.token_secret;
			var door		:String	= '&doorId=' + ServerInfo.door;
			var request_url	:String = ServerInfo.localURL + 'plugins/MySpaceID/myspaceid_proxy.php' + func + token + token_secret + door;
			//SAMPLE CALL 'http://host.staging.oddcast.com/plugins/MySpaceID/myspaceid_proxy.php?fnc=GetUser&Token=CQdWjZXxWdYwmSxTajGnGhD02qP4NMvH4IRrEBi2RWS7PvHJ0xErRGTHB4l3oPQ1ldvO8RgxcfPFW521KwQ1uoKr8QuOuFxzCVqvT2BIwyo%3D&TokenSecret=e9a9f9743f65431ab966e297bba96519'
			
			Gateway.retrieve_XML( request_url, new Callback_Struct( php_response, null, _fail ) );
			
			function php_response( _xml:XML ):void
			{
				if ( new Eval_PHP_Response(_xml).is_response_valid() )
				{
					var ns:Namespace			= _xml.namespace();
					user_struct.user_id			= _xml.ns::userid;
					user_struct.name			= _xml.ns::displayname;
					user_struct.image_url		= _xml.ns::largeimageuri;
					user_struct.thumb_url		= _xml.ns::imageuri;
					user_struct.is_logged_in	= (user_struct.user_id.length > 0);
					if (user_struct.is_logged_in)
					{
						_completed();
						load_user_thumb( user_struct.thumb_url );
					}
					else
						_fail();
				}
				else
					_fail();
			}
			
		}
		private function load_user_thumb( _thumb_url:String ) : void
		{
			remove_prev_thumb();
			var thumb_height:Number	= ui.status_dialogue.thumb.height;
			var thumb_width	:Number	= ui.status_dialogue.thumb.width;
			
			Gateway.retrieve_Loader( new Gateway_Request( _thumb_url, new Callback_Struct(fin, null, error), 0, null, null, true ) );
			function fin( _ldr:Loader ) : void
			{
				// set the right size for it
				_ldr.width	= thumb_width;
				_ldr.height	= thumb_height;
				
				ui.status_dialogue.thumb.addChild( _ldr );
				cur_thumb = _ldr;
			}
			function error( _msg:String ) : void
			{
				
			}
		}
		private function remove_prev_thumb(  ) : void
		{
			if (cur_thumb)
			{
				if (cur_thumb.parent)
					cur_thumb.parent.removeChild(cur_thumb);
				cur_thumb.unload();
				cur_thumb = null;
			}
		}
		/**
		 * download logged in users friends photos
		 * _completed function to be called once the process is complete
		 * _fail error occurred
		 */
		private function get_myspace_friends( _completed:Function, _fail:Function ):void 
		{
			if (user_struct.is_logged_in)
				download_data();
			else
				_fail();
			
			function download_data():void
			{
				var func		:String	= '?fnc=GetFriends';
				var uid			:String = '&UID=' + user_struct.user_id;
				var token		:String = '&Token=' + user_struct.token;
				var token_secret:String = '&TokenSecret=' + user_struct.token_secret;
				var door		:String	= '&doorId=' + ServerInfo.door;
				var request_url	:String = ServerInfo.localURL + 'plugins/MySpaceID/myspaceid_proxy.php' + func + uid + token + token_secret + door;
				//SAMPLE CALL 'http://host.staging.oddcast.com/plugins/MySpaceID/myspaceid_proxy.php?fnc=GetFriends&UID=123456789&Token=CQdWjZXxWdYwmSxTajGnGhD02qP4NMvH4IRrEBi2RWS7PvHJ0xErRGTHB4l3oPQ1ldvO8RgxcfPFW521KwQ1uoKr8QuOuFxzCVqvT2BIwyo%3D&TokenSecret=e9a9f9743f65431ab966e297bba96519'
				
				//Gateway.download_XML(new Gateway_Request( request_url, new Callback_Struct( fin, null, error )));
				Gateway.retrieve_XML( request_url, new Callback_Struct( fin, null, error ));
				function fin( _content:XML ):void 
				{	friends_images_list = new User_Friends_Images_List( _content );
					_completed();
				}
				function error( _msg:String ):void 
				{	_fail();
				}
			}
		}
		/**
		 * download logged in users photos
		 * _completed function to be called once the process is complete
		 * _fail error occurred
		 */
		private function get_myspace_photos( _completed:Function, _fail:Function ):void 
		{
			if (user_struct.is_logged_in)
				download_data();
			else
				_fail();
			
			function download_data():void
			{
				var func		:String	= '?fnc=GetPhotos';
				var uid			:String = '&UID=' + user_struct.user_id;
				var token		:String = '&Token=' + user_struct.token;
				var token_secret:String = '&TokenSecret=' + user_struct.token_secret;
				var door		:String	= '&doorId=' + ServerInfo.door;
				var request_url	:String = ServerInfo.localURL + 'plugins/MySpaceID/myspaceid_proxy.php' + func + uid + token + token_secret + door;
				//SAMPLE CALL 'http://host.staging.oddcast.com/plugins/MySpaceID/myspaceid_proxy.php?fnc=GetPhotos&UID=123456789&Token=CQdWjZXxWdYwmSxTajGnGhD02qP4NMvH4IRrEBi2RWS7PvHJ0xErRGTHB4l3oPQ1ldvO8RgxcfPFW521KwQ1uoKr8QuOuFxzCVqvT2BIwyo%3D&TokenSecret=e9a9f9743f65431ab966e297bba96519'
				
				Gateway.retrieve_XML( request_url, new Callback_Struct( fin, null, error ));
				function fin( _content:XML ):void 
				{	user_images_list = new User_Images_List( _content );
					_completed();
				}
				function error( _msg:String ):void 
				{	_fail();
				}
			}
		}
		
	}
	
}
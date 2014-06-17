package code.skeleton.mediator 
{
	import code.HeadStruct;
	import code.controllers.alert.IAlert;
	import code.controllers.auto_photo.IAuto_Photo_Win;
	import code.controllers.auto_photo.apc.IAuto_Photo_APC;
	import code.controllers.auto_photo.auto_photo.IAuto_Photo;
	import code.controllers.auto_photo.browse.IAuto_Photo_Browse;
	import code.controllers.auto_photo.mask.IAuto_Photo_Mask;
	import code.controllers.auto_photo.points.IAuto_Photo_Points;
	import code.controllers.auto_photo.position.IAuto_Photo_Position;
	import code.controllers.auto_photo.search.IAuto_Photo_Search;
	import code.controllers.auto_photo.webcam.IAuto_Photo_Webcam;
	import code.controllers.backgrounds.IBG_Selector;
	import code.controllers.body_position.IBody_Position;
	import code.controllers.email.IEmail;
	import code.controllers.facebook_connect.IFacebook_Connect;
	import code.controllers.facebook_friend.IFacebook_Friend_Search;
	import code.controllers.jpg_export.IJPG_Export;
	import code.controllers.main_loader.IMain_Loader;
	import code.controllers.message_player.IMessage_Player;
	import code.controllers.myspace_connect.IMyspace_Connect;
	import code.controllers.persistent_image.IPersistent_Image;
	import code.controllers.processing.IProcessing;
	import code.controllers.vhost_back_selection.IVhost_Back_Selection;
	import code.controllers.vhost_selection.IVhost_Selection;
	import code.skeleton.App;
	import code.skeleton.Localizer;
	import code.skeleton.Utils;
	import code.utils.Image_Uploader;
	
	import com.adobe.images.PNGEncoder;
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.host.api.morph.*;
	import com.oddcast.player.IInternalPlayerAPI;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.throttle.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	import workshop.fbconnect.FacebookUser;

	/**
	 * ...
	 * @author Me^
	 */
	public class Mediator extends EventDispatcher
	{
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ********************** LIST OF INTERFACE CONTROLLERS which the mediator can communicate with *******/
		
		/** a list of controllers that the mediator references to pass data and events */		
		private var controller_pool:Controller_Pool = new Controller_Pool();
		
		/**
		 * stores a reference to a class if one is declared properly* for the mediator to communicate with 
		 * @param _interface if youre adding code.controllers.Alert make sure there is a variable in Controller_Pool of type Alert or whatever interface IAlert for example
		 * @return true if the class was registerred 
		 */		
		public function register_controller(_interface:*) : Boolean
		{
			return controller_pool.register_controller(_interface);
		}
		/********************************************************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
		public function Mediator() 
		{}
		
		/*
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
		* ************************************* GENERAL OR SARGENT PEPPER */
		public function playScene():void
		{	
			//scene_editing.playSceneAudio();
			//track_audio_playback_type(scene_editing.audio);
		}
		public function stopScene():void
		{	//scene_editing.stopAudio();
			//controller_pool.dance_scene.stop();
		}
		/**
		 * called when the status of the checkbox changes	
		 * @param	_is_checked
		 */
		public function morph_checkbox_color_clicked( _is_checked:Boolean ):void 
		{	scene_editing.change_color_analyzer( _is_checked );
		}
		/**
		 * called when the status of the checkbox changes
		 * @param	_is_checked value of the checkbox
		 */
		public function morph_checkbox_clicked( _is_checked:Boolean ):void 
		{	// make sure we can morph before doing anything
			if (_is_checked &&
				!App.asset_bucket.model_store.list_vhosts.is_morphing_capable())
			{	
				alert_user ( new AlertEvent( AlertEvent.ERROR, '', 'Morphing assets missing'));
				App.ws_art.check_morph.set_check( false );
				return;
			}
			
			App.ws_art.vhost_type_selector.visible	= !_is_checked;
			App.ws_art.check_morph_color.visible	= _is_checked;
			
			if (controller_pool.vhost_selection_back)
			{	
				if (_is_checked)
					controller_pool.vhost_selection_back.open_win();
				else				
					controller_pool.vhost_selection_back.close_win();
			}
			
			if (App.ws_art.check_morph.get_is_selected() )		
				morph_models();
			else													
				load_non_morph_model();
		}
		public function background_upload( _e:MouseEvent ):void 
		{
			Throttler.autophoto_upload_allowed( upload_file, server_capacity_surpassed, server_capacity_surpassed );
			
			function upload_file(  ):void 
			{
				if (Throttler.last_response_was_instant)
					build_request(true);
				else
				{
					var alert:AlertEvent = new AlertEvent(AlertEvent.CONFIRM, 'f9t542', 'Click ok to continue', false, build_request);
					alert.report_error = false;
					alert_user(alert);
				}
					
				function build_request( _ok:Boolean ):void 
				{
					if (_ok)
					{
						manage_listeners(true);
						toggle_processing_on_waiting(true);
						App.asset_bucket.bg_uploader.autoSubmitBrowsed = true;
						App.asset_bucket.bg_uploader.browse();
						
						function image_selected(_e:Event):void
						{
							manage_listeners(false);
							toggle_processing_on_waiting(false);
						}
						function image_selection_cancelled(_e:Event):void
						{
							manage_listeners(false);
							toggle_processing_on_waiting(false);
						}
						function toggle_processing_on_waiting( _start:Boolean ):void
						{
							var processing_text:String = App.asset_bucket.model_store.list_errors.get_error_text('f9t546', 'Waiting for file selection');
							if (_start)
								App.mediator.processing_start( processing_text, processing_text );
							else
								App.mediator.processing_ended( processing_text );
						}
						function manage_listeners(_add:Boolean):void
						{
							if (_add)
							{
								App.listener_manager.add(App.asset_bucket.bg_uploader,Event.SELECT,image_selected,this);
								App.listener_manager.add(App.asset_bucket.bg_uploader,Event.CANCEL,image_selection_cancelled,this);
							}
							else
							{
								App.listener_manager.remove(App.asset_bucket.bg_uploader,Event.SELECT,image_selected);
								App.listener_manager.remove(App.asset_bucket.bg_uploader,Event.CANCEL,image_selection_cancelled);
							}
						}
					}
				}
			}
			function server_capacity_surpassed(  ):void 
			{
				alert_user(new AlertEvent(AlertEvent.ERROR, "", "Server capacity surpassed.  Please try again later."));
			}
		}
		
		/**
		 * appropriate filename to be saved on users machine for any extension
		 * @param	_server_filename original filename as it resides on the server
		 * @return string of filename
		 */
		public function appropriate_filename( _server_filename:String ):String
		{	var file_name	:String		= App.settings.SHARE_APP_TITLE;
			var index		:int		= _server_filename.split('.').length - 1;
			var extension	:String		= _server_filename.split('.')[index];
			return (file_name + '.' + extension);
		}
		/**********************************************************
		* 
		* 
		*
		* 
		* 
		* 
		* 
		* 
		* ************************************* FACEBOOK CONNECT */
		/**
		 * retrieve the user ID of the current logged in user
		 * @return
		 */
		public function facebook_connect_checkLoginState(callback:Function):void
		{
			controller_pool.facebook_connect.checkConnectedState(callback);
		}
		public function facebook_connect_user_id(  ) : String
		{
			if (controller_pool.facebook_connect)
				return controller_pool.facebook_connect.user_id();
			return '';
		}
		public function facebook_connect_user():FacebookUser
		{
			return controller_pool.facebook_connect.user;
		}
		public function facebook_connect_is_logged_in():Boolean
		{
			if (controller_pool.facebook_connect)
				return controller_pool.facebook_connect.is_logged_in();
			return false;
		}
		public function facebook_connect_login(_callback:Function ):void
		{
			if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.login( _callback );
		}
		public function facebook_connect_get_friends_info(_fin:Function, _include_self:Boolean = true, _max_return:int = -1 ):void
		{
			if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.fbcGetFriendsInfo( _fin, _include_self, _max_return );
		}
		public function facebook_connect_get_user_photos(_fin:Function):void
		{
			if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.getUserPictures( _fin );
		}
		public function facebook_connect_get_friends_photos(_fin:Function, _friend_id:String):void
		{
			if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.fbcGetFriendsPictures(_fin,_friend_id );
		}
		public function facebook_connect_get_users_album_photos( _fin:Function, _user_id:String = null, _max_photos:Number=300 ):void
		{
			if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.fbcGetPicturesFromAlbums(_fin, _user_id,_max_photos);
		}
		public function facebook_connect_get_users_tagged_and_albums( _fin:Function, _user_id:String = null, _max_photos:Number=300 ):void
		{
			if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.fbcGetUserPicturesTaggedAndAlbumsCombo(_fin, _user_id,_max_photos);
		}
		public function postToOwnWall():void
		{
			if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.post_to_own_wall();
		}
		
		public function postToGooglePlus():void
		{
			if (controller_pool.google_connect)
				controller_pool.google_connect.post_to_GooglePlus();
		}
		
		public function twitterPostProfileImage():void
		{
			if (controller_pool.twitter_connect)
				controller_pool.twitter_connect.post_profile_image();
		}
		
		public function twitterTweet():void
		{
			if (controller_pool.twitter_connect)
				controller_pool.twitter_connect.update_status();
		}
		/**
		 * logs a user in, creates a thumb url, creates an mid, posts data
		 * @param	_user_id if null then posts to your own wall
		 * @param	_thumb_url	if null one will be autogenerated or used from settings xml
		 */
		public function facebook_post_new_mid_to_user( _user_id:String = null, _thumb_url:String = null ):void
		{
			if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.post_new_mid_to_user( _user_id, _thumb_url );
		}
		
		
		public function googlePlus_connect_get_user_photos(_fin:Function):void
		{	trace("Mediator::googlePlus_connect_get_user_photos - ");
			if (controller_pool.google_connect)
				controller_pool.google_connect.gpcGetPictures(_fin);
		}
		/**********************************************************
		* 
		* 
		*
		* 
		* 
		* 
		* 
		* 
		* ************************************* ALERT CONFIRM COPY */
		public function alert_set_init_params( _show_alert_code:Boolean ):void
		{
			if (controller_pool.alert)
				controller_pool.alert.set_properties(_show_alert_code);
		}
		/**
		 * alert the user of an error or a confirmation
		 * @param	_e
		 */
		public function alert_user( _e:AlertEvent ):void 
		{
			if (controller_pool.alert)
				controller_pool.alert.alert(_e);
		}
		/**
		 * reports an error to the backend
		 * @param	_alert		error information
		 * @param	_alert_text	error text (optional, this overwrites the one from the alert if present )
		 */
		public function report_error( _alert:AlertEvent, _alert_text:String = null ):void
		{	
			if (controller_pool.alert)
				controller_pool.alert.report_error( _alert, _alert_text );
		}
		/**********************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* ************************************* SMALL AND BIG SHOWS */
		/** event dispatched when the user is ready to interact with the application, playback or editing state */
		public const EVENT_WORKSHOP_LOADED:String					= 'EVENT_WORKSHOP_LOADED';
		/** event dispatched when the editing state of the app is ready */
		public const EVENT_WORKSHOP_LOADED_EDITING_STATE:String		= 'EVENT_WORKSHOP_LOADED_EDITING_STATE';
		/** event dispatched when the playback state of the app is ready */
		public const EVENT_WORKSHOP_LOADED_PLAYBACK_STATE:String	= 'EVENT_WORKSHOP_LOADED_PLAYBACK_STATE';
		/** event dispatched when the playback state of the app is ready */
		public const EVENT_WORKSHOP_LOADED_DANCES:String	= 'EVENT_WORKSHOP_LOADED_DANCES';
		
		/**
		 * load the big show MID and play back the message
		 * @param	_mid	database ID for this messages information xml
		 */
		public function show_playback_state( _mid:String, _edit_state_starter_callback:Function ):void 
		{	
			Throttler.turned_on = false; // turn off in playback mode;
			/*App.ws_art.panel_buttons.visible = false;
			App.ws_art.vhost_type_selector.visible =  false;
			App.ws_art.background_type_selector.visible =  false;
			App.ws_art.check_morph.visible =  false;
			App.ws_art.vhost_position.visible = false;
			App.ws_art.bg_position.visible = false;*/
			
			/*if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.close_win();
			if (controller_pool.myspace_connect)		
				controller_pool.myspace_connect.close_win();
			if (controller_pool.vhost_selection)		
				controller_pool.vhost_selection.close_win();
			if (controller_pool.vhost_selection_back)	
				controller_pool.vhost_selection_back.close_win();*/
			if (controller_pool.bigShow)
				controller_pool.bigShow.load_and_play_message( ServerInfo.mid, _edit_state_starter_callback );
		}
		/**
		 * usually for closing the bigshow and setting the workshop up for small show
		 */
		public function show_editing_state(  ):void 
		{	
			Throttler.turned_on = true;	// turn on when not in playback mode
			/*App.ws_art.check_morph.visible			= ServerInfo.is3D;
			//App.ws_art.panel_buttons.visible		= true;
			App.ws_art.vhost_type_selector.visible	= true;
			App.ws_art.background_type_selector.visible			= true;*/
			
			if (controller_pool.facebook_connect)
				controller_pool.facebook_connect.open_win();
			if (controller_pool.myspace_connect)		
				controller_pool.myspace_connect.open_win();
			if (controller_pool.message_player)
				controller_pool.message_player.close_win();
			if (controller_pool.body_position)
				controller_pool.body_position.open_win();
			
			// hide the elements that dont apply to full body type workshops
			if (ServerInfo.app_type == ServerInfo.APP_TYPE_Flash_10_FB_3D)
			{
				App.ws_art.background_type_selector.visible			= false;
				App.ws_art.vhost_type_selector.visible	= false;
				App.ws_art.check_morph.visible			= false;
				App.ws_art.check_morph_color.visible	= false;
			}
		}
		public function workshop_finished_loading_playback_state():void
		{
			workshop_finished_loading();
			dispatchEvent(new Event(EVENT_WORKSHOP_LOADED_PLAYBACK_STATE));
		}
		public function workshop_finished_loading_edit_state(  ) : void
		{
			WSEventTracker.event("ev");
			workshop_finished_loading();
			dispatchEvent(new Event(App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE));
		}
		protected var _throttled:Boolean;
		public function checkOptIn(_callback:Function):Boolean
		{
			_callback();
			return true;
			
			if(controller_pool.terms_conditions.optedIn) 
			{
				_callback();
				return true;
			}else
			{
				alert_user( new AlertEvent(AlertEvent.ALERT, "termsAlert", "Please agree to terms and conditions.") );
				//controller_pool.terms_conditions.openWin(_callback);
				return false;
			}
			
			if (!_throttled)	// only if its not loaded already
			{	
				_throttled = true;
				Throttler.autophoto_open_allowed( _callback, no_capacity, no_capacity);
				function no_capacity():void
				{	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, null, "Server capacity surpassed.  Please try again later."));
					_throttled = false;
					
				}
			}
			else
			{
				_callback();
			}
			
			return true;
		
			
			
		}
		/**
		 *either the big show or small show has finished loading at this point 
		 * 
		 */		
		private function workshop_finished_loading():void
		{
			main_loader_close_win()
			dispatchEvent(new Event(EVENT_WORKSHOP_LOADED));
		}
		/**********************************************************
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
		 * ************************************* POPULAR MEDIA */
//		public function popular_media_login():void
//		{
//			if (controller_pool.PUPULAR_MEDIA_LOGIN)
//				controller_pool.PUPULAR_MEDIA_LOGIN.open_win();
//		}
//		public function popular_media_contact_list():void
//		{
//			var recipient_list:Array=[];
//			var iemail:IEmail=controller_pool.pool.get_interface(IEmail);
//			if (iemail)
//				recipient_list=iemail.get_recipient_list();
//			if (controller_pool.PUPULAR_MEDIA_CONTACT_SELECTOR)
//				controller_pool.PUPULAR_MEDIA_CONTACT_SELECTOR.open_win(recipient_list);
//		}
//		public function email_add_recipient(_contact:Popular_Media_Contact_Item):Boolean
//		{
//			var iemail:IEmail=controller_pool.pool.get_interface(IEmail);
//			if (iemail)
//				return iemail.add_recipient(_contact);
//			return false;
//		}
//		public function email_remove_recipient(_contact:Popular_Media_Contact_Item):void
//		{
//			var iemail:IEmail=controller_pool.pool.get_interface(IEmail);
//			if (iemail)
//				iemail.remove_recipient(_contact);
//		}
		/**********************************************************
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
		 * ************************************* PROCESSING */
		private const PROCESS_LOADING_AUDIO		:String = 'PROCESS_LOADING_AUDIO';
		private const MSG_LOADING_AUDIO			:String = 'Loading the audio';
		private const PROCESS_LOADING_MODEL		:String = 'PROCESS_LOADING_MODEL';
		private const MSG_LOADING_MODEL			:String = 'Loading the model';
		private const PROCESS_LOADING_BG		:String = 'PROCESS_LOADING_BG';
		private const MSG_LOADING_BG			:String = 'Loading the background';
		private const PROCESS_LOADING_FULL_BODY	:String = 'PROCESS_LOADING_FULL_BODY';
		private const MSG_LOADING_FULL_BODY		:String = 'Loading the body';
		private var processing_show_authored_creation:Boolean;
		/**
		 * shows the processing window
		 * @param	_process_name		the current process name as there can be others were waiting for (eg: Win_Processing.PROCESS_SAVING_MESSAGE)
		 * @param	_display_process	what process to display to the user
		 * @param	_display_percent	(0-100) what percent to display to the user
		 * @param	_time_to_animate	duration of time to animate the processing to the target value
		 */
		public function processing_start( _process_name:String, _display_process:String = null, _display_percent:int = -1, _time_to_animate:Number = -1, force_no_authored_creation:Boolean =  false):void 
		{	
			if(force_no_authored_creation) processing_show_authored_creation = false;
			if (controller_pool.processing)	
				controller_pool.processing.processing_start( _process_name, _display_process, _display_percent, _time_to_animate, processing_show_authored_creation );
		}
		/**
		 * hides the processing window if all processes in the queue are finished
		 * @param	_process_name the current process name as there can be others were waiting for (eg: Win_Processing.PROCESS_SAVING_MESSAGE)
		 */
		public function processing_ended( _process_name:String ):void 
		{	if (controller_pool.processing)	
				controller_pool.processing.processing_ended( _process_name );
		}
		/************************ FROM EVENT BASED OBJECTS ************************/
		public function onProcessingStarted(evt:ProcessingEvent):void
		{	switch (evt.processName)
			{	case ProcessingEvent.MODEL:		processing_start( PROCESS_LOADING_MODEL, MSG_LOADING_MODEL );			break;
				case ProcessingEvent.AUDIO:		processing_start( PROCESS_LOADING_AUDIO, MSG_LOADING_AUDIO );			break;
				case ProcessingEvent.BG:		processing_start( PROCESS_LOADING_BG, MSG_LOADING_BG );					break;
				case ProcessingEvent.FULL_BODY:	processing_start( PROCESS_LOADING_FULL_BODY, MSG_LOADING_FULL_BODY);	break;
			}
		}
		public function onProcessingEnded(evt:ProcessingEvent):void
		{	switch (evt.processName)
			{	case ProcessingEvent.MODEL:		processing_ended( PROCESS_LOADING_MODEL );			break;
				case ProcessingEvent.AUDIO:		processing_ended( PROCESS_LOADING_AUDIO );			break;
				case ProcessingEvent.BG:		processing_ended( PROCESS_LOADING_BG );				break;
				case ProcessingEvent.FULL_BODY:	processing_ended( PROCESS_LOADING_FULL_BODY );		break;
			}
		}
		public function onProcessingProgress(evt:ProcessingEvent):void
		{	var percent:int = Math.round(evt.percent * 100);
			switch (evt.processName)
			{	case ProcessingEvent.MODEL:		processing_start( PROCESS_LOADING_MODEL, MSG_LOADING_MODEL, percent );				break;
				case ProcessingEvent.BG:		processing_start( PROCESS_LOADING_BG, MSG_LOADING_BG, percent );					break;
				case ProcessingEvent.FULL_BODY:	processing_start( PROCESS_LOADING_FULL_BODY, MSG_LOADING_FULL_BODY, percent );		break;
			}                                   
		}
		public function main_loading_process_status_update( _type:String, _percent:int ):void
		{
			if (controller_pool.main_loader)	
				controller_pool.main_loader.process_status_update( _type, _percent );
		}
		private function main_loader_close_win():void
		{
			if (controller_pool.main_loader)
				controller_pool.main_loader.close_win();
		}
		/**********************************************************
		* 
		* 
		* 
		* 
		*
		* 
		* 
		* 
		* 
		* ************************************* SCENE CONTROLLERS */
		private var editing_scene_controller:ISceneController;
		private var playback_scene_controller:IInternalPlayerAPI;
		public function set scene_editing( _scene:ISceneController ):void
		{
			editing_scene_controller = _scene;
		}
		/**
		 * scene controller responsible for the model and background manipulation for EDITING mode 
		 * @return 
		 * 
		 */		
		public function get scene_editing():ISceneController
		{	
			return editing_scene_controller;
		}
		public function set scene_playback( _scene:IInternalPlayerAPI ):void
		{
			playback_scene_controller = _scene;
		}
		/**
		 * scene controller responsible for the model and background manipulation for PLAYBACK mode 
		 * @return 
		 * 
		 */		
		public function get scene_playback():IInternalPlayerAPI
		{
			return playback_scene_controller;
		}
		/**********************************************************
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
		* ************************************* SHARING */
		private function save_persistent_image_model( _fin:Function = null ):void 
		{	
			if (controller_pool.persistent_image)
				controller_pool.persistent_image.save_new_model( scene_editing.model, _fin );
		}
		public function persistent_image_update_facebook_id( _id:String ):void
		{
			if (controller_pool.persistent_image)
				controller_pool.persistent_image.update_fb_username( _id );
		}
		public function bitly_url_shorten( _url:String, _callbacks:Callback_Struct ):void
		{
			if (controller_pool.bitly_url)
				controller_pool.bitly_url.shorten_url( _url, _callbacks );
		}
		/**
		 * opens the facebook friends search panel
		 * @param	_callback	when a friend is selected this is called passing {Facebook_Friend_Item}
		 */
		public function facebook_search_friends( _callback:Function, fromAutoPhoto:Boolean = false ):void
		{
			if (controller_pool.facebook_friend_search)	
				controller_pool.facebook_friend_search.open_win( _callback, fromAutoPhoto );
		}
		public function auto_photo_back_to_facebook_search_friends(foo:Boolean = false):void
		{
			//holy ghetto.
			App.ws_art.facebook_friend.visible = true;
			App.ws_art.facebook_friend.tileList.clearSelection();
		}
		public function facebook_search_friends_close(  ):void
		{
			if (controller_pool.facebook_friend_search)	
				controller_pool.facebook_friend_search.close_win();
		}
		public function myspace_friends_photos( _callback:Function ):void
		{
			if (controller_pool.myspace_connect)		
				controller_pool.myspace_connect.friends_photos_requested( _callback );
		}
		public function myspace_users_photos( _callback:Function ):void
		{
			if (controller_pool.myspace_connect)		
				controller_pool.myspace_connect.users_photos_requested( _callback );
		}
		/**********************************************************
		* 
		* 
		* 
		* 
		*
		* 
		* 
		* 
		* 
		* ************************************* AUTO PHOTO */
		/** keeps track of which window was used to upload the image so when the user wants to reupload we know what step they used */
		private var autophoto_used_to_upload:*;
		/** ask user for confirmation only if the progressed far enough in the process that they would lose something */
		private var autophoto_require_confirmation_on_close:Boolean = false;
		public function autophoto_is_apc_loaded(  ):Boolean
		{	
			if (controller_pool.auto_photo_apc)		
				return controller_pool.auto_photo_apc.is_loaded();
			return false;
		}
		
		public function autophoto_init_apc( _url:String, _callbacks:Callback_Struct ):void 
		{	if (controller_pool.auto_photo_apc)		
				controller_pool.auto_photo_apc.load_and_init( _url, _callbacks );
		}
		public function autophoto_open_mode_selector( ok:Boolean = false  ) : void
		{
			
			App.ws_art.makeAnother.visible = false;
			//App.ws_art.dancers.visible = true;
			if (controller_pool.auto_photo_mode_selector)
				controller_pool.auto_photo_mode_selector.open_win();

			processing_show_authored_creation = false;
		}
		public function autophoto_mode_browse():void 
		{	
			autophoto_require_confirmation_on_close = false;
			processing_show_authored_creation = false;
			autophoto_close_all_subpanels();
			if (controller_pool.auto_photo_apc)	
			{
				controller_pool.auto_photo_apc.restart_apc( );
			}
				
			if (controller_pool.auto_photo_browse)	
			{	
				WSEventTracker.event("ce1");  
				controller_pool.auto_photo_browse.open_win();
				autophoto_used_to_upload = controller_pool.auto_photo_mode_selector;
			}
		}
		public function autophoto_begin_upload():void
		{
			//controller_pool.auto_photo_apc.beginFileUpload();
		}
		public function autophoto_begin_browse():void
		{
			//controller_pool.auto_photo_apc.fileBrowse();
		}
		public function autophoto_mode_webcam():void 
		{	autophoto_require_confirmation_on_close = false;
			processing_show_authored_creation = false;
			autophoto_close_all_subpanels();
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.restart_apc( );
			if (controller_pool.auto_photo_webcam)
			{	
				controller_pool.auto_photo_webcam.open_win();
				autophoto_used_to_upload = controller_pool.auto_photo_webcam;
			}
		}
		public function autophoto_mode_search(searchType:String = ""):void 
		{	autophoto_require_confirmation_on_close = false;
			processing_show_authored_creation = false;
			autophoto_close_all_subpanels();
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.restart_apc( );
			if (controller_pool.auto_photo_search)
			{	
				
				controller_pool.auto_photo_search.startSearch(searchType);
				controller_pool.auto_photo_search.open_win();
				autophoto_used_to_upload = controller_pool.auto_photo_search;
			}
		}
		public function autophoto_analyze_photo( _url:String ):void
		{	
			autophoto_require_confirmation_on_close = true;
			/*if (controller_pool.auto_photo_apc)		
				controller_pool.auto_photo_apc.analyze_photo( _url );*/
			controller_pool.auto_photo_mode_selector.close_win();
			if(controller_pool.auto_photo_apc)
				controller_pool.auto_photo_apc.beginMasking(_url);
		}
		public function autophoto_get_apc_oriBitmap():Bitmap{	
			if (controller_pool.auto_photo_apc)	
				return controller_pool.auto_photo_apc.oriBitmap;
			return null;
		}
		public function autophoto_begin_process(bmp:Bitmap, fromWebcam:Boolean = false):void
		{
			if(controller_pool.auto_photo_apc)
				controller_pool.auto_photo_apc.imageLoaded(bmp, fromWebcam);
		}
		public function autophoto_mask( bmp:Bitmap ):void
		{
			controller_pool.auto_photo_mask.mask( bmp );
		}
		public function save_masked_photo( bmp:Bitmap, contrast:Number = 0, chinPoint:Point = null):void
		{
			//App.utils.image_uploader.upload_binary(
			//processing_show_authored_creation = true;
			//we don't need to do this, in this instance
			//controller_pool.auto_photo_apc.saveHead( bmp, true, cutPoint );
			
			//controller_pool.dance_scene.swapHead( bmp, controller_pool.auto_photo_apc.headIndex, cutPoint);
			controller_pool.preview.placeHead(bmp, contrast, chinPoint);
			gotoPreview();
		}
		
		public function uploadPhoto(callback:Function):void
		{
			
			var bmp:Bitmap = controller_pool.preview.take_snapshot();			
			var img_data:ByteArray = PNGEncoder.encode( bmp.bitmapData );
			
			var PROCESS_UPLOADING:String = "uploading photo";
			
			function onSaved(e:*):void
			{
				//var struct:HeadStruct = new HeadStruct(bmp, (e.target as HeadSaver).url, null, (e.target as HeadSaver).cutPoint);
				App.asset_bucket.last_mid_saved = null;
				App.ws_art.processing.authored_creation.visible = false;
				App.mediator.processing_ended( PROCESS_UPLOADING);
				callback(e.url);
			}
			
			if (img_data == null)
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t201', 'Error saving image.'));
			else
			{
				App.mediator.processing_start( PROCESS_UPLOADING);
				App.utils.image_uploader.upload_binary( new Callback_Struct( onSaved, function():void{}, function():void{}), img_data, "png");
				App.ws_art.processing.authored_creation.visible = true;
			}
			
		}
		public function hideDancers():void
		{
			App.ws_art.dancers.visible = false;
		}
		public function gotoMakeAnother():void
		{
			if(controller_pool.makeAnother)
			{	
				controller_pool.makeAnother.open_win();
			}
			
		}
		public function gotoPreview():void
		{
			if(controller_pool.preview)
			{	
				controller_pool.preview.open_win();
			}
		}
		public function persistant_swap_head( head:HeadStruct ):void
		{
			/*processing_show_authored_creation = true;
			controller_pool.auto_photo_apc.saveHead(  head.image as Bitmap , false );
			
			controller_pool.dance_scene.swapHead( head.image, controller_pool.auto_photo_apc.headIndex, head.mouth );*/
			//controller_pool.dance_scene.swapHead( head.image, controller_pool.auto_photo_apc.headIndex );
		}
		public function autophoto_update_model_type( _type:int ):void 
		{	
			if (controller_pool.auto_photo_apc)		
				controller_pool.auto_photo_apc.set_model_type( _type );
		}
		public function autophoto_position_photo( fromWebCam:Boolean = false ):void 
		{	
			autophoto_require_confirmation_on_close = false;
			autophoto_close_all_subpanels();
			if (controller_pool.auto_photo_position)	
				controller_pool.auto_photo_position.open_win(fromWebCam);
		}
		public function autophoto_back_to_position( ):void 
		{	
			autophoto_require_confirmation_on_close = false;
			autophoto_close_all_subpanels();
			if (controller_pool.auto_photo_position)	
				controller_pool.auto_photo_position.reopen_win();
		}
		public function autophoto_position_points(  ):void
		{
			autophoto_require_confirmation_on_close = true;
			autophoto_close_all_subpanels();
			if (controller_pool.auto_photo_points)	
				controller_pool.auto_photo_points.open_win();
		}
		public function autophoto_position_mask_points(  ):void
		{
			autophoto_require_confirmation_on_close = false;
			autophoto_close_all_subpanels();
			if (controller_pool.auto_photo_mask)		
				controller_pool.auto_photo_mask.open_win();
		}
		public function autophoto_get_apc_display():DisplayObject
		{	
			if (controller_pool.auto_photo_apc)	
				return controller_pool.auto_photo_apc.get_display_obj();
			return null;
		}
		public function autophoto_set_apc_display_size( _size:Point ):void 
		{	
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.set_display_size( _size );
		}
		public function autophoto_get_apc_display_size(  ):Point 
		{	
			return controller_pool.auto_photo_apc.get_display_size( );
		}
		public function autophoto_move_photo( _dir:String, _amount:int ):void
		{	
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.position_photo( _dir, _amount );
		}
		public function autophoto_zoom_to(value:Number):void
		{
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.zoomTo(value);
		}
		public function autophoto_rotate_to(degrees:Number):void
		{
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.rotateTo(degrees);
		}
		public function autophoto_update_zoomer_bounds():void
		{
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.updateZoomerBounds();
		}
		public function autophoto_back_to_upload(  ):void 
		{	
			autophoto_require_confirmation_on_close = false;
			
			if (controller_pool.auto_photo_apc)
			{
				controller_pool.auto_photo_apc.restart_apc( );
				controller_pool.auto_photo_apc.photo_expiration_stop_timer();
			}
			autophoto_close_all_subpanels();
			if (autophoto_used_to_upload)	autophoto_used_to_upload.open_win();	// open the window that was used to upload the photo, user selected of course
		}
		public function autophoto_submit_photo_position(  ):void 
		{	autophoto_require_confirmation_on_close = false;
			
			 controller_pool.auto_photo_position.close_win();
			 
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.submit_photo_position( );
			
		}
		public function autophoto_submit_points_position(  ):void 
		{	autophoto_require_confirmation_on_close = true;
			
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.submit_photo_points( );
		}
		public function autophoto_submit_mask_position(  ):void 
		{	autophoto_require_confirmation_on_close = false;
			
			if (controller_pool.auto_photo_apc)	
				controller_pool.auto_photo_apc.submit_mask_points( );
		}
		public function autophoto_change_photo(  ):void
		{
			autophoto_back_to_upload();
			return;
			alert_user(new AlertEvent(AlertEvent.CONFIRM, "f9t215", "You will lose your positioning changes for this photo. Do you want to proceed?", null, confirm_change_photo));
			function confirm_change_photo( _ok:Boolean ):void 
			{	if ( _ok )	autophoto_back_to_upload();
			}
		}
		public function autophoto_close( _suppress_confirmation:Boolean = false ):void
		{
			
			if (autophoto_require_confirmation_on_close && !_suppress_confirmation)
			{	
				var alert:AlertEvent = new AlertEvent(AlertEvent.CONFIRM, '', 'Are you sure you want to close autophoto?  You will lose your changes.', null, user_response);
				alert.report_error = false;
				alert_user( alert );
			}
			else
				user_response( true );
			function user_response( _ok:Boolean ):void
			{
				if (_ok)
				{
					processing_show_authored_creation = false;
					autophoto_close_all_subpanels();
					if (controller_pool.auto_photo_mode_selector)
						controller_pool.auto_photo_mode_selector.close_win();
					if (controller_pool.auto_photo_apc)	
						controller_pool.auto_photo_apc.photo_expiration_stop_timer();
				}
			}
		}
		private function autophoto_close_all_subpanels(  ):void 
		{	
			if (controller_pool.auto_photo_browse)
				controller_pool.auto_photo_browse.close_win();
			if (controller_pool.auto_photo_webcam)	
				controller_pool.auto_photo_webcam.close_win();
			if (controller_pool.auto_photo_search)	
				controller_pool.auto_photo_search.close_win();
			if (controller_pool.auto_photo_position)	
				controller_pool.auto_photo_position.close_win();
			if (controller_pool.auto_photo_points)	
				controller_pool.auto_photo_points.close_win();
			if (controller_pool.auto_photo_mask)		
				controller_pool.auto_photo_mask.close_win();
			if (controller_pool.auto_photo_mode_selector)		
				controller_pool.auto_photo_mode_selector.close_win();
		}
		public function autophoto_image_source_type( _type:String ):void
		{
			if (controller_pool.auto_photo)	
				controller_pool.auto_photo.image_source_type( _type );
		}
		public function autophoto_track_image_source_type():void
		{
			if (controller_pool.auto_photo)	
				controller_pool.auto_photo.track_image_source_type();
		}
		public function autophoto_set_persistant_images( heads:Array ):void
		{
			if(controller_pool.auto_photo_apc)
				controller_pool.auto_photo_apc.setInitialPersistantImages( heads );
		}
		/**********************************************************
		* 
		* 
		* 
		* 
		*
		* 
		* 
		* 
		* 
		* ************************************* MODEL LOADING */
		/**
		 * a model has completed loading at this point 
		 * @param evt
		 * 
		 */		
		public function configDone(evt:Event):void
		{
			//this line causes the zooming to be done around the center of the host.  if you want zooming
			//to be done around the center of the mask instead, comment out this line:
			scene_editing.zoomer.anchorTo(scene_editing.getHostMC());
			save_persistent_image_model();
		}
		public function onModelLoadError(evt:SceneEvent):void
		{
			var details:String = evt.data as String;
			alert_user(new AlertEvent(AlertEvent.ERROR, "f9t161", "There was an error loading this model.  Please reload\n\n\n\ndetails:\n"+details,{details:details}));
		}
		/*		*/
		private function load_model( _model:WSModelStruct ):void 
		{
			scene_editing.loadModel( _model );
			// update selected models in the panels
			
			if (controller_pool.vhost_selection)
				controller_pool.vhost_selection.select_vhost( _model );
			if (controller_pool.vhost_selection_back)
				controller_pool.vhost_selection_back.select_vhost( _model );
		}
		
		/*	decide if to morph or just load the one model	*/
		public function model_selected_in_panel( _model:WSModelStruct ):void 
		{
			if (App.ws_art.check_morph.get_is_selected() )	
				morph_models();
			else								
				load_model( _model );
		}
		/**
		 *	morphs 2 vhosts which are selected in the vhost selection panels or passed as arguments 
		 * @param _front_vhost	force this vhost to load
		 * @param _back_vhost	force this vhost to load
		 */		
		public function morph_models( _front_vhost:WSModelStruct = null, _back_vhost:WSModelStruct = null ):void 
		{	
			if (controller_pool.vhost_selection && controller_pool.vhost_selection_back)
			{	
				var target_model	:WSModelStruct	= _front_vhost ? _front_vhost : controller_pool.vhost_selection.get_selected_vhost();
				var back_model		:WSModelStruct	= _back_vhost  ? _back_vhost  : controller_pool.vhost_selection_back.get_selected_model();
				var color_dominance	:Boolean		= App.ws_art.check_morph_color.get_is_selected();
				if (target_model && back_model )
					scene_editing.morph_models( target_model, back_model, color_dominance, MorphPhotoFaceUsersSkintone );
				else	
					fail();
			}
			else	
				fail();
			
			function fail(  ):void 
			{	alert_user( new AlertEvent( AlertEvent.ERROR, '', 'Morphing assets incomplete'));
			}
		}
		/*	if the current loaded hosts are morphed we need to revert back to a normal host	*/
		private function load_non_morph_model(  ):void 
		{	
			if (controller_pool.vhost_selection)
			{	var selected_model_id	:int			= controller_pool.vhost_selection.get_selected_vhost().id;
				var cur_back_model		:WSModelStruct	= App.asset_bucket.model_store.list_vhosts.get_vhost_by_id( selected_model_id );
				if (!cur_back_model)	fail();
				var force_clean_reload	:Boolean		= true;
				scene_editing.loadModel( cur_back_model, force_clean_reload );
			}
			else 
				fail();
			
			function fail(  ):void 
			{	alert_user( new AlertEvent( AlertEvent.ERROR, '', 'Loading Model assets incomplete' ) );
			}
		}
		/**
		 * when a new models is added to the list or when the list has loaded we 
		 * refresh the display list of available models in the selection panels
		 * @param	_e
		 */
		public function models_list_changed( _e:Event ):void 
		{	
			if (controller_pool.vhost_selection)		
				controller_pool.vhost_selection.populate_vhosts();
			if (controller_pool.vhost_selection_back)	
				controller_pool.vhost_selection_back.populate_vhosts();
		}
		
		/**
		 * builds an WSMOdelStruct from basic xml data from autophoto process or persistent image
		 * @param	_basic_model_xml
		 * @param	_created_from_persistent_image
		 * @param	_autophoto_session_id
		 * @return	created WSModelStruct
		 */
		public function build_model_from_xml( 
												_basic_model_xml:XML, 
												_created_from_persistent_image:Boolean = false, 
												_autophoto_session_id:String = '0',
												_model_type:int = 0
											):void
		{
			// model to suck data from 
			var vhost_by_oa1	:WSModelStruct = App.asset_bucket.model_store.list_vhosts.get_vhost_by_oa1_type( _model_type );
			var default_vhost	:WSModelStruct = App.asset_bucket.model_store.list_vhosts.get_default_vhost();
			var target_vhost:WSModelStruct = vhost_by_oa1 ? vhost_by_oa1 : default_vhost;// use a specific oa1 model if not then use any default model 
			
			var vhost:WSModelStruct 				= new WSModelStruct(null);	// new model which target model will dictate
			vhost.charXml 							= _basic_model_xml;
			vhost.autoPhotoSessionId 				= parseInt(_autophoto_session_id, 16);
			vhost.thumbUrl							= _basic_model_xml.url.(@id == "thumb").@url.toString();
			vhost.created_from_persistent_image		= _created_from_persistent_image;
			
			vhost.is3d					= true;
			vhost.url 					= target_vhost.url;
			vhost.id 					= target_vhost.id;
			vhost.engine 				= target_vhost.engine;
			vhost.name 					= "Autophoto Model";
			vhost.isAutoPhoto			= true;
			
			App.asset_bucket.model_store.list_vhosts.add_vhost(vhost);
			load_autophoto_model( vhost );
			
			/**
			 * load the model just built from the autophoto component
			 * @param	_model
			 */
			function load_autophoto_model( _model:WSModelStruct ):void 
			{	
				if (controller_pool.vhost_selection)	
					controller_pool.vhost_selection.select_vhost( _model );
				
				if (App.ws_art.check_morph.get_is_selected() )	
					morph_models();
				else								
					scene_editing.loadModel( _model );
			}
		}
		/**********************************************************
		* 
		* 
		* 
		* 
		*
		* 
		* 
		* 
		* 
		* ************************************* BACKGROUNDS */
		public function bg_uploaded(evt:SceneEvent):void
		{
			WSEventTracker.event("edbgu");
		}
		public function bg_loaded(evt:SceneEvent):void
		{
			var bg_id:String = (scene_editing.bg) ? scene_editing.bg.id.toString() : '0';
			WSEventTracker.event('edbgs', null, 0, bg_id);
			updateMoveZoom();
		}
		public function bg_expired(evt:SceneEvent):void
		{
			updateMoveZoom();
		}
		public function updateMoveZoom():void
		{	if (!App.asset_bucket.bg_controller)	return;
			var bg_controls_enabled:Boolean = (	App.asset_bucket.bg_controller.bg && 
												App.asset_bucket.bg_controller.isUploadPhoto && 
												!App.asset_bucket.is_playback_mode);
			var host_controls_enabled:Boolean = !App.asset_bucket.is_playback_mode &&
												ServerInfo.app_type != ServerInfo.APP_TYPE_Flash_10_FB_3D;
			enableBGMoveZoom(bg_controls_enabled);
			enableHostMoveZoom(host_controls_enabled);
		}
		private function enableBGMoveZoom(b:Boolean):void
		{	
			App.ws_art.bg_position.visible = b
			App.asset_bucket.bg_controller.zoomer.enableDragging(b);
			if (App.asset_bucket.bg_controller.hasDynamicMask) 
				App.asset_bucket.bg_controller.getDynamicMask().visible = b;
		}
		private function enableHostMoveZoom(b:Boolean):void
		{	
			App.ws_art.vhost_position.visible = b
			scene_editing.zoomer.enableDragging(b,false);
		}
		public function checkPhotoExpired():Boolean 
		{	
			
			if (controller_pool.auto_photo_apc.photoHasExpired) 
			{	
				
				alert_user(new AlertEvent(AlertEvent.ERROR, "f9t313", App.localizer.getTranslation(Localizer.ALERT_PHOTO_UPLOAD_EXPIRATION)));
				return(false);
			}
			else	return(true);
		}
		public function backgrounds_open_win(  ):void
		{
			if (controller_pool.bg_selection)	
				controller_pool.bg_selection.open_win();
		}
		/**********************************************************
		* 
		* 
		* 
		* 
		*
		* 
		* 
		* 
		* 
		* ************************************* AUDIO */
		/**
		 * notification from the model engine that audio has been loaded and started playing
		 * @param	_e
		 */
		public function talkStarted(_e:Event):void
		{	
			// if audio is TTS notify throttling that an audio has been loaded
				if (scene_editing.audio is TTSAudioData)
					Throttler.audio_successfully_loaded( scene_editing.audio.url );
		}
		/**
		 * notification from the model engine that audio cannot be loaded or played back
		 * @param	_e
		 */
		public function talkError(_e:Event):void 
		{	
			alert_user(new AlertEvent(AlertEvent.ERROR, "f9t152", "There was an error with your audio"));
		}
		public function track_audio_playback_type(in_audio:AudioData):void 
		{	if (in_audio)	
			{	switch ( in_audio.type )
				{	case AudioData.MIC:			WSEventTracker.event("apmic");	break;
					case AudioData.PHONE:		WSEventTracker.event("apph");	break;
					case AudioData.TTS:			WSEventTracker.event("aptts");	break;
					case AudioData.UPLOADED:	WSEventTracker.event("apup");	break;
					default:					WSEventTracker.event("ap");
				}
			}
		}
		/**
		 * checks if an audio is saved with the current scene and alerts the user if one is NOT present
		 * @return
		 */
		public function checkHasAudio():Boolean 
		{	if (scene_editing.audio == null) 
			{	alert_user(new AlertEvent(AlertEvent.ERROR,"f9t100","You must create an audio message prior to sending or posting your message. Please create audio using one of the available options."));
				return(false);
			}		
			else	return(true);
		}
		/**********************************************************
		* 
		* 
		* 
		* 
		*
		* 
		* 
		* 
		* 
		* ************************************* APS VIDEO EXPORT */
		private const PROCESS_DOWNLOAD_VIDEO	:String = 'PROCESS_DOWNLOAD_VIDEO';
		private const MSG_PROCESS_DOWNLOAD_VIDEO:String = 'Saving video';
		public function download_video_by_mId( _mid:String ):void
		{
			//http://host.oddcast.com/api_misc/1083/checkout.php?mId={mid}&email={email}&optin={optin 0/1}
			return;
			scene_editing.stopAudio();
			add_listeners();
			App.asset_bucket.video_downloader.captureVideo( _mid );
			video_progress( new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.SAVING, 0) ); // start the loader right away... so there are no flashes
			
			function video_saved( _e:SendEvent ):void
			{
				remove_listeners();
				alert_user(new AlertEvent(AlertEvent.CONFIRM, 'f9t150', 'Click OK to download your video...', null, user_response));
				WSEventTracker.event("eddlph");
				
				function user_response( _ok:Boolean ):void
				{
					if (_ok)
					{
						var filename:String = appropriate_filename( App.asset_bucket.video_downloader.capturedSceneUrl );
						App.asset_bucket.video_downloader.downloadFile(App.asset_bucket.video_downloader.capturedSceneUrl, filename);
					}
				}
			}
			function video_progress( _e:ProcessingEvent ):void
			{
				switch( _e.type )
				{
					case ProcessingEvent.STARTED:		processing_start( PROCESS_DOWNLOAD_VIDEO, MSG_PROCESS_DOWNLOAD_VIDEO, 0 );	break;
					case ProcessingEvent.PROGRESS:		processing_start( PROCESS_DOWNLOAD_VIDEO, MSG_PROCESS_DOWNLOAD_VIDEO, _e.percent );	break;
					case ProcessingEvent.DONE:			processing_ended( PROCESS_DOWNLOAD_VIDEO );	break;
				}
			}
			function video_error( _e:AlertEvent ):void
			{
				remove_listeners();
				video_progress( new ProcessingEvent( ProcessingEvent.DONE, ProcessingEvent.SAVING ) );
			}
			function add_listeners():void
			{
				App.listener_manager.add( App.asset_bucket.video_downloader, SendEvent.DONE, video_saved, this );
				App.listener_manager.add( App.asset_bucket.video_downloader, AlertEvent.EVENT, video_error, this );
				App.listener_manager.add( App.asset_bucket.video_downloader, ProcessingEvent.STARTED, video_progress, this );
				App.listener_manager.add( App.asset_bucket.video_downloader, ProcessingEvent.PROGRESS, video_progress, this );
				App.listener_manager.add( App.asset_bucket.video_downloader, ProcessingEvent.DONE, video_progress, this );
			}
			function remove_listeners():void
			{
				App.listener_manager.remove( App.asset_bucket.video_downloader, SendEvent.DONE, video_saved );
				App.listener_manager.remove( App.asset_bucket.video_downloader, AlertEvent.EVENT, video_error );
				App.listener_manager.remove( App.asset_bucket.video_downloader, ProcessingEvent.STARTED, video_progress );
				App.listener_manager.remove( App.asset_bucket.video_downloader, ProcessingEvent.PROGRESS, video_progress );
				App.listener_manager.remove( App.asset_bucket.video_downloader, ProcessingEvent.DONE, video_progress );
			}
		}
		/**********************************************************
		* 
		* 
		* 
		* 
		*
		* 
		* 
		* 
		* 
		* ************************************* SCREENSHOTS */
		public function screenshot_host(_callbacks:Callback_Struct = null, _scale:Number = Number.NaN, _dimensions:Point = null, _offset:Point = null):void
		{
			if (controller_pool.jpg_export)
				controller_pool.jpg_export.screenshot_host(_callbacks,_scale,_dimensions,_offset);
		}
		public function screenshot_target( _target:MovieClip, _callbacks:Callback_Struct = null, _scale:Number = Number.NaN, _dimensions:Point = null, _offset:Point = null ):void
		{
			if (controller_pool.jpg_export)
				controller_pool.jpg_export.screenshot_target(_target,_callbacks,_scale,_dimensions,_offset);
		}
		/**********************************************************
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
		* ************************************ URLS  */
		/**
		 * open a hyperlink URL
		 * @param	_url	url to open
		 * @param	_window	window mode (eg: URL_Opener.BLANK)
		 */
		public function open_hyperlink( _url:String, _window:String = null ):void 
		{	if (_window)	URL_Opener.open_url( _url, _window );
			else			URL_Opener.open_url( _url );
		
			if (App.settings.ALERT_ON_LINK)
			{	
				var alert:AlertEvent = new AlertEvent(AlertEvent.CONFIRM, '', App.localizer.getTranslation(Localizer.ALERT_BLOCKED_LINK)+'\n\n' + _url, null, user_response );
				alert.report_error = false;
				alert_user( alert );
				
				function user_response( _ok:Boolean ):void 
				{	if ( _ok )
					{	try 					{	System.setClipboard( _url );		}
						catch (err:Error)		{	}
					}
				}
			}
		}
		public function open_hyperlink_oddcast( _e:Event = null ):void 
		{	open_hyperlink( 'http://www.oddcast.com' );
		}
		/******************************************
		* 
		* 
		* 
		* 
		* 
		* 
		*/
		public function get persistantImages():Array
		{
			return controller_pool.auto_photo_apc.persistantImages;
		}
		public function get savedHeads():Array
		{
			return controller_pool.auto_photo_apc.savedHeads || [];
		}
		public function get danceIndex():Number
		{
			return controller_pool.dance_scene.danceIndex;
		}
		public function get optInMessage():String
		{
			return controller_pool.facebook_connect.optinData;
			//return controller_pool.terms_conditions.optinData;
		}
		public function facebookLoginFail():void
		{
			if(App.ws_art.facebook_friend.visible || App.ws_art.auto_photo_search.visible) autophoto_open_mode_selector();
			controller_pool.facebook_friend_search.close_win();
			controller_pool.auto_photo_search.close_win();	
		}
		
		public function clearHeads():void
		{
			controller_pool.auto_photo_apc.savedHeads 		= [];
			App.asset_bucket.last_mid_saved 				= null;
			controller_pool.auto_photo_apc.currentHeadIndex = -1;
			
			for(var j:Number = 1; j<6; j++)
			{
				var clip:* = App.ws_art.dancers.getChildByName("face_"+j);
				var hold:MovieClip= (clip.getChildByName("head_hold") as MovieClip);
			
				for(var i:Number = 0; i<hold.numChildren; i++)
				{
					if(hold.getChildAt(i) != null) hold.removeChildAt(i);
				}
			}
			
			/*for(var i:Number = 1; i<6; i++)
			{
				var face:* = App.ws_art.dancers.getChildByName("face_"+i);
				if(face.numChildren>3) face.removeChildAt(face.numChildren-1);
			}*/
		}
	}

}
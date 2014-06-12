package code.controllers.facebook_connect
{
	
	import code.skeleton.App;
	
	import com.adobe.utils.ArrayUtil;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.Event_Expiration;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ExternalInterface_Proxy;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSEventTracker;
	import com.oddcast.workshop.WorkshopMessage;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import workshop.fbconnect.FacebookImage;
	import workshop.fbconnect.FacebookUser;
	import workshop.fbconnect.Facebook_Friend_Item;
	
	
	/**
	 * FaceBook Connect interfaces with javascript for retrieving user information, friends and photos
	 * @author Me^
	 */
	public class Facebook_Connect implements IFacebook_Connect
	{
		
		private const EVENT_GET_PHOTOS_KEY	:String = 'EVENT_GET_PHOTOS_KEY';
		private const PROCESSING_LOADING_FACEBOOK_DATA :String = 'Loading facebook data';
		
		private const POSTING_TO_FACEBOOK	:String = 'POSTING_TO_FACEBOOK';
		private const POSTING_MSG			:String = 'Posting your scene.';
		
		private var ui					:Facebook_Connect_Status_UI;
		
		private var facebookId	:Number = 0;		
		
		public var user		:FacebookUser;
		
		/** current user thumb */
		private var cur_thumb				: Loader;
		/** get user pictures callback */
		private var get_user_pictures_callback:Function;
		/** when the user logs in something might need to be notified so this is how. */
		private var on_logged_in_callback:Function;
		/** keeps track of external calls that timeout */
		private var event_expiration		:Event_Expiration = new Event_Expiration();
		
		/** previous results stored by user id key... so dic[userid] = String of previous javascript query */
		private var cached_results_friends_info:Dictionary = new Dictionary();
		/** previous results stored by user id key... so dic[userid] = String of previous javascript query */
		private var cached_results_users_pictures:Dictionary = new Dictionary();
		/** previous results stored by user id key... so dic[userid] = String of previous javascript query */
		private var cached_results_friends_pictures:Dictionary = new Dictionary();
		/** previous results stored by user id key... so dic[userid] = String of previous javascript query */
		private var cached_results_friends_album_pictures:Dictionary = new Dictionary();
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
		public function Facebook_Connect( _ui:Facebook_Connect_Status_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui = _ui;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				init();// init after inauguration since allow domain is set up there
			}
		}
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	
			App.listener_manager.add( ui.accountInfo.logoutBtn, MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add( ui.loginBtn, MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add_multiple_by_object([App.ws_art.facebook_friend.btn_logout,
														App.ws_art.auto_photo_search.btn_logout], MouseEvent.CLICK, onLogout, this);
			facebookId = 0;
			ui.accountInfo.visible = false;
			
			try 
			{
				ExternalInterface_Proxy.addCallback("fbcSetUserInfo"			, fbcSetUserInfo);
				ExternalInterface_Proxy.addCallback("fbcSetUserPictures"		, fbcSetUserPictures);
				ExternalInterface_Proxy.addCallback("fbcSetConnectState"		, fbcSetConnectState);
				ExternalInterface_Proxy.addCallback("fbcSetProfileAlbumCover"	, fbcSetProfileAlbumCover);
				
				ExternalInterface_Proxy.call("fbcGetConnectState");
				
			}
			catch (e:Error) 
			{
				trace('(Oo) Facebook_Connect CANT SET JAVASCRIPT LISTENERS');
			}
			
			
			ui.accountInfo.tf_userName.text = '';
			ui.accountInfo.tf_location.text = '';
			
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
		/**
		 * displays the UI
		 * @param	_e
		 */
		public function open_win(  ):void 
		{	
			ui.visible = true;
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		public function close_win(  ):void 
		{	
			ui.visible = false;
		}
		public function user_id(  ) : String
		{
			if (user)
				return user.id.toString();
			return '';
		}
		
		public function is_logged_in():Boolean {
			return(facebookId > 0);
		}
		public function checkConnectedState(callback:Function):void
		{
			_onGotConnectedStateCallback = callback;
			//ExternalInterface_Proxy.addCallback("fbcSetConnectState"		, fbcSetConnectState);
			ExternalInterface_Proxy.call("fbcGetConnectState");
			// this will know automaticall that we DO need to login - this is just in case we logged out.
			if(!is_logged_in())
			{
				_onGotConnectedStateCallback();
			}
		}
		public function login( _on_logged_in_callback:Function = null ):void
		{
			on_logged_in_callback = _on_logged_in_callback;
			ExternalInterface_Proxy.call("fbcLogin");
		}
		
		/**
		 * retrieve friends data
		 * @param	_fin			called when process finishes passes {Array}
		 * @param	_include_self	include yourself in the list
		 * @param	_max_return		max number of return values
		 */
		public function fbcGetFriendsInfo( _fin:Function, _include_self:Boolean = true, _max_return:int = -1 ):void 
		{	
			var prev_result:String = cached_results_friends_info[user.id];
			if (prev_result)	// reuse previous result or a new one
				fbcSetFriendsInfo(prev_result);
			else	// get a new result
			{
				ExternalInterface_Proxy.addCallback("fbcSetFriendsInfo"		, fbcSetFriendsInfo);
				App.mediator.processing_start(PROCESSING_LOADING_FACEBOOK_DATA,PROCESSING_LOADING_FACEBOOK_DATA);
				if (_max_return == -1)
					ExternalInterface_Proxy.call('fbcGetFriendsInfo', _include_self);
				else	
					ExternalInterface_Proxy.call('fbcGetFriendsInfo', _include_self, _max_return);
			}
			
			/**
			 * parses the friends photos xml 
			 * @param _friends_xml sample XML
				<xml>
					<response result="OK">
					<0>
						<current_location></current_location>
						<hometown_location></hometown_location>
						<meeting_sex></meeting_sex>
						<name>Yvonne</name>
						<pic_big>http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs864.snc4/70612_8108831_5223878_n.jpg</pic_big>
						<relationship_status></relationship_status>
						<sex></sex>
						<uid>8108831</uid>
						<pic_square>http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs355.snc4/41707_8108831_5831244_q.jpg</pic_square>
					</0>
					...
				</xml>
			*/ 
			function fbcSetFriendsInfo( _friends_xml:String ):void 
			{
				App.mediator.processing_ended(PROCESSING_LOADING_FACEBOOK_DATA);
				
				// store result to not have to requery next time
				cached_results_friends_info[user.id] = _friends_xml;
				
				var friends_list	:Array	= new Array();
				var friends_xml		:XML 	= new XML( _friends_xml );
				var res				:String	= friends_xml.response.@result.toString();
				var num_of_images	:int 	= friends_xml.response.children().length();
				for (var i:int = 0; i < num_of_images; i++)
				{
					var amigo_node	:XML	= friends_xml.response.children()[i];
					var name		:String = amigo_node.name.toString(); 
					var img_full	:String = amigo_node.pic_big.toString();
					var img_thumb	:String = amigo_node.pic_square.toString();
					var uid			:String = amigo_node.uid.toString();
					var first_letter:String	= name.substr(0,1);
					var new_friend	:Facebook_Friend_Item = new Facebook_Friend_Item( first_letter, name, img_full, img_thumb, uid );
					friends_list.push( new_friend ); 
				}
				_fin( friends_list );
			}
		}
		public function getUserPictures(_fin:Function):void
		{	
			get_user_pictures_callback = _fin;
			
			var prev_result:String = cached_results_users_pictures[user.id];
			if (prev_result)
				fbcSetUserPictures( prev_result );
			else 
			{	
				App.mediator.processing_start(PROCESSING_LOADING_FACEBOOK_DATA,PROCESSING_LOADING_FACEBOOK_DATA);
				event_expiration.add_event( EVENT_GET_PHOTOS_KEY, App.settings.EVENT_TIMEOUT_MS, get_friends_timedout );
				
				ExternalInterface_Proxy.call("fbcGetUserPictures");
				
				function get_friends_timedout(  ):void 
				{	
					get_user_pictures_callback = null;	// remove callbacks in case it comes in later on
					_fin(null);	// indicate there was an error
				}
			}
		}
		public function fbcGetFriendsPictures( _fin:Function, _friends_id:String ):void 
		{
			var prev_result:String = cached_results_friends_pictures[_friends_id];
			if (prev_result)	// reuse previous result
				fbcSetFriendsPictures(prev_result)
			else	// get a new result
			{
				App.mediator.processing_start(PROCESSING_LOADING_FACEBOOK_DATA,PROCESSING_LOADING_FACEBOOK_DATA);
				ExternalInterface_Proxy.addCallback("fbcSetFriendsPictures"	, fbcSetFriendsPictures);
				ExternalInterface_Proxy.call('fbcGetFriendsPictures', _friends_id);
			}
			
			function fbcSetFriendsPictures( _pics_xml:String ):void 
			{	
				App.mediator.processing_ended(PROCESSING_LOADING_FACEBOOK_DATA);
				cached_results_friends_pictures[_friends_id] = _pics_xml;
				var arr_photos	:Array 	= build_photos_array(_pics_xml);
				_fin(arr_photos);
			}
		}
		/**
		 * retrieves photos from users albums, there might not be faces present 
		 * @param _fin - passes array when complete
		 * @param _user_id - if null retrieves logged in users photos (self)
		 * @param _max_photos - max num of photos... its been known to fail over 400
		 */	
		public function fbcGetPicturesFromAlbums( _fin:Function, _user_id:String = null, _max_photos:Number=300 ):void
		{
			var user_id:String = _user_id==null ? facebookId.toString() : _user_id;
			
			var prev_result:String = cached_results_friends_album_pictures[user_id];
			if (prev_result)	// reuse previous result
				fbcSetPicturesFromAlbums(prev_result)
			else	// get a new result
			{
				App.mediator.processing_start(PROCESSING_LOADING_FACEBOOK_DATA,PROCESSING_LOADING_FACEBOOK_DATA);
				ExternalInterface_Proxy.addCallback("fbcSetPicturesFromAlbums"	, fbcSetPicturesFromAlbums);
				ExternalInterface_Proxy.call('fbcGetPicturesFromAlbums', user_id, _max_photos);
			}
			
			function fbcSetPicturesFromAlbums(_pics_xml:String):void
			{
				App.mediator.processing_ended(PROCESSING_LOADING_FACEBOOK_DATA);
				cached_results_friends_album_pictures[user_id] = _pics_xml;
				var arr_photos	:Array 	= build_photos_array(_pics_xml);
				_fin(arr_photos);
			}
		}
		/**
		 * retrieves users tagged photos and users album photos (ONLY if tagged photos are less than _max_photos)
		 * there might not be faces present 
		 * @param _fin - passes array when complete
		 * @param _user_id - if null retrieves logged in users photos (self)
		 * @param _max_photos - max num of photos... its been known to fail over 400
		 */	
		public function fbcGetUserPicturesTaggedAndAlbumsCombo( _fin:Function, _user_id:String = null, _max_photos:Number=300 ):void
		{
			var arr_photos:Array;
			var user_id:String = _user_id==null ? facebookId.toString() : _user_id;
			fbcGetFriendsPictures(got_tagged_photos,user_id);
			function got_tagged_photos(_photos:Array):void
			{
				arr_photos=_photos;
				if (arr_photos.length>_max_photos) // we have enough photos
					_fin(arr_photos);
				else // get more photos from users albums
				{
					fbcGetPicturesFromAlbums(got_album_photos,user_id);
					function got_album_photos(_photos:Array):void
					{
						arr_photos=arr_photos.concat(_photos);
						_fin(arr_photos);
					}
				}
			}
		}
		public function post_to_own_wall():void
		{
			
			
			//var scene:SceneStruct = mid_message.sceneArr[i];
			//var image:WSBackgroundStruct = mid_message.sceneArr[i].bg as WSBackgroundStruct;
			
			
			post_new_mid_to_user( user_id() );
		}
		/**
		 * logs a user in, creates a thumb url, creates an mid, posts data
		 * @param	_user_id if null then posts to your own wall
		 * @param	_thumb_url	if null one will be autogenerated or used from settings xml
		 */
		public function post_new_mid_to_user( _user_id:String = null, _thumb_url:String = null ):void
		{
			if (is_logged_in())
				user_is_logged_in();
			else
				login( user_is_logged_in );
			
			function user_is_logged_in():void 
			{
				if (_user_id)	// indicated user id
					create_thumbnail( _user_id );
				else	// post to own wall
					create_thumbnail( user_id() );
			}
			function create_thumbnail( _user_id:String ):void 
			{
				//if (_thumb_url)	// use indicated thumb
				//	thumb_ready(_thumb_url);
				//else if (App.settings.FACEBOOK_POST_GENERATE_IMAGE)	// autogenerate one
				//	App.mediator.screenshot_host( new Callback_Struct(thumb_ready,null,thumb_error) );
				//else	// use the settings indicated one
				
				thumb_ready( App.settings.FACEBOOK_POST_IMAGE_URL );
				/*
				var allNull:Boolean = true;
				for (var i:Number =0; i< App.mediator.savedHeads.length; i++)
				{
					if(App.mediator.savedHeads[i] != null) allNull = false;
					//App.asset_bucket.last_mid_saved = "111";
					
				}
				if(allNull ) 
				{
					post_to_user( _user_id, App.asset_bucket.last_mid_saved, App.settings.FACEBOOK_POST_IMAGE_URL );
				}else
				{
					thumb_ready( App.settings.FACEBOOK_POST_IMAGE_URL );
				}*/
				/**
				 * error generating thumb
				 * @param	_e
				 */
				function thumb_error( _e:AlertEvent ):void 
				{	
					App.mediator.alert_user( _e );
				}
				/**
				 * thumb is ready for posting
				 * @param	_thumb_url
				 */
				function thumb_ready( _thumb_url:String = null ):void 
				{
					App.mediator.processing_start(POSTING_TO_FACEBOOK, POSTING_MSG);

					
					App.utils.mid_saver.save_message( null, new Callback_Struct(fin_message_saved, null, error_message) );
					function fin_message_saved():void
					{
						end_processing();
						App.mediator.alert_user( new AlertEvent(AlertEvent.FACEBOOK_CONFIRM, 'f9t542', 'Press OK to share on Facebook.', false, user_response, false) );
						function user_response( _ok:Boolean ):void
						{
							if (_ok)
								post_to_user( _user_id, App.asset_bucket.last_mid_saved, _thumb_url );
						}
					}
					function error_message( _e:AlertEvent ):void
					{	end_processing();
					}
					function end_processing(  ):void 
					{	App.mediator.processing_ended(POSTING_TO_FACEBOOK);
					}
				}
			}
			
			/**
			 * post data to a user
			 * @param	_user_id	user id to post to
			 * @param	_mid		mid to post
			 * @param	_thumb_url	thumb url of the post
			 */
			function post_to_user( _user_id:String, _mid:String, _thumb_url:String ):void
			{
				// TO DO - get uploaded image url from workshop message... either do that here or pass in the url 
				var message:WorkshopMessage = App.asset_bucket.mid_message;
				
				//http://content.oddcast.com/ccs6/customhost/1221/m/bg/bb/81/140237946992682.png
				var url:String = (_mid != "" && _mid != null) ? ServerInfo.pickup_url + '?mId=' + _mid : ServerInfo.pickup_url;
				var defaultURL:String = _mid != "" ? ServerInfo.default_url + 'swf/player_embed.swf?mId=' + _mid + '&stem=' + ServerInfo.stem_gwi : ServerInfo.default_url + 'swf/player_embed.swf?stem=' + ServerInfo.stem_gwi;
				// javascript function fbcPublishStream2(nFriendId, strTitle, strMessageContent, strName, strCaption, strDescription, strVideSource, strImageSource, strHref, strImgW, strImgH, strVidW, strVidH)
				defaultURL 					= defaultURL.split("http:").join("https:");
				var strMessage		:String = App.settings.FACEBOOK_POST_MESSAGE;
				var strName			:String = App.settings.FACEBOOK_POST_NAME;
				var strCaption		:String = App.settings.FACEBOOK_POST_CAPTION;
				var strDescription	:String = App.settings.FACEBOOK_POST_DESCRIPTION.split("{pickUpLink}").join(ServerInfo.pickup_url);
				var strDisplay		:String = App.settings.FACEBOOK_POST_DISPLAY;
				
				defaultURL = App.asset_bucket.lastPhotoSavedURL;
				
				ExternalInterface_Proxy.call
					(
						'fbcPublishFeedStory',
/*strToId*/ 			_user_id, 
/*strMessage*/ 			App.settings.FACEBOOK_POST_MESSAGE, 
/*strLink*/ 			url, 
/*strPicture*/ 			defaultURL, 
/*strSwfSource*/ 		defaultURL, 
/*strName*/ 			App.settings.FACEBOOK_POST_NAME,
/*strCaption*/ 			App.settings.FACEBOOK_POST_CAPTION,
/*strDescription*/ 		App.settings.FACEBOOK_POST_DESCRIPTION,
/*strDisplay*/ 			App.settings.FACEBOOK_POST_DISPLAY
					);
				
				
				
				
				
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
		 ***************************** INTERNALS */
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case ui.accountInfo.logoutBtn:
					onLogout(null);
					break;
				case ui.loginBtn:
					onLogin(null);
					break;
			}
		}
		
		
		
		
		
		
		
		/**
		 * called when the user has logged in from the popup window
		 * @param	n
		 */
		private var _onGotConnectedStateCallback:Function;
		private function fbcSetConnectState(n:Number):void {
			if (n < 0) 
				n = 0;
			if (n == facebookId) 
			{
				if(n == 0) App.mediator.facebookLoginFail();
				if(_onGotConnectedStateCallback != null) _onGotConnectedStateCallback();
				_onGotConnectedStateCallback = null;
				return;
			}
			facebookId = n;
			
			ui.loginBtn.visible = (!is_logged_in());
			ui.accountInfo.visible = is_logged_in();
			
			App.ws_art.facebook_friend.btn_logout.visible = App.ws_art.auto_photo_search.btn_logout.visible = is_logged_in();
			if (is_logged_in()) 
			{
				getUserInfo();
				WSEventTracker.event("edfbc");
			}
			else 
			{
				user = null;
				App.mediator.facebookLoginFail();
				
			}			
			if(_onGotConnectedStateCallback != null) _onGotConnectedStateCallback();
			// TODO - maybe handle not loggin in here?
			
			_onGotConnectedStateCallback = null;
		}
		private var _userProfilePicId:String;
		private function fbcSetProfileAlbumCover(_xml:*):void
		{
			var xml		:XML 	= new XML( _xml );
			var picXML:XML  = xml.response.children()[0];
			_userProfilePicId = picXML.child("pid").toString();
		}
		private function onLogin(evt:MouseEvent):void 
		{
			WSEventTracker.event('uifbc');
			login();
		}
		
		private function onLogout(evt:MouseEvent):void 
		{
			logout();
		}
		
		
		public function logout():void 
		{
			ExternalInterface_Proxy.call("fbcLogout");
			remove_prev_thumb();
		}
		
		private function setLoggedIn(b:Boolean):void 
		{
			ui.loginBtn.visible = !b;
			ui.accountInfo.visible = b;
			App.ws_art.facebook_friend.btn_logout.visible = App.ws_art.auto_photo_search.btn_logout.visible = b;
			if (!b)
			{
				ui.tf_location.text='';
				ui.tf_userName.text='';
				App.ws_art.facebook_friend.btn_logout.setName(""); 
				App.ws_art.auto_photo_search.btn_logout.setName("");
			}
		}
		
		private function getUserInfo():void 
		{
			ExternalInterface_Proxy.call("fbcGetUserInfo");
		}
		
		private function fbcSetUserInfo(inputXML:String):void
		{
			var _xml:XML = new XML(inputXML);
			var res:String = _xml.response.@result.toString();
			if (res == "OK") 
			{
				parseUserInfo(_xml);
				ui.accountInfo.tf_userName.text = user.name.toUpperCase();
				ui.accountInfo.tf_location.text = user.getLocation().toUpperCase();
				App.ws_art.facebook_friend.btn_logout.setName(user.name); 
				App.ws_art.auto_photo_search.btn_logout.setName(user.name);
				
				ExternalInterface_Proxy.call("fbcGetProfileAlbumCover");
				load_user_thumb(user.thumbUrl);
				update_persistent_image_username( user.id.toString() );
			}
			else if (res == "ERROR") 
			{
			}
			
			// notify caller that were logged in
			if (on_logged_in_callback != null)
			{
				on_logged_in_callback();
				on_logged_in_callback = null;
			}
		}
		
		
		private function load_user_thumb( _thumb_url:String ) : void
		{
			remove_prev_thumb();
			Gateway.retrieve_Loader( new Gateway_Request( _thumb_url, new Callback_Struct(fin, null, error), 0, null, null, true ) );
			function fin( _ldr:Loader ) : void
			{
				ui.accountInfo.thumb.addChild(_ldr);
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
		 * indicates to the engine that the username has been updated
		 * @param	_fb_user_id facebook user id
		 */
		private function update_persistent_image_username( _fb_user_id:String ):void 
		{
			App.mediator.persistent_image_update_facebook_id( _fb_user_id );
		}
		
		private function parseUserInfo(_xml:XML):void 
		{
			var userXML:XML = _xml.response.children()[0];
			user = new FacebookUser(userXML);
			/*user.id = parseFloat(userXML.uid.toString());
			user.name = userXML.name.toString();
			user.thumbUrl = userXML.pic_square.toString();
			user.city = userXML.current_location.city.toString();
			user.state = userXML.current_location.state.toString();
			user.country = userXML.current_location.country.toString();
			user.zip = userXML.current_location.zip.toString();*/
		}
		
		
		private function fbcSetUserPictures(inputXML:String):void 
		{
			App.mediator.processing_ended(PROCESSING_LOADING_FACEBOOK_DATA);
			cached_results_users_pictures[user.id] = inputXML;// store result for reusability
			
			event_expiration.remove_event( EVENT_GET_PHOTOS_KEY );
			
			var _xml:XML = new XML(inputXML);
			var res:String = _xml.response.@result.toString();
			if (res == "OK") 
			{
				var photoArr:Array = build_photos_array(inputXML);
				if (get_user_pictures_callback != null)		// possibly removed because it timed out
				{	
					if (photoArr.length == 0)	
						get_user_pictures_callback(null)		// no photos
					else						
						get_user_pictures_callback(photoArr);	// everything is ok
				}
			}
			else if (res == "ERROR")
			{
				if (get_user_pictures_callback != null)	
					get_user_pictures_callback(null);		// possibly removed because it timed out
			}
		}
		
		/**
		 * builds an array of FacebookImage 
		 * @param _raw_xml XML photo node
			<1>
				<pid>23687925792340515</pid>
				<aid>23687925755872275</aid>
				<owner>5515275</owner>
				<src>http://photos-f.ak.fbcdn.net/hphotos-ak-snc1/hs026.snc1/2357_625662839546_5515275_38894115_6564_s.jpg</src>       <!-- aprox 130x97 -->
				<src_big>http://sphotos.ak.fbcdn.net/hphotos-ak-snc1/hs026.snc1/2357_625662839546_5515275_38894115_6564_n.jpg</src_big>    <!-- aprox 600x450 -->
				<src_small>http://photos-f.ak.fbcdn.net/hphotos-ak-snc1/hs026.snc1/2357_625662839546_5515275_38894115_6564_t.jpg</src_small>    <!-- aprox 75x56 -->
				<link>http://www.facebook.com/photo.php?pid=38894115&amp;id=5515275</link>
				<caption/>
				<created>1235426176</created>
				<modified>1252470728</modified>
				<object_id>625662839546</object_id>
				<src_small_height>56</src_small_height>
				<src_small_width>75</src_small_width>
				<src_big_height>450</src_big_height>
				<src_big_width>600</src_big_width>
				<src_height>97</src_height>
				<src_width>130</src_width>
			</1>
		 * 
		 * @return
		 */		
		private function build_photos_array(_raw_xml:String):Array
		{
			var xml			:XML = new XML(_raw_xml);
			var photoXML	:XML;
			var photo		:FacebookImage;
			var arr_photos	:Array = new Array();
			var num_of_images:int = xml.response.children().length();
			var profileImage:FacebookImage;
			for (var i:int = 0; i < num_of_images; i++)
			{
				photoXML			= xml.response.children()[i];
				
				photo				= new FacebookImage();
				photo.id			= parseInt(photoXML.pid.toString());
				
				photo.albumId		= parseInt(photoXML.aid.toString());
				photo.userId		= parseInt(photoXML.owner.toString());
				photo.name			= photoXML.caption.toString();
				photo.url			= photoXML.src_big.toString();
				photo.thumbUrl		= photoXML.src.toString();//photoXML.square.toString();photoXML.src_small.toString(); // too small
				photo.linkUrl		= photoXML.link.toString();
				photo.creationTime	= parseInt(photoXML.created.toString());
				photo.modifyTime	= parseInt(photoXML.modified.toString());
				if(photoXML.pid.toString() == _userProfilePicId) 
				{
					profileImage = photo;
				}
				else{
					arr_photos.push(photo);
				}
			}
			if(profileImage) arr_photos.unshift(profileImage);
			return arr_photos;
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
		public function get optinData():String
		{
			var result		:String  = "";
			if( user == null ) return "";
			var data:Object = {	email		: user.email, 
				name		: user.name, 
				dob			: user.birthday_date,
				location	: user.getLocation(),
				gender		: user.sex
			}

			
			for( var key:* in data)	
			{
				if(data[key] != "") result += key+": "+data[key]+", ";
			}
			
			// trim last comma and space
			result = result.substr(0, result.length-2);
			return result;
			
		}
				
	}
	
}
package code.controllers.renren_connect
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
	public class RenRen_Connect 
	{
		
		private const EVENT_GET_PHOTOS_KEY	:String = 'EVENT_GET_PHOTOS_KEY';
		private const PROCESSING_LOADING_GOOGLEPLUS_DATA :String = 'Loading GooglePlus data'
		
		private var ui					:Facebook_Connect_Status_UI;
		
		private var id					:Number = 0;//isaac
		
		
		/** current user thumb */
		private var cur_thumb				: Loader;
		/** get user pictures callback */
		private var get_user_pictures_callback:Function;
		/** when the user logs in something might need to be notified so this is how. */
		private var on_logged_in_callback:Function;
		/** keeps track of external calls that timeout */
		private var event_expiration		:Event_Expiration = new Event_Expiration();
		
		/** previous results stored by user id key... so dic[userid] = String of previous javascript query */
		private var cached_results_friends_info:Dictionary 			= new Dictionary();
		/** previous results stored by user id key... so dic[userid] = String of previous javascript query */
		private var cached_results_users_pictures:Dictionary 		= new Dictionary();
		/** previous results stored by user id key... so dic[userid] = String of previous javascript query */
		private var cached_results_friends_pictures:Dictionary 		= new Dictionary();
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
		public function RenRen_Connect(  ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
		
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
			try 
			{				
				//for Google Plus 
				ExternalInterface_Proxy.addCallback("rSetConnectState",	rSetConnectState);
				ExternalInterface_Proxy.addCallback("rSetProfileInfo",	rSetProfileInfo);
				ExternalInterface_Proxy.addCallback("rSetPictures",	rSetUserPictures);
				//ExternalInterface_Proxy.call("rSetConnectState");
			}
			catch (e:Error) 
			{
				trace('(Oo) RenRen_Connect CANT SET JAVASCRIPT LISTENERS');
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
		
		
		//*********************************************************************
		
		
		private var _onLoginCallback:Function;
		
		public function is_logged_in():Boolean { 			
			return(id > 0);
		}
		
		public function rSetConnectState(n:Number):void { 
			trace("RenRen_Connect::rSetConnectState - renren - n='"+n+"'");
			if (n < 0) 				n = 0;		
			id = n;	
			trace("RenRen_Connect::rSetConnectState - renren id = '"+id+"'");
			
			if ( is_logged_in() ) {
				if(_onLoginCallback != null) 
				{
					_onLoginCallback();
					return;
				}
				
				WSEventTracker.event("edfbc");
			}else{								
				App.mediator.googlePlusLoginFail();					
			}
			
		}
		public function rSetProfileInfo(xml:*):void{
			trace("RENRENCONNECT::rSetProfileInfo: "+xml);
			
		}
		public function login(cb:Function):void
		{
			trace("RENREN_LOGIN");
			_onLoginCallback = cb;
			ExternalInterface_Proxy.call("rLogin");
		}
		
		public function logout():void
		{
			id = -1;
			ExternalInterface_Proxy.call("rLogout");
		}
		
		
		public function rGetPictures( _fin:Function, _friends_id:String=null ):void {///Isaac
			trace("RenRen_Connect::gpcGetPictures - googlePlus - ");
			
			get_user_pictures_callback = _fin;
			event_expiration.add_event( EVENT_GET_PHOTOS_KEY, App.settings.EVENT_TIMEOUT_MS+30000, get_friends_timedout );
			
			function get_friends_timedout(  ):void 
			{	
				get_user_pictures_callback = null;	// remove callbacks in case it comes in later on
				_fin(null);	// indicate there was an error
			}
			
			if(is_logged_in()) onLoggedIn();
			else login(onLoggedIn);
			
			function onLoggedIn(e:* = null):void
			{
				trace("RENREN GETTING PICTURES");
				ExternalInterface_Proxy.call("rGetPictures");
			}
			//ExternalInterface_Proxy.call("gpLogin");//isaac
			
		}
		
		public function rSetUserPictures(inputXML:String):void { ///Isaac
			trace("RenRen_Connect::gpSetUserPictures - googlePlus - inputXML='" + inputXML + "'");
			
			App.mediator.processing_ended(PROCESSING_LOADING_GOOGLEPLUS_DATA);
			event_expiration.remove_event( EVENT_GET_PHOTOS_KEY );
			
			var _xml:XML = new XML(inputXML);
			var res:String = _xml.response.@result.toString();
			
			if (res == "OK") {
				trace("RenRen_Connect::gpSetUserPictures - googlePlus - res="+res);
				var photoArr:Array = build_photos_array(inputXML);
				
				if (get_user_pictures_callback != null){	// possibly removed because it timed out
					trace("RenRen_Connect::gpSetUserPictures - googlePlus - photoArr.length="+photoArr.length);
					
					if (photoArr.length == 0) {
						trace("RenRen_Connect::gpSetUserPictures - googlePlus - no photos");
						get_user_pictures_callback(null)		// no photos
					}else{
						get_user_pictures_callback(photoArr);	// everything is ok
					}
				}
			}else if (res == "ERROR") {
				trace("RenRen_Connect::gpSetUserPictures - googlePlus - res="+res);
				if (get_user_pictures_callback != null)		get_user_pictures_callback(null);		// possibly removed because it timed out
			}
		}
		
		
		private static const POSTING_TO_RENREN:String = "POSTING TO RENREN";
		private static const POSTING_MSG:String = "now posting to renren";
		public function post_profile_image( ):void
		{
			if (is_logged_in())
				user_is_logged_in();
			else
				login( user_is_logged_in );
			
			function user_is_logged_in():void 
			{
				if(App.asset_bucket.last_mid_saved) {
					post();
					return;
				}
				App.mediator.processing_start(POSTING_TO_RENREN, POSTING_MSG);
				
				App.utils.mid_saver.save_message( null, new Callback_Struct(fin_message_saved, null, error_message) );
				
				function fin_message_saved():void
				{
					end_processing();
					
					App.mediator.alert_user( new AlertEvent(AlertEvent.RENREN_CONFIRM, 'f9t542', 'Press OK to share on RenRen.', false, user_response, false) );
					function user_response( _ok:Boolean ):void
					{
						if (_ok)
							post();
					}
				}
				function error_message( _e:AlertEvent ):void
				{	end_processing();
				}
				function end_processing(  ):void 
				{	App.mediator.processing_ended(POSTING_TO_RENREN);
				}
			}
			
			
			/**
			 * post data to a user
			 * @param	_user_id	user id to post to
			 * @param	_mid		mid to post
			 * @param	_thumb_url	thumb url of the post
			 */
			function post( ):void
			{
				trace("rPostPicture: "+App.asset_bucket.lastPhotoSavedURL);
				ExternalInterface_Proxy.call('rPostPicture',  App.asset_bucket.lastPhotoSavedURL, App.settings.FACEBOOK_POST_MESSAGE);
			}
		}
		
		
		
		
		public function update_status( ):void
		{
			trace("UPDATING RENREN STATUS:");
			if (is_logged_in())
				user_is_logged_in();
			else
				login( user_is_logged_in );
			
			function user_is_logged_in():void 
			{
				if(App.asset_bucket.last_mid_saved) {
					post();
					return;
				}
				App.mediator.processing_start(POSTING_TO_RENREN, POSTING_MSG);
				
				App.utils.mid_saver.save_message( null, new Callback_Struct(fin_message_saved, null, error_message) );
				
				function fin_message_saved():void
				{
					end_processing();
					
					App.mediator.alert_user( new AlertEvent(AlertEvent.GOOGLE_CONFIRM, 'f9t542', App.localizer.getTranslation('renren_share_pop_up_title'), false, user_response, false) );
					function user_response( _ok:Boolean ):void
					{
						if (_ok)
							post();
					}
				}
				function error_message( _e:AlertEvent ):void
				{	end_processing();
				}
				function end_processing(  ):void 
				{	App.mediator.processing_ended(POSTING_TO_RENREN);
				}
			}
			
			
			/**
			 * post data to a user
			 * @param	_user_id	user id to post to
			 * @param	_mid		mid to post
			 * @param	_thumb_url	thumb url of the post
			 */
			function post( ):void
			{	
				trace("RENREN POST LINK");
				var asset:* = App.asset_bucket;
				var mid:String = App.asset_bucket.last_mid_saved;
				var message_id		:String =  App.asset_bucket.last_mid_saved ? '&mId=' + App.asset_bucket.last_mid_saved + '.3' : "";
				var embed_url 		:String = ServerInfo.pickup_url + message_id;
				//rPostPicture(this._renrenPost.picture, postDescriptionLink, _callback);
				ExternalInterface_Proxy.call('rPostPicture', App.asset_bucket.lastPhotoSavedURL, App.settings.FACEBOOK_POST_MESSAGE);//encodeURIComponent(App.settings.FACEBOOK_POST_MESSAGE+' '+embed_url));
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
				var images:XML = photoXML.images[0];
				var largeImage:* = images.child('0');
				var headImage:* = images.child('2');
				photo.url			= largeImage.url.toString();
				photo.thumbUrl		= headImage.url.toString();//photoXML.src_small.toString(); // too small
				photo.linkUrl		= photoXML.link.toString();
				photo.creationTime	= parseInt(photoXML.created.toString());
				photo.modifyTime	= parseInt(photoXML.modified.toString());
				
				arr_photos.push(photo);
				
			}
			
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
		
		
		
	}
	
}
package code 
{
	import code.controllers.CopyURL;
	import code.controllers.Embed;
	import code.controllers.MakeAnother;
	import code.controllers.accessories.Accessories;
	import code.controllers.alert.Alert;
	import code.controllers.audio_to_phone.Audio_To_Phone;
	import code.controllers.audio_volume.Audio_Volume;
	import code.controllers.auto_photo.apc.Auto_Photo_APC;
	import code.controllers.auto_photo.auto_photo.Auto_Photo;
	import code.controllers.auto_photo.browse.Auto_Photo_Browse;
	import code.controllers.auto_photo.mask.Auto_Photo_Mask;
	import code.controllers.auto_photo.mode_selector.Auto_Photo_Mode_Selector;
	import code.controllers.auto_photo.points.Auto_Photo_Points;
	import code.controllers.auto_photo.position.Auto_Photo_Position;
	import code.controllers.auto_photo.search.Auto_Photo_Search;
	import code.controllers.auto_photo.webcam.Auto_Photo_Webcam;
	import code.controllers.backgrounds.BG_Selector;
	import code.controllers.bg_browse.BG_Browse;
	import code.controllers.bg_multiple_upload.BG_Multiple_Upload;
	import code.controllers.bg_type_selector.BG_Type_Selector;
	import code.controllers.bitly_url.Bitly_Url;
	import code.controllers.body_position.Body_Position;
	import code.controllers.canned_audio.Canned_Audios;
	import code.controllers.color.Color;
	import code.controllers.coming_soon.ComingSoon;
	import code.controllers.download.Download;
	import code.controllers.email.Email;
	import code.controllers.expiration.Expiration;
	import code.controllers.facebook_connect.Facebook_Connect;
	import code.controllers.facebook_friend.Facebook_Friend_Post;
	import code.controllers.facebook_friend.Facebook_Friend_Search;
	import code.controllers.facial_expressions.Facial_Expressions;
	import code.controllers.gallery_post.Gallery_Post;
	import code.controllers.gif_export.GIF_Export;
	import code.controllers.gigya.Gigya;
	import code.controllers.jpg_export.JPG_Export;
	import code.controllers.main_loader.Main_Loader;
	import code.controllers.message_player.Message_Player;
	import code.controllers.microphone.Microphone;
	import code.controllers.mogreet.MoGreet;
	import code.controllers.myspace_connect.MySpace_Connect;
	import code.controllers.paypal.Paypal;
	import code.controllers.persistent_image.Persistent_Image;
	import code.controllers.phone.Phone;
	import code.controllers.player.Player;
	import code.controllers.player_holder.Player_Holder;
	import code.controllers.privacy_policy.Privacy_Policy;
	import code.controllers.processing.Processing;
	import code.controllers.preview.Preview;
	import code.controllers.share_delicious.Share_Delicious;
	import code.controllers.share_digg.Share_Digg;
	import code.controllers.share_misc.Share_Misc;
	import code.controllers.share_twitter.Share_Twitter;
	import code.controllers.terms_conditions.Terms_Conditions;
	import code.controllers.tts.TTS;
	import code.controllers.vhost_back_selection.VHost_Selection_Back;
	import code.controllers.vhost_proportions.VHost_Proportions;
	import code.controllers.vhost_selection.VHost_Selection;
	import code.controllers.vhost_type_selection.VHost_Type_Selection;
	import code.controllers.youtube.Youtube;
	import code.skeleton.App;
	import code.skeleton.inauguration.Inauguration;
	import code.utils.MID_Save;
	
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.VisiblePlugin;
	import com.oddcast.utils.TextFieldScrollKeyFix;
	import com.oddcast.workshop.Body_Controller;
	import com.oddcast.workshop.SceneController2D;
	import com.oddcast.workshop.SceneController3D;
	import com.oddcast.workshop.WSEventTracker;
	
	import custom.DanceScene;
	import custom.PhotoMaskingScreen;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLVariables;

	
	// Documentation found at http://livedocs.adobe.com/flex/3/html/help.html?content=app_container_2.html
	[SWF(
		width="1300",					// Stage width
		height="569",					// Stage height
//		usePreloader="true"				// Specifies whether to disable the application preloader (false) or not (true). The default value is true. To use the default preloader, your application must be at least 160 pixels wide.
//		preloader="path"				// Specifies the path of a SWC component class or ActionScript component class that defines a custom progress bar.
//		widthPercent="#",				// 
//		heightPercent="#",				// 
//		scriptRecursionLimit="#",		// Specifies the maximum depth of the Flash Player or AIR call stack before Flash Player or AIR stops. This is essentially the stack overflow limit.  The default value is 1000.
//		scriptTimeLimit="#",			// Specifies the maximum duration, in seconds, that an ActionScript event listener can execute before Flash Player or AIR assumes that it has stopped processing and aborts it.  The default value is 60 seconds, which is also the maximum allowable value that you can set.
		backgroundColor="#000000",		// background color of the 
		frameRate="24"					// Specifies the frame rate of the application, in frames per second. The default value is 24.
	)]
	
	/**
	 * Sofer Document class
	 * 
	 * 
	 * responsible for 
	 * 1. creates art elements from swc
	 * 2. loading assets
	 * 3. instantiating View Controllers that are specified
	 * 4. links controllers with views
	 * 
	 * @author Me^
	 */
	public class editor_art extends Sprite
	{	
		/** reference to the art holder from the library swc containing all the panels */
		private var art			: WS_Art;
		
		/**
		 * Constructor
		 * set a reference in the Bridge for the editor art to be able to communicate with this class
		 * trace the build date of this app 
		 * 
		 */		
		public function editor_art() 
		{	
			if (stage)	stage_ready_handler();
			else 		App.listener_manager.add(this,Event.ADDED_TO_STAGE, stage_ready_handler, this );
		}
		
		private function stage_ready_handler( _e:Event=null ) : void
		{
			App.listener_manager.remove(this,Event.ADDED_TO_STAGE, stage_ready_handler);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align =StageAlign.LEFT;
			stage.addEventListener(Event.RESIZE, _onResize);
			// trace timestamp even if traces are turned off
			var force_trace:Function = trace;  force_trace('\n\t********** sofer version: ' + App.settings.BUILD_TIMESTAMP + ' **********\n\n');
			
			// yellow focus rectangle
			if (stage) 
				stage.stageFocusRect = false;
			
			// remove a bug where the cursor jumps twice in firefox with wmode!=window
			if (stage)
				TextFieldScrollKeyFix.init( stage );
			
			initiate_art();
			_onResize();
			instantiate_controllers();
			constructors_ready();
		}
		
		/**
		 * adds to stage the art for the controllers 
		 * 
		 */		
		private function initiate_art(  ) : void
		{
			art = new WS_Art();
			App.ws_art = art;
			addChild(art);
			TweenPlugin.activate([VisiblePlugin]);
		}
		/**
		 * called from workshop ART when the cunstructors for all UIs have been called and are ready to be driven
		 */ 
		public function constructors_ready(  ):void 
		{	
			// SLIM JIM THE SHIM... IF YOU DONT NEED SceneController2D replace it with null for example
			// this class is responsible for loading all the assets shared by the big and small show
			// and assets needed initially
			new Inauguration( 	
								this.stage,
								loaderInfo, 
								inauguration_fin, 
								SceneController2D,	// 2d type workshop
								SceneController3D,	// 3d || FB type workshop
								null//Body_Controller 	// Full Body type workshop, also requires 3D controller (PUBLISH FOR FLASH 10)
							);
			
			/**
			 * Initialize the rest of the controllers which will rely on the data loaded by Inauguration
			 * NOTE: big show or small show is loading at this point
			 */
			function inauguration_fin(  ):void
			{
				art.danceBtn3.visible = App.settings.USE_THIRD_DANCE;
				art.shadow_3.visible = App.settings.USE_THIRD_DANCE;
			}
		}
		
		
		
		
	
		
		
		/**
		 * instantiates UI controllers
		 * @NOTE : if a controller is to be removed simply comment it out and it will not be compiled into the swf  
		 * 
		 */		
		private function instantiate_controllers():void
		{
			// main controllers
			new Main_Loader				( art.main_loader );
			new Alert					( art.alert );
		//	new Message_Player			( art.message_player, art.player_holder.player );
			new MySpace_Connect			( art.myspace_connect_status );
			new Facebook_Connect		( art.facebook_connect_status );
			
			var dummy:InteractiveObject = new Sprite();
			// sharing
			//new Share_Digg				( art.panel_buttons.diggBtn );
			//new Share_Delicious			( art.panel_buttons.deliciousBtn );
			new Share_Misc				(dummy, art.mainPlayer.get_url_btn, dummy, dummy);
			
			
			
			new Email					( art.email_btn, art.email, art.emailSuccess );
			//new Gallery_Post			( art.panel_buttons.postBtn, art.gallery_post );
			new Facebook_Friend_Search	( art.facebook_btn, art.facebook_friend );
			new Facebook_Friend_Post	( art.facebook_btn, art.post_to_facebook );
			//new GIF_Export				( art.panel_buttons.btn_animated_gif, art);
			//new JPG_Export				( art.panel_buttons.saveJpegBtn, art, art);//.player_holder.player.hostMask );
			//new Audio_To_Phone			( art.panel_buttons.audioToPhoneBtn, art.audio_to_phone );
			/*new Gigya					( art.panel_buttons.btn_gigya, art.gigya );
			new Bitly_Url				( art.panel_buttons.btn_bitly );
			new Youtube					( art.panel_buttons.btn_youtube, art.youtube );
			new Paypal					( art.panel_buttons.btn_paypal, art.paypal );
			new MoGreet					( art.panel_buttons.btn_mogreet, art.mogreet );*/
			new Share_Twitter			( art.twitter_btn );
			
			// background
			/*new BG_Browse				( art.panel_buttons.btn_browse_popup, art.browse_image ); 
			new BG_Selector				( art.panel_buttons.bgBtn, art.background_selector );
			new BG_Multiple_Upload		( art.panel_buttons.btn_upload_bg_multiple );
			new BG_Type_Selector		( art.background_type_selector );*/
			
			new Processing				( art.processing );
			new Terms_Conditions		( art.terms_conditions );
			//new Privacy_Policy			( art.panel_buttons.btn_privacy );
			new Expiration				( art.expired );
			art.addChildAt(new DanceScene(), art.getChildIndex(art.main_bg)+1);
			new MakeAnother(dummy, art.makeAnother);
			new Embed(art.mainPlayer.embed_btn, art.embed);
			new ComingSoon(art.comingSoon);
			
			new Preview					(art.preview);
/*			
			
			// misc
			new Player					( art.player_holder.player );
			new Player_Holder			( art.player_holder, art.player_holder.player, art.btn_play, art.btn_stop );
			new VHost_Type_Selection	( art.vhost_type_selector );
			new VHost_Selection			( art.panel_buttons.btn_default_models, art.vhost_front_selector );
			new VHost_Selection_Back	( art.vhost_back_selector );
			
			// face
			new Persistent_Image		( art.panel_buttons.btn_persistent, art.persistent_image );
			new Accessories				( art.panel_buttons.accBtn, art.vhost_accessories );
			new Color					( art.panel_buttons.colorBtn, art.vhost_color );
			new Facial_Expressions		( art.panel_buttons.expressionBtn, art.vhost_expressions );
			new VHost_Proportions		( art.panel_buttons.sizingBtn, art.vhost_proportions );
			
			// audio
			new TTS						( art.panel_buttons.ttsBtn, art.tts );
			new Microphone				( art.panel_buttons.micBtn, art.microphone );
			new Canned_Audios			( art.panel_buttons.prerecBtn, art.canned_audio );
			new Phone					( art.panel_buttons.c2cBtn, art.panel_buttons.phoneBtn, art.phone );
			new Audio_Volume			( art.audio_volume );
*/			
			// Auto Photo
			// Auto Photo
			new Auto_Photo_APC			( this.loaderInfo.applicationDomain );	
			new Auto_Photo				( dummy );		
			new Auto_Photo_Mode_Selector( art.auto_photo_mode_selector );
			new Auto_Photo_Browse		( art.auto_photo_browse );
			new Auto_Photo_Position		( art.auto_photo_position );
			//			new Auto_Photo_Points		( art.auto_photo_points );
			//new Auto_Photo_Mask			( art.auto_photo_mask );
			new Auto_Photo_Webcam		( art.auto_photo_webcam );
			new PhotoMaskingScreen();
			new Auto_Photo_Search		( art.auto_photo_search );
			new Download 				(art.mainPlayer.btn_storedownload, art.download);
			//new CopyURL					(art.mainPlayer.get_url_btn, art.copyURL);
			
			
			// popular media contact import
//			new Popular_Media_Login();
//			new Popular_Media_Contact_Selector();
			
			// full body panels -- ALL SWFS NEED TO BE PUBLISHED AS FLASH 10 FOR THESE TO WORK
//			new Body_Position();
//			new Body_Presets();
//			new Body_Material_Conf();
//			new Body_Decals();
//			new Body_Commands();
//			new Body_Color();
//			new Body_Anim();
			/*_firstBtns 			= [art.facebook_btn, 
									art.email_btn, 
									art.link_btn,
									art.twitter_btn,
									art.dance_Btn, 
									art.danceBtn1, 
									art.danceBtn2, 
									art.danceBtn3, 
									art.upload_btns.upload_btn1,
									art.upload_btns.upload_btn2,
									art.upload_btns.upload_btn3,
									art.upload_btns.upload_btn4,
									art.upload_btns.upload_btn5
									]
									
			App.listener_manager.add_multiple_by_object(_firstBtns, MouseEvent.CLICK, _firstClick, this);
			
			var bigFirstBtns:Array = [art.mainPlayer.btn_create_your_own,
										art.mainPlayer.btn_replay,
										art.mainPlayer.facebook_btn,
										art.mainPlayer.link_btn,
										art.mainPlayer.twitter_btn,
										art.mainPlayer.email_btn];
			
			App.listener_manager.add_multiple_by_object(bigFirstBtns, MouseEvent.CLICK, _bigFirstClick, this);*/
			
			if(App.asset_bucket.is_playback_mode) art.stage.addEventListener(MouseEvent.CLICK, _bigFirstClick);
			else art.stage.addEventListener(MouseEvent.CLICK, _firstClick);
			
		}
		private var _firstBtns:Array = [];
		protected var _firstClicked:Boolean = false; 
		private function _firstClick(e:MouseEvent):void
		{
			if(!_firstClicked) 
			{
				if(App.asset_bucket.is_playback_mode) WSEventTracker.event("gce1");
//				else WSEventTracker.event("ce1");
			}
			_firstClicked = true;
		}
		protected var _bigFirstClicked:Boolean = false;
		private function _bigFirstClick(e:MouseEvent):void
		{
			if(!_bigFirstClicked) WSEventTracker.event("gce1");
			_bigFirstClicked = true;
		}
		private function _onResize(e:Event=null):void
		{
			art.x = Math.round(stage.stageWidth/2)- 500;
			//art.main_bg.x = stage.stageWidth - art.main_bg.x;
		}
	}
	
}
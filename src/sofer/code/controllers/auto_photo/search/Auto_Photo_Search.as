package code.controllers.auto_photo.search 
{
	import code.component.skinners.Custom_Scrollbar_Skinner;
	import code.component.skinners.Custom_TileList_Skinner;
	import code.controllers.*;
	import code.controllers.auto_photo.Auto_Photo_Constants;
	import code.controllers.facebook_friend.Facebook_Friends_TileList_CellRenderer;
	import code.controllers.myspace_connect.*;
	import code.models.*;
	import code.skeleton.*;
	import code.utils.*;
	
	import com.oddcast.assets.structures.*;
	import com.oddcast.event.*;
	import com.oddcast.ui.ComponentStyle;
	import com.oddcast.ui.Selector;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.*;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.sampler.NewObjectSample;
	
	import org.casalib.display.CasaSprite;
	import org.casalib.util.RatioUtil;
	
	import workshop.fbconnect.*;

	/**
	 * ...
	 * @author Me^
	 */
	public class Auto_Photo_Search implements IAuto_Photo_Search
	{
		private var ui					:Search_UI;
		private var image_searcher		:ImageSearcher;
		private var num_of_images		:int;
		private const search_only_faces	:Boolean = false;
		private const TF_MAX_CHARS		:int = 50;
		public static const PROCESS_UPLOADING	:String = 'PROCESS_UPLOADING uploading autophoto image';
		public static const PROCESS_SEARCHING	:String = 'PROCESS_SEARCHING';
		
		public static const GOOGLE_PLUS:String = "GooglePlus";
		public static const FACEBOOK:String = "Facebook";
		public static const REN_REN:String = "RenRen";
		public static const WEIBO:String = "Weibo";
		
		public function Auto_Photo_Search( _ui:Search_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui		= _ui;
			
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
			//AAEEFF
			App.listener_manager.add_multiple_by_object( [	ui.btn_next,
															ui.btn_flickr,
															ui.btn_google,
															ui.btn_myspace_friends,
															ui.btn_myspace_user,
															ui.btn_new_search,
															ui.btn_photobucket,
															ui.btn_photobucket_user,
															ui.btn_facebook_friends,
															ui.btn_facebook_user,
															ui.btn_facebook_user_album,
															ui.btn_facebook_tagged_albums,
															//ui.btn_close,
															ui.btn_back] , MouseEvent.CLICK, click_event_handler, this);
			
			ui.tf_search.maxChars = TF_MAX_CHARS;
			ui.tf_search.restrict = "A-Za-z0-9 \-!@#$&'\", . / ?";
			
			ui.selector_image.addScrollBtn(ui.btn_left, -5);
			ui.selector_image.addScrollBtn(ui.btn_right, 5);
			
			image_searcher = new ImageSearcher(25);
			App.listener_manager.add( image_searcher, Event.COMPLETE, populate_image_selector, this);
			App.listener_manager.add( image_searcher, AlertEvent.ERROR, image_search_error_handler, this);
			//ui.selector_image.addEventListener(SelectorEvent.SELECTED,_onItemSelected,false,0,true);
			//new Custom_Scrollbar_Skinner( ui.tileList );
			//new Custom_TileList_Skinner( ui.tileList, Facebook_Friends_TileList_CellRenderer );
			//App.listener_manager.add(ui.tileList, Event.CHANGE, friend_selected, this);
			ui.selector_image.addEventListener(SelectorEvent.SELECTED,_onItemSelected,false,0,true);

			ui.user_image_placehold.visible = false;
			//ui.tileList.width=531;
		}
		protected function _onItemSelected(e:SelectorEvent):void
		{
			select_image();
		}
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERFACE */
		public function open_win( ):void
		{
			
			ui.visible = true;
			
			//ui.tileList.selectedItem = null;
			App.localizer.localize(ui, "fb_upload");
		}
		protected var _currentSearchType:String;
		public function startSearch(searchType:String = ""):void
		{
			// fix for back button on search because this doesn't actually show first
			ui.visible = false;
			toggle_search( false );
			reset();
			set_focus();
			//App.mediator.facebook_search_friends( facebook_friend_selected, true );	
			if(searchType == GOOGLE_PLUS)
			{
				retrieve_googlePlus_images();
				_currentSearchType = GOOGLE_PLUS;
			}else if(searchType == FACEBOOK)
			{
				retrieve_facebook_user_tagged_and_albums();//isaac
				_currentSearchType = FACEBOOK;
			}
			else if(searchType == REN_REN)
			{
				retrieve_renren_images();
				_currentSearchType = REN_REN;
			}
			else if(searchType == WEIBO)
			{
				retrieve_weibo_images();
				_currentSearchType = WEIBO;
			}
			App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SOCIAL_MEDIA );
		}
		public function close_win(  ):void
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
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERNALS */
		private function image_search_error_handler( _e:AlertEvent ):void 
		{
			App.mediator.processing_ended( PROCESS_SEARCHING );
			App.mediator.alert_user( _e );
		}
		public function reset():void
		{
			App.listener_manager.remove(ui.selector_image, ScrollEvent.SCROLL, retrieve_next_page );
			ui.selector_image.clear();
			//ui.tileList.removeAll();
		}
		private function click_event_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case ui.btn_next:					select_image();	
												break;
				case ui.btn_new_search:				toggle_search( false );
													reset();
												break;
				case ui.btn_facebook_friends:		App.mediator.facebook_search_friends( facebook_friend_selected );	
													App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SOCIAL_MEDIA );
												break;
				case ui.btn_facebook_user_album:	retrieve_facebook_user_albums();	
													App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SOCIAL_MEDIA );
												break;
				case ui.btn_facebook_tagged_albums:	retrieve_facebook_user_tagged_and_albums();	
													App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SOCIAL_MEDIA );
												break;
				case ui.btn_facebook_user:			retrieve_facebook_user_own_images();	 
													App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SOCIAL_MEDIA );
												break;
				case ui.btn_myspace_friends:		App.mediator.myspace_friends_photos( myspace_photos_retrieved );	
													App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SOCIAL_MEDIA );
												break;
				case ui.btn_myspace_user:			App.mediator.myspace_users_photos( myspace_photos_retrieved );	
													App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SOCIAL_MEDIA );
												break;
				case ui.btn_photobucket:			if (search_is_valid( false ))
													{
														start_search_processing();
														image_searcher.searchPhotobucket(ui.tf_search.text);
														App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_PHOTOBUCKET );
													}
												break;
				case ui.btn_photobucket_user:		if (search_is_valid( true ))
													{
														image_searcher.getPhotobucketUserImages(ui.tf_search.text);	
														App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_PHOTOBUCKET );
													}
												break;
				case ui.btn_flickr:					if (search_is_valid( false ))	
													{
														image_searcher.searchFlickr(ui.tf_search.text);	
														App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SEARCH );
													}
												break;
				case ui.btn_google:					if (search_is_valid( false ))
													{
														image_searcher.searchGoogle(ui.tf_search.text, 'large', search_only_faces?'face':'');	
														App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SEARCH );
													}
												break;
				case ui.btn_back:				close_win();
												App.mediator.autophoto_open_mode_selector();
												//App.mediator.auto_photo_back_to_facebook_search_friends();
												break;
												
				case ui.btn_close:
					close_win();
					App.mediator.autophoto_open_mode_selector();
					//App.mediator.autophoto_close(true);
					break;
			}
			
			function search_is_valid( _user_search:Boolean ):Boolean
			{
				if (ui.tf_search.text.length == 0)
				{	
					if (_user_search)	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t217', 'The username text box is blank.  Please enter a user name.'));
					else				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t216', 'The search keyword text box is blank.  Please enter a search term.'));
					return false;
				}
				return true;
			}
			
		}
		private function start_search_processing(  ):void
		{
			App.mediator.processing_start( PROCESS_SEARCHING );
		}
		private function myspace_photos_retrieved( _photos:Array ):void
		{
			ui.selector_image.clear();
			if (!_photos || _photos.length == 0)
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t212', 'Your friend does not allow applications to access their photos, please try another friend.'));
			else
			{
				for (var n:int = _photos.length, i:int = 0; i < n; i++)
				{
					var ms_image		:Image_Item			= _photos[i];
					var selector_image	:WSBackgroundStruct = new WSBackgroundStruct( ms_image.image_url, parseInt(ms_image.id), ms_image.thumb_url );
					ui.selector_image.add(i, selector_image.name, selector_image);
				}
				//ui.selector_image.update();
				toggle_search( true );
			}
		}
		protected var _userThumb:CasaSprite;
		
		private function facebook_friend_selected( _friend:Facebook_Friend_Item ):void
		{
			
			App.mediator.facebook_search_friends_close();
			ui.visible = true;
			//ui.selector_image.clear();
			
			if(_userThumb) _userThumb.destroy();
			/*if(_friend.user_id == App.mediator.facebook_connect_user_id()) 
			{
				retrieve_facebook_user_own_images();
				
			}else
			{*/
				App.mediator.facebook_connect_get_users_tagged_and_albums( got_friends_pics, _friend.user_id );
			//}
			
			_userThumb = new CasaSprite();
			
			var request:Gateway_Request = new Gateway_Request( _friend.img_large_url, new Callback_Struct(fin) );
			Gateway.retrieve_Loader( request );

			ui.user_name.text = _friend.name;
			function fin(ldr:Loader):void
			{
				_userThumb.addChild(ldr);
				var scaler:Rectangle = RatioUtil.scaleToFit( new Rectangle(0,0,ldr.width, ldr.height), new Rectangle(0,0, ui.user_image_placehold.width,  ui.user_image_placehold.height));
				_userThumb.x = ui.user_image_placehold.x;
				_userThumb.y = ui.user_image_placehold.y;
				ldr.width = scaler.width;
				ldr.height = scaler.height;
				_userThumb.graphics.beginFill(0,1);
				_userThumb.graphics.drawRect(-4,-4,scaler.width+8, scaler.height+8);
				_userThumb.graphics.endFill();
				ui.addChild(_userThumb);
			}
			
			
			function got_friends_pics( _list:Array ):void 
			{	
				if (_list && _list.length > 0)
					image_searcher.set_photo_list( _list );
					
				else
					App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t212', 'Your friend does not allow applications to access their photos, please try another friend.', null, closeAndGoBack));
			}
			function closeAndGoBack():void
			{
				App.mediator.autophoto_open_mode_selector();
				close_win();
			}
		}
		private function retrieve_facebook_user_own_images(  ):void
		{
			if (App.mediator.facebook_connect_is_logged_in())
				user_logged_in_get_own_photos();
			else	
				App.mediator.facebook_connect_login(user_logged_in_get_own_photos);
				
				function user_logged_in_get_own_photos(  ):void 
				{	
					start_search_processing();
					image_searcher.getFacebookUserImages();
				}
		}
		private function retrieve_facebook_user_albums():void
		{
			if (App.mediator.facebook_connect_is_logged_in())
				user_logged_in();
			else	
				App.mediator.facebook_connect_login(user_logged_in);
			
			function user_logged_in(  ):void 
			{	
				start_search_processing();
				image_searcher.getFacebookUserAlbums();
			}
			
		}
		private function retrieve_facebook_user_tagged_and_albums():void
		{
			if (App.mediator.facebook_connect_is_logged_in())
				user_logged_in();
			else	
				App.mediator.facebook_connect_login(user_logged_in);
			
			function user_logged_in(  ):void 
			{	
				start_search_processing();
				image_searcher.getFacebookUserTaggedAndAlbums();
			}
		}
		
		private function retrieve_googlePlus_images(  ):void
		{
			start_search_processing();
			image_searcher.getGooglePlusImages();
		}
		
		private function retrieve_renren_images(  ):void
		{
			start_search_processing();
			image_searcher.getRenRenImages();
		}
		
		private function retrieve_weibo_images(  ):void
		{
			start_search_processing();
			image_searcher.getWeiboImages();
		}
		private function friend_selected( _e:Event ):void
		{
			select_image();
			var selected_item:Object = ui.tileList.selectedItem;
			if (selected_item)
			{
			
			
			}
		}
		
//		private function select_image(  ):void
//		{
//			var selected_item:Object = ui.selector_image.selectedItem;
//			if (selected_item)
//			{
//				var image:WSBackgroundStruct = selected_item.data as WSBackgroundStruct;
//				App.mediator.processing_start( PROCESS_UPLOADING );
//				close_win();
//				App.utils.image_uploader.upload_url( new Callback_Struct( fin, progress, error ), image.url, true);
//				function fin(_bg:BackgroundStruct):void 
//				{	
//					App.mediator.processing_ended( PROCESS_UPLOADING );
//					App.mediator.autophoto_analyze_photo( _bg.url );
//				}
//				function progress(_percent:int):void 
//				{	
//					App.mediator.processing_start( PROCESS_UPLOADING, null, _percent );
//				}
//				function error(_e:AlertEvent):void 
//				{	
//					App.mediator.processing_ended( PROCESS_UPLOADING );
//					App.mediator.alert_user(_e);
//				}
//			}
//			else
//			{
//				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t210', 'Please select an image'));
//			}
//		}
		private function select_image(  ):void
		{
			if (!ui.selector_image.isSelected())
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t210', 'Please select an image'));
			else
			{
				if(_currentSearchType == FACEBOOK){
					ExternalInterface_Proxy.call('fbTrackGMApp', 'upload-photo');
				}
				var image:WSBackgroundStruct = ui.selector_image.getSelectedItem().data as WSBackgroundStruct;
				App.mediator.processing_start( PROCESS_UPLOADING );
				
				App.utils.image_uploader.upload_url( new Callback_Struct( fin, progress, error ), image.url, true);
				function fin(_bg:BackgroundStruct):void 
				{	
					App.mediator.processing_ended( PROCESS_UPLOADING );
					App.mediator.autophoto_analyze_photo( _bg.url );
				}
				function progress(_percent:int):void 
				{	
					App.mediator.processing_start( PROCESS_UPLOADING, null, _percent );
				}
				function error(_e:AlertEvent):void 
				{	
					App.mediator.processing_ended( PROCESS_UPLOADING );
					App.mediator.alert_user(_e);
				}
			}
		}
		private function populate_image_selector( _e:Event ):void
		{
			App.mediator.processing_ended( PROCESS_SEARCHING );
			if (image_searcher.isFirstCall) 
			{
				if (image_searcher.imageArr.length == 0) 
				{
					App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t212', 'No image results'));
					toggle_search( false );
					return;
				}
				else 
				{
					num_of_images = 0;
					ui.selector_image.clear();
				}
			}
			
			for (var n:int = image_searcher.imageArr.length, i:int = 0; i < n; i++)
			{
				var image:WSBackgroundStruct = image_searcher.imageArr[i];
				num_of_images++;
				ui.selector_image.add(num_of_images, image.name, image, false);
			}
			ui.selector_image.update();			
			
			App.listener_manager.add(ui.selector_image, ScrollEvent.SCROLL, retrieve_next_page, this );
			toggle_search( true );
		}
		
		private function populate_image_selector_rob( _e:Event ):void
		{
			App.mediator.processing_ended( PROCESS_SEARCHING );
			//ui.tileList.setStyle(ComponentStyle.TILE_LIST.CELL_RENDERER, AutoPhoto_Search_CellRenderer_UI);
			//new Custom_TileList_Skinner( ui.tileList, AutoPhoto_Search_CellRenderer_UI );
			//new Custom_Scrollbar_Skinner( ui.tileList );
			ui.tileList.removeAll();
		//	ui.tileList.setSize(435, 128);
		//	ui.tileList.verticalScrollBar.x = 430;
			/*var list:Array = new Array();
			for (var i:int = 0; i < friends_list.length; i++) 
			{	var cur_friend	:Facebook_Friend_Item 	= friends_list[i];
				if ( selected_list.indexOf(cur_friend.filter_str.toLowerCase()) >= 0 )
					list.push(cur_friend);
			}
			populate_tileList( list );*/
			
			if (image_searcher.isFirstCall) 
			{
				if (image_searcher.imageArr.length == 0) 
				{
					App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t212', 'Your friend does not allow applications to access their photos. Please try another friend.'));
					toggle_search( false );
					return;
				}
				else 
				{
					num_of_images = 0;
					
				}
			}
			var user:FacebookUser = App.mediator.facebook_connect_user();
			
			
			for (var n:int = image_searcher.imageArr.length, i:int = 0; i < n; i++)
			{
				var image:WSBackgroundStruct = image_searcher.imageArr[i];
				num_of_images++;
				if(image && image.url) 
					ui.tileList.addItem( {thumb:image.url, label:"", data:image} );
				//ui.selector_image.add(num_of_images, image.name, image, false);
			}
			//ui.selector_image.update();			
			
			//App.listener_manager.add(ui.selector_image, ScrollEvent.SCROLL, retrieve_next_page, this );
			//toggle_search( true );
		}
		
		/**
		 * check to see if you reach the end of the selector.  If so, load more images.
		 * @param	evt
		 */
		private function retrieve_next_page(_e:ScrollEvent):void
		{
			if (_e.step == ui.selector_image.maxScroll) 
			{
				App.listener_manager.remove(ui.selector_image, ScrollEvent.SCROLL, retrieve_next_page );
				var next_page_available:Boolean = image_searcher.getNextPage();
				if (next_page_available) 
					start_search_processing();
			}
		}
		private function toggle_search( _active:Boolean = false ):void
		{
			
			 
			ui.btn_new_search.visible	=_active;
		}
		private function set_focus():void
		{	
			if (ui.stage)	ui.stage.focus = ui.tf_search;
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
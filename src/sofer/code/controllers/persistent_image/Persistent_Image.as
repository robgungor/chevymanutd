package code.controllers.persistent_image 
{
	import code.controllers.auto_photo.Auto_Photo_Constants;
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.data.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.Persistent_Image.IPersistent_Image;
	import com.oddcast.workshop.Persistent_Image.IPersistent_Image_Item;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	
	import workshop.persistent_image.Persistent_Image_Selector_Item;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Persistent_Image implements code.controllers.persistent_image.IPersistent_Image
	{
		private var btn_open_pi				:InteractiveObject;
		private var ui						:Persistent_Image_UI;
		
		private var pi_api					:com.oddcast.workshop.Persistent_Image.IPersistent_Image;
		private var loader					:Loader;
		private var engine_loaded_callback	:Function;
		private var refresh_needed			:Boolean			= true;
		private var facebook_RAW_user_id	:String 			= '';
		private var engine_busy_refreshing	:Boolean			= false;
		
		private const PROCESSING_LOADING_DATA:String = 'loading persistent image data...';
		
		public function Persistent_Image( _btn_open:InteractiveObject, _ui:Persistent_Image_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui				= _ui;
			btn_open_pi		= _btn_open;
			
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
			// this feature may be turned off by admin
				if (ServerInfo.persistent_image_access_type == ServerInfo.PERSISTANT_IMAGE_OFF)
				{
					btn_open_pi.mouseEnabled = false;
				}
			// listeners
				App.listener_manager.add( btn_open_pi, MouseEvent.CLICK, open_win, this );
				App.listener_manager.add( ui.btn_close, MouseEvent.CLICK, close_win, this );
			init_selector();
			init_shortcuts();
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
		public function save_new_model( _model:WSModelStruct, _complete_callback:Function = null ):void 
		{
			if (ServerInfo.persistent_image_access_type == ServerInfo.PERSISTANT_IMAGE_READ_WRITE)
			{
				var has_head_data		:Boolean			= _model.engine && _model.charXml;
				var is_auto_photo		:Boolean			= _model.isAutoPhoto;
				var not_from_PI			:Boolean			= !(_model.created_from_persistent_image);
				var not_already_saved	:Boolean			= !(_model.saved_to_persistent_image);
				if ( has_head_data && is_auto_photo && not_from_PI && not_already_saved )
				{
					var autophoto_xml:XML = new XML(_model.charXml);
					save_new_fgdata( autophoto_xml, save_fin );
				}
				
				function save_fin():void 
				{	_model.saved_to_persistent_image = true;
					if (_complete_callback != null)
						_complete_callback();
				}
			}
			else if (_complete_callback!=null) 
				_complete_callback();
		}
		public function update_fb_username( _fb_userid:String ):void 
		{
			facebook_RAW_user_id = _fb_userid;
			if (pi_api != null)	// if engine was previously loaded then we need to notify it
				pi_api.user_logged_into_facebook( facebook_RAW_user_id, name_update_fin );
			
			function name_update_fin(  ):void 
			{	}
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
		private function close_win( _e:MouseEvent = null ):void 
		{
			ui.visible = false;
		}
		private function open_win( _e:MouseEvent ):void 
		{
			if (
					ServerInfo.persistent_image_access_type != 0 &&	// 0 means off
					ServerInfo.persistent_image_engine_url && 
					ServerInfo.persistent_image_engine_url.length > 1 &&
					(
						ServerInfo.app_type == ServerInfo.APP_TYPE_Flash_9_2D ||
						(
							(
								ServerInfo.app_type == ServerInfo.APP_TYPE_Flash_9_3D ||
								ServerInfo.app_type == ServerInfo.APP_TYPE_Flash_10_FB_3D
							) &&
							App.mediator.scene_editing.model &&
							App.mediator.scene_editing.model.has_head_data()
						)
					)
				)
			{	
				ui.visible = true;
				initialize_engine( engine_intialized );
				
				function engine_intialized():void
				{	if (refresh_needed)	// only if told so by engine or first load	
						refresh_images();	
				}
				
				set_focus();
			}
			else	
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t536', 'Persistent Image is not available, or this model does not support it'));
		}
		private function init_selector(  ):void 
		{
			ui.image_selector.addScrollBtn( ui.btn_scroll_prev, -2 );
			ui.image_selector.addScrollBtn( ui.btn_scroll_next, 2 );
			ui.image_selector.addItemEventListener( Persistent_Image_Selector_Item.DELETE_IMAGE_EVENT, delete_image );
			ui.image_selector.addItemEventListener( Persistent_Image_Selector_Item.SELECT_EVENT, image_selected );
		}
		private function delete_image( _e:SelectorEvent ):void 
		{
			var thumb_data:ThumbSelectorData = _e.currentTarget.data;
			var cur_photo:IPersistent_Image_Item = thumb_data.obj as IPersistent_Image_Item;
			var cur_id:String = cur_photo.id();
			initialize_engine( engine_ready_for_deletion );
			
			function engine_ready_for_deletion():void
			{	pi_api.remove_image( cur_id, image_removed );	} 
			function image_removed():void
			{}
		}
		private function image_selected( _e:SelectorEvent ):void 
		{
			var wrapper_obj		:ThumbSelectorData		= _e.currentTarget.data as ThumbSelectorData;
			var selected_image	:IPersistent_Image_Item	= wrapper_obj.obj as IPersistent_Image_Item; 
			
			if (selected_image && selected_image.prepared_xml())
			{
				
				if ( ServerInfo.app_type == ServerInfo.APP_TYPE_Flash_9_2D )
				{
					var image_url:String = selected_image.prepared_xml().url.(@id == 'photoface').@url;
					App.mediator.scene_editing.loadBG( new WSBackgroundStruct(image_url) );
				}
				if (
						ServerInfo.is3D &&
						App.mediator.scene_editing.model &&
						App.mediator.scene_editing.model.has_head_data()
					)
					{
						App.mediator.build_model_from_xml( selected_image.prepared_xml(), true );
						App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_PERSISTENT );
						App.mediator.autophoto_track_image_source_type();
					}
			}
			pi_api.image_selected( selected_image.id(), image_selected_fin );
			close_win();

			function image_selected_fin():void {}
		}
		
		private function refresh_of_images_needed(  ):void 
		{
			if ( ui.visible )	refresh_images();		// refresh only if the window is open... avoid needlessly calling server
			else				refresh_needed = true;
		}
		private function populate_selector(  ):void 
		{
			ui.image_selector.clear();
			var num_of_images:int = pi_api.get_num_of_images();
			for (var i:int = 0; i < num_of_images; i++) 
			{
				var cur_image:IPersistent_Image_Item = pi_api.get_image( i );
				var id:int = parseInt( cur_image.id() );
				var image:ThumbSelectorData = new ThumbSelectorData( cur_image.thumb_url(), cur_image );
				var nume:String = '';
				ui.image_selector.add( i, nume, image, false );
			}
			ui.image_selector.update();
		}
		
		
		
		
		/*
		 * 
		 * 
		 * 
		 * 
		 * ***************************** ENGINE COMMUNICATION
		 */
		
		/**
		 * loads and prepares the API
		 */
		private function initialize_engine( _engine_loaded_callback:Function = null ):void 
		{
			if (pi_api != null)
			{
				if (_engine_loaded_callback != null)
					_engine_loaded_callback();
				return;	// avoiding multiple loads 
			}
			
			App.mediator.processing_start(PROCESSING_LOADING_DATA,PROCESSING_LOADING_DATA);
			engine_loaded_callback = _engine_loaded_callback;
			loader = new Loader();
			App.listener_manager.add( loader.contentLoaderInfo, Event.COMPLETE, engine_loaded, this );
			var engine_url				:String = ServerInfo.contentURL + ServerInfo.persistent_image_engine_url;// NOTE: engine MUST be loaded from the same domain as the workshop (shell) for interfaces to be used
			// if loading it from a different domain
/*				var loader_context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
				loader.load( new URLRequest( engine_url ),loader_context);*/
			// loading the engine from the same domain
				loader.load( new URLRequest( engine_url ) );
		}
		private function engine_loaded( _e:Event ):void 
		{
			App.mediator.processing_ended(PROCESSING_LOADING_DATA);
			//loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, engine_loaded);
			App.listener_manager.remove_all_listeners_on_object( loader.contentLoaderInfo );
			pi_api = loader.content as com.oddcast.workshop.Persistent_Image.IPersistent_Image;
			var fg_params			:String = ServerInfo.persistent_image_gf_params;// '4-30-53';
			var server_stem			:String = ServerInfo.localURL;// 'http://host.staging.oddcast.com/';
			pi_api.initialize( fg_params, server_stem, facebook_RAW_user_id, engine_initialized, refresh_of_images_needed );
			
			function engine_initialized(  ):void 
			{
				refresh_of_images_needed();
				if (engine_loaded_callback != null )
				{
					engine_loaded_callback();
					engine_loaded_callback = null;
				}
			}
		}
		private function refresh_images(  ):void
		{	if (!engine_busy_refreshing)
			{	engine_busy_refreshing = true;
				App.mediator.processing_start(PROCESSING_LOADING_DATA,PROCESSING_LOADING_DATA);
				pi_api.prepare_photo_list( photos_ready );
				refresh_needed = false;
				
				function photos_ready():void
				{	
					App.mediator.processing_ended(PROCESSING_LOADING_DATA);
					engine_busy_refreshing = false;
					populate_selector();	
				}
			}
		}
		/**
		 * loads the engine if need be and saves the new new image xml
		 * @param	_autophoto_xml xml created from autophoto APC
		 */
		private function save_new_fgdata( _autophoto_xml:XML, _save_fin_callback:Function ):void 
		{
			initialize_engine( engine_ready_for_save );
			
			function engine_ready_for_save():void 
			{	pi_api.save_image( _autophoto_xml, save_fin );		}
			
			function save_fin():void
			{	_save_fin_callback();	 }
		}
		/**
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
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close ); 
		}
		private function shortcut_close(  ):void
		{	close_win();
		}
		 /*******************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
	}
	
}
package code.skeleton.inauguration 
{
	import code.controllers.main_loader.Main_Loader;
	import code.skeleton.App;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.Method_Sequence_Manager;
	import com.oddcast.utils.OddcastSharedObject;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.BGUploader;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.DownloadVideo;
	import com.oddcast.workshop.ErrorReporter;
	import com.oddcast.workshop.ExternalInterface_Proxy;
	import com.oddcast.workshop.HostLoader;
	import com.oddcast.workshop.ISceneController;
	import com.oddcast.workshop.ProcessingEvent;
	import com.oddcast.workshop.SceneEvent;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSBackgroundStruct;
	import com.oddcast.workshop.WSEventTracker;
	import com.oddcast.workshop.WSModelStruct;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.SoundMixer;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import workshop.uploadphoto.BGController;
	
	/**
	 * @description responsible for the initial loading/setup of all the assets needed for this app at start up
	 * @author Me^
	 */
	public class Inauguration
	{	
		private var scene_controller_2d:Class;
		private var scene_controller_3d:Class;
		private var scene_controller_FB:Class;
		
		private const PROCESSING_LOADING_EDITING_STATE		:String = 'PROCESSING_LOADING_EDITING_STATE';
		private const PROCESSING_LOADING_EDITING_STATE_MSG	:String = 'intializing...';
		
		public function Inauguration( _stage:Stage ,_loader_info:LoaderInfo, _fin:Function, _2d_class:Class = null, _3d_class:Class = null, _fb_class:Class = null )
		{
			scene_controller_2d = _2d_class;
			scene_controller_3d = _3d_class;
			scene_controller_FB = _fb_class;
			
			ServerInfo.setLoaderInfo(_loader_info);
			
			var mid:* = ServerInfo.mid;
			App.asset_bucket.is_playback_mode = ServerInfo.hasMessage;
			
			var msm:Method_Sequence_Manager = new Method_Sequence_Manager( sequence_completed );
			msm.register_sequence( /*call this*/	set_context_menu, 	/*when done call these*/		[load_gwi]);
			msm.register_sequence( /*call this*/	load_gwi, 			/*when done call these*/		[init_shared_objects,
																										load_errors, 
																										load_settings,
																										load_localization,
																										init_scene_controller, 
																										init_error_reporting,
																										init_tracking,
																										init_morph_controls,
																										]);
			msm.register_sequence( /*call this*/	init_scene_controller,	/*when done call these*/	[set_misc]);
			msm.register_sequence( /*call this*/	load_settings, 			/*when done call these*/	[set_allow_domains,
																										load_profanity_filter,
																										init_alert,
																										]);
			msm.start_sequence();
				
			function sequence_completed():void
			{
				if (App.asset_bucket.is_playback_mode)
					App.mediator.show_playback_state( ServerInfo.mid, edit_state_imaguration );
				else
					edit_state_imaguration( );
				
				
				_fin();	// this will initialize the controllers
			}
		}
		
		
		
		
		/**
		 * called when the users clicks "Create your own" in the message player or if there is no MID available 
		 * 
		 */		
		private function edit_state_imaguration(  ) : void
		{
			//App.mediator.processing_start( PROCESSING_LOADING_EDITING_STATE, PROCESSING_LOADING_EDITING_STATE_MSG );
			//App.mediator.show_editing_state();
			App.asset_bucket.is_playback_mode = false;
			allDone();
						
			return;
			
			var msm:Method_Sequence_Manager = new Method_Sequence_Manager( sequence_complete );
			msm.register_sequence( /*call this*/set_view_states, 	/*when done call these*/	[init_video_downloader, 
																								init_bg_uploader,
																								position_host_holder,
																								load_vhosts_list,
																								load_background_list,
																								]);
			msm.register_sequence( /*call this*/load_vhosts_list,	/*when done call these*/	[load_initial_face,
																								load_initial_body,
																								]);
			msm.register_sequence( /*call this*/load_background_list,/*when done call these*/	[load_initial_background]);
			msm.start_sequence();
			
			App.mediator.processing_ended( PROCESSING_LOADING_EDITING_STATE );
			function sequence_complete():void
			{
				loadIdles(loadDances, allDone);
			}
			function allDone():void
			{
				App.mediator.dispatchEvent(new Event(App.mediator.EVENT_WORKSHOP_LOADED_DANCES ));
				App.mediator.show_editing_state();
				App.mediator.workshop_finished_loading_edit_state();
			}
		}
		protected function loadFirstIdle(_continue:Function, _key:Function):void
		{
			// might be too smart.
			var swfURL:String = ServerInfo.content_url_door + "misc/idle_vid01.swf";
			Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( fin ) ) );
			
			function fin(l:Loader):void
			{
				(l.content as MovieClip).stop();
				App.asset_bucket.idleScenes.push(l.content as MovieClip);
				_continue(_key);
			}			
		}
		protected function loadFirstDance(_callback:Function = null):void
		{	
			// might be too smart.
			var swfURL:String = ServerInfo.content_url_door + "misc/dancing_vid01.swf";
			Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( fin, progress ) ) );
			
			function fin(l:Loader):void
			{
				(l.content as MovieClip).stop();
				SoundMixer.stopAll();
				App.asset_bucket.danceScenes[0] = (l.content as MovieClip);
				if(_callback != null) _callback();
					
			}
			function progress(percent:*):void
			{
				// not the greatest idea
				//SoundMixer.stopAll();
				
				App.mediator.main_loading_process_status_update( Main_Loader.TYPE_BACKGROUND, percent );
			}
			
			
		}
		private function loadIdles(_continue:Function, _key:Function):void
		{
			if(App.asset_bucket.idleScenes.length > 2)
			{
				_continue(_key);
				return;
			}
			var swfURL:String = ServerInfo.content_url_door + "misc/idle_vid0"+String(App.asset_bucket.idleScenes.length+1)+".swf";
			Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( fin ) ) );
			
			function fin(l:Loader):void
			{
				(l.content as MovieClip).stop();
				App.asset_bucket.idleScenes.push(l.content as MovieClip);
				
				if(App.asset_bucket.idleScenes.length > 2)
				{
					_continue(_key);
					return;
				}else
				{
					loadIdles(_continue, _key);
				}
			}
		}
		private function loadDances(_callback:Function):void
		{
			var swfURL:String = ServerInfo.content_url_door + "misc/dancing_vid0"+String(App.asset_bucket.danceScenes.length+1)+".swf";
			Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( fin ) ) );
			
			function fin(l:Loader):void
			{
				(l.content as MovieClip).stop();
				SoundMixer.stopAll();
				App.asset_bucket.danceScenes.push(l.content as MovieClip);
				if(App.asset_bucket.danceScenes.length > 2)
				{
					_callback();
					return;
				}else
				{
					loadDances(_callback);
				}
			}
		}
		private function loadIdleScene(_continue:Function, _key:Function):void
		{
			// for now 
			_continue(_key);
			return;
			var swfURL:String = ServerInfo.content_url_door + "misc/idle_vid01.swf";
			Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( fin ) ) );
			
			function fin(l:Loader):void
			{
				App.asset_bucket.idleScene = (l.content as MovieClip);
				_continue(_key);
			}
		}
		private function error_initializing( _msg:String ):void
		{
			App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, '', 'Cannot Initialize\n\n' + _msg, null, user_response));
			function user_response( _ok:Boolean ):void
			{
				try					{	ExternalInterface_Proxy.call('window.location.reload()');	}
				catch (err:Error)	{		}
			}
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
		*
		********************************************* MAIN INAUGURATION - METHODS TO CHOOSE FROM FOR THE MANAGER *****/
		/**
		 * this will allow calls coming from external assets such as other swf and javascript calls..
		 * without this for eg., callbacks for facebook connect will not work
		 */
		private function set_allow_domains(_continue:Function, _key:Function):void
		{	
			var allow_domains:Array = App.settings.ALLOW_DOMAINS;
			var domain:String;
			for (var i:int = 0, n:int = allow_domains.length; i<n; i++ )
			{
				domain = allow_domains[ i ] + '.oddcast.com';
				Security.allowDomain( domain );
			}
			_continue(_key);// continue sequence
		}
		private function init_alert(_continue:Function, _key:Function):void
		{
			App.mediator.alert_set_init_params( App.settings.ALERT_SHOW_CODE );
			_continue(_key);// continue sequence
		}
		private function set_context_menu(_continue:Function, _key:Function):void
		{
			var myMenu:ContextMenu = new ContextMenu();
			myMenu.hideBuiltInItems();
			
			var menu_item_oddcast:ContextMenuItem 		= new ContextMenuItem("Powered By Oddcast");
			var menu_item_timestamp:ContextMenuItem		= new ContextMenuItem( App.settings.BUILD_TIMESTAMP )
			App.listener_manager.add( menu_item_oddcast, ContextMenuEvent.MENU_ITEM_SELECT, App.mediator.open_hyperlink_oddcast, this );
			myMenu.customItems.push(menu_item_oddcast);
			myMenu.customItems.push(menu_item_timestamp);
			App.ws_art.contextMenu = myMenu;
			
			_continue(_key);// continue sequence
		}
		private function load_gwi(_continue:Function, _key:Function):void
		{
			if (ServerInfo.stem_gwi && ServerInfo.stem_gwi.indexOf('://') > 0)
			{
				Gateway.retrieve_XML( ServerInfo.stem_gwi, new Callback_Struct( fin, progress, error ));
				function fin( _content:XML ):void 
				{	
					ServerInfo.parseXML( _content );
					_continue(_key);// continue sequence
				}
				function progress( _percent:int ):void
				{
					App.mediator.main_loading_process_status_update( Main_Loader.TYPE_GET_WORKSHOP_INFO, _percent );
				}
				function error( _msg:String ):void 
				{	error_initializing( _msg );
				}
			}
			else
				error_initializing('invalid get workshop info url');
		}
		private function init_shared_objects(_continue:Function, _key:Function):void
		{
			OddcastSharedObject.enabled = ServerInfo.shared_objects_enabled;
			_continue(_key);// continue sequence
		}
		private function load_errors(_continue:Function, _key:Function):void
		{
			progress( 0 );
			App.asset_bucket.model_store.list_errors.load(null, new Callback_Struct(fin, progress, error));
			
//			var url:String = ServerInfo.default_url + Bridge_Engine.settings.ERRORS_XML_PATH;
//			Gateway.retrieve_XML( url, new Callback_Struct( fin, progress, error ));
//			function fin(_xml:XML):void 
//			{	
//				Bridge_Engine.asset_bucket.alert_translation = new TranslationLookup();
//				Bridge_Engine.asset_bucket.alert_translation.autoParse(_xml.error);
//				
//				_continue(_key);// continue sequence
//			}
			function fin(  ) : void
			{
				_continue(_key);// continue sequence
			}
			function progress( _percent:int ):void
			{	App.mediator.main_loading_process_status_update( Main_Loader.TYPE_ERRORS, _percent );
			}
			function error( _msg:String ):void 
			{	_continue(_key);// continue sequence
			}
		}
		private function load_settings(_continue:Function, _key:Function):void
		{
			var url:String = ServerInfo.default_url + App.settings.SETTINGS_XML_PATH;
			progress( 0 );
			Gateway.retrieve_XML( url, new Callback_Struct( fin, progress, error ));
			function fin( _content:XML ):void 
			{	App.settings.parse_xml( _content );
				_continue(_key);// continue sequence
			}
			function progress( _percent:int ):void
			{	App.mediator.main_loading_process_status_update( Main_Loader.TYPE_SETTINGS, _percent );
			}
			function error( _msg:String ):void 
			{	error_initializing( _msg );
			}
		}
		private function load_localization(_continue:Function, _key:Function):void
		{
			var url:String = ServerInfo.default_url + "xml/"+ ServerInfo.lang + '.xml';// App.settings.SETTINGS_XML_PATH;
			progress( 0 );
			Gateway.retrieve_XML( url, new Callback_Struct( fin, progress, error ));
			function fin( _content:XML ):void 
			{	App.localizer.parse_xml( _content );
				_continue(_key);// continue sequence
			}
			function progress( _percent:int ):void
			{	App.mediator.main_loading_process_status_update( Main_Loader.TYPE_SETTINGS, _percent );
			}
			function error( _msg:String ):void 
			{	error_initializing( 'Language XML file not found: '+ServerInfo.lang + '.xml');
			}
		}
		private function load_profanity_filter(_continue:Function, _key:Function):void
		{
			if (App.settings.USE_BAD_WORDS)
			{	App.asset_bucket.profanity_validator.load( new Callback_Struct(loaded,null, error) );
				
				function loaded():void	
				{
					_continue(_key);
				}
				function error( _e:AlertEvent ):void
				{
					App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT,'','Profanity filter cannot be loaded'));
					_continue(_key);
				}
			}
			else
				_continue(_key);
		}
		private function init_scene_controller(_continue:Function, _key:Function):void
		{
			_continue(_key);
			return;
			var new_scene	:ISceneController;
			var host_holder	:HostLoader = new HostLoader();
			//App.ws_art.player_holder.player.addChildAt(host_holder, App.ws_art.player_holder.player.getChildIndex( App.ws_art.player_holder.player.model_layer ) );
			
			var scene_clazz:Class;
			switch ( ServerInfo.app_type )
			{	case ServerInfo.APP_TYPE_Flash_9_2D:		scene_clazz = scene_controller_2d;		break;
				case ServerInfo.APP_TYPE_Flash_9_3D:		scene_clazz = scene_controller_3d;		break;
				case ServerInfo.APP_TYPE_Flash_10_FB_3D:	scene_clazz = scene_controller_FB;		break;	// we need to init 3d first then fb3d
				default:
			}
			
			if (scene_clazz == null)
			{	throw new Error('Error instantiating scene class, please make sure inauguration class receives 2d/3d/full body controller');
				return;
			}
			new_scene = new scene_clazz(	null, 
				App.ws_art.player_holder.player.hostMask, 
				App.ws_art.player_holder.player.bgMask, 
				host_holder, 
				App.ws_art.player_holder.player.bgHolder
			);
			
			App.mediator.scene_editing = new_scene;
			App.mediator.scene_editing.init();
			
			init_full_body( scene_initted, host_holder as InteractiveObject );
			
			/**
			 * initialized the full body for usage, or hides elements if this isnt an FB application
			 * @param	_fin					the completed function as this can have subprocesses
			 * @param	_host_holder_to_remove	the head placeholder should be attached to the engine in FB mode... so we remove it from stage
			 */
			function init_full_body( _fin:Function, _host_holder_to_remove:InteractiveObject ):void
			{
				
				if (ServerInfo.app_type == ServerInfo.APP_TYPE_Flash_10_FB_3D)	// if this is intended as an FB application
				{
					if (!scene_controller_FB)	// no class to initialize... developer must define it
						throw new Error('Error instantiating FB3D scene class, please make sure inauguration class receives valid parameters');
					else
					{
						App.ws_art.player_holder.player.fb_holder.visible = true;	// holder for the full body art
						App.ws_art.player_holder.player.fb_holder.mask = App.ws_art.player_holder.player.fb_mask;
						if (_host_holder_to_remove && _host_holder_to_remove.parent)
							_host_holder_to_remove.parent.removeChild(_host_holder_to_remove);	// remove the 3d head since we added it to the full body display list
						
						App.mediator.scene_editing.full_body = new scene_controller_FB(); // set up the fb logic class for loading later when a model is requested to be loaded
						App.mediator.scene_editing.full_body.set_holder( App.ws_art.player_holder.player.fb_holder.placeholder as Sprite );
						_fin();
					}
				}
				else // not meant as an FB application
				{
					App.ws_art.player_holder.player.fb_holder.visible = false;	// hide the fb holder since it will not be used
					App.ws_art.player_holder.player.fb_mask.visible = false;
					_fin();
				}
			}
			
			function scene_initted():void
			{
				_continue(_key);// continue sequence
			}
		}
		private function set_misc(_continue:Function, _key:Function):void
		{
			App.listener_manager.add( App.asset_bucket.model_store.list_vhosts,	Event.CHANGE,					App.mediator.models_list_changed, this);
			App.listener_manager.add( App.ws_art.oddcastBtn,					MouseEvent.CLICK, 				App.mediator.open_hyperlink_oddcast, this );
			//App.listener_manager.add( App.ws_art.panel_buttons.uploadBGBtn, 	MouseEvent.CLICK, 				App.mediator.background_upload, this );
			
			// if its 2d or 3d
			if (App.mediator.scene_editing)
			{
				App.listener_manager.add( App.mediator.scene_editing, 			SceneEvent.MODEL_LOADED, 		App.mediator.configDone, this);
				App.listener_manager.add( App.mediator.scene_editing, 			SceneEvent.MODEL_LOAD_ERROR, 	App.mediator.onModelLoadError, this);
				App.listener_manager.add( App.mediator.scene_editing, 			SceneEvent.TALK_STARTED, 		App.mediator.talkStarted, this);
				App.listener_manager.add( App.mediator.scene_editing, 			SceneEvent.TALK_ERROR, 			App.mediator.talkError, this);
				App.listener_manager.add( App.mediator.scene_editing, 			ProcessingEvent.STARTED, 		App.mediator.onProcessingStarted, this);
				App.listener_manager.add( App.mediator.scene_editing, 			ProcessingEvent.PROGRESS, 		App.mediator.onProcessingProgress, this);
				App.listener_manager.add( App.mediator.scene_editing, 			ProcessingEvent.DONE, 			App.mediator.onProcessingEnded, this);
			}
			_continue(_key);// continue sequence
			return;
			App.asset_bucket.bg_controller = App.mediator.scene_editing.getBGMC() as BGController;
			App.listener_manager.add( App.asset_bucket.bg_controller, 			SceneEvent.BG_LOADED,			App.mediator.bg_loaded, this);
			App.listener_manager.add( App.asset_bucket.bg_controller, 			SceneEvent.BG_UPLOADED, 		App.mediator.bg_uploaded, this);
			App.listener_manager.add( App.asset_bucket.bg_controller, 			SceneEvent.BG_EXPIRED,			App.mediator.bg_expired, this);
			App.listener_manager.add( App.asset_bucket.bg_controller, 			ProcessingEvent.STARTED, 		App.mediator.onProcessingStarted, this);
			App.listener_manager.add( App.asset_bucket.bg_controller, 			ProcessingEvent.PROGRESS, 		App.mediator.onProcessingProgress, this);
			App.listener_manager.add( App.asset_bucket.bg_controller, 			ProcessingEvent.DONE, 			App.mediator.onProcessingEnded, this);
			
			App.ws_art.vhost_position.setTarget(App.mediator.scene_editing.zoomer);
			App.ws_art.bg_position.setTarget(App.asset_bucket.bg_controller.zoomer);
						
			
		}
		private function init_tracking(_continue:Function, _key:Function):void
		{
			if (ServerInfo.hasEventTracking) 
				WSEventTracker.init(ServerInfo.trackingURL, { apt:"W", acc:ServerInfo.door, emb:ServerInfo.viralSourceId } );
			_continue(_key);// continue sequence
		}
		private function init_error_reporting(_continue:Function, _key:Function):void
		{
			ErrorReporter.init( App.ws_art.stage );
			_continue(_key);// continue sequence
		}
		private function init_morph_controls(_continue:Function, _key:Function):void
		{
			_continue(_key);// continue sequence
			return;
			// default to false
			App.ws_art.check_morph.set_check( false );
			App.ws_art.check_morph.init_params( 'Morph Models', App.mediator.morph_checkbox_clicked );
			
			// set default to true
			App.ws_art.check_morph_color.visible = App.ws_art.check_morph.get_is_selected();
			App.ws_art.check_morph_color.set_check( true );
			App.ws_art.check_morph_color.init_params( 'Color Mode', App.mediator.morph_checkbox_color_clicked );
			_continue(_key);// continue sequence
		}
		/******************************************************************************************
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
		*
		********************************************* EDITING STATE IMAUGURATION - METHODS TO CHOOSE FROM FOR THE MANAGER *****/
		private function set_view_states(_continue:Function, _key:Function):void
		{	
			App.mediator.updateMoveZoom();
			//App.ws_art.panel_buttons.visible = false;
			if(App.mediator.scene_editing) App.mediator.scene_editing.clearAudio();
			
			_continue(_key);//continue sequence
		}
		private function init_video_downloader(_continue:Function, _key:Function):void
		{	
			App.asset_bucket.video_downloader = new DownloadVideo();
			App.asset_bucket.video_downloader.set_expiration_timeout( App.settings.UPLOAD_TIMEOUT_SEC );
			App.listener_manager.add(App.asset_bucket.video_downloader,ProcessingEvent.STARTED, App.mediator.onProcessingStarted , this );
			App.listener_manager.add(App.asset_bucket.video_downloader,ProcessingEvent.PROGRESS, App.mediator.onProcessingProgress , this );
			App.listener_manager.add(App.asset_bucket.video_downloader,ProcessingEvent.DONE, App.mediator.onProcessingEnded , this );
			App.listener_manager.add(App.asset_bucket.video_downloader,AlertEvent.ERROR, App.mediator.alert_user , this );
			
			_continue(_key);//continue sequence
		}
		private function load_vhosts_list( _continue:Function, _key:Function ):void
		{
			progress( 0 );
			App.asset_bucket.model_store.list_vhosts.load(null, new Callback_Struct( fin, progress, error ), incomplete_model_found );
			function fin():void 
			{	_continue(_key);
			}
			function progress( _percent:int ):void
			{	App.mediator.main_loading_process_status_update( Main_Loader.TYPE_MODELS_LIST, _percent );
			}
			function error( _msg:String ):void 
			{	App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, null, 'Error Loading models list', { details:_msg } ));
				_continue(_key);// continue loading... possibly there are no models for this door
			}
			function incomplete_model_found( _msg:String ):void
			{	
				var alert:AlertEvent = new AlertEvent(AlertEvent.ALERT, null, _msg );
				alert.report_error = false;
				App.mediator.alert_user(alert);
			}
		}
		private function load_background_list( _continue:Function, _key:Function ):void
		{
			progress( 0 );
			App.asset_bucket.model_store.list_backgrounds.load( null, new Callback_Struct( fin, progress, error ) );
			function fin():void 
			{	_continue(_key);// continue sequence
			}
			function progress( _percent:int ):void 
			{	App.mediator.main_loading_process_status_update( Main_Loader.TYPE_BG_LIST, _percent );
			}
			function error( _msg:String ):void 
			{	App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, null, 'Error Loading backgrounds list', { details:_msg } ));
				_continue(_key);// continue loading... possibly there are no backgrounds for this door
			}
		}
		
		private function position_host_holder( _continue:Function, _key:Function ):void 
		{	
			if (App.mediator.scene_editing.getHostMC())
			{	
				App.mediator.scene_editing.getHostMC().x		= App.settings.AVATAR_POS_X;
				App.mediator.scene_editing.getHostMC().y		= App.settings.AVATAR_POS_Y;
				App.mediator.scene_editing.getHostMC().scaleX	= App.settings.AVATAR_SCALE;
				App.mediator.scene_editing.getHostMC().scaleY	= App.settings.AVATAR_SCALE;
			}
			_continue(_key);//continue sequence
		}
		
		private function load_initial_face( _continue:Function, _key:Function ):void
		{
			var firstModel:WSModelStruct = App.asset_bucket.model_store.list_vhosts.get_default_vhost();
			if (firstModel)	
			{	
				add_listeners( true );
				progress( new ProcessingEvent( ProcessingEvent.PROGRESS, ProcessingEvent.MODEL, 0 ));
				App.mediator.scene_editing.loadModel(firstModel);
				
				function fin( _e:SceneEvent ):void 
				{	add_listeners(false);
					_continue(_key);// continue sequence
				}
				function progress( _e:ProcessingEvent ):void 
				{	
					if (_e.processName == ProcessingEvent.MODEL)
					{
						var percent:int = Math.round(_e.percent * 100);
						App.mediator.main_loading_process_status_update( Main_Loader.TYPE_FACE, percent );
					}
				}
				function add_listeners( _add:Boolean ):void
				{
					if (_add)
					{
						App.listener_manager.add( App.mediator.scene_editing, SceneEvent.MODEL_LOADED, fin, this );
						App.listener_manager.add( App.mediator.scene_editing, ProcessingEvent.PROGRESS, progress, this );
					}
					else
					{
						App.listener_manager.remove( App.mediator.scene_editing, SceneEvent.MODEL_LOADED, fin );
						App.listener_manager.remove( App.mediator.scene_editing, ProcessingEvent.PROGRESS, progress );
					}
				}
			}
			else
				_continue(_key);// continue sequence
		}
		/**
		 * provides status update to the main loader of the body loading
		 */
		private function load_initial_body( _continue:Function, _key:Function ):void
		{
			var firstModel:WSModelStruct = App.asset_bucket.model_store.list_vhosts.get_default_vhost();
			if (firstModel && firstModel.has_body_data())	
			{	
				add_listeners( true );
				progress( new ProcessingEvent( ProcessingEvent.FULL_BODY, ProcessingEvent.BG, 0 ));
				// you dont have to request to load it since the load_initial_face() loads the face and body.. this simply indicates progress on the body
				function fin(_e:ProcessingEvent):void 
				{	
					if (_e.processName == ProcessingEvent.FULL_BODY)
					{
						add_listeners(false);
						_continue(_key);// continue sequence
					}
				}
				function progress( _e:ProcessingEvent ):void 
				{	
					if (_e.processName == ProcessingEvent.FULL_BODY)
					{
						var percent:int = Math.round(_e.percent * 100);
						App.mediator.main_loading_process_status_update( Main_Loader.TYPE_BODY, percent );
					}
				}
				function add_listeners( _add:Boolean ):void
				{
					if (_add)
					{
						App.listener_manager.add( App.mediator.scene_editing, ProcessingEvent.DONE, fin, this );
						App.listener_manager.add( App.mediator.scene_editing, ProcessingEvent.PROGRESS, progress, this );
					}
					else
					{
						App.listener_manager.remove( App.mediator.scene_editing, ProcessingEvent.DONE, fin );
						App.listener_manager.remove( App.mediator.scene_editing, ProcessingEvent.PROGRESS, progress );
					}
				}
			}
			else
				_continue(_key);// continue sequence
		}
		/**
		 * loads the first background and provides status update to the main loader
		 */
		private function load_initial_background( _continue:Function, _key:Function ):void 
		{	
			var firstBG:WSBackgroundStruct = App.asset_bucket.model_store.list_backgrounds.model.get_all_items()[0];
			if (firstBG)
			{
				add_listeners( true );
				progress( new ProcessingEvent( ProcessingEvent.PROGRESS, ProcessingEvent.BG, 0 ));
				App.mediator.scene_editing.loadBG(firstBG);
				function fin( _e:SceneEvent ):void 
				{	add_listeners(false);
					_continue(_key);// continue sequence
				}
				function progress( _e:ProcessingEvent ):void 
				{	
					if (_e.processName == ProcessingEvent.BG)
					{
						var percent:int = Math.round(_e.percent * 100);
						App.mediator.main_loading_process_status_update( Main_Loader.TYPE_BACKGROUND, percent );
					}
				}
				function add_listeners( _add:Boolean ):void
				{
					if (_add)
					{
						App.listener_manager.add( App.asset_bucket.bg_controller, SceneEvent.BG_LOADED, fin, this );
						App.listener_manager.add( App.asset_bucket.bg_controller, ProcessingEvent.PROGRESS, progress, this );
					}
					else
					{
						App.listener_manager.remove( App.asset_bucket.bg_controller, SceneEvent.BG_LOADED, fin );
						App.listener_manager.remove( App.asset_bucket.bg_controller, ProcessingEvent.PROGRESS, progress );
					}
				}
			}
			else
			{
				App.mediator.scene_editing.unloadBG();
				_continue(_key);// continue sequence
			}
			
		}
		
		private function init_bg_uploader(_continue:Function, _key:Function):void 
		{	
			_continue(_key);// continue sequence
			return;
			App.asset_bucket.bg_uploader = new BGUploader();
			var min_kb:Number = App.settings.BG_MIN_SIZE_KB * 1024;
			var max_mb:Number = App.settings.BG_MAX_SIZE_MB * 1024 * 1024;
			App.asset_bucket.bg_uploader.setByteSizeLimits(min_kb, max_mb);
			App.asset_bucket.bg_uploader.set_expiration_timeout(App.settings.UPLOAD_TIMEOUT_SEC);
			App.asset_bucket.bg_controller.addUploader(App.asset_bucket.bg_uploader);
			App.listener_manager.add( App.asset_bucket.bg_uploader, AlertEvent.ERROR, App.mediator.alert_user,this);
			
			_continue(_key);// continue sequence
		}
		
		/******************************************************************************************
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
		 */
	}

}
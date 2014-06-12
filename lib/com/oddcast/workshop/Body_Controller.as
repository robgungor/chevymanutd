package com.oddcast.workshop 
{	
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.host.api.fullbody.*;
	import com.oddcast.utils.*;
	import com.oddcast.vhost.accessories.*;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.fb3d.*;
	import com.oddcast.workshop.fb3d.dataStructures.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Body_Controller implements IBody_Controller
	{
		private var fb3dController		:FB3dController;
		private var saved_anim_id		:int;
		private var fb_placeholder		:Sprite;
		private var arr_loaded_decal_id	:Array	= new Array();
		private var cur_loaded_acc_set	:int	= NO_ACC_SET_LOADED;
		private const NO_ACC_SET_LOADED	:int	= -373737;
		
		
		public function Body_Controller() 
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
		***************************** FB3D MAMBO JUMBO :-) */
		public function set_holder( _fb_holder:Sprite ):void
		{
			fb_placeholder = _fb_holder;
		}
		public function is_initialized(  ):Boolean
		{
			return (fb3dController != null);
		}
		public function init(_callbacks:Callback_Struct, 
							_domain:ApplicationDomain, 
							_fb3d_engine_url:String, 
							_api_url:String, 
							_content_url:String, 
							_cache_url:String, 
							_package_url:String,
							_acc_set_id:int,
							_cateory_id:int = 0,
							_head_engine_api:IHeadPlugin = null):void 
		{
			if (!fb_placeholder)
			{
				if (_callbacks.error != null)
					_callbacks.error( 'full body controller needs a reference to a valid sprite to initialize' );
				return;
			}
			
			// keep the same load but change the model category
			if (cur_loaded_acc_set == _acc_set_id)
			{
				fb3dController.loadModel( _cateory_id, _callbacks.fin, _callbacks.error, progress );
			}
			else	// get rid of the old controller
			{
				if (fb3dController)
					fb3dController.dispose( init_controller );
				else
					init_controller();
			}
				
			function init_controller (  ):void
			{
				arr_loaded_decal_id = new Array();
				fb3dController = new FB3dController();
				fb3dController.init( _domain, _fb3d_engine_url, _api_url, _content_url, fb_placeholder, _acc_set_id, _cateory_id, _head_engine_api, null, fin, error, progress );
				
				function fin():void
				{	
					fb3dController.setCacheUrl(_cache_url);
					cur_loaded_acc_set = _acc_set_id;
					if (_callbacks && _callbacks.fin != null)
						_callbacks.fin();
				}
				function error( _msg:String ):void 
				{
					if (_callbacks && _callbacks.error != null)
						_callbacks.error( _msg );
				}
			}
			function progress( _loaded:int, _total:int ):void 
			{	
				if (_callbacks && _callbacks.progress != null)
				{
					var percent:int = _loaded / _total;
					_callbacks.progress( percent );
				}
			}
		}
		public function init_audio( _talk_started:Function, _talk_ended:Function, _talk_error:Function ):void
		{
			if (fb3dController.audioPlayback)
			{
				fb3dController.audioPlayback.addEventListener(FB3dControllerEvent.AUDIO_DOWNLOAD_PROGRESS, function (evt:FB3dControllerEvent)
				{
					var evtDesc:EventDescription = evt.data;
					// unhandled
				});
				fb3dController.audioPlayback.addEventListener(FB3dControllerEvent.AUDIO_DOWNLOADED,  function (evt:FB3dControllerEvent)
				{
					var evtDesc:EventDescription = evt.data;
					// unhandled
				});
				fb3dController.audioPlayback.addEventListener(FB3dControllerEvent.AUDIO_ENDED,  function (evt:FB3dControllerEvent)
				{
					var evtDesc:EventDescription = evt.data;
					// unhandled
				});
				fb3dController.audioPlayback.addEventListener(FB3dControllerEvent.AUDIO_STARTED,  function (evt:FB3dControllerEvent)
				{
					var evtDesc:EventDescription = evt.data;
					// unhandled
				});
				fb3dController.audioPlayback.addEventListener(FB3dControllerEvent.AUDIO_ERROR,  function (evt:FB3dControllerEvent)
				{
					var evtDesc:EventDescription = evt.data;
					_talk_error();
				});
				fb3dController.audioPlayback.addEventListener(FB3dControllerEvent.TALK_ENDED,  function (evt:FB3dControllerEvent)
				{
					var evtDesc:EventDescription = evt.data;
					_talk_ended();
				});
				fb3dController.audioPlayback.addEventListener(FB3dControllerEvent.TALK_STARTED,  function (evt:FB3dControllerEvent)
				{
					var evtDesc:EventDescription = evt.data;
					_talk_started();
				});
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
		***************************** API :-) */
		public function enable_trucking( _value:Boolean ):void 
		{	if (fb3dController)		fb3dController.enableTrucking( _value );
		}
		
		public function enable_zooming( _value:Boolean ):void 
		{	if (fb3dController)		fb3dController.enableZooming( _value );
		}
		public function set camera_aim_x( _x:Number ):void
		{
			if (fb3dController)		fb3dController.setCameraAim( _x, camera_aim_y, camera_aim_z );
		}
		public function get camera_aim_x(  ):Number
		{
			if (fb3dController)		return fb3dController.getCameraAim().x;
			return 0;
		}
		public function set camera_aim_y( _y:Number ):void
		{
			if (fb3dController)		fb3dController.setCameraAim( camera_aim_x, _y, camera_aim_z );
		}
		public function get camera_aim_y(  ):Number
		{
			if (fb3dController)		return fb3dController.getCameraAim().y;
			return 0;
		}
		public function set camera_aim_z( _z:Number ):void
		{
			if (fb3dController)		fb3dController.setCameraAim( camera_aim_x, camera_aim_y, _z );
		}
		public function get camera_aim_z(  ):Number
		{
			if (fb3dController)		return fb3dController.getCameraAim().z;
			return 0;
		}
		public function set camera_pos_x( _x:Number ):void
		{
			if (fb3dController)		fb3dController.setCameraPos( _x, camera_pos_y, camera_pos_z );
		}
		public function get camera_pos_x(  ):Number
		{
			if (fb3dController)		return fb3dController.getCameraPos().x;
			return 0;
		}
		public function set camera_pos_y( _y:Number ):void
		{
			if (fb3dController)		fb3dController.setCameraPos( camera_pos_x, _y, camera_pos_z );
		}
		public function get camera_pos_y(  ):Number
		{
			if (fb3dController)		return fb3dController.getCameraPos().y;
			return 0;
		}
		public function set camera_pos_z( _z:Number ):void
		{
			if (fb3dController)		fb3dController.setCameraPos( camera_pos_x, camera_pos_y, _z );
		}
		public function get camera_pos_z(  ):Number
		{
			if (fb3dController)		return fb3dController.getCameraPos().z;
			return 0;
		}
		public function get_presets():*//PresetListData
		{	if (fb3dController)	return fb3dController.getPresets();
			return null;
		}
		public function load_preset( _preset_id:int, _callbacks:Callback_Struct ):void
		{	if (fb3dController)	fb3dController.loadPreset( _preset_id, _callbacks.fin, _callbacks.error, progress );
		
			function progress( _loaded:int, _total:int ):void 
			{	var percent:int = (_loaded * 100) / _total;
				if (_callbacks.progress != null)
					_callbacks.progress( percent );
			}
		}
		public function get_material_config():*//MaterialConfigurationListData
		{	if (fb3dController)	return fb3dController.getMaterialConfigurations();
			return null;
		}
		public function load_material_conf( _material_id:int, _callbacks:Callback_Struct):void
		{	if (fb3dController) fb3dController.loadMaterialConfig( _material_id, _callbacks.fin, _callbacks.error, progress );
		
			function progress( _loaded:int, _total:int ):void 
			{	var percent:int = (_loaded * 100) / _total;
				if (_callbacks.progress != null)
					_callbacks.progress( percent );
			}
		}
		public function get_decals():*//DecalConfigurationListData
		{	if (fb3dController)	return fb3dController.getDecalConfigurations();
			return null;
		}
		public function load_decal( _decal_id:int, _callbacks:Callback_Struct):void
		{	if (fb3dController) fb3dController.loadDecalConfig( _decal_id, fin, _callbacks.error, progress );
		
			function progress( _loaded:int, _total:int ):void 
			{	var percent:int = (_loaded * 100) / _total;
				if (_callbacks.progress != null)
					_callbacks.progress( percent );
			}
			function fin(  ):void
			{
				arr_loaded_decal_id.push( _decal_id );
				if (_callbacks && _callbacks.fin != null)
					_callbacks.fin();
			}
		}
		public function unload_decal( _decal_id:int ):void
		{
			if (fb3dController) fb3dController.removeDecalConfig( _decal_id );
			arr_loaded_decal_id.splice( arr_loaded_decal_id.indexOf( _decal_id ), 1 );
		}
		public function get_loaded_decal_ids(  ):Array
		{
			return arr_loaded_decal_id;
		}
		public function get_commands( _scene_id:int, _callbacks:Callback_Struct ):void
		{
			if (fb3dController)	fb3dController.getCommandsData( _scene_id, _callbacks.fin, _callbacks.error );
		}
		public function get_anim():*//AnimationListData
		{	
			if (fb3dController)	return fb3dController.getAnimations();
			return null;
		}
		public function load_anim( _anim_id:int, _callbacks:Callback_Struct, _anim_finished:Function, _loop:Boolean, _interrupt:Boolean):void
		{	if (fb3dController) fb3dController.loadAnimation( _anim_id, _loop, _interrupt, _callbacks.fin, _anim_finished, _callbacks.error, progress );
		
			function progress( _loaded:int, _total:int ):void 
			{	var percent:int = (_loaded * 100) / _total;
				if (_callbacks.progress != null)
					_callbacks.progress( percent );
			}
		}
		public function save_anim( _anim_id:int ):void
		{	saved_anim_id = _anim_id;
		}
		public function get saved_anim(  ):int
		{	return saved_anim_id;
		}
		public function get_color_list(  ):*//ColorableListData
		{
			if (fb3dController)		return fb3dController.getColorableCategories();
			return null;
		}
		public function set_color_category( _cat_name:String, _color:uint ):void
		{
			if (fb3dController)		fb3dController.setColorableMaterialLayersColor( _cat_name, _color );
		}
		public function get_camera_position(  ):String
		{
			var vector_pos:Vector3D = fb3dController.getCameraPos();
			return (vector_pos.x.toString() + ',' + vector_pos.y.toString() + ',' + vector_pos.z.toString())
		}
		public function get_camera_aim(  ):String
		{
			var vector_aim:Vector3D = fb3dController.getCameraAim();
			return (vector_aim.x.toString() + ',' + vector_aim.y.toString() + ',' + vector_aim.z.toString())
		}
		public function save_avatar( _callbacks:Callback_Struct ):void
		{
			fb3dController.saveAvatar( _callbacks.fin, byte_array_saved, _callbacks.error, progress );
			
			function byte_array_saved():void
			{}
			function progress( _loaded:int, _total:int ):void
			{
				var percent:int = (_loaded * 100) / _total;
				if (_callbacks.progress != null)
					_callbacks.progress( percent );
			}
		}
		public function avatar_cached_url(  ):String
		{
			if (fb3dController)	return fb3dController.getAvatarCacheUrl();
			return null;
		}
		public function has_changed_since_last_save(  ):Boolean
		{	if (fb3dController) return fb3dController.scene_has_changed();
			return false;
		}
		public function scene_was_saved(  ):void
		{
			if (fb3dController)	fb3dController.scene_was_saved();
		}
		public function say( _url:String ):void
		{
			if (audio_api_ready())
				fb3dController.audioPlayback.say( _url );
		}
		public function stop_audio():void
		{
			if (audio_api_ready())
				fb3dController.audioPlayback.stopSpeech();
		}
		public function freeze():void
		{
			if (audio_api_ready())
				fb3dController.audioPlayback.freeze();
		}
		public function resume():void
		{
			if (audio_api_ready())
				fb3dController.audioPlayback.resume();
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
		***************************** PRIVATES */
		/**
		 * checks if the audio is initialized and the api is ready
		 * @return
		 */
		private function audio_api_ready(  ):Boolean
		{
			return (fb3dController &&
					fb3dController.audioPlayback)
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
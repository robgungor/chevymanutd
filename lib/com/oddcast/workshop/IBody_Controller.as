package com.oddcast.workshop 
{
	import com.oddcast.host.api.fullbody.IHeadPlugin;
	import flash.display.*;
	import flash.system.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IBody_Controller
	{
		/**
		 * fb controller needs a display object to render the body
		 * this should be done before initialization of the body controller
		 * @param	_fb_holder	Sprite to render the body
		 */
		function set_holder( _fb_holder:Sprite ):void;
		/**
		 * checks if the fb3d controller has already been initialized for this application
		 * @return
		 */
		function is_initialized(  ):Boolean;
		/**
		 * initialize the full body controller, loads and accessory set and adds the head plugin
		 * @param	_callbacks 			the application domain in which the engine will load into
		 * @param	_domain				application domain
		 * @param	_fb3d_engine_url	url of the full body plugin swf
		 * @param	_api_url			
		 * @param	_content_url		
		 * @param	_cache_url			url for caching the saved AVT (http://char.dev.oddcast.com/)
		 * @param	_package_url		packages so less calls will be made to server when retrieving the data (http://content.dev.oddcast.com/char/fb/)
		 * @param	_acc_set_id			accessory set to load for this body
		 * @param	_head_engine_api	the head to add for this body (null if no head is present)
		 */
		function init(_callbacks:Callback_Struct, _domain:ApplicationDomain, _fb3d_engine_url:String, _api_url:String, _content_url:String, _cache_url:String, _package_url:String, _acc_set_id:int, _cateory_id:int = 0, _head_engine_api:IHeadPlugin = null):void
		/**
		 * initializes information for the audio status
		 * @param	_talk_started	called when audio starts
		 * @param	_talk_ended		called when audio ends
		 * @param	_talk_error		called when theres an audio error
		 */
		function init_audio( _talk_started:Function, _talk_ended:Function, _talk_error:Function ):void
		/**
		 * controll user shortcut moving the body on screen with Shift key
		 * @param	_value
		 */
		function enable_trucking( _value:Boolean ):void;
		/**
		 * controll user shortcut zooming with Ctrl key
		 * @param	_value
		 */
		function enable_zooming( _value:Boolean ):void;
		/**
		 * provides an array of presets type:PresetListData
		 * @return
		 */
		function get_presets():*;//PresetListData
		/**
		 * loads a specified preset id
		 * @param	_preset_id		preset id
		 * @param	_callbacks		fin when loaded, error when loading failed passes {a string with an error msg}, progress passes {loaded:uint and total:uint}
		 */
		function load_preset( _preset_id:int, _callbacks:Callback_Struct ):void
		/**
		 * provides an array of material configurations type:MaterialConfigurationListData
		 * @return
		 */
		function get_material_config():*;//MaterialConfigurationListData
		/**
		 * loads a specific material configuration id
		 * @param	_material_id	material configuration id
		 * @param	_callbacks		fin when loaded, error when loading failed passes {a string with an error msg}, progress passes {loaded:uint and total:uint}
		 */
		function load_material_conf( _material_id:int, _callbacks:Callback_Struct):void
		/**
		 * provides an array of decals type:DecalConfigurationListData
		 * @return
		 */
		function get_decals():*;//DecalConfigurationListData
		/**
		 * loads a specific decal id
		 * @param	_decal_id		decal id
		 * @param	_callbacks		fin when loaded, error when loading failed passes {a string with an error msg}, progress passes {loaded:uint and total:uint}
		 */
		function load_decal( _decal_id:int, _callbacks:Callback_Struct):void;
		/**
		 * provides an array of int ids that have been loaded for this model
		 * @return
		 */
		function get_loaded_decal_ids(  ):Array
		/**
		 * unloads a specific decal id
		 * @param	_decal_id		decal id
		 */
		function unload_decal( _decal_id:int ):void;
		/**
		 * provides a list of commands that can be used for editing and playback
		 * @param	_scene_id	the id used for filterring
		 * @param	_callbacks	fin( {Vector.<CommandData>} ), error( {String} );
		 */
		function get_commands( _scene_id:int, _callbacks:Callback_Struct ):void;
		/**
		 * provides an array of Animations type:AnimationListData
		 * @return
		 */
		function get_anim():*;//AnimationListData
		/**
		 * loads a specific Animation id
		 * @param	_anim_id		animation ID
		 * @param	_callbacks		fin when loaded, error when loading failed passes {a string with an error msg}, progress passes {loaded:uint and total:uint}
		 * @param	_anim_finished	called when the animation cycle has ended
		 * @param	_loop			if to loop the animation
		 * @param	_interrupt		if to interrupt the current animation
		 */
		function load_anim( _anim_id:int, _callbacks:Callback_Struct, _anim_finished:Function, _loop:Boolean, _interrupt:Boolean):void;
		/**
		 * saves an animation for sharing (will auto play when the message is opened)
		 * @param	_anim_id	animation id (TIP TO SAVE MULTIPLE ANIMATIONS USE A DELIMITER such as 123.234.345)
		 */
		function save_anim( _anim_id:int ):void;
		/**
		 * the currently saved animation meant for sharing
		 */
		function get saved_anim(  ):int;
		/**
		 * provides and array of colorable items type:ColorableListData
		 * @return
		 */
		function get_color_list(  ):*//ColorableListData
		/**
		 * applies a color to a specific category by name
		 * @param	_cat_name	name
		 * @param	_color		color: 0xff0000
		 */
		function set_color_category( _cat_name:String, _color:uint ):void
		/**
		 * saves the avatar file to the server
		 * @param	_callbacks	fin(), progress(int), error(String)
		 */
		function save_avatar( _callbacks:Callback_Struct ):void;
		/**
		 * creates an avatar url used for saving and playback
		 * @return
		 */
		function avatar_cached_url(  ):String
		/**
		 * checks if no decals, acc etc have beel loaded since the last save 
		 * @return	true if a new save needs to happen
		 */
		function has_changed_since_last_save(  ):Boolean;
		/**
		 * notifies that the current avatar was saved
		 */
		function scene_was_saved(  ):void
		/**
		 * string representing x,y,z values of the Vector3D object
		 * @return
		 */
		function get_camera_position(  ):String;
		/**
		 * string representing x,y,z values of the Vector3D object
		 * @return
		 */
		function get_camera_aim(  ):String;
		function set camera_aim_x( _x:Number ):void;
		function get camera_aim_x(  ):Number;
		function set camera_aim_y( _y:Number ):void;
		function get camera_aim_y(  ):Number;
		function set camera_aim_z( _z:Number ):void;
		function get camera_aim_z(  ):Number;
		function set camera_pos_x( _x:Number ):void;
		function get camera_pos_x(  ):Number;
		function set camera_pos_y( _y:Number ):void;
		function get camera_pos_y(  ):Number;
		function set camera_pos_z( _z:Number ):void;
		function get camera_pos_z(  ):Number;
		/**
		 * say an audio
		 * @param	_url
		 */
		function say( _url:String ):void;
		/**
		 * stop an audio playback
		 */
		function stop_audio():void;
		/**
		 * freeze current audio
		 */
		function freeze():void;
		/**
		 * resume current audio
		 */
		function resume():void;
	}
	
}
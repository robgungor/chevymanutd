package com.oddcast.workshop 
{
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.EngineEvent;
	import com.oddcast.host.api.IEditorAPI;
	import com.oddcast.host.api.morph.MorphPhotoFace;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.vhost.accessories.AccessoryData3D;
	import com.oddcast.workshop.ISceneController;
	import com.oddcast.workshop.SceneEvent;
	import com.oddcast.workshop.WSModelStruct;
	
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * 
	 * @author Me^
	 */
	public class Morph_Controller extends EventDispatcher
	{
		/** morphing api */
		private var model_morpher				:MorphPhotoFace;
		/** the scene associated to the current morphing instance */
		private var scene_controller			:ISceneController;
		/** current set target character */
		private var current_set_target_char		:WSModelStruct;
		/** current set back character */
		private var current_set_back_char		:WSModelStruct;
		/** the next in line target character to be loaded */
		private var next_set_target_char		:WSModelStruct;
		/** the next in line back character to be loaded */
		private var next_set_back_char			:WSModelStruct;
		/** color mode value */
		private var color_mode_value			:Boolean			= false;
		/** callback when morphing is complete */
		private var on_complete_callback		:Function;
		/** are we going to morph the model after the base model loads or not */
		private var now_waiting_for_base_model	:Boolean			= false;
		/** morphing class name to use */
		private var morph_class					:Class;
		
		/** constants for internal use */
		private const ACCESSORY_APPLIED			:String				= 'acc applied to the host';
		private const BACK_CHARACTER_SET		:String				= 'back character xml finished loading';
		private const TARGET_CHARACTER_SET		:String				= 'target character xml finished loading';
		private const FACE_BLENDING_ACC_ID		:int				= 31;
		
		/**
		 * constructor
		 */
		public function Morph_Controller() 
		{
		}
		/**
		 * current engine of the loaded host
		 * @return
		 */
		private function get_current_host_engine(  ):IEditorAPI
		{
			var engine:* = scene_controller.getHostMC().api;
			var engine_interface:IEditorAPI = engine as IEditorAPI;
			return engine_interface;
		}
		
		/**
		 * sets the scene associated with the morphing
		 * @param	_scene scene pointing to all the needed objects
		 */
		public function init_params( _scene:ISceneController ):void 
		{
			scene_controller		= _scene;
		}
		/**
		 * creates a new model morphing instance for... well.. morphing
		 */
		private function init_morphing(  ):void 
		{
			if (model_morpher == null)
			{
				/*switch ( morph_class )	//model_morpher = new MorphPhotoFaceUsersSkintone( get_current_host_engine() );
				{
					case MORPH_CLASS_MorphPhotoFaceUsersSkintone:		model_morpher = new MorphPhotoFaceUsersSkintone( get_current_host_engine() );	break;
					case MORPH_CLASS_MorphPhotoFaceVideoStar:			model_morpher = new MorphPhotoFaceFlashVideoStar( get_current_host_engine() );	break;
					default:	throw( new Error('INCOMPATIBLE MORPH CLASS :: com.oddcast.workshop.Morph_Controller.init_morphing()') );
				}*/
				model_morpher = new morph_class( get_current_host_engine() );
			}
		}
		/**
		 * needed when the current engine is removed
		 */	
		public function destroy_current_morpher(  ):void 
		{
			if (model_morpher)
			{
				model_morpher.unload();
				model_morpher = null;
			}
		}
		/**
		 * loads the back model, morphs the face with the head
		 * @param	_target_model model whos face will be visible
		 * @param	_back_model the back of the head of the model
		 * @param	_color_mode color setting
		 * @param	_on_complete_callback callback for when finished
		 * @param	_morph_class the morphing class to use... 
		 * for example "MorphPhotoFaceUsersSkintone" for workshops and "MorphPhotoFaceVideoStar" for videostar
		 */
		public function morph_these_models( _target_model:WSModelStruct, _back_model:WSModelStruct, _color_mode:Boolean, _on_complete_callback:Function, _morph_class:Class ):void 
		{
			on_complete_callback		= _on_complete_callback;
			color_mode_value			= _color_mode;
			next_set_target_char		= _target_model;
			next_set_back_char			= _back_model;
			morph_class			= _morph_class;
			
			load_base_model();
		}
		/**
		 * updates the color setting
		 * @param	_color_mode
		 */
		public function change_color_dependency_on_current_models( _color_mode:Boolean ):void 
		{
			color_mode_value			= _color_mode;				// update color value to be used later
			scene_controller.getHostMC().destroy_host();			// destroy only the host not everything, force only loadXML to happen
			now_waiting_for_base_model = true;
			scene_controller.loadModel( current_set_back_char );	// start the process
		}
		/**
		 * loads the characters engine, mesh OA1 if need be
		 */
		private function load_base_model(  ):void 
		{
			now_waiting_for_base_model = true;
			scene_controller.loadModel( next_set_back_char );
		}
		/**
		 * callback when the engine, mesh (OA1) are all ready	
		 */
		public function base_model_loaded( /*_e:SceneEvent*/ ):void 
		{
			now_waiting_for_base_model = false;
			apply_color_setting()
		}
		/**	
		 * applies the color dominance btw the face and the head 
		 */
		private function apply_color_setting(  ):void 
		{
			get_current_host_engine().usePhotoColorForSkinTone( color_mode_value );
			
			set_back_character();/*set_back_and_front_characters();*/
		}
		private function set_back_character(  ):void 
		{
			init_morphing();
			
			listener_manager( BACK_CHARACTER_SET, get_current_host_engine().addEventListener );
			model_morpher.setBackCharacter	( next_set_back_char.charXml.toString() );
		}
		private function back_character_complete( _e:Event ):void 
		{
			current_set_back_char		= next_set_back_char;
			listener_manager( BACK_CHARACTER_SET, get_current_host_engine().removeEventListener );
			
			set_target_character();
		}
		private function set_target_character(  ):void 
		{
			listener_manager( TARGET_CHARACTER_SET, get_current_host_engine().addEventListener );
			model_morpher.setTargetCharacter( next_set_target_char.charXml.toString() );
		}
		private function target_character_complete( _e:Event ):void 
		{
			current_set_target_char		= next_set_target_char;
			listener_manager( TARGET_CHARACTER_SET, get_current_host_engine().removeEventListener );
			
			blend_face_to_head();
		}
		/**	
		 * loads an accessorie that blends the face smoothly to the head	
		 */
		private function blend_face_to_head(  ):void 
		{
			var url:String = ServerInfo.acceleratedURL + 'php/vhss_editors/getAccessories/doorId=' + ServerInfo.door + "/modelId=" + scene_controller.model.id.toString();
			Gateway.retrieve_XML( url, new Callback_Struct(fin, null, error),response_eval );
			function response_eval( _xml:XML ) : Boolean
			{
				return (_xml && _xml.ITEM && _xml.ITEM.length() > 0);
			}
			function fin( _xml:XML ) : void
			{
				apply_blend_accessorie( get_first_morph_acc( _xml, FACE_BLENDING_ACC_ID ) );
			}
			function error( _msg:String ) : void
			{
				all_morhing_complete();
			}
		}
		private function get_first_morph_acc( _xml:XML, _morph_acc_type:int ) : AccessoryData3D
		{
			var acc:AccessoryData3D;
			var all_acc:Array = new Accessory_XML_Parser().parse_xml( _xml );
			loop1: for (var i:int = 0, n:int = all_acc.length; i<n; i++ )
			{
				acc = all_acc[ i ];
				if (acc.typeId == _morph_acc_type)
					return acc;
			}
			return null;
		}
		/**	
		 * apply accessorie that blends the face	
		 */
		private function apply_blend_accessorie( _acc:AccessoryData3D ):void 
		{
			listener_manager( ACCESSORY_APPLIED, scene_controller.addEventListener );
			if (_acc)
				scene_controller.loadAccessory( _acc );
			else
				face_blending_finished( null );
		}
		private function face_blending_finished( _e:Event ):void 
		{
			listener_manager( ACCESSORY_APPLIED, scene_controller.removeEventListener );
			all_morhing_complete();
		}
		/**	
		 * called when all the morphing has finished and is ready to release the loaders	
		 */
		private function all_morhing_complete(  ):void 
		{
			if ( on_complete_callback != null ) 
				on_complete_callback();
		}
		/**	
		 * called when all base models are loaded to check if morphing needs to continue or bypass	
		 */
		public function is_morphing_pending(  ):Boolean
		{
			return now_waiting_for_base_model;
		}
		/**
		 * adds specific listeners or removes any present..
		 * @param	_mode the mode of the listeners type
		 * @param	_control the function (eg. object.addEventListener )
		 */
		private function listener_manager( _mode:String, _control:Function ):void 
		{
			switch(_mode)
			{
				case ACCESSORY_APPLIED:		_control( SceneEvent.ACCESSORY_LOADED, face_blending_finished );
											break;
				case BACK_CHARACTER_SET:	_control( EngineEvent.PROCESSING_ENDED, back_character_complete );
											break;
				case TARGET_CHARACTER_SET:	_control( EngineEvent.PROCESSING_ENDED, target_character_complete );
											break;
			}
		}
	}
	
}
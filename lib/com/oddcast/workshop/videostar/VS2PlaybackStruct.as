package com.oddcast.workshop.videostar 
{
	import com.oddcast.assets.structures.*;
	import com.oddcast.audio.*;
	import com.oddcast.workshop.*;
	
	/**
	* ...
	* @author Sam Myer, Me^
	*/
	public class VS2PlaybackStruct extends WSVideoStruct 
	{
		public var modelArr			:Array;
		public var keyFileArr		:Array;
		public var audio			:AudioData;
		/* DEPRECATING
		 * set this to turn on morphing */
		public var morph_back_model	:WSModelStruct;
		/* array of WS_Morph_Model, models to morph */
		public var morph_model_list	:Array;
		/* if to load the morph models or not */
		public var load_morph_models:Boolean = false;
		
		/**
		 * struct holding video information needed for playback
		 * @param	_url video url
		 * @param	_id the id
		 * @param	_audio AudioData information
		 */
		public function VS2PlaybackStruct(_url:String, _id:int = -1, _audio:AudioData = null ):void 
		{
			super(_url, _id);
			modelArr		= new Array();
			keyFileArr		= new Array();
			audio			= _audio;
		}
		
		/**
		 * adds another actor to the list
		 * @param	_model model information
		 * @param	keyFile keyfile information for that model
		 */
		public function addActor(_model:WSModelStruct, keyFile:LoadedAssetStruct) : void {
			modelArr.push(_model);
			keyFileArr.push(keyFile);
		}
		
		/**
		 * add models if we want to morph them
		 * @param	_face face of the model
		 * @param	_head head of the model
		 */
		public function add_morph_model( _face:WSModelStruct, _head:WSModelStruct ):void 
		{
			if (morph_model_list == null)
				morph_model_list = new Array();
				
			morph_model_list.push( new WS_Morph_Model( _face, _head ) );
		}
		
		
		
		public function get model():WSModelStruct {
			return(modelArr[0]);
		}
	}
	
}
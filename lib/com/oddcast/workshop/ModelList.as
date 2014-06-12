/**
* @author Sam Myer, Me^
* This class is for loading and storing a list of models for this door.
* In the MVC pattern, this is (coincidentally) the model class.
* 
***** Functions:
* loadModels() - makes php call to load audios
* 
* getModelByName
* getModelById - get a specific model matching the specified criterion
* 
* getModelsByCatId
* getModelsByCatName - returns an array of WSModelStruct objects matching specified category
* getModelsByCatNameOld - deprecated - before category name was implemented the category name was included in the
* model name.  This is no longer in use
* 
* getModelsByOA1Type - returns array of 3d WSModelStruct's with given oa1 type id (representing full face, photo mask, etc.)
* 
* addModel - usually called after autophoto process completes.  adds a new model to the model list
* 
***** Properties:
* modelArr - after loading is complete, this points to an array of WSModelStruct objects
* 
***** Events:
* Event.COMPLETE - when loading successfully completes
* AlertEvent.ERROR - when there is a loading error
*/
package com.oddcast.workshop 
{
	import com.oddcast.assets.structures.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	
	import flash.events.*;
	
	public class ModelList extends EventDispatcher 
	{
		/* indicates if a load is in process to not allow multiple loads */
		private var isProcessing			:Boolean;
		/* array of WSModelStruct representing non "back" models */
		private var front_models_list		:Array;
		/* array of WSModelStruct representing "back" models */
		private var back_models_list		:Array;
		/* engine flag indicating its meant for full body */
		private const ENGINE_TYPE_FB		:String = 'FB3D';
		/* CATNAME in the model determines if this is meant for morphing as a head */
		private const CATEGORY_BACK			:String = 'back';
		/* indicates a 3D model type */
		private const MODEL_TYPE_3D			:String = '3D';
		/* true indicates that the list is already loaded */
		public var is_loaded				:Boolean = false;
		
		public function ModelList() 
		{
			front_models_list 	= new Array();
			back_models_list	= new Array();
		}
		
		/**
		 * loads the models XML and parses it
		 */
		public function loadModels():void
		{
			load_models();
		}
		
		public function load_models( _callbacks:Callback_Struct = null, _invalid_model_callback:Function = null ):void
		{
			if (!isProcessing)
			{
				isProcessing = true;
				var models_url:String
				switch ( ServerInfo.app_type )
				{	case ServerInfo.APP_TYPE_Flash_10_FB_3D:	models_url = ServerInfo.acceleratedURL + "php/vhss_editors/getModelsFB/doorId=" + ServerInfo.door;
																break;
					default:									models_url = ServerInfo.acceleratedURL + "php/vhss_editors/getModels/doorId=" + ServerInfo.door;
				}
				
				Gateway.retrieve_XML( models_url, new Callback_Struct( fin, progress, error ));
				function fin( _content:XML ):void 
				{	
					isProcessing = false;
					parseModels( _content, _invalid_model_callback );
					dispatchEvent( new Event(Event.COMPLETE ) );
					if (_callbacks && _callbacks.fin != null)	_callbacks.fin();
				}
				function progress( _percent:int ):void
				{
					if (_callbacks && _callbacks.progress != null)	_callbacks.progress( _percent );
				}
				function error( _msg:String ):void 
				{	
					isProcessing = false;
					dispatchEvent( new AlertEvent(AlertEvent.ERROR, 'f9t370', _msg));
					if (_callbacks && _callbacks.error != null)	_callbacks.error( _msg );
				}
			}
		}
		
		/**
		 * parse the models for construction of models and engines lists
		 * @param	_xml	models XML
		 */
		public function parseModels(_xml:XML, _invalid_model_callback:Function = null):void
		{
			is_loaded = true;
			front_models_list 		= new Array();
			back_models_list		= new Array();
			
			var item		:XML;
			var model		:WSModelStruct;
			var thumbBaseUrl:String = _xml.@THUMB_BASE_URL;
			var ohBaseUrl	:String = _xml.@OH_BASE_URL;
			var fgBaseUrl	:String = _xml.@FG_BASE_URL;
			var modelType	:String;
			var thumbUrl	:String;
			var modelName	:String;
			var modelId		:int;
			var modelUrl	:String;
			var charXML		:XML;
			var xurls		:XMLList;
			var engine		:EngineStruct;
			var engineArr	:Array = new Array();
			var engineId	:int;
			var engine_type	:String;
			var engine_url	:String;
			
			// parse the ENGINES
				for (var i:int = 0; i < _xml.ENGINE.length(); i++) 
				{
					item 		= _xml.ENGINE[i];
					engineId 	= parseInt(item.@ID.toString());
					engine_type	= item.@TYPE.toString();
					engine_url	= item.@URL.toString();
					engine 		= new EngineStruct(engine_url, engineId, engine_type);
					
					if (item.@CTL != undefined) 
						engine.ctlUrl = item.@CTL.toString();
						
					if (item.@VERSION != undefined)
						engine.version = item.@VERSION.toString();
					
					engineArr[engineId] = engine;
				}
			
			// parse the MODELS
				for (i = 0; i < _xml.MODEL.length(); i++) 
				{
					item 		= _xml.MODEL[i];
					modelType 	= _xml.ENGINE.(@ID == item.@ENGINE).@TYPE.toString();
					thumbUrl 	= item.@THUMB.toString();
					if (thumbUrl == "") 
						thumbUrl = null;
					if (thumbUrl != null && thumbUrl.indexOf("http://") != 0) 
						thumbUrl = thumbBaseUrl + thumbUrl;
					modelName 	= item.@NAME.toString();
					modelId 	= parseInt(item.@ID.toString());
					engineId 	= parseInt(item.@ENGINE.toString());
					// Full Body and 3D models should be treated the same since the fb engine can handle adding a 3d head
						if (ServerInfo.app_type == ServerInfo.APP_TYPE_Flash_10_FB_3D ||	// full body type of applicatin
							modelType.toLowerCase() == MODEL_TYPE_3D.toLowerCase()) 		// 3d model type of character
						{
							if (item.hasOwnProperty("CHARACTER") && item.CHARACTER[0].hasOwnProperty("fgchar")) 
							{
								charXML = item.CHARACTER[0].fgchar[0];
								
								//add base url to urls in char xml
								xurls 	= charXML.elements("url");
								for (var j:int = 0; j < xurls.length(); j++) 
									xurls[j].@url = fgBaseUrl + xurls[j].@url;
							}
							else charXML = null;
							
							modelUrl 		= _xml.SAMSET.(@ID == item.@SAMSET).@URL.toString();
							model 			= new WSModelStruct(modelUrl, modelId, thumbUrl, modelName);
							model.charXml 	= charXML;
							model.is3d 		= true;
							model.oa1Type 	= parseInt(_xml.SAMSET.(@ID == item.@SAMSET).@CATID.toString());
							
							// add full body data if an engine is present
							if (item.@FBENGID != undefined)
							{
								model.full_body_struct = new WS_Body_Struct();
								var fb_engine_id:int	= parseInt(item.@FBENGID.toString());
								var fb_cat_id	:int	= parseInt(item.@FBCAT.toString());
								var fb_scene_id	:String = item.@SCENE_ID.toString();
								model.full_body_struct.engine		= engineArr[ fb_engine_id ];
								model.full_body_struct.scene_id		= fb_scene_id;
								model.full_body_struct.category_id	= fb_cat_id;
								
								// add full body accessory set id, this is only for full body usage
								if (item.@ASET != undefined)
									model.full_body_struct.acc_set_id = parseInt(item.@ASET.toString());
							}
						}
					// 2D models
						else 
						{
							modelUrl 	= item.@OH.toString();
							if (modelUrl.slice(0, 7) != "http://") 
								modelUrl = ohBaseUrl + modelUrl;
							model		= new WSModelStruct(modelUrl, modelId, thumbUrl, modelName);
							model.is3d 	= false;
						}
						
					model.engine 	= engineArr[engineId];
					if (item.@CATID.toString().length > 0) 
						model.catId = parseInt(item.@CATID.toString());
					
					model.catName 	= item.@CATNAME;
					
					// check that the 3D model isnt missing any information and report it
					var model_is_incomplete:Boolean = false;
					if (model.is3d)
					{
						if (model.has_head_data())
						{
							if (!model.url || model.url.toLowerCase().indexOf('://') < 1)	
							{
								if (_invalid_model_callback != null)
									_invalid_model_callback('missing SAMSET for model: ' + model.id + ' - ' + model.name);
								model_is_incomplete = true;
							}
							if (!model.charXml || !model.charXml.hasOwnProperty('url'))
							{
								if (_invalid_model_callback != null)
									_invalid_model_callback('missing CHARACTER XML for model: ' + model.id + ' - ' + model.name);
								model_is_incomplete = true;
							}
						}
						if (model.has_body_data())
						{
							if (!model.full_body_struct.acc_set_id || model.full_body_struct.acc_set_id <= 0)
							{
								if (_invalid_model_callback != null)
									_invalid_model_callback('missing ACCESSORY SET for model: ' + model.id + ' - ' + model.name);
								model_is_incomplete = true;
							}
						}
					}
					
					// add model is its complete
					// add new model to seperate lists for morphing
					if (!model_is_incomplete)
					{
						if ( is_back_model( model ) )
							back_models_list.push( model );
						else
							front_models_list.push( model );
					}
				}
			
			/**
			 * checks if a model is supposed to be only a back model, used for morphing
			 * @param	_model	model to be determined
			 * @return	true if its a back model type
			 */
			function is_back_model( _model:WSModelStruct ):Boolean
			{
				if ( _model.catName.toLowerCase() == CATEGORY_BACK.toLowerCase() )
					return true;
				return false;
			}
		}
		
		/**
		 * if we have a back models present then we can morph
		 * @return true if there is morphing information
		 */
		public function is_morphing_capable(  ):Boolean
		{
			return ( back_models_list && back_models_list.length > 0 );
		}
		
		/**
		 * models intended for morphing as a back model
		 * Array of WSModelStruct
		 */
		public function get back_models(  ):Array
		{
			return back_models_list;
		}
		
		/**
		 * models intended for morphing as a front model
		 * Array of WSModelStruct
		 */
		public function get models():Array 
		{
			return(front_models_list);
		}
		
		/**
		 * find a model by its name
		 * @param	_name	name of the model
		 * @return	null if not found
		 */
		public function get_model_by_name ( _name:String ):WSModelStruct 
		{
			var model:WSModelStruct = find_model_in_array( _name, front_models_list );
			if (model == null)	// not found in front models list
				model				= find_model_in_array( _name, back_models_list );
				
			return model;
			
			/**
			 * search for a model name in a specified list of models
			 * @param	_name	name of model
			 * @param	_array_of_models	list of models
			 * @return	null if not found
			 */
			function find_model_in_array( _name:String, _array_of_models:Array ):WSModelStruct
			{
				for (var i:int = 0; i < _array_of_models.length; i++) 
				{
					var model:WSModelStruct = _array_of_models[i];
					if (model.name == _name) 
						return model;
				}
				return null;
			}
		}
		
		/**
		 * find a model by its ID
		 * @param	_name	name of the model
		 * @return	null if not found
		 */
		public function get_model_by_id( _id:int ):WSModelStruct 
		{
			var model:WSModelStruct = find_model_in_array( _id, front_models_list );
			if (model == null)	// not found in front models list
				model				= find_model_in_array( _id, back_models_list );
				
			return model;
			
			/**
			 * search for a model name in a specified list of models
			 * @param	_id	id of model
			 * @param	_array_of_models	list of models
			 * @return	null if not found
			 */
			function find_model_in_array( _id:int, _array_of_models:Array ):WSModelStruct
			{
				for (var i:int = 0; i < _array_of_models.length; i++) 
				{
					var model:WSModelStruct = _array_of_models[i];
					if (model.id == _id)
						return model;
				}
				return null;
			}
		}
		
		/**
		 * finds a list of models based on OA1 type
		 * @param	_cat_id	OA1 category ID
		 * @return
		 */
		public function getModelsByOA1Type( _cat_id:int):Array 
		{
			var mArr:Array = new Array();
			find_model_in_array( _cat_id, mArr, front_models_list);
			find_model_in_array( _cat_id, mArr, back_models_list);
			return(mArr);
			
			function find_model_in_array( _OA1_id:int, _found_models:Array, _arr_to_search:Array ):void
			{
				for (var i:int = 0; i < _arr_to_search.length; i++) 
				{
					var model	:WSModelStruct = _arr_to_search[i];
					if (model.oa1Type == _OA1_id)
						_found_models.push(model);
				}
			}
		}
		
		/**
		 * adds a new model to the front models list
		 * @param	_new_model	new model to be added
		 */
		public function addModel( _new_model:WSModelStruct):void
		{
			front_models_list.push( _new_model );
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
	
}
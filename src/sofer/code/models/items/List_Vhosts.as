package code.models.items
{
	import code.models.Model_Item;
	
	import com.oddcast.assets.structures.EngineStruct;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSModelStruct;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class List_Vhosts extends EventDispatcher
	{
		public var is_loaded:Boolean;
		/** vhosts for default loading (non morph) or if for morph meant as front vhosts or target vhosts */
		public var model_front:Model_Item = new Model_Item();
		/** vhosts for morphing as a back vhost */
		public var model_back:Model_Item = new Model_Item();
		
		private var callbacks:Callback_Struct;
		private var callback_incomplete_vhost:Function;
		
		private const ERROR_LOADING_CODE:String ='f9t370';
		private const ERROR_LOADING_MSG	:String ='Error loading vhosts list';
		private const SUB_URL			:String = "php/vhss_editors/getModels/doorId=";
		private const SUB_URL_FB		:String = "php/vhss_editors/getModelsFB/doorId=";
		
		/** engine flag indicating its meant for full body */
		private const ENGINE_TYPE_FB		:String = 'FB3D';
		/** CATNAME in the vhost determines if this is meant for morphing as a head */
		private const CATEGORY_BACK			:String = 'back';
		
		public function List_Vhosts()
		{}
		
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
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ****************************** PUBLIC *****************/
		/**
		 * loads and parses an xml creating wsmodelstruct objects 
		 * @param _url							specific url to the php script
		 * @param _callbacks					callbacks fin()    |    progress(int)    |    error(AlertEvent)
		 * @param _incomplete_vhost_callback	incomplete(String)
		 * 
		 */
		public function load(_url:String=null, _callbacks:Callback_Struct=null, _incomplete_vhost_callback:Function = null):void
		{
			callbacks = _callbacks;
			callback_incomplete_vhost = _incomplete_vhost_callback;
			
			if (is_loaded)
				model_loaded();
			else
			{
				var url:String;
				if (_url)
					url = _url;
				else
				{
					switch ( ServerInfo.app_type )
					{
						case ServerInfo.APP_TYPE_Flash_10_FB_3D :	// full body
							url = ServerInfo.acceleratedURL + SUB_URL_FB + ServerInfo.door;
							break;
						default:	// 2d or 3d
							url = ServerInfo.acceleratedURL + SUB_URL + ServerInfo.door;
					}
				}
				
				Gateway.retrieve_XML( url, new Callback_Struct(fin, progress, error), response_eval);
				function response_eval(_xml:XML):Boolean
				{
				/* 2D
				
					<?xml version="1.0" ?>
					<DATA THUMB_BASE_URL="http://content.oddcast.com/" OH_BASE_URL="http://content.oddcast.com/char/" FG_BASE_URL="http://content.oddcast.com/ccs6/customhost/302/3d/">
						<ENGINE ID="63" TYPE="2D" URL="http://content.oddcast.com/char/engines/engineV5.03.27.09.swf" CTL="" VERSION="5"/>
						<MODEL ID="771" NAME="female_punk" THUMB="ccs6/customhost/302/thumbs/1278079396315648.jpg" OH="oh/771/7846/27499/7272/0/7281/314/302/0/0/0/ohv2.swf?cs=3090196:549c9c7:6a4b5e3:6906066:b24e4e6:100:100:100:100:100.01373291015598:0:0:100:0" ENGINE="63" CATID="688" CATNAME="cat1"/>
						<MODEL ID="2413" NAME="test_swfmill_female_assigned_hair" THUMB="ccs6/customhost/302/thumbs/1277826649914490.jpg" OH="oh/2413/1281/36435/33970/0/0/313/302/0/0/10081/ohv2.swf?cs=8e54863:549c9c7:651c1c6:6906066:b24e4e6:100:100:100:100:100.01373291015598:1:0:0:0" ENGINE="63" CATID="688" CATNAME="cat1"/>
					</DATA>
				*/
				
				
				
				
				/* 3D
				
					<?xml version="1.0" ?>
					<DATA THUMB_BASE_URL="http://content.oddcast.com/" OH_BASE_URL="http://content.oddcast.com/char/" FG_BASE_URL="http://content.oddcast.com/ccs6/customhost/239/3d/">
						<ENGINE ID="31" TYPE="3D" URL="http://content.oddcast.com/char/engines/3D/v1/engineE3Dv1.2008.09.09.swf" CTL="http://content.oddcast.com/ccs6/customhost/3dtemp/ctl/si_race.ctl" VERSION="2008.09.09"/>
						<SAMSET ID="23" URL="http://content.oddcast.com/ccs2/mam/a9/d5/a9d59.oa1" CATID="1"/>
						<SAMSET ID="71" URL="http://content.oddcast.com/ccs2/mam/7c/2c/7c2ce.oa1" CATID="1"/>
						<MODEL ID="3725" NAME="-f9_3dTest_startrek_spock" THUMB="ccs6/customhost/239/thumbs/1278456645131452.jpg" ENGINE="31" SAMSET="23" CATID="685" CATNAME="front" CONFIG="" ASET="0">
							<CHARACTER>
								<fgchar>
									<url id="photoface" url="-f9_3dTest_startrek_spock.jpg"/>
									<url id="fgfile" url="-f9_3dTest_startrek_spock.fg"/>
									<url id="alpha" url="-f9_3dTest_startrek_spock.png"/>
								</fgchar>
							</CHARACTER>
						</MODEL>
						<MODEL ID="14005" NAME="monkifier1-2" THUMB="ccs6/customhost/239/thumbs/monkifier_monkey1-2.jpg" ENGINE="31" SAMSET="71" CATID="684" CATNAME="back" CONFIG="" ASET="0">
							<CHARACTER>
								<fgchar>
									<url id="photoface" url="monkifier1-2.jpg"/>
									<url id="fgfile" url="monkifier1-2.fg"/>
									<url id="alpha" url="monkifier1-2.png"/>
								</fgchar>
							</CHARACTER>
						</MODEL>
					</DATA>
				*/
					
				
				
				
				
				/* FULL BODY :: http://host-d.oddcast.com/php/vhss_editors/getModelsFB/doorId=712
					
					<?xml version="1.0" ?>
					<DATA THUMB_BASE_URL="http://content.oddcast.com/" OH_BASE_URL="http://content.oddcast.com/char/" FG_BASE_URL="http://content.oddcast.com/ccs6/customhost/712/3d/">
						<ENGINE ID="31" TYPE="3D" URL="http://content.oddcast.com/char/engines/3D/v1/engineE3Dv1.2008.09.09.swf" CTL="http://content.oddcast.com/ccs6/customhost/3dtemp/ctl/si_race.ctl" VERSION="2008.09.09"/>
						<ENGINE ID="114" TYPE="FB3D" URL="http://content.oddcast.com/char/engines/3D/fb3d/Oc3dPlugIn.template_2010_06_21.swf" CTL="" VERSION="2010.17.02"/>
						<MODEL ASET="38551" FBENGID="114" SCENE_ID="41135" FBCAT="0"></MODEL>
						<MODEL ASET="41133" FBENGID="114" SCENE_ID="41134" FBCAT="0"></MODEL>
					</DATA>
				*/ 
					return (_xml && 
							_xml.MODEL && 
							_xml.MODEL.length() > 0 &&	// do we have vhosts?
							_xml.ENGINE && 
							_xml.ENGINE.length() > 0	// do we have engines?
					);
				}
				function fin(_content:XML):void
				{
					parse(_content);
					model_loaded();
				}
				function progress(_percent:int):void
				{
					if (callbacks&&callbacks.progress!=null)
						callbacks.progress(_percent);
				}
			}
			
			function model_loaded():void
			{
				is_loaded=true;
				if (callbacks&&callbacks.fin!=null)
					callbacks.fin();
			}
		}
		
		/**
		 * if we have a back vhosts present then we can morph
		 * @return true if there is morphing information
		 */
		public function is_morphing_capable(  ):Boolean
		{
			var back_vhosts:Array = model_back.get_all_items();
			return ( back_vhosts && back_vhosts.length > 0 );
		}
		
		
		/**
		 * find a vhost by its ID
		 * @param	_name	name of the vhost
		 * @return	null if not found
		 */
		public function get_vhost_by_id( _id:int ):WSModelStruct
		{
			var models_back:Array = model_back.get_items_by_property( 'id', _id );
			var models_front:Array = model_front.get_items_by_property( 'id', _id );
			if (models_back && models_back.length > 0)
				return models_back[0];
			if (models_front && models_front.length > 0)
				return models_front[0];
			return null;
		}
		/**
		 * find specific model by oa1 type 
		 * @param _vhost_type
		 * @return 
		 * 
		 */		
		public function get_vhost_by_oa1_type( _vhost_type:int ):WSModelStruct
		{
			var models_front:Array = model_front.get_items_by_property( 'oa1Type', _vhost_type );
			if (models_front && models_front.length > 0)
				return models_front[0];
			var models_back:Array = model_back.get_items_by_property( 'oa1Type', _vhost_type );
			if (models_back && models_back.length > 0)
				return models_back[0];
			return null;
		}
		/**
		 * find list of vhosts by oa1 type 
		 * @param _vhost_type
		 * @return 
		 * 
		 */		
		public function get_vhosts_by_oa1_type( _vhost_type:int ):Array
		{
			var matched_vhosts:Array = new Array();
			var models_back:Array = model_back.get_items_by_property( 'oa1Type', _vhost_type );
			var models_front:Array = model_front.get_items_by_property( 'oa1Type', _vhost_type );
			if (models_back && models_back.length > 0)
				matched_vhosts = matched_vhosts.concat(models_back);
			if (models_front && models_front.length > 0)
				matched_vhosts = matched_vhosts.concat(models_front);
			
			return matched_vhosts;
		}
		/**
		 * add a new vhost to the list 
		 * @param _vhost
		 * @param _notify_list_is_updated dispatch an event that the list is updated notifying handlers
		 * 
		 */		
		public function add_vhost(_vhost:WSModelStruct, _notify_list_is_updated:Boolean = true):void
		{
			is_back_vhost_type(_vhost) ? model_back.add_item(_vhost) : model_front.add_item(_vhost);
			
			if(_notify_list_is_updated)
				list_has_been_updated();
		
			/**
			 * checks if a model is supposed to be only a back model, used for morphing
			 * @param	_model	model to be determined
			 * @return	true if its a back model type
			 */
			function is_back_vhost_type( _vhost:WSModelStruct ):Boolean
			{
				if ( _vhost && _vhost.catName && _vhost.catName.toLowerCase() == CATEGORY_BACK.toLowerCase() )
					return true;
				return false;
			}
		}
		/**
		 * retrieve the default vhost of the application, EG: the first vhost to be loaded 
		 * @return 
		 * 
		 */		
		public function get_default_vhost():WSModelStruct
		{
			var all_vhosts:Array = model_front.get_all_items();
			if (all_vhosts && all_vhosts[0])
				return all_vhosts[0];
			return null;
		}
		/***************************************
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
		/**
		 * the list of models has been updated, dispatch an event to notify all handlers 
		 * 
		 */		
		private function list_has_been_updated():void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		private function error(_msg:String):void
		{
			if (callbacks&&callbacks.error!=null)
				callbacks.error(new AlertEvent(AlertEvent.ERROR,ERROR_LOADING_CODE,ERROR_LOADING_MSG));
		}
		private function incomplete_vhost( _msg:String ):void
		{
			if (callback_incomplete_vhost != null)
				callback_incomplete_vhost( _msg );
		}
		private function parse( _xml:XML ):void
		{
			// parse engines
			var engines_by_id:Dictionary = parse_engines( _xml.ENGINE );
			// parse samsets
			var samset_by_id:Dictionary = parse_samset( _xml.SAMSET );
			// parse models
			var vhosts:Array;
			var thumb_base_url:String = _xml.@THUMB_BASE_URL;
			var oh_base_url	:String = _xml.@OH_BASE_URL;
			var fg_base_url	:String = _xml.@FG_BASE_URL;
			switch ( ServerInfo.app_type )
			{
				case ServerInfo.APP_TYPE_Flash_9_2D :
					vhosts = parse_2d_vhosts( engines_by_id, _xml.MODEL, thumb_base_url, oh_base_url );
					break;
				case ServerInfo.APP_TYPE_Flash_9_3D :
					vhosts = parse_3d_vhosts( engines_by_id, samset_by_id, _xml.MODEL, thumb_base_url, fg_base_url );
					break;
				case ServerInfo.APP_TYPE_Flash_10_FB_3D :
					vhosts = parse_FB_vhosts( engines_by_id, samset_by_id, _xml.MODEL, thumb_base_url );
					break;
				default:
					error('unknown vhost type xml'); 
			}
			// add models to their respective model structs
			MODELS_LOOP: for (var i:int = 0, n:int = vhosts.length; i<n; i++ )
			{
				var vhost:WSModelStruct = vhosts[ i ];
				add_vhost(vhost);
				// break MODELS_LOOP;
			}
		}
		/**
		 * parse samsets 
		 * @param _xml
		 * @return 
		 * 
		 */		
		private function parse_samset(_xml:XMLList):Dictionary
		{
			var samset_urls_by_id:Dictionary = new Dictionary();
			var item:XML, id:String, url:String, cat_id:String;
			SAMSET_LOOP: for (var i:int = 0, n:int = _xml.length(); i<n; i++ )
			{
				item = _xml[ i ];
				id = item.@ID;
				url = item.@URL;
				cat_id = item.@CATID;
				samset_urls_by_id[id] = {url:url, id:id, cat_id:cat_id};
				// break SAMSET_LOOP;
			}
			return samset_urls_by_id;
		}
		/**
		 * parse vhost engines 
		 * @param _xml
		 * @return 
		 * 
		 */		
		private function parse_engines(_xml:XMLList):Dictionary
		{
			var engines_by_id:Dictionary = new Dictionary();
			
			var item:XML, id:int, type:String, url:String, engine:EngineStruct;
			
			ENGINE_LOOP: for (var i:int = 0, n:int = _xml.length(); i<n; i++ )
			{
				item 	= _xml[ i ];
				id 		= parseInt(item.@ID.toString());
				type	= item.@TYPE.toString();
				url		= item.@URL.toString();
				engine 	= new EngineStruct(url, id, type);
				
				if (item.@CTL != undefined) 
					engine.ctlUrl = item.@CTL.toString();
				
				if (item.@VERSION != undefined)
					engine.version = item.@VERSION.toString();
				
				engines_by_id[id] = engine;
				// break ENGINE_LOOP;
			}
			return engines_by_id;
		}
		/**
		 * parse 2d vhost types 
		 * @param _engines_by_id
		 * @param _xml
		 * @param _thumb_stem_url
		 * @param _oh_stem_url
		 * @return 
		 * 
		 */		
		private function parse_2d_vhosts(_engines_by_id:Dictionary, _xml:XMLList, _thumb_stem_url:String, _oh_stem_url:String):Array 
		{
			var vhosts:Array = new Array();
			
			var item:XML, vhost:WSModelStruct, url:String;
			
			for (var i:int = 0, n:int = _xml.length(); i<n; i++ )
			{
				item = _xml[i];
				vhost = build_basic_vhost_from_xml( item, _engines_by_id, _thumb_stem_url );
				url 	= item.@OH.toString();
				if (url.slice(0, 7) != "http://") 
					url = _oh_stem_url + url;
				vhost.url = url;
				vhost.is3d 	= false;
				vhosts.push(vhost);
			}
			return vhosts;
		}
		/**
		 * parse 3d vhost types 
		 * @param _engines_by_id
		 * @param _samset_by_id
		 * @param _xml
		 * @param _thumb_stem_url
		 * @param _fg_stem_url
		 * @return 
		 * 
		 */		
		private function parse_3d_vhosts(_engines_by_id:Dictionary, _samset_by_id:Dictionary, _xml:XMLList, _thumb_stem_url:String, _fg_stem_url:String):Array 
		{
			var vhosts:Array = new Array();
			
			var item:XML, vhost:WSModelStruct, element_url:XMLList, char_xml:XML, samset_id:String, url:String;
			
			for (var i:int = 0, n:int = _xml.length(); i<n; i++ )
			{
				item = _xml[i];
				if (item.hasOwnProperty("CHARACTER") && item.CHARACTER[0].hasOwnProperty("fgchar")) 
				{
					char_xml = item.CHARACTER[0].fgchar[0];
					
					//add base url to urls in char xml
					element_url 	= char_xml.elements("url");
					for (var j:int = 0; j < element_url.length(); j++) 
						element_url[j].@url = _fg_stem_url + element_url[j].@url;
				}
				else char_xml = null;
				
				samset_id		= item.@SAMSET;
				url 			= _samset_by_id[samset_id].url;//_xml.SAMSET.(@ID == item.@SAMSET).@URL.toString();
				vhost 			= build_basic_vhost_from_xml(item, _engines_by_id, _thumb_stem_url);//new WSModelStruct(modelUrl, modelId, thumbUrl, modelName);
				vhost.url		= url;
				vhost.charXml 	= char_xml;
				vhost.is3d 		= true;
				vhost.oa1Type 	= _samset_by_id[samset_id].cat_id;//parseInt(_xml.SAMSET.(@ID == item.@SAMSET).@CATID.toString());
				
				if (is_vhost_complete( vhost ))
					vhosts.push(vhost);
			}
			return vhosts;
		}
		private function parse_FB_vhosts(_engines_by_id:Dictionary,_samset_by_id:Dictionary, _xml:XMLList, _thumb_stem_url:String):Array 
		{
			var vhosts:Array = new Array();
			// todo finish parsing full body vhosts
			return vhosts;
		}
		/**
		 * create a vhost struct with basic information which will later be added params based on type 
		 * @param item
		 * @param _engines_by_id
		 * @param _thumb_stem_url
		 * @return 
		 * 
		 */		
		private function build_basic_vhost_from_xml(item:XML, _engines_by_id:Dictionary, _thumb_stem_url:String):WSModelStruct
		{
			var vhost:WSModelStruct, name:String, type:String, thumb_url:String, id:int, engine_id:int;
			
			thumb_url 	= item.@THUMB.toString();
			if (thumb_url == "") 
				thumb_url = null;
			if (thumb_url != null && thumb_url.indexOf("http://") != 0) 
				thumb_url = _thumb_stem_url + thumb_url;
			name 		= item.@NAME.toString();
			id 			= parseInt(item.@ID.toString());
			engine_id 	= parseInt(item.@ENGINE.toString());
			type		= (_engines_by_id[engine_id] as EngineStruct).type;	//	_xml.ENGINE.(@ID == item.@ENGINE).@TYPE.toString();
			vhost		= new WSModelStruct(null, id, thumb_url, name);
			vhost.engine = _engines_by_id[engine_id];
			if (item.@CATID.toString().length > 0) 
				vhost.catId = parseInt(item.@CATID.toString());
			vhost.catName 	= item.@CATNAME;
			return vhost;
		}
		/**
		 * checks if a vhost has the necessary parameters to be loaded
		 * @NOTE this also alerts on an incomplete model 
		 * @param _vhost
		 * @return 
		 * 
		 */		
		private function is_vhost_complete( _vhost:WSModelStruct ) : Boolean
		{
			if (_vhost.has_head_data())	// 3d only
			{
				if (!_vhost.url || _vhost.url.toLowerCase().indexOf('://') < 1)	
				{
					incomplete_vhost('missing SAMSET for model: ' + _vhost.id + ' - ' + _vhost.name);
					return false;
				}
				if (!_vhost.charXml || !_vhost.charXml.hasOwnProperty('url'))
				{
					incomplete_vhost('missing CHARACTER XML for model: ' + _vhost.id + ' - ' + _vhost.name);
					return false
				}
			}
			if (_vhost.has_body_data())	// full body
			{
				if (!_vhost.full_body_struct.acc_set_id || _vhost.full_body_struct.acc_set_id <= 0)
				{
					incomplete_vhost('missing ACCESSORY SET for model: ' + _vhost.id + ' - ' + _vhost.name);
					return false;
				}
			}
			return true;
		}
	}
}
package code.models.items
{
	import code.models.*;
	
	import com.adobe.fileformats.vcard.Address;
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.oc3d.shared.CompositeMode;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.workshop.*;
	
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	
	public class List_Vhost_Accessories
	{
		public var model:Model_Item = new Model_Item();
		
		/** dictionary of accessory models by vhost model ID, so models[1234]=model of accessories */
		private var models_by_id			: Dictionary = new Dictionary();
		/** array of available type ids */
		private var arr_type_ids			: Array;
		/** array of available type names */
		private var arr_type_names			: Array;
		/** parses the xml */
		private var acc_xml_parser			: Accessory_XML_Parser = new Accessory_XML_Parser();
		
		private const ERROR_LOADING_CODE:String='f9t300';
		private const ERROR_LOADING_MSG:String='Error loading accessories list';
		private const SUB_URL:String='php/vhss_editors/getAccessories/doorId=';
		
		public function List_Vhost_Accessories()
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
		 *	loads the current accessories list for the specified model ID, every model has a different list of accessories 
		 * @param _vhost_id	vhost id
		 * @param _url specific url for the accessories xml, if null default is used
		 * @param _callbacks callbacks fin(), progress(int), error(AlertEvent)
		 * 
		 */		
		public function load(_vhost_id:Number, _url:String=null, _callbacks:Callback_Struct=null):void
		{
			if (is_loaded(_vhost_id))
			{	
				retrieve_from_cache( _vhost_id );
				model_loaded();
			}
			else
			{
				var url:String = _url ? _url : ServerInfo.acceleratedURL + SUB_URL + ServerInfo.door + "/modelId=" + _vhost_id.toString();
				
				Gateway.retrieve_XML( url, new Callback_Struct(fin, progress, error), response_eval);
				function response_eval(_xml:XML):Boolean
				{
				/* 2D
					
					<ACCESSORIES COUNT="0" BASE_URL="http://content-vd.oddcast.com/prod/ccs2/mam/">
						<ITEM ID="7271" NAME="female_punk_hair_1" CATID="5" CATEGORY="Default" COMPAT="0" COMPATID="0" THUMB="09/91/accessory_thumnail_7271.jpg" IS3D="0" TYPE="3" TYPENAME="Hair" TYPEGROUP="" ZORDER="">
							<FRAGMENT TYPE="Left" FILENAME="e8/82/f9_fragment_ac7271_fr1.swf"/>
							<FRAGMENT TYPE="Right" FILENAME="fa/7b/f9_fragment_ac7271_fr2.swf"/>
							<FRAGMENT TYPE="Back" FILENAME="0f/aa/f9_fragment_ac7271_fr3.swf"/>
						</ITEM>
					...
					</ACCESSORIES>
					
				*/
					
				/* 3D
					
					<ACCESSORIES COUNT="0" BASE_URL="http://content-vd.oddcast.com/prod/ccs2/mam/">
						<ASSETTBASE ID="40" FILENAME="e1/86/a_40.oa1"/>
						<ITEM ID="55163" NAME="Glasses000_01" CATID="5" CATEGORY="Default" COMPAT="0" COMPATID="0" THUMB="ef/17/accessory_thumnail_55163.jpg" IS3D="1" TYPE="4" TYPENAME="Glasses" TYPEGROUP="Glasses" ZORDER="0">
							<FRAGMENT TYPE="MAIN" ID="1">
								<ASSET ID="40" TYPE="Base" VALUE="40" TYPEID="2"/>
								<ASSET ID="45" TYPE="BMP" VALUE="e1/bb/a_45.oa1" TYPEID="1"/>
							</FRAGMENT>
						</ITEM>
					...
					</ACCESSORIES>
					
				*/
					return (_xml && _xml.ITEM && _xml.ITEM.length() > 0);
				}
				function fin(_content:XML):void
				{
					// need new objects
					model = new Model_Item();
					arr_type_ids = new Array();
					arr_type_names = new Array();
					
					parse(_content);
					
					// save the current data
					save_to_cache( _vhost_id, model, arr_type_ids, arr_type_names );
					model_loaded();
				}
				function progress(_percent:int):void
				{
					if (_callbacks&&_callbacks.progress!=null)
						_callbacks.progress(_percent);
				}
				function error(_msg:String):void
				{
					if (_callbacks&&_callbacks.error!=null)
						_callbacks.error(new AlertEvent(AlertEvent.ERROR,ERROR_LOADING_CODE,ERROR_LOADING_MSG));
				}
			}
			
			function model_loaded():void
			{
				if (_callbacks&&_callbacks.fin!=null)
					_callbacks.fin();
			}
		}
		/**
		 * returns the accessory type name, such as glasses or hair for a type id 
		 * @param _type_id	accessory type id
		 * @return 
		 * 
		 */		
		public function get_type_name( _type_id:int ) : String
		{
			var accs:Array = model.get_items_by_property('typeId',_type_id);
			var acc:AccessoryData;
			if (accs && accs[0])
			{
				acc = accs[0];
				return acc.type_name;
			}
			return null;	// return nothing as its not found
		}
		/**
		 *	returns the available type ids for the currently loaded accessories 
		 * @return 
		 * 
		 */		
		public function get_available_type_ids(  ) : Array
		{
			return arr_type_ids;
		}
		/**
		 *	 returns the available type names for the currently loaded accessories 
		 * @return 
		 * 
		 */		
		public function get_available_type_names(  ) : Array
		{
			return arr_type_names;
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
		 * checks if the accessories for this model ID have been loaded already 
		 * @param _vhost_id
		 * 
		 */		
		private function is_loaded( _vhost_id:Number ):Boolean
		{
			return (models_by_id[_vhost_id] != null);
		}
		private function parse( _xml:XML ):void
		{
			var all_acc:Array = acc_xml_parser.parse_xml( _xml );
			var acc:AccessoryData;
			
			loop1: for (var i:int = 0, n:int = all_acc.length; i<n; i++ )
			{
				acc = all_acc[ i ];
				add_type_id( acc.typeId );
				add_type_name( acc.type_name );
				model.add_item( acc );
				// break loop1;
			}
		}
		private function add_type_id( _type_id:int ) : void
		{
			if (arr_type_ids.indexOf(_type_id) == -1)
				arr_type_ids.push(_type_id);
		}
		private function add_type_name( _type_name:String ) : void
		{
			if (arr_type_names.indexOf(_type_name) == -1)
				arr_type_names.push(_type_name);
		}
		private function save_to_cache( _vhost_id:Number, _model:Model_Item, _acc_types:Array, _acc_type_names:Array ) : void
		{
			models_by_id[ _vhost_id ] = new Acc_Model( _model, _acc_types, _acc_type_names );
		}
		private function retrieve_from_cache( _vhost_id:Number ):void
		{
			var acc_model:Acc_Model = models_by_id[_vhost_id];
			model = acc_model.model;
			arr_type_ids = acc_model.acc_types;
			arr_type_names = acc_model.acc_type_names;
		}
		
	}
}










import code.models.Model_Item;
class Acc_Model
{
	public var model			: Model_Item;
	public var acc_types		: Array;
	public var acc_type_names	: Array;

	public function Acc_Model ( _model : Model_Item, _acc_types : Array, _acc_type_names : Array )
	{
		model = _model;
		acc_types = _acc_types;
		acc_type_names = _acc_type_names;
	}
}
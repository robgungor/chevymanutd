package code.models
{
	import flash.utils.Dictionary;

	public class Model_Item
	{
		/** dictionary of arrays by property... 
		 * example... {label:'SomeName'}... dic['label']='SomeName';
		 */
		private var dic_item_by_properties:Dictionary=new Dictionary();
		/** all items added to the model */
		private var arr_all_items:Array=new Array();
		private const KEY_DELIMITER:String = '===';
		
		public function Model_Item()
		{}
		public function get_all_items():Array
		{
			return arr_all_items;
		}
		public function get_items_by_property(_prop:String,_value:*):Array
		{
			var key:String=_prop+KEY_DELIMITER+_value;
			return dic_item_by_properties[key];
		}
		/**
		 * adds items to dictionary and array 
		 * @param _item object to be used
		 * @param _index_properties array of strings which are properties of the _item that should be indexable, NULL will index ALL properties
		 * 
		 */		
		public function add_item(_item:Object,_index_properties:Array=null):void
		{
			arr_all_items.push(_item);
			var prop_name:String, prop_type:String, prop_value:*;
			if (_index_properties) // index specified properties
			{
				for (var i:int=0, n:int=_index_properties.length; i<n; ++i)
				{
					prop_name=_index_properties[i];
					prop_value=_item[prop_name];
					add_item_to_property_key(dic_item_by_properties,prop_name, prop_value,_item);
				}
			}
			else // index all properties
			{
				var propList:XML=flash.utils.describeType(_item);
				for each (var xml_node:XML in propList.children())
				{
					prop_name=xml_node.@name;
					prop_type=xml_node.@type;
					if (prop_is_indexable(prop_type))
					{
						prop_value=_item[prop_name];
						add_item_to_property_key(dic_item_by_properties,prop_name, prop_value,_item);
					}
				}
			}
			function prop_is_indexable(_type:String):Boolean
			{
				if 
					(
						_type=='String'||
						_type=='int'||
						_type=='uint'||
						_type=='Number'||
						_type=='Boolean'
					)
					return true;
				return false;
			}
			function add_item_to_property_key(_dic:Dictionary,_prop:String,_value:*,_item:Object):void
			{
				var key:String=_prop+KEY_DELIMITER+_value;
				if (_dic[key]==null)
					_dic[key]=new Array();
				(_dic[key] as Array).push(_item);
			}
		}
	}
}
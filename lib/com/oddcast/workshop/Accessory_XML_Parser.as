package com.oddcast.workshop
{
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.vhost.accessories.AccessoryData3D;
	import com.oddcast.vhost.accessories.AccessoryFragment;

	public class Accessory_XML_Parser
	{
		public function Accessory_XML_Parser()
		{
		}
		/**
		 * parses an xml into an array of accessory objects 
		 * @param _xml
		 * @return 
		 * 
		 */		
		public function parse_xml( _xml:XML ) : Array
		{
			if (ServerInfo.is3D)
				return parse_3d_types(_xml);
			else
				return parse_2d_types(_xml);
			return null;
		}
		private function parse_3d_types( _xml:XML ):Array
		{
			var all_acc:Array = new Array();
			var acc:AccessoryData3D, acc_node:XML;
			var id:int, type:int, thumb:String, name:String, compatibility:int, type_name:String, type_group_name:String, z_order:Number;
			var fragment_node:XML, frag_assets:XMLList, frag_url:String, frag_base_url:String, frag_id:int, frag_type:String;
			var stem_url:String = _xml.@BASE_URL;
			LOOP_ITEMS: for (var i:int = 0, n:int = _xml.ITEM.length(); i<n; i++ )
			{
				acc_node 		= _xml.ITEM[ i ];
				id				= parseInt(acc_node.@ID.toString());
				type			= parseInt(acc_node.@TYPE.toString());
				thumb			= stem_url + acc_node.@THUMB.toString();
				name			= acc_node.@NAME.toString();
				compatibility	= parseInt(acc_node.@COMPATID.toString());
				type_name		= acc_node.@TYPENAME.toString();
				type_group_name	= acc_node.@TYPEGROUP.toString();
				z_order			= parseFloat(acc_node.@ZORDER.toString());
				
				acc = new AccessoryData3D(id, name, type, thumb, compatibility);
				acc.accGroupName = type_group_name;
				acc.zOrder 		= z_order;
				acc.type_name	= type_name;
				
				LOOP_FRAGMENTS: for (var ii:int = 0, nn:int = acc_node.FRAGMENT.length(); ii<nn; ii++ )
				{
					fragment_node = acc_node.FRAGMENT[ ii ];
					frag_assets = fragment_node.ASSET.(@TYPE == "BMP");
					if (frag_assets.length() == 0)
						frag_url=null;
					else 
						frag_url = stem_url + frag_assets[0].@VALUE.toString();
					
					frag_assets = fragment_node.ASSET.(@TYPE == "Base");
					if (frag_assets.length() == 0)
						frag_base_url = null;
					else 
						frag_base_url = stem_url + _xml.ASSETTBASE.(@ID == frag_assets[0].@VALUE).@FILENAME.toString();
					
					frag_id 	= parseInt(fragment_node.@ID.toString());
					frag_type 	= fragment_node.@TYPE.toString();
					
					acc.addFragment3d(new AccessoryFragment(frag_type, frag_url, frag_id, frag_base_url));
					// break LOOP_FRAGMENTS;
				}
				
				all_acc.push( acc );
				// break LOOP_ITEMS;
			}
			return all_acc;
		}
		private function parse_2d_types( _xml:XML ) : Array
		{
			var all_acc:Array = new Array();
			var acc:AccessoryData, acc_node:XML;
			var stem_url:String = _xml.@BASE_URL;
			var id:int, type:int, thumb:String, name:String, compatibility:int, type_name:String;
			var fragment_node:XML, frag_type:String, frag_url:String;
			LOOP_ITEMS: for (var i:int = 0, n:int = _xml.ITEM.length(); i<n; i++ )
			{
				acc_node		 = _xml.ITEM[ i ];
				id 				= parseInt(acc_node.@ID.toString());
				type 			= parseInt(acc_node.@TYPE.toString());
				thumb 			= stem_url + acc_node.@THUMB.toString();
				name 			= acc_node.@NAME.toString();
				compatibility 	= parseInt(acc_node.@COMPATID.toString());
				type_name 		= acc_node.@TYPENAME.toString();
				
				acc = new AccessoryData(id, name, type, thumb, compatibility );
				acc.type_name 	= type_name;
				
				LOOP_FRAGMENTS: for (var ii:int = 0, nn:int = acc_node.FRAGMENT.length(); ii<nn; ii++ )
				{
					fragment_node 	= acc_node.FRAGMENT[ ii ];
					frag_type		= fragment_node.@TYPE;
					frag_url 		= fragment_node.@FILENAME;
					frag_url 		= frag_url.split("/fragment").join("/f9_fragment");
					if (frag_url.indexOf("http://") == -1) 
						frag_url 	= stem_url + frag_url;
					acc.addFragment(frag_type,frag_url);
					// break LOOP_FRAGMENTS;
				}
				
				all_acc.push( acc );
				// break LOOP_ITEMS;
			}
			return all_acc;
		}
	}
}
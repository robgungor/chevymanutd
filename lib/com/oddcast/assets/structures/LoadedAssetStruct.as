/**
* ...
* @author David Segal
* @version 0.1
* @date 12.03.2007
* 
*/

package com.oddcast.assets.structures
{
	import flash.display.DisplayObject;
	import flash.display.Loader;

	public class LoadedAssetStruct
	{
		public var id:int;
		public var url:String;
		public var type:String;
		public var loader:Loader; // deprecated parameter
		public var display_obj:DisplayObject;
		public var name:String;
		public var catId:int;
		public var catName:String;
		
		public function LoadedAssetStruct($url:String = null, $id:int = 0, $type:String = null)
		{
			id = $id;
			url = $url;
			type = $type;
		}
		
		public function destroy():void
		{
			display_obj = null;
			loader = null;
		}
	}
	
}
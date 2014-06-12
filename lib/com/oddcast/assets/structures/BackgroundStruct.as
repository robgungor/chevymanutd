/**
* ...
* @author Dave Segal
* @version 0.1
* @Date 11.28.2007
*/

package com.oddcast.assets.structures {
	

	public class BackgroundStruct extends LoadedAssetStruct
	{
		//public var bg_type:String;
		public var is_looping:Boolean = false;
		
		public function BackgroundStruct($url:String = null, $id:int = 0, $type:String = "bg")
		{
			super($url, $id, $type);
			//bg_type = $bg_type;
		}
		//public var visible:Boolean;
	}
	
}
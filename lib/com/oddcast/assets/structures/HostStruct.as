/**
* ...
* @author David Segal
* @version 0.1
* 
*/

package com.oddcast.assets.structures
{
	import flash.display.MovieClip;

	public class HostStruct extends LoadedAssetStruct
	{
		public static const HOST_2D:String = "host_2d";
		public static const HOST_3D:String = "host_3d";
		public static const HOST_FB_3D:String = "host_fb3d";
		
		public var model_ptr:MovieClip;
		public var host_container:MovieClip;
		public var cs:String;
		public var engine:EngineStruct = new EngineStruct();
		
		public function HostStruct($url:String = null, $id:uint = 0, $type:String = HOST_2D)
		{
			super($url, $id, $type);
		}
	}
	
}
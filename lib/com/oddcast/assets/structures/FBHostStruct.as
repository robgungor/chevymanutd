package com.oddcast.assets.structures
{
	public class FBHostStruct extends HostStruct
	{
		public var fb3d_scene_id:int;
		
		public function FBHostStruct($url:String=null, $id:uint=0, $fb_scene_id:int=0, $type:String=HOST_FB_3D)
		{
			fb3d_scene_id = $fb_scene_id;
			super($url, $id, $type);
		}
		
	}
}
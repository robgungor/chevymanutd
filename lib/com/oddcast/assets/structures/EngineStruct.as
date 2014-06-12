/**
* ...
* @author Dave Segal
* @version 0.1
* @Date 03.11.08
* 
*/

package com.oddcast.assets.structures 
{
	
	public class EngineStruct extends LoadedAssetStruct
	{
		
		public static const ENGINE_2D:String = "2d";
		public static const ENGINE_3D:String = "3d";
		public static const ENGINE_FB:String = 'FB';
		
		public var ctlUrl:String; //url of control file
		/* engine version (eg: 2010.17.02) */
		public var version:String;
		
		public function EngineStruct($url:String = null, $id:uint = 0, $type:String = "2d")
		{
			super($url, $id, $type);
		}
		
		//public var visible:Boolean;
		
	}
}
package com.oddcast.workshop 
{
	import com.oddcast.assets.structures.*;
	import flash.utils.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class WS_Body_Struct
	{
		/* byte array to be uploaded */
		public var byte_array		:ByteArray;
		/* url of the file representing the byte_array of this avatar 
		 * (eg: http://content.dev.oddcast.com/char/oh/36895/m/36842/d/34402/v/1.0/oh.avt?36867=0000FF ) */
		public var avatar_url		:String;
		/* full body engine associated with this character */
		public var engine			:EngineStruct;
		/* full body accessory set id -- which body to load */
		public var acc_set_id		:int;
		/* full body scene ID meant for asset identification on playback */
		public var scene_id			:String;
		/* ok.. ill do my best here to explain.. an acc set id can be human, that has male and female properties, this category id distinguishes if we want to work only with the male or female
		 * 0 will provide both male and female for eg */
		public var category_id		:int	= 0;
		
		public function WS_Body_Struct(  ) 
		{	
		}
		
	}

}
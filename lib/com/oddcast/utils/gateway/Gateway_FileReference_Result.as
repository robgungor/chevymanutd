package com.oddcast.utils.gateway
{
	public class Gateway_FileReference_Result
	{
		public var full_url:String;
		public var thumb_url:String;
		
		public function Gateway_FileReference_Result( _full_url:String, _thumb_url:String )
		{
			full_url = _full_url;
			thumb_url = _thumb_url;
		}
	}
}
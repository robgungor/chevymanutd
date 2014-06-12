package com.oddcast.io.archiver
{
	public class OA1FileDesc
	{
		public var isString:Boolean;
		public var data:*;
		public var name:String;
		public var compress:Boolean;
		
		public function OA1FileDesc($name:String, $data:*, $isString:Boolean = true, $compress:Boolean = true)
		{
			name = $name;
			data = $data;
			isString = $isString;
			compress = $compress;
		}

	}
}
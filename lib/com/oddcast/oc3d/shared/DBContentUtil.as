package com.oddcast.oc3d.shared
{
	public class DBContentUtil
	{
		public function DBContentUtil()
		{
		}
		
		public static function stripUrlDoubleSlashes(s:String):String
		{
			var httpStr:String = "http://";
			var sNoHttp:String;
			var needHttp:Boolean;
			if (s.indexOf(httpStr)>=0)
			{
				sNoHttp = s.split(httpStr)[1];
				needHttp = true;
			}
			else
			{
				sNoHttp = s;
			}	
			var regex:RegExp = /\/\//g;
			return (needHttp?httpStr:'')+sNoHttp.replace(regex,"/");	
		}

	}
}
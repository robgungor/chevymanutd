/**
* ...
* @author Dave Segal
* @version 0.1
* date 11/02/07
*
*/

package com.oddcast.utils {
	public class UTF8Encoder {
		
		public static function encode(str:String):String
		{
			var t_str:String = new String();
			for (var i:Number = 0; i < str.length; ++i)
			{
				var c:Number = str.charCodeAt(i);
				//trace("encode  ::  "+c);
				if (c < 128) 
				{
					t_str += String.fromCharCode(c);
				}
				else if((c > 127) && (c < 2048)) 
				{
					t_str += String.fromCharCode((c >> 6) | 192);
					t_str += String.fromCharCode((c & 63) | 128);
				}
				else 
				{
					t_str += String.fromCharCode((c >> 12) | 224);
					t_str += String.fromCharCode(((c >> 6) & 63) | 128);
					t_str += String.fromCharCode((c & 63) | 128);
				}
			}
			return t_str;
		}
		
		/*
		public static function utf8unescape(str:String):String	{		
			var bytes:Array=new Array();
			var i=0;
			while (i<str.length) {
				if (str[i]=="%") {
					bytes.push(parseInt(str.substr(i+1,2),16))
					i+=3;
				}
				else {
					bytes.push(str.charCodeAt(i))
					i++;
				}
			}
			var t_str:String=new String();
			i=0;
			var c:Number
			while (i<bytes.length) {
				if ((bytes[i]>>7)==0) {
					c=bytes[i];
					t_str+=String.fromCharCode(c);
					i++;
				}
				else if (bytes[i]>>5==6) {
					c=((bytes[i]&0x1F)<<6)+(bytes[i+1]&0x3F)
					t_str+=String.fromCharCode(c);
					i+=2;
				}
				else if (bytes[i]>>5==7) {
					c=((bytes[i]&0x0F)<<12)+((bytes[i+1]&0x3F)<<6)+(bytes[i+2]&0x3F)
					t_str+=String.fromCharCode(c);
					i+=3;
				}
			}
			return(t_str);
		}
		
		public static function utf8escape(str:String):String {
			var t_str:String = new String();
			for (var i:Number = 0; i < str.length; ++i)
			{
				var c:Number = str.charCodeAt(i);
				//trace("encode  ::  "+c);
				if (c < 128) 
				{
					t_str += escape(str.charAt(i));
				}
				else if((c > 127) && (c < 2048)) 
				{
					t_str += "%"+((c >> 6) | 192).toString(16);
					t_str += "%"+((c & 63) | 128).toString(16);
				}
				else 
				{
					t_str += "%"+((c >> 12) | 224).toString(16);
					t_str += "%"+(((c >> 6) & 63) | 128).toString(16);
					t_str += "%"+((c & 63) | 128).toString(16);
				}
			}
			trace("UTF8 escape rtn: "+newline+t_str+newline+escape(str));
			return t_str;
		}
		*/
	}
}
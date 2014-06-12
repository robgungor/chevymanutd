/*
* 
* CachedTTS
* Created: 02/01/2007
* By David Segal
* 
* 
* Description - class that returns the cached tts url 
* 
* Events -
* 
* 
* Modified - 
* 
* 
*/

package com.oddcast.audio {
	//import com.adobe.crypto.MD5;
	import com.oddcast.encryption.md5;
	import com.oddcast.utils.UTF8Encoder;

	public class CachedTTS{
		
		private static var request_domain:String;
		private static var server_folder:String = "/c_fs";
		
		public static function setDomain(in_str:String):void{
			if (in_str.lastIndexOf("/") == in_str.length-1) in_str = in_str.substr(0, in_str.length-1);
			request_domain = in_str;
		}
		
		public static function setServerFolder(in_str:String):void{
			if (in_str.indexOf("/") != 0) in_str = "/"+in_str;
			server_folder = in_str;
		}
		
		public static function getTTSURL(in_txt:String, in_voice:int, in_lang:int, in_engine:int, in_fx_type:String="", in_fx_level:Number=Number.NaN):String{
			if (in_txt==null||in_voice==0 || in_lang == 0 || in_engine == 0) throw new Error("Invalid TTS parameters");
			var tags:String="<engineID>"+in_engine+"</engineID><voiceID>"+in_voice+"</voiceID><langID>"+in_lang+"</langID>";
			if (in_fx_type!="" && !isNaN(in_fx_level) && in_fx_level != 0) tags+="<FX>"+in_fx_type.toLowerCase()+in_fx_level+"</FX>";
			tags += "<ext>mp3</ext>";
			
			//I switched from using com.adobe.crypto.MD5 because it wasn't hashing asian characters correctly
			//resulting in asian TTS being broken.
			//-sam
			var m:md5 = new md5();
			//var t_str:String = MD5.hash(tags + UTF8Encoder.encode(in_txt));
			var t_str:String = m.hash(tags + UTF8Encoder.encode(in_txt));
			
			var url:String=request_domain+server_folder+"/"+t_str+".mp3?engine="+in_engine+"&language="+in_lang+"&voice="+in_voice+"&text="+as2Encode(in_txt)+"&useUTF8=1";
			if (in_fx_type!="" && !isNaN(in_fx_level) && in_fx_level != 0) url+="&fx_type="+escape(in_fx_type.toLowerCase())+"&fx_level="+in_fx_level;
			//trace("cachedTTS url = "+url+" md5 = "+tags+in_txt)
			return url;
		}
		
		private static function as2Encode(s:String):String {
			//the escape function works differently in as2 than as3.  This mimics the way it would be encoded
			//if you do escape(s) in as2
			
			var ss:String = encodeURIComponent(s);
			ss=ss.split("-").join("%2D");
			ss=ss.split("_").join("%5F");
			ss = ss.split(".").join("%2E");
			
			return(ss);
		}
	}
}
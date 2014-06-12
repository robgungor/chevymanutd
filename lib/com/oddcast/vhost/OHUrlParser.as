/**
* ...
* @author Dave Segal
* @version 2.0
* 
* OHUrlParser
* - parses the optimized host url string.
* 
* key:
* 	oh/modelId/costumeId/mouthId/hairId/fhairId/hatId/necklaceId/glassesId/bottomId/shoesId/oh.swf?cs=eyesRGB:hairRGB:mouthRGB:skinRGB:make-upRGB:hyscale:hxscale:mscale:nscale:bscale:age:blush:make-up
* 	
* sample:
* 	http://char.dev.oddcast.com/oh/335/416/522/361/0/860/969/306/0/0/oh.swf?cs=ff00287:ff00280:ff12287:ff00286:ff12FF0:101:101:101:101:60:1:100:100 
* 
* 
* Created: 12/22/2006
* By: David Segal
* 
* Modified:
* 
* Adapted from the AS2 original by Sam Dec 11 2007
*/


package com.oddcast.vhost {

	public class OHUrlParser {

		private static const oh_array:Array = new Array(
			"model",
			"costume",
			"mouth",
			"hair",
			"fhair",
			"hat",
			"necklace",
			"glasses",
			"bottom",
			"shoes",
			"props"
		);
	
	
		/*
		* returns an object that contains the id for each accessory item based on the
		* optimized host url
		*/
		public static function getOHObject(in_str:String):Object{			
			var s:String = in_str.substr(in_str.indexOf("oh/")+3); //get string starting with modelId
			s = s.substr(0,s.indexOf("oh.swf"));					
			var t_ar:Array = s.split("/");
			var t_obj:Object =new Object();			
			for (var i:int = 0; i<oh_array.length; ++i){			
				t_obj[oh_array[i]] = isNaN(parseFloat(t_ar[i]))?0:t_ar[i];
			}			
			t_obj["cs"] = in_str.substr(in_str.indexOf("=")+1);			
			/*
			trace("OHURLParse::getOHObject returning:");
			for (var j in t_obj)
			{
				trace(j+"-->"+t_obj[j]);
			}
			*/
			return t_obj;
		}
		
		/*
		* returns a the portion of the optimized host url that defines the host accessory parts
		* ie - 335/416/522/361/0/860/969/306/0/0/0
		*/
		public static function getOHString(in_obj:Object,excludeTypeName:String=""):String{
			var t_str:String = new String();
			for (var i:int = 0; i<oh_array.length; ++i){
				if(oh_array[i] == excludeTypeName) {
					in_obj[oh_array[i]] = 0;
				}
				t_str+= (in_obj[oh_array[i]] != undefined) ? in_obj[oh_array[i]]+"/" : "0/";			
			}
			return t_str;
		}
		
		public static function getFilteredOHString(in_obj:Object,filterTypeNameArr:Array=null):String{
			var t_str:String = new String();
			for (var i:int = 0; i<oh_array.length; ++i){
				if (filterTypeNameArr is Array)
				{
					if(filterTypeNameArr[oh_array[i]])  {
						in_obj[oh_array[i]] = 0;
					}
				}
				t_str+= (in_obj[oh_array[i]] != undefined) ? in_obj[oh_array[i]]+"/" : "0/";			
			}
			return t_str;
		}
	}
	
}
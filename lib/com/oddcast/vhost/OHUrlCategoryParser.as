/*
* 
* OHUrlCategoryParser
* - parses the optimized host url string for the category array.
* The array contains the categoryId of the model and accessories
* 
* key:
* 	oh/modelId/costumeId/mouthId/hairId/fhairId/hatId/necklaceId/glassesId/bottomId/shoesId/propsId/oh.swf?cs=eyesRGB:hairRGB:mouthRGB:skinRGB:make-upRGB:hyscale:hxscale:mscale:nscale:bscale:age:blush:make-up&co=costumeId:mouthId:hairId:fhairId:hatId:necklaceId:glassesId:bottomId:shoesId:propsId&cat=modelId:costumeId:mouthId:hairId:fhairId:hatId:necklaceId:glassesId:bottomId:shoesId:propsId
* 	
* sample:
* 	http://char.dev.oddcast.com/oh/335/416/522/361/0/860/969/306/0/0/0/oh.swf?cs=ff00287:ff00280:ff12287:ff00286:ff12FF0:101:101:101:101:60:1:100:100&co=13:0:9:0:0:0:0:0:0:0&cat=27:90:90:88:0:88:0:90:0:0:0
*  the url above will have the costume which is not compatible with bottom and hair which is not compatible with hat
* 
* 
* Created: 2/15/2007
* By: Jonathan Achai
* 
* Modified:
* 
*/

package com.oddcast.vhost
{

	public class OHUrlCategoryParser extends com.oddcast.vhost.OH
	{
		private static var oh_array:Array = new Array(
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
		* returns an object that contains the categoryId of model and accessories base on the
		* optimized host url
		*/
		public static function getOHCategoryObject(in_str:String):Object{
			var lv:LoadVars = new LoadVars();
			var c_ar:Array = in_str.split("?");
			lv.decode(c_ar[1]);
			var co_str:String = lv.cat;
			var co_arr:Array = co_str.split(":");
			var t_obj:Object = Object();
			for (var i:Number = 0; i<oh_array.length; ++i){
				t_obj[oh_array[i]] = co_arr[i];
			}		
			return t_obj;
		}
		
		/*
		* returns a the portion of the optimized host url that defines the accessory incompatibility scheme
		* ie - 27:90:90:88:0:88:0:90:0:0:0
		*/
		public static function getOHCategoryString(in_obj:Object):String{
			var t_str:String = new String();
			for (var i:Number = 0; i<oh_array.length; ++i){
				t_str+= (in_obj[oh_array[i]] != undefined) ? in_obj[oh_array[i]]+":" : "0:";			
			}
			return t_str;
		}
	}
}
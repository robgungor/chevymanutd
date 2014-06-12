/**
* ...
* @author Sam
* @version 0.1
* 
* extension of the BackgroundStruct class for the workshops
*/

package com.oddcast.workshop {
	import com.oddcast.assets.structures.BackgroundStruct;
	import com.oddcast.data.IThumbSelectorData;
	
	public class WSBackgroundStruct extends BackgroundStruct implements IThumbSelectorData {
		protected static var tempCounter:int		= 1;
		private var _tempId				:int		= 0;
		public var 	typeId				:int;
		public var 	isUploadPhoto		:Boolean;
		private var bgThumbUrl			:String;
		private var is_default			:Boolean;
		
		public function WSBackgroundStruct(in_url:String, in_id:int = 0, in_thumb:String = "", in_name:String = "", in_catId:int = 0, in_typeId:int = 0, _is_default:Boolean = false)
		{
			super(in_url, in_id);
			
			_tempId 	= tempCounter;
			tempCounter++;
			
			thumbUrl 	= in_thumb;
			name 		= in_name;
			is_default	= _is_default;
			
/*			catId=in_catId;
			typeId=in_typeId;*/
		}
		/* returns: if the background is a default or a user uploaded bg
		 * default backgrounds should not be cropped or editted */
		public function get is_bg_default():Boolean 
		{
			return(is_default);
		}

		public function get thumbUrl():String {
			return(bgThumbUrl);
		}
		
		public function set thumbUrl(s:String) : void {
			bgThumbUrl=s;
		}
		
		public function get hasId():Boolean {
			return(id>0);
		}
		
		public function get tempId():int {
			if (hasId) return(-1);
			else return(_tempId);
		}
		
	}
	
}
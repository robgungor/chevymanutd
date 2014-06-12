/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* This contains data for the thumbselector - it works with the ThumbSelectorItem
* Usage:
* selector.add(3,"dana",new ThumbSelectorData("http://www.oddcast.com/danathumb.jpg"))
* 
* @see
* com.oddcast.ui.ThumbSelectorItem
*/

package com.oddcast.data {

	public class ThumbSelectorData implements IThumbSelectorData {
		public var url:String
		public var obj:Object;
		
		public function ThumbSelectorData(in_url:String,in_obj:Object=null) {
			url=in_url;
			obj=in_obj;
		}
		
		public function get thumbUrl():String {
			return(url);
		}
	}
	
}
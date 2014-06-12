/**
 * ...
 * @author Jake Lewis
 *  3/25/2010 6:20 PM
 */

 
package  com.oddcast.cv.util {
//import  com.oddcast.cv.util.OA1Uploader_Util;
	
	import com.oddcast.workshop.OA1_Uploader;
	import flash.net.URLVariables;
	
	
	public class OA1Uploader_Util extends OA1_Uploader
	{
		
		public function setPHP_URL(phpURL:String, filename:String="noFilename"):void {
			this.phpURL = phpURL;
			this.filename = filename;
		}
		
		
		override protected function getPHP_URL():String {
			var retStr:String = phpURL + "?&rand=" + Math.floor(Math.random() * 1000000).toString();
			//trace(retStr);
			return retStr;
		}
		
		override protected function setPostVar(post_vars :URLVariables):void {
			super.setPostVar(post_vars);
			post_vars.userfile = filename;
		    
		}
		
		private var phpURL:String;  //ServerInfo.localURL + "api/oa1Uploader_multi.php
		private var filename:String;
	}
	
}


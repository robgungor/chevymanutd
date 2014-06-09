/**
* ...
* @author Sam Myer
*/
package workshop.fbconnect {
	import com.oddcast.workshop.WSBackgroundStruct;
	
	public class FacebookImage extends WSBackgroundStruct {
		public var albumId:int;
		public var userId:int;
		public var linkUrl:String;
		public var creationTime:uint;
		public var modifyTime:uint;
		
		public function FacebookImage($photoId:int=0, $albumId:int=0, $userId:int=0, $url:String=null, $urlSmall:String=null, $urlLarge:String=null, $linkUrl:String=null, $caption:String="", $creationTime:int=-1, $modifyTime:int=-1) {
			super($urlLarge, $photoId, $urlSmall, $caption);
			albumId = $albumId;
			userId = $userId;
			linkUrl = $linkUrl
			creationTime = $creationTime;
			modifyTime = $modifyTime;
		}
	}
	
}
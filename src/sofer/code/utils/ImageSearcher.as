package code.utils {
	import code.skeleton.App;
	
	import com.adobe.serialization.json.JSON;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.util.Base64;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.workshop.WSBackgroundStruct;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import workshop.fbconnect.FacebookImage;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ImageSearcher extends EventDispatcher {
		private var bgArr:Array;
		private var curPage:uint;
		private var requestedPerPage:uint=50;
		private var perPage:uint;
		private var lastSearchFn:Function;
		private var lastSearchArgs:Array;
		private var isLastPage:Boolean = false;
		
		//flickr_key= "91088c3edb6160c5f0c0431a89520695";   THIS KEY BELONGS TO SOMEONE ELSE.  DONT USE THIS KEY!!!
		public var flickr_key:String=null;
		public var photobucket_key:String = "149825928";  //aka <consumer_key>, provided by photobucket for this application
		public var photobucket_secretKey:String = "ae78f854f0457ea30b019c29d0431357";  //aka <consumer_secret>, provided by photobucket
		
		
		public function ImageSearcher($perPage:uint = 25)
		{
			perPage = $perPage;
		}
		
		/**
		 * set your custom list of photos to the image searcher
		 * @param	_list	array of FacebookImage
		 */
		public function set_photo_list( _list:Array ):void 
		{	if (_list && _list.length > 0)
			{	bgArr = new Array();
				for (var i:int = 0; i < _list.length; i++) 
				{	var cur_image:FacebookImage = _list[i];
					bgArr.push( new WSBackgroundStruct( cur_image.url, -1, cur_image.thumbUrl ) );
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		//---------------------------------  GOOGLE -------------------------------------
		
		public function searchGoogle(searchStr:String, imageSize:String = "large", imageType:String = "face", imageColor:String = "color", safety:String = "active"):void {
			lastSearchFn = doSearchGoogle;
			lastSearchArgs = arguments;
			bgArr = new Array();
			curPage = 0;
			isLastPage = false;
			getNextPage();
		}
		
		private function doSearchGoogle(searchStr:String, imageSize:String = "large", imageType:String = "face", imageColor:String = "color", safety:String = "active"):void {
			//parameters are:
			//imageSize - icon/samall/medium/large/xlarge/xxlarge/huge
			//imageType - face/photo/clipart/lineart
			//imageColor - mono/gray/color
			//safety - active/moderate/off
			//numResults - small=4 large=8
			
			var fileType:String = "jpg";
			var numResults:String;
			if (requestedPerPage > 4) {
				perPage = 8;
				numResults = "large";
			}
			else {
				perPage = 4;
				numResults = "small";
			}
			var startNum:String = ((curPage - 1) * perPage).toString();
			var url:String = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz="+numResults+"&start="+startNum+"&q=" + searchStr+"&imgsz="+imageSize+"&imgc="+imageColor+"&imgtype="+imageType+"&as_filetype="+fileType+"&safe="+safety;
			XMLLoader.sendAndLoad(url, gotGoogleImages, null, String);			
		}
		
		private function gotGoogleImages(s:String):void {
			if (s == null) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t211", "Error loading image search XML"));
				isLastPage = true;
				return;
			}
			try {
				var dataObj:Object = JSON.decode(s);
			}
			catch (e:Error) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t213", "Could not decode google API string"));
				isLastPage = true;
				return;
			}
			
			if (dataObj.responseData == null) {
				trace("ImageSearcher::gotGoogleImages - no images found : "+dataObj.responseDetails);
				bgArr = [];
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			var resultArr:Array = dataObj.responseData.results;
			bgArr = new Array();
			var bg:WSBackgroundStruct;
			
			for (var i:int = 0; i < resultArr.length; i++) {
				bg = new WSBackgroundStruct(unescape(resultArr[i].url), -1, unescape(resultArr[i].tbUrl), unescape(resultArr[i].titleNoFormatting));
				bgArr.push(bg);
			}
			
			if (bgArr.length==0) isLastPage = true;

			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		//---------------------------------  FLICKR -------------------------------------
		
		public function searchFlickr(searchStr:String):void {
			lastSearchFn = doSearchFlickr;
			lastSearchArgs = arguments;
			isLastPage = false;
			bgArr = new Array();
			curPage = 0;
			getNextPage();
		}
			
		private function doSearchFlickr(searchStr:String):void {
			perPage = requestedPerPage;
			if (flickr_key == null) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, null, "There is no flickr key for this application.  You need to get one from Erez."));
				isLastPage = true;
				return;
			}
			
			var pageNum:String = curPage.toString();
			var url:String = "http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=" + flickr_key + "&tags=" + searchStr + "&per_page="+perPage.toString()+"&page="+pageNum;
			XMLLoader.loadXML(url, gotFlickrImages);
		}
		
		private function gotFlickrImages(_xml:XML):void {
			if (_xml == null) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t211", "Error loading image search XML"));
				isLastPage = true;
				return;
			}
			var statusOK:Boolean = (_xml.@stat == "ok");
			if (!statusOK) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t214", "Flickr API Error - could not load photos."));
				isLastPage = true;
				return;				
			}
			
			bgArr = new Array();
			var bg:WSBackgroundStruct;
			var imageUrl:String;
			var imageBase:String;
			var thumbUrl:String;
			
			var photos:XMLList = _xml.photos.photo;
			for (var i:int = 0; i < photos.length(); i++) {
				imageBase = "http://farm" + photos[i].@farm + ".static.flickr.com/" + photos[i].@server + "/" + photos[i].@id + "_" + photos[i].@secret;
				imageUrl = imageBase + ".jpg";
				thumbUrl = imageBase + "_s.jpg";
				bg = new WSBackgroundStruct(imageUrl, -1, thumbUrl, photos[i].@title);
				bgArr.push(bg);
			}
			if (bgArr.length==0) isLastPage = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		//--------------------------------- PHOTOBUCKET -------------------------------------
		
		public function searchPhotobucket(searchStr:String):void {
			lastSearchFn = doSearchPhotobucket
			lastSearchArgs = arguments;
			isLastPage = false;
			bgArr = new Array();
			curPage = 0;
			getNextPage();
		}
		
		public function getPhotobucketUserImages(searchStr:String):void {
			lastSearchFn = doGetPhotobucketUserImages;
			lastSearchArgs = arguments;
			isLastPage = false;
			bgArr = new Array();
			curPage = 0;
			getNextPage();
		}
		
		private function doSearchPhotobucket(searchStr:String):void {
			callPhotobucketAPI("http://api.photobucket.com/search/" + escape(searchStr));
		}
		
		private function doGetPhotobucketUserImages(username:String):void {
			callPhotobucketAPI("http://api.photobucket.com/user/"+escape(username)+"/search");
		}
		
		private function callPhotobucketAPI(baseUrl:String):void {
			perPage = requestedPerPage;
			
			var params:Object = new Object();
			
			params.format = "xml";
			params.oauth_consumer_key = photobucket_key;
			params.oauth_timestamp = Math.floor(new Date().getTime()/1000).toString();  // number of seconds since the beatles broke up
			params.oauth_nonce = Math.floor(Math.random() * 999999999).toString();  //this is just a random string called nonce
			params.oauth_version = "1.0"; //version is always this
			params.oauth_signature_method = "HMAC_SHA1"; //encryption type is always this
			params.perpage = perPage.toString();  //number of images to return
			params.page = curPage.toString();
			params.recentfirst = "true";  //sort the images by most recently updated
			
			//sort the parameters by name (bit-wise) and create parameter string
			var paramArr:Array = new Array();
			for (var paramName:String in params) {
				paramArr.push(paramName);
			}
			paramArr.sort();
			for (var i:int = 0; i < paramArr.length; i++) {
				paramArr[i] = paramArr[i] + "=" + params[paramArr[i]];
			}
			var paramString:String = paramArr.join("&");
			
			var baseString:String = "GET&" + escape(baseUrl) + "&" + escape(paramString);
			baseString = baseString.split("/").join("%2F");
			
			
			//encryption steps:
			//convert key "a8987df38" from string into hex integer into bytearray
			var keyBinary:ByteArray = new ByteArray();
			keyBinary.writeUTFBytes(photobucket_secretKey + "&");
			
			//convert base string into bytearray
			var baseStrBinary:ByteArray = new ByteArray();
			baseStrBinary.writeUTFBytes(baseString);
			
			//HMAC-SHA1 super-secret encryption
			var result:ByteArray = Crypto.getHMAC("sha1").compute(keyBinary,baseStrBinary);
			var signature:String = Base64.encodeByteArray(result);
			signature = signature.split("+").join("%2b"); //encode + sign
			
			var url:String = baseUrl + "?" + paramString + "&oauth_signature=" + signature; 
			XMLLoader.loadXML(url, gotPhotobucketImages);
		}
		
		
		private function gotPhotobucketImages(_xml:XML):void {
			//trace("UploadSearchWin::gotPhotobucketImages : " + _xml+" -- "+XMLLoader.lastError);
			if (_xml == null) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t218", "We could not access your photobucket images."));
				isLastPage = true;
				return;
			}
			var status:String = _xml.@status.toString();
			if (!status.toUpperCase() == "OK") {
				var errorMsg:String = _xml.message.toString();
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t214", "Photobucket API Error - could not load photos : " + errorMsg, { details:errorMsg } ));
				isLastPage = true;
				return;				
			}
			
			var photos:XMLList;
			if (_xml.content.hasOwnProperty("album")) photos = _xml.content.album.media;
			else if (_xml.content.hasOwnProperty("result")) photos = _xml.content.result.primary.media;
			else photos= _xml.content.media;
			bgArr = new Array();
			var bg:WSBackgroundStruct;
			var imageUrl:String;
			var thumbUrl:String;
			var imageName:String;
			var mediaType:String;
			
			for (var i:int = 0; i < photos.length(); i++) {
				mediaType = photos[i].@type.toString();
				if (mediaType != "image") continue;
				
				//imageUrl = photos[i].@url.toString();
				//thumbUrl = photos[i].@thumbUrl.toString();
				imageUrl = photos[i].url.toString();
				thumbUrl = photos[i].thumb.toString();
				imageName=photos[i].@name.toString();
				bg = new WSBackgroundStruct(imageUrl, -1, thumbUrl, imageName);
				bgArr.push(bg);
			}
			
			if (bgArr.length==0) isLastPage = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		//--------------------------------- FACEBOOK -------------------------------------
		
		public function getFacebookUserImages():void
		{
			lastSearchFn = getFacebookUserImages;
			lastSearchArgs = arguments;
			isLastPage = true;
			if (!App.mediator.facebook_connect_is_logged_in())
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t219", "We could not access your facebook images.  Please make sure you are logged in."));
			}
			else
				App.mediator.facebook_connect_get_user_photos(gotFacebookUserImages);
		}
		
		public function getFacebookUserAlbums():void
		{
			lastSearchFn = getFacebookUserAlbums;
			lastSearchArgs = arguments;
			isLastPage = true;
			if (!App.mediator.facebook_connect_is_logged_in())
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t219", "We could not access your facebook images.  Please make sure you are logged in."));
			}
			else
				App.mediator.facebook_connect_get_users_album_photos(gotFacebookUserImages);
		}
		
		public function getFacebookUserTaggedAndAlbums():void
		{
			lastSearchFn = getFacebookUserTaggedAndAlbums;
			lastSearchArgs = arguments;
			isLastPage = true;
			if (!App.mediator.facebook_connect_is_logged_in())
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t219", "We could not access your facebook images.  Please make sure you are logged in."));
			}
			else
				App.mediator.facebook_connect_get_users_tagged_and_albums(gotFacebookUserImages);
		}
		
		private function gotFacebookUserImages(arr:Array):void {
			if (arr == null ||
				arr.length == 0) 
			{
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t220", "We could not retreive any facebook images.  Please make sure you are tagged in your photos."));
				return;
			}
			bgArr = arr;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		//--------------------------------- GooglePlus -------------------------------------
		
		public function getGooglePlusImages():void{
			trace("ImageSearcher::getGooglePlusImages - ");
			App.mediator.googlePlus_connect_get_user_photos(gotGooglePlusImages);
		}
		
		private function gotGooglePlusImages(arr:Array):void {
			if (arr == null || arr.length == 0){
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "", "We could not retreive any GooglePlus images.  Please make sure you are tagged in your photos."));//f9t220
				return;
			}
			bgArr = arr;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		//--------------------------------- THE END -------------------------------------
		
		public function getNextPage():Boolean {  //returns true if there is a next page to get
			trace("getNextPAge :: isLastPage=" + isLastPage);
			if (isLastPage||lastSearchFn == null) return(false);
			else {
				curPage++;
				lastSearchFn.apply(this, lastSearchArgs);
				return(true);
			}
		}
		
		public function get imageArr():Array {
			return(bgArr);
		}
		
		public function get isFirstCall():Boolean {
			return(curPage == 1);
		}
	}
	
}
package workshop.uploadphoto {
	
	/**
	* ...
	* @author Sam Myer
	*/
	//import com.oddcast.data.ThumbSelectorData;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.Selector;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.workshop.BGUploader;
	import com.oddcast.workshop.WSBackgroundStruct;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import workshop.fbconnect.Facebook_Friend_Item;
	import workshop.fbconnect.FacebookConnect;
	
	public class UploadSearchWin extends MovieClip {
		public var selectWin:MovieClip;
		public var searchWin:MovieClip;
		public var loadingBar:MovieClip;
		public var facesOnly:Boolean = false;
		
		private var bgArr:Array;
		private var uploader:BGUploader;
		public var imageSearch:ImageSearcher;
		private var fbConnect:FacebookConnect;
		private var numImages:uint = 0;
		
		public static const STEP_LOADING:String = 'loading';
		public static const STEP_SELECT	:String = 'select';
		public static const STEP_SEARCH	:String = 'code.skeleton.auto_photo__search';
		
		public function UploadSearchWin() {
			searchWin.addEventListener(MouseEvent.CLICK, search);
			selectWin.searchBtn.addEventListener(MouseEvent.CLICK, newSearch);
			imageSelector.addScrollBtn(selectWin.leftBtn, -2);
			imageSelector.addScrollBtn(selectWin.rightBtn, 2);
			selectWin.nextBtn.addEventListener(MouseEvent.CLICK, submitImage);
			
			imageSearch = new ImageSearcher(25);
			imageSearch.addEventListener(Event.COMPLETE, gotImages);
			imageSearch.addEventListener(AlertEvent.ERROR, onSearchError);
			
			(searchWin.tf_search as TextField).restrict = "A-Za-z0-9 \-!@#$&'\", . / ?";
			(searchWin.tf_username as TextField).restrict = "A-Za-z0-9 \-!@#$&'\", . / ?";
			visible = false;
		}

		public function openWin() {
			visible = true;
			reset();
		}
		
		public function closeWin() {
			visible = false;
		}
		
		public function get imageSelector():Selector {
			return(selectWin.imageSelector);
		}
		public function setUploader($uploader:BGUploader) {
			uploader = $uploader;
		}
		public function setFacebookConnect($fbConnect:FacebookConnect) {
			fbConnect = $fbConnect;
			imageSearch.fbConnect = fbConnect;
		}
		private function search(evt:MouseEvent) {
			var searchStr:String;
			var btn_name:String = evt.target.name;
			
			if (btn_name == "googleBtn" ||
				btn_name == "flickrBtn" ||
				btn_name == "photobucketBtn")
			{
				searchStr = searchWin.tf_search.text;
				if (searchStr.length == 0) 
				{	dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t216", "The search keyword text box is blank.  Please enter a search term."));
					return;
				}
				gotoStep(STEP_LOADING);
				if (evt.target.name == "googleBtn") 		imageSearch.searchGoogle(searchStr,"large",facesOnly?"face":"");
				if (evt.target.name == "flickrBtn") 		imageSearch.searchFlickr(searchStr);
				if (evt.target.name == "photobucketBtn") 	imageSearch.searchPhotobucket(searchStr);
			}
			else if (btn_name == "photobucketUserBtn")
			{
				searchStr = searchWin.tf_username.text;
				if (searchStr.length == 0) {
					dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t217", "The username text box is blank.  Please enter a user name."));
					return;
				}
				gotoStep(STEP_LOADING);
				imageSearch.getPhotobucketUserImages(searchStr);
			}
			else if (btn_name == "facebookUserBtn")
			{
				if (fbConnect.isLoggedIn) 
						user_logged_in_get_own_photos();
				else	fbConnect.login( user_logged_in_get_own_photos );
				
				function user_logged_in_get_own_photos(  ):void 
				{	gotoStep(STEP_LOADING);
					imageSearch.getFacebookUserImages();
				}
			}
			/*else if (btn_name == "btn_facebook_friends")
			{
				if (fbConnect.isLoggedIn)
						user_logged_in_get_friends_photos();
				else	fbConnect.login( user_logged_in_get_friends_photos );
				
				function user_logged_in_get_friends_photos(  ):void 
				{	gotoStep(STEP_LOADING);
					fbConnect.fbcGetFriendsInfo( got_friends_info );
				
					function got_friends_info( _list:Array ):void 
					{	var friend:Facebook_Friend_Item = _list[10];
						fbConnect.fbcGetFriendsPictures( got_friends_pics, friend.user_id );
						
						function got_friends_pics( _list:Array ):void 
						{	if (_list && _list.length > 0)
							{	imageSearch.set_photo_list( _list );
							}
							else dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t212", "No image results"));
						}
					}
				}
			}*/
		}
		
		private function gotImages(evt:Event) {
			if (imageSearch.isFirstCall) {
				if (imageSearch.imageArr.length == 0) {
					dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t212", "Your friend does not allow applications to access their photos. Please try another friend."));
					gotoStep(STEP_SEARCH);
					return;
				}
				else {
					numImages = 0;
					imageSelector.clear();
				}
			}
			
			var bg:WSBackgroundStruct;
			for (var i:int = 0; i < imageSearch.imageArr.length; i++) {
				bg = imageSearch.imageArr[i];
				numImages++;
				imageSelector.add(numImages, bg.name, bg,false);
			}
			imageSelector.update();			
			
			imageSelector.addEventListener(ScrollEvent.SCROLL, selectorPosUpdate);
			gotoStep(STEP_SELECT);
		}
		
		private function onSearchError(evt:AlertEvent) {
			dispatchEvent(evt);
			gotoStep(STEP_SEARCH);
		}
		
		/**
		 * check to see if you reach the end of the selector.  If so, load more images.
		 * @param	evt
		 */
		private function selectorPosUpdate(evt:ScrollEvent) 
		{
			if (evt.step == imageSelector.maxScroll) 
			{
				imageSelector.removeEventListener(ScrollEvent.SCROLL, selectorPosUpdate);
				var hasNextPage:Boolean = imageSearch.getNextPage();
				if (hasNextPage) 
					gotoStep(STEP_LOADING);
			}
		}
		
		private function submitImage(evt:MouseEvent) {
			if (!imageSelector.isSelected()) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t210", "Please select an image"));
				return;
			}
			uploader.uploadUrl(getSelectedBG().url, true);
		}
		
		private function newSearch(evt:MouseEvent) {
			reset();
		}
		public function reset() {
			imageSelector.removeEventListener(ScrollEvent.SCROLL, selectorPosUpdate);
			imageSelector.clear();
			gotoStep(STEP_SEARCH);
		}
		
		private function getSelectedBG():WSBackgroundStruct {
			if (!imageSelector.isSelected()) return(null);
			else return(imageSelector.getSelectedItem().data as WSBackgroundStruct);
		}
		
		/**
		 * shows one of several steps (movieclips) while hiding the others
		 * @param	stepName static constant such as UploadSearchWin.STEP_LOADING
		 */
		public function gotoStep(stepName:String):void
		{
			searchWin.visible	= (stepName == STEP_SEARCH);
			loadingBar.visible	= (stepName == STEP_LOADING);
			selectWin.visible	= (stepName == STEP_SELECT || stepName == STEP_LOADING);
		}
		
		public function destroy() {
			if (searchWin!=null) searchWin.removeEventListener(MouseEvent.CLICK, search);
			if (selectWin != null) {
				selectWin.searchBtn.removeEventListener(MouseEvent.CLICK, newSearch);
				selectWin.nextBtn.removeEventListener(MouseEvent.CLICK, submitImage);
			}
		}
	}	
}
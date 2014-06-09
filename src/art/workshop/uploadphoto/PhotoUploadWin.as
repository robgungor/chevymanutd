/**
* @author Sam Myer, Me^
* 
* This is the photo upload window UI used in autophoto, as well as classic upload bg.
* It just contain windows for the different upload modes and buttons to switch between the modes.
* The upload UI is in the three upload classes.
* 
* FUNCTIONS:
* setUploader() - you are required to call this function before opening this window.  specify the instance
* of BGUploader you want to use to do the actual uploading
* 
* setWebcamDimensions(w,h) - passes this function along to the webcam win
* 
* selectMode(mode) - switches mode - mode is a string : "browse" "webcam" or "search"
* 
* openWin() - opens panel in the selected mode
* closeWin() - close panel
*/
package workshop.uploadphoto {
	import com.oddcast.event.*;
	import com.oddcast.ui.*;
	import com.oddcast.workshop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	public class PhotoUploadWin extends MovieClip {
		public var browseWin:UploadBrowseWin;
		public var webcamWin:UploadWebcamWin;
		public var searchWin:UploadSearchWin;
		
		public var browseBtn:BaseButton;
		public var webcamBtn:BaseButton;
		public var searchBtn:BaseButton;
		
		public var closeBtn:SimpleButton;
		public var processing:MovieClip;
		
		private var curMode:String = "code.skeleton.auto_photo__browse";
		private var isOpen:Boolean = false;
		private var uploader:BGUploader;
		
		public function PhotoUploadWin() 
		{
			loaderInfo.addEventListener(Event.UNLOAD, onDestroy);
			addEventListener(MouseEvent.CLICK, modeSelected);
			if (closeBtn != null) {
				closeBtn.addEventListener(MouseEvent.CLICK, onClose);
				addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			}
			visible = false;
			if (processing != null) processing.visible = false;
		}
		
		public function setWebcamDimensions(w:Number, h:Number) {
			webcamWin.setDimensions(w, h);
		}
		
		public function selectMode(mode:String) {
			if (mode == curMode) return;
			trace("PhotoUploadWin::selectMode "+mode)
			if (isOpen) {  //switch modes if window is open, otherwise, save new state and wait until window is opened
				var success:Boolean = openMode(mode);
				if (success) {
					closeMode(curMode);
					curMode = mode;
				}
			}
			else curMode = mode;
		}
		
		public function setUploader($uploader:BGUploader) {
			uploader = $uploader;
			if (browseWin!=null) browseWin.setUploader(uploader);
			if (webcamWin!=null) webcamWin.setUploader(uploader);
			if (searchWin != null) searchWin.setUploader(uploader);
			uploader.addEventListener(ProcessingEvent.STARTED, onProcessingStarted);
			uploader.addEventListener(ProcessingEvent.DONE, onProcessingDone);
		}
		
		private function onProcessingStarted(evt:ProcessingEvent) {
			if (processing != null) processing.visible = true;
		}
		private function onProcessingDone(evt:ProcessingEvent) {
			if (processing != null) processing.visible = false;
			closeWin();
		}
		
		private function openMode(mode:String):Boolean {
			var success:Boolean = true;
			if (mode == "code.skeleton.auto_photo__webcam") success=webcamWin.openWin();
			else if (mode == "code.skeleton.auto_photo__search") searchWin.openWin();
			else browseWin.openWin();
			trace("PhotoUploadWin::openMode "+mode+" success="+success)
			return(success);
		}
		private function closeMode(mode:String) {
			trace("PhotoUploadWin::closeMode "+mode)
			if (mode == "code.skeleton.auto_photo__webcam") webcamWin.closeWin();
			else if (mode == "code.skeleton.auto_photo__search") searchWin.closeWin();
			else browseWin.closeWin();
		}
		public function openWin():Boolean {
			isOpen=openMode(curMode);
			visible = isOpen;
			if (isOpen && stage != null) stage.focus = this;
			return isOpen;
		}
		public function closeWin() {
			if (isOpen) closeMode(curMode);
			visible = false;
			isOpen = false;
		}
		private function onClose(evt:MouseEvent) {
			closeWin();
		}
		private function modeSelected(evt:MouseEvent) {
			if (evt.target == webcamBtn) selectMode("code.skeleton.auto_photo__webcam");
			if (evt.target == browseBtn) selectMode("code.skeleton.auto_photo__browse");
			if (evt.target == searchBtn) selectMode("code.skeleton.auto_photo__search");
		}
		
		private function onKeyPressed(evt:KeyboardEvent) {
			if (!visible) return;
			if (evt.keyCode == Keyboard.ESCAPE) closeWin();
		}
		
		private function onDestroy(evt:Event) {
			destroy();
		}
		public function destroy() {
			loaderInfo.removeEventListener(Event.UNLOAD, onDestroy);
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			removeEventListener(MouseEvent.CLICK, modeSelected);
			if (closeBtn != null) closeBtn.removeEventListener(MouseEvent.CLICK, onClose);
			if (uploader!=null) {
				uploader.removeEventListener(ProcessingEvent.STARTED, onProcessingStarted);
				uploader.removeEventListener(ProcessingEvent.DONE, onProcessingDone);
			}
		}
	}
	
}
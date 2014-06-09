package workshop.uploadphoto {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.workshop.BGUploader;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextField;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class UploadBrowseWin extends MovieClip {
		public var browseBtn:BaseButton;
		public var submitBtn:BaseButton;
		public var tf_filename:TextField;
		private var uploader:BGUploader;
		private var fileRef:FileReference;
		private var isFileSelected:Boolean=false;
		
		public function UploadBrowseWin() {
			if (browseBtn != null) browseBtn.addEventListener(MouseEvent.CLICK, onBrowse);
			if (submitBtn != null) submitBtn.addEventListener(MouseEvent.CLICK, onSubmit);
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, onFileSelected);
			visible = false;
		}
		
		public function openWin() {
			visible = true;
			setFilename("");
		}
		public function closeWin() {
			visible = false;
		}
		
		public function setUploader($uploader:BGUploader) {
			uploader = $uploader;
			//uploader.addEventListener(Event.SELECT, onFileSelected);
			//uploader.setTypeFilter(uploader.defaultImageTypeFilter);
		}
		
		
		private function onBrowse(evt:MouseEvent) {
			try 
			{
				fileRef.browse(uploader.defaultImageTypeFilter);
				var block_event:AlertEvent = new AlertEvent(AlertEvent.ALERT,'f9t546','Please select the file(s) for uploading');
				block_event.report_error = false;
				block_event.block_user_feedback = true;
				dispatchEvent(block_event);
			}
			catch (e:Error) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t502", "Error opening browse window for file upload : "+e.message,{details:e.message}));
			}
		}
		
		private function onFileSelected(evt:Event) {
			setFilename(fileRef.name);
		}
		private function onSubmit(evt:MouseEvent) {
			submit();
		}
		public function submit() {
			if (isFileSelected)
				uploader.uploadFile(fileRef, true);
			else dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t210", "Please select an image before proceeding."));
		}
		
		private function setFilename(s:String) {
			if (tf_filename != null) tf_filename.text = s == null?"":s;
			isFileSelected = (s != null && s.length > 0);
		}
	}
	
}
/**
* @author Sam Myer
*/
	
package workshop.uploadphoto {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.ToggleButton;
	import com.oddcast.utils.WebcamCapture;
	import com.oddcast.workshop.BGUploader;
	import com.oddcast.workshop.ErrorReporter;
	import com.oddcast.workshop.WSEventTracker;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.ByteArray;
	
	public class UploadWebcamWin extends MovieClip 
	{
		public var holder				:WebcamCapture;
		public var nextBtn				:BaseButton;
		public var captureBtn			:ToggleButton;
		private var imageFile			:ByteArray;
		private var uploader			:BGUploader;
		private var webcamAvailable		:Boolean;
		private var isInited			:Boolean;
		
		private var cameraWidth			:Number = 800;
		private var cameraHeight		:Number = 600;
		private var orig_holder_width	:Number;
		private var orig_holder_height	:Number;
		
		public function UploadWebcamWin() 
		{
			nextBtn.addEventListener(MouseEvent.CLICK, uploadWebcam);
			captureBtn.getChildByName("captureBtn").addEventListener(MouseEvent.CLICK, captureWebcam);
			captureBtn.getChildByName("clearBtn").addEventListener(MouseEvent.CLICK, clearWebcam);
			visible = false;
			prepare_webcam_size( true );
		}
		/**
		 * prepares the webcam for initialization (size)
		 * @param	_force_ratio if to prevent distorion of the image by keeping it a 4:3 ratio
		 */
		private function prepare_webcam_size( _force_ratio:Boolean ):void
		{
			if (_force_ratio)
			{
				var w_ratio:Number	= holder.width / 4;		// width ratio of 4
				var h_ratio:Number	= holder.height / 3;	// width ratio of 3
				
				// use smallest of the ratios
					if (w_ratio > h_ratio)	holder.width	= h_ratio * 4;
					else					holder.height	= w_ratio * 3;
			}
			orig_holder_width	= holder.width;
			orig_holder_height	= holder.height;
		}
		
		private function get webcam():WebcamCapture 
		{
			return(holder);
		}
		
		public function setUploader($uploader:BGUploader) {
			uploader = $uploader;
		}
		public function setDimensions(w:Number, h:Number) {
			cameraWidth = w;
			cameraHeight = h;
		}
		
		/**
		 * tracks information about the users webcam
		 * @param _available if the webcam is abailable for usage
		 */
		private function track_webcam_usage( _available:Boolean ):void
		{
			var webcam_name:String = _available ? webcam.cameraName : '';
			var camera_event:AlertEvent = new AlertEvent(AlertEvent.EVENT, 'f9t537', 'Webcam Initialization Information', { Available:_available, Name:webcam_name } );
			ErrorReporter.report(camera_event, camera_event.text);
		}
		
		public function openWin():Boolean {
			clearWebcam();
			captureBtn.btn="captureBtn";
			
			var use_users_default_camera:Boolean = true;
			if (!isInited)
			{	webcamAvailable = webcam.init(cameraWidth, cameraHeight, use_users_default_camera);
				isInited = true;
			}
			WSEventTracker.event("uiwci");
			
			track_webcam_usage( webcamAvailable );
				
			if (!webcamAvailable) {
				if (!webcam.cameraAvailable) dispatchEvent(new AlertEvent(AlertEvent.ALERT, "f9t200", "Camera not available."));
				else dispatchEvent(new AlertEvent(AlertEvent.ALERT, "f9t205", "Your camera model is not supported by Adobe.",{cameras:webcam.cameraNames.join(",")}));
				
				// destroy so that next time this is requested it can reinitialize since the user might have plugged in their webcam
					webcam.destroy();
					isInited = false;
				
				return false;
			}
			
			
			visible = true;
			webcam.activate(true);
			webcam.width  = orig_holder_width;
			webcam.height = orig_holder_height;
			//webcam.setVideo(orig_holder_width, orig_holder_height);
			if (webcam.activated) showActive(true);
			else {
				Security.showSettings(SecurityPanel.PRIVACY);
				showActive(false);
			}
			webcam.addEventListener(Event.ACTIVATE, webcamActivated);
			webcam.addEventListener(Event.DEACTIVATE, webcamDeactivated);
			return true;
		}
		public function closeWin() {
			trace("webcam deactivate");
			webcam.activate(false);
			visible = false;
		}
		
		private function webcamActivated(evt:Event) {
			trace("UploadWebcamWin::webcamActivated");
			showActive(true);
		}
		private function webcamDeactivated(evt:Event) {
			trace("UploadWebcamWin::webcamDeactivated");
			showActive(false);
		}
		private function showActive(b:Boolean) {
			holder.visible = b;
			nextBtn.visible = b;
			captureBtn.visible = b;
		}
		private function captureWebcam(evt:MouseEvent=null) {
			webcam.capture();
			WSEventTracker.event("uiwcc");
			//captureBtn.btn="clearBtn";
		}
		private function clearWebcam(evt:MouseEvent=null) {
			webcam.clear();
			//captureBtn.btn="captureBtn";
		}
		
		private function uploadWebcam(evt:MouseEvent) {
			imageFile=webcam.getJPG();
			if (imageFile == null) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t201", "Error capturing image."));
			}
			else {
				uploader.uploadBinary(imageFile, "jpg", true);
			}
			clearWebcam();
		}
		public function destroy() {
			if (nextBtn != null) nextBtn.removeEventListener(MouseEvent.CLICK, uploadWebcam);
			if (captureBtn != null) {
				captureBtn.getChildByName("captureBtn").removeEventListener(MouseEvent.CLICK, captureWebcam);
				captureBtn.getChildByName("clearBtn").removeEventListener(MouseEvent.CLICK, clearWebcam);
			}
			if (webcam != null) {
				webcam.destroy();
				webcam.removeEventListener(Event.ACTIVATE, webcamActivated);
				webcam.removeEventListener(Event.DEACTIVATE, webcamDeactivated);
			}
		}
	}
	
}
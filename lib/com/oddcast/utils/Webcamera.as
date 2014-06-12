/**
* ...
* @author Sam, Jason
* @version 0.1
* 
* Movieclip which contains webcam output
* 
* METHODS:
* 
* init(width, height, useDefault) - create webcam window. 
*	width - width of video and webcam
*	height - height of video and webcam
*	useDefault - (boolean) use the user's default camera (true) or use the approved camera list (false/default)
* setWebcamMode(width, height, favorArea, shouldSetVideoDimensions) - set the area of the web camera
* setVideoDimensions(width, height) - set the video display size
* capture() - capture still image from webcam
* clear() - clear still image
* activate(value) - activate/disactivate webcam.
* getJPG() - returns captured still image as jpeg-encoded ByteArray
* destroy() - destroys object and frees memory, listeners
* 
* PROPERTIES:
* activated - camera is allowed by user
* cameraAvailable - returns true if there is a camera on your machine.  returns true even if the camera isn't on the
* list of approved cameras
* cameraNames - returns a list of cameras set up on your machine
* 
* EVENTS:
* Event.ACTIVATE - camera dispatches this event when you move around in front of the camera
* Event.DEACTIVATE - camera dispatches this event when you stop moving around in front of the camera
*/

package com.oddcast.utils {

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.media.*;
	import flash.system.*;
	import flash.utils.ByteArray;

	public class Webcamera extends MovieClip {
		
		public static const WEBCAM_ACTIVATE		:String = "webcamActivate";
		public static const WEBCAM_DEACTIVATE	:String = "webcamDeactivate";
		public static const CAMERA_MUTED		:String = "Camera.Muted";
		public static const CAMERA_UNMUTED		:String = "Camera.Unmuted";
		
		private const DEFAULT_FPS		:Number = 15.0;
		private const defaultMacCamera	:String = "USB Video Class Video";
		private const MacOSSignature	:String = "Mac";
		
		// webcam and vid need to be public for Augmented Reality
		public var webcam				:Camera;
		public var vid					:Video;
		
		protected var vidHolder			:Sprite;
		
		private var allowedCameras		:Array;
		private var isAvailable			:Boolean = false;
		private var _cameraNames		:Array;
		private var _useDefault			:Boolean = false;
		
		public function get activated():Boolean
		{
			return !webcam.muted;
		}
		
		public function get cameraAvailable():Boolean 
		{
			return isAvailable;
		}
		
		public function get cameraName():String
		{
			return webcam.name;
		}
		
		public function get cameraNames():Array 
		{
			return _cameraNames;
		}
		
		public function Webcamera()
		{
			allowedCameras = [	"webcam", 
								"Integrated Camera", 
								"Creative Webcam Vista Plus", 
								"Logitech QuickCam Fusion", 
								"Logitech QuickCam Pro 5000", 
								"Logitech QuickCam Pro 4000", 
								"Logitech QuickCam Express", 
								"Logitech QuickCam Easy", 
								"Logitech QickCam Pro 9000" ];
		}
		
		public function init(width:Number, height:Number, useDefault:Boolean = false, fps:Number = DEFAULT_FPS, favorArea:Boolean = true):Boolean
		{
			_useDefault = useDefault;
			isAvailable = false;
			//isAllowed = false;
			_cameraNames = [];
			webcam = Camera.getCamera();
			if (!webcam) {
				return false;
			} else {
				isAvailable = true;
			}
			if (!_useDefault) {
				_cameraNames = [webcam.name];
				if (!isAllowed(webcam.name)) {
					var hasAllowedCam:Boolean = false;
					_cameraNames = Camera.names;
					for (var i:Number = 0; i < _cameraNames.length; ++i) {
						if (isAllowed(String(_cameraNames[i]).toLocaleLowerCase())) {
							hasAllowedCam = true;
							webcam = Camera.getCamera(i.toString());
							break;
						}
					}
					if (!hasAllowedCam) return false;
				}
			} else {
				var t_choose_mac_camera:Boolean = false;
				var t_index:int;
				if (Capabilities.os.search(MacOSSignature) != -1) {
					var t_cameras:Array = Camera.names;
					for (t_index = 0; t_index < t_cameras.length; t_index++) {
						//trace("Webcamera camera:" + t_index + " " + t_cameras[t_index] + " ,"+defaultMacCamera);
						if (t_cameras[t_index] == defaultMacCamera) {
							t_choose_mac_camera = true;
							//trace("Webcamera t_choose_mac_camera:" + t_index.toString() + " " + t_cameras[t_index] + " ,"+defaultMacCamera);
							break;
						}
					}	
				} else {
					//trace("Webcamera Not Mac:" + MacOSSignature);
				}
				if (!t_choose_mac_camera) {
					webcam = Camera.getCamera();
				} else {
					webcam = Camera.getCamera(t_index.toString());
				}
			}
			
			webcam.addEventListener(StatusEvent.STATUS, onStatus, false, 0, true);
			webcam.addEventListener(ActivityEvent.ACTIVITY, onActivity, false, 0, true);
			webcam.setMode(width, height, fps);
			webcam.setLoopback(false);   //some cameras hold a memory of this!
			
			vidHolder = new Sprite();
			addChild(vidHolder);
			vid = new Video(webcam.width, webcam.height);
			vidHolder.addChild(vid);
			//trace("WebcamCapture::init webcam requested size="+width+","+height+"  actual size="+webcam.width+","+webcam.height+"   vid size = "+[vid.width,vid.height]+"   vid source = "+[vid.videoWidth,vid.videoHeight]);
			
			vid.attachCamera(webcam);
			
			return true;
		}
		
		public function setWebcamMode(width:int, height:int, favorArea:Boolean = true, shouldSetVideoDimensions:Boolean = true, fps:Number = DEFAULT_FPS):void
		{
			//trace("WCC - setMode - w: " + width + " h: " + height + " favorArea: " + favorArea + " resize video: " + shouldSetVideo);
			webcam.setMode(width, height, fps, favorArea);
			if (shouldSetVideoDimensions) {
				setVideoDimensions(width, height);
			}
		}
		
		public function setVideoDimensions(width:int, height:int):void
		{
			vid.width = width;
			vid.height = height;
		}
		
		public function setCamera(name:String):void
		{
			//trace("SET CAMERA " + name);
			Camera.getCamera(name);
		}
		
		public function activate(value:Boolean):void
		{
			if (vid) {
				vid.attachCamera(value ? webcam : null);
			}
		}
		
		public function destroy():void
		{
			if (webcam) {
				webcam.removeEventListener(StatusEvent.STATUS, onStatus);
				webcam.removeEventListener(ActivityEvent.ACTIVITY, onActivity);
			}
			if (vid) {
				vid.attachCamera(null);
			}
			webcam = null;
			vid = null;
			allowedCameras = null;
		}
		
		private function isAllowed(cam:String):Boolean
		{
			if (cam.toLowerCase().indexOf("usb") != -1) return true;
			
			for (var i:Number = 0; i < allowedCameras.length; ++i) {
				//trace("WEBCAMCAPTURE - IS ALLOWED --- " + String(allowedCameras[i]).toLocaleLowerCase()+ "  pass: " + (String(allowedCameras[i]).toLocaleLowerCase() == cam.toLowerCase()));
				if (String(allowedCameras[i]).toLocaleLowerCase() == cam.toLowerCase()) {
					return true;
				}
			}
			return false;
		}
		
		public function onStatus(event:StatusEvent):void
		{
			//trace('Webcamera checking status on deny: event = ', event, webcam.muted);
			var t_allowed:Boolean = !_useDefault ? isAllowed(webcam.name) : true;
			//trace("Webcamera ==  on Status -- code=" + event.code + "  level=" + event.level + "  !isAllowed(" + webcam.name + ") : " + t_allowed + " webcam: " + webcam + "activated:" + activated);
			if (event.code == CAMERA_UNMUTED && !t_allowed) {
				Security.showSettings(SecurityPanel.CAMERA);
			}
			dispatchEvent(new Event(activated ? WEBCAM_ACTIVATE : WEBCAM_DEACTIVATE));
		}
		
		protected function onActivity(event:ActivityEvent):void
		{
			//trace("WEBCAMCAPTURE::onActivity  activating=" + evt.activating);
		}
	}
}

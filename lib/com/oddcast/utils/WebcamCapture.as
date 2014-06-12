/**
* ...
* @author Sam, Jason
* @version 0.1
* 
* Movieclip which contains webcam output
* 
* METHODS:
* 
* init(w,h,useDefault) - create webcam window. 
*	w - width of video and webcam
*	h - height of video and webcam
*	useDefault - (boolean) use the user's default camera (true) or use the approved camera list (false/default)
* setWebcamMode($w, $h, $favorArea, $setVideo) - set the area of the web camera
* setVideo($w, $h) - set the video display size
* capture() - capture still image from webcam
* clear() - clear still image
* activate(b) - activate/disactivate webcam.
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

	import com.adobe.images.JPGEncoder;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.media.*;
	import flash.system.*;
	import flash.utils.ByteArray;
	
	//import mx.controls.TextArea;

	public class WebcamCapture extends Webcamera {
		
		public var bitmap		:Bitmap;
		
		private var encoder		:JPGEncoder;
		
		public function capture(evt:MouseEvent = null):void
		{
			if (bitmap && bitmap.bitmapData) {
				bitmap.bitmapData.dispose();
			}
			bitmap = new Bitmap();
			bitmap.bitmapData = new BitmapData(webcam.width, webcam.height);
			var m:Matrix = new Matrix();
			m.scale(webcam.width / vid.width, webcam.height / vid.height);
			bitmap.bitmapData.draw(vid, m);
			bitmap.width = vidHolder.width;
			bitmap.height = vidHolder.height;
			addChild(bitmap);
			//trace("WebcamCapture::capture - webcam:" + [webcam.width, webcam.height] + "  vid source = "+[vid.videoWidth,vid.videoHeight]+"   vid=" + [vid.width, vid.height] + "  bitmap=" + [bitmapData.width, bitmapData.height]);
		}
		
		public function clear(event:MouseEvent = null):void
		{
			if(bitmap)
			{
				if (bitmap && bitmap.parent && this.contains(bitmap)) {
					removeChild(bitmap);
				}
				
				if (bitmap.bitmapData) {
					bitmap.bitmapData.dispose();
				}
				bitmap.bitmapData = null;
			}
		}
		
		public function getJPG():ByteArray
		{
			if (!vid) return null;
			if(!bitmap){
				capture();
			}
			if (!bitmap.bitmapData) {
				capture();
			}
			if (!encoder) {
				// encoder only created when necessary. Jake
				encoder = new JPGEncoder(80);
			}
			return encoder.encode(bitmap.bitmapData);
		}
		
		public function WebcamCapture()
		{
		}
		override public function destroy():void
		{
			clear();
			bitmap = null;
			encoder = null;
			super.destroy();
		}
	}
}

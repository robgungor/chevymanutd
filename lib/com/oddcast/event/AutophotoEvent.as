
package com.oddcast.event
{
	import flash.events.Event;

	public class AutophotoEvent extends Event{
						
		//photo upload events
		/**
		 * Dispatched when the image finished being uploaded
		 * @eventType photoFileLoaded				 
		 */		
		public static const PHOTO_FILE_UPLOADED:String = "photoFileLoaded";
		/**
		 * Dispatched when an image file has been selected using the OS browse dialog box. The name of the file (string) can be retrieved using the data object
		 * @eventType photoFileSelected				 
		 */		
		public static const PHOTO_FILE_SELECTED:String = "photoFileSelected";				
		//public static const PHOTO_FILE_UPLOAD_PROGRESS:String = "photoFileProgress";		
		/**
		 * Dispatched if uploading of the image has failed. The event's data object contains: { id, msg, info}
		 * @eventType photoUploadError				 
		 */		
		public static const PHOTO_FILE_UPLOAD_ERROR:String = "photoUploadError";		
		/**
		 * Dispatched when downloading of the uploaded image is completed
		 * @eventType photoFileDownloaded				 
		 */		
		public static const PHOTO_FILE_DOWNLOADED:String = "photoFileDownloaded";
		/**
		 * Dispatched when downloading of the cropped image after positioning is completed
		 * @eventType croppedPhotoFileDownloaded				 
		 */		
		public static const CROPPED_PHOTO_DOWNLOADED:String = "croppedPhotoFileDownloaded";
		//processing events
		/**
		 * Dispatched when downloading of any image (original or cropped) is completed - not in use
		 * @eventType photoLoaded				 
		 */		
		public static const PHOTO_LOADED:String = "photoLoaded";
		/**
		 * Dispatched while processing is taking place. Can be used to monitor upload/download and conversion progress. However, for conversion progress it is recommended to use the OVERALL_PROCESSING_PROGRESS event.
		 * The event's data object contains: {percent,msg}
		 * @eventType processingProgress				 
		 */		
		public static const PROCESSING_PROGRESS:String = "processingProgress";
		/**
		 * Dispatched when the cropped image is ready. The event's data object contains: {image, img} (both are the full url to the cropped image)
		 * @eventType processingImageReady				 
		 */		
		public static const PROCESSING_IMAGE_READY:String = "processingImageReady";
		/**
		 * Dispatched while doing the photoface processing. The event's data object contains: {percent} and can be used to monitor over all processing of the entire process
		 * @eventType overallProcessingProgress				 
		 */
		public static const OVERALL_PROCESSING_PROGRESS:String = "overallProcessingProgress";
		/**
		 * Dispatched when the point positioning step is ready.
		 * @eventType onPoints				 
		 */
		public static const ON_POINTS:String = "onPoints";
		/**
		 * Dispatched when the masking step is ready.
		 * @eventType onMask				 
		 */
		public static const ON_MASK:String = "onMask";
		/**
		 * Dispatched when the mask has been saved succesfully
		 * @eventType onMaskReady				 
		 */
		public static const ON_MASK_READY:String = "onMaskReady";
		/**
		 * Dispatched when the photoface processing has completed successfully
		 * @eventType onFGReady				 
		 */
		public static const ON_FG_READY:String = "onFGReady";
		//public static const ON_REDO_POINTS:String = "onRedoPoints";
		/**
		 * Dispatched when the entire APC process is completed
		 * @eventType onDone				 
		 */
		public static const ON_DONE:String = "onDone";
		/**
		 * Dispatched when the point placement step needs to be repeated due to an error
		 * @eventType onRedoPosition				 
		 */
		public static const ON_REDO_POSITION:String = "onRedoPosition";		
		/**
		 * Dispatched when an error occurs. The event's data object contains: {id,msg, info, xml, code}
		 * @eventType onError				 
		 */
		public static const ON_ERROR:String = "onError";	
		/**
		 * Dispatched when a placement point has been mouse pressed. The event's data object contains a string with the point name 
		 * @eventType onPointPressed				 
		 */
		public static const ON_POINT_PRESSED:String = "onPointPressed";
		/**
		 * Dispatched when a placement point has been mouse released. The event's data object contains a string with the point name 
		 * @eventType onPointReleased				 
		 */
		public static const ON_POINT_RELEASED:String = "onPointReleased";
		/**
		 * Dispatched when an error occured with the webcam capturing. The event's data object contains: { id, msg, info} 
		 * @eventType onPointReleased				 
		 */
		public static const WEBCAM_ERROR:String = "onWebcamError";		
		/**
		 * Dispatched when the webcam has become active 
		 * @eventType onWebcamActive				 
		 */
		public static const WEBCAM_ACTIVE:String = "onWebcamActive";
		/**
		 * Dispatched when the webcam has become inactive 
		 * @eventType onWebcamInactive				 
		 */
		public static const WEBCAM_INACTIVE:String = "onWebcamInactive";
		/**
		 * Dispatched when an acitivty was detected on the APC side such as mouse clicks, and processes. The event's data is either the mouse event (MouseEvent) or null. 
		 * This can be used to detect idleness of the user and whether a session expired error message should be dispatched by client application. 
		 * @eventType onAPCActivity				 
		 */
		public static const ON_ACTIVITY:String = "onAPCActivity";
		/**
		 * Dispatched when the APC has finished loading its initilization data 
		 * @eventType onAPCReady				 
		 */
		public static const ON_APC_READY:String = "onAPCReady";
		/**
		 * Dispatched when the APC has used facefinder autocrop feature to detect faces on the upload image. See APC's getFaces() for how to continue when this event is dispatched. 
		 * @eventType onAPCAutoCropped				 
		 */
		public static const ON_APC_AUTO_CROPPED:String = "onAPCAutoCropped";
		
		public var data:Object;
		
		public function AutophotoEvent($type:String, $data:Object, $bubbles:Boolean = false, $cancelable:Boolean = true):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new AutophotoEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("AutophotoEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}	
}
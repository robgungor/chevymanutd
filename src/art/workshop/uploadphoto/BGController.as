/**
* @author Sam Myer
* @version 1.0
* 
* This class takes care of most of the upload photo features.  It is used as the base class for the movieclip on the
* stage (playerHolder.player.bgHolder), and the backgrounds are loaded inside of this movieclip
* 
* This class implements com.oddcast.workshop.IBGLoader
* 
* FUNCTIONS:
* 
* addUploader(BGUploader) - add a reference to an instance of BGUploader in order to upload photos
* 
* setMask(DisplayObject) - set a  mask for the background.  this can be either a static sprite, or it can be
* a dynamic mask object.  The BGMask class is used for a dynamic mask where the user can alter the shape
* of the mask by moving around points.  This function is usually automatically called by the SceneController
* class which adds the mask which is on the stage in the .fla (@ playerHolder.player.bgMask)
* 
* createDynamicMask() - automatically creates a dynamic mask (BGMask) with the same dimensions as the
* current mask and adds it to the stage
* 
* getDynamicMask():BGMask - if a dynamic mask (type BGMask) is present, returns that mask
* 
* loadBG(WSBackgroundStruct) - loads background.  loadBG(null) does the same thing as unloadBG()
* unloadBG() - unloads background
* 
* crop() - starts cropping process.  the image is cropped to the bounds of the mask.  In the case of the dynamic mask,
* the image is cropped to the maximum possible size of that mask (i.e. the bounds if the user were to move the
* points out as far as possible)
* 
* PROPERTIES:
* 
* zoomer (readonly) - returns MoveZoomUtil object that can be used to move/zoom/rotate the background
* 
* bg (readonly) - current loaded WSBackgroundStruct
* 
* bgPosition (read/write) - get/set the position of the background directly.
* affects the Sprite.transform.matrix property of the background

* isExpired (readonly) - backgrounds get deleted from the temp server every few minutes.  when a background is
* uploaded, a timer gets started.  once the timer has elapsed, the background is considered to have been expired
* and deleted from the server.  This only applies to uploaded bgs, not to backgrounds which are loaded through
* loadBG command and are assumed to be in a more permanent location
* 
* EVENTS:
* ProcessingEvent.STARTED
* ProcessingEvent.PROGRESS
* ProcessingEvent.DONE -
* These events are dispatched to show loading bar for either the upload process or the bg loading process
* The process name used for the image loading process is ProcessingEvent.BG
* The process name used for the upload process is "upload"  There is no PROGRESS event for the upload process
* 
* SceneEvent.BG_UPLOADED - dispatched when a background has been uploaded
* SceneEvent.BG_CROPPED - dispatched when cropping process is complete
* SceneEvent.BG_CROP_FAILED - dispatched when cropping fails
* SceneEvent.BG_LOADED - dispatched when the background is loaded, or when the background has finished unloading
* following an unload() call
* SceneEvent.BG_EXPIRED - dispatched a certain amount of time after the current background has been uploaded
* indicating that an uploaded background may have been deleted from the temp server
* 
* AlertEvent.EVENT - on error
*/
package workshop.uploadphoto {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.BGEvent;
	import com.oddcast.utils.MoveZoomUtil;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.workshop.BGUploader;
	import com.oddcast.workshop.IBGLoader;
	import com.oddcast.workshop.ProcessingEvent;
	import com.oddcast.workshop.SceneEvent;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSBackgroundStruct;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	
	public class BGController extends Sprite implements IBGLoader {
		private var holder:Sprite;
		private var imgLoader:Loader;
		
		private var uploader:BGUploader;
		private var _zoomer:MoveZoomUtil;
		private var dynamicMask:BGMask;
		private var expiryTimer:Timer;
		private var curBG:WSBackgroundStruct;
		private var bgToLoad:WSBackgroundStruct;
		private var cropArea:DisplayObject;
		
		private var autoResize:Boolean = true;
		private var centerOnLoad:Boolean = false;
		private var isLoadingCropped:Boolean = false;
		private var cropOffset:Point = null;
		private var photoHasExpired:Boolean = false;
		
		/*is this an upload photo workshop?*/
		public var isUploadPhoto:Boolean = false; 
		
		public function BGController() {
			holder = new Sprite();
			addChild(holder);
			imgLoader = new Loader();
			holder.addChild(imgLoader);
			imgLoader.contentLoaderInfo.addEventListener(Event.INIT, bgLoaded, false, 0, true);
			imgLoader.contentLoaderInfo.addEventListener(Event.UNLOAD, bgUnloaded, false, 0, true);
			imgLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError,false,0,true);
			imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_zoomer = new MoveZoomUtil(holder);
			zoomer.setScaleLimits(0.1, 3);
			expiryTimer = new Timer(ServerInfo.sessionTimeoutSeconds*1000, 1);
		}
		
		public function addUploader($uploader:BGUploader):void {
			uploader = $uploader;
			uploader.addEventListener(BGEvent.SELECT, bgUploaded);
			uploader.addEventListener(ProcessingEvent.STARTED, uploaderProcessingStarted);
			uploader.addEventListener(ProcessingEvent.DONE, uploaderProcessingEnded);
			uploader.addEventListener(AlertEvent.EVENT, uploaderError);
			//uploader.byteMinimumLimit = 5 * 1024; //5 Kb minimum
			//uploader.byteSizeLimit=2560*1024;  //default of 2.5 Mb maximum file size
		}
		
		/*sets the bg mask.  this can either be a dynamic mask of type BGMask or a regular sprite
		If you don't set it, it uses playerHolder.player.bgHolder.bgMask as the default mask*/
		public function setMask($mask:DisplayObject):void {
			
			if ($mask == null) $mask = mask;
			if ($mask == null) return;
			if ($mask is BGMask) {
				dynamicMask = $mask as BGMask;
				dynamicMask.visible = true;
				mask = dynamicMask.fill;
				cropArea = dynamicMask.boundsMC;
			}
			else {
				mask = $mask;
				cropArea = mask;
			}
			mask.visible = false;
			zoomer.boundBy(mask,MoveZoomUtil.MASK_AREA);
			zoomer.anchorTo(mask);
		}
		
		/*automatically create a mask with a bunch of points that you can move around to resize it*/
		public function createDynamicMask():void {
			var rectArea:Rectangle = mask.getRect(this);
			dynamicMask = new BGMask(rectArea);
			parent.addChildAt(dynamicMask, parent.getChildIndex(this) + 1);
			setMask(dynamicMask);
		}
		
		public function get hasDynamicMask():Boolean {
			return(dynamicMask != null);
		}
		
		public function getDynamicMask():BGMask {
			return(dynamicMask);
		}
		
		private function removeMask():void {
			mask = null;
		}
		
		private function startExpiryTimer():void {
			expiryTimer.reset();
			expiryTimer.delay = ServerInfo.sessionTimeoutSeconds * 1000;
			expiryTimer.addEventListener(TimerEvent.TIMER_COMPLETE, photoExpired);
			expiryTimer.start();
		}
		
		private function stopExpiryTimer():void {
			expiryTimer.stop();
			expiryTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, photoExpired);
		}
		
		public function loadBG(bg:WSBackgroundStruct):void {
			if (expiryTimer != null) stopExpiryTimer();
			photoHasExpired = false;
			doLoadBG(bg, false);
		}
		
		public function unloadBG():void {
			loadBG(null);
		}
		
		private function doLoadBG(bg:WSBackgroundStruct, $centerOnLoad:Boolean = false, $cropped:Boolean = false):void {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED, ProcessingEvent.BG));
			isLoadingCropped=$cropped
			centerOnLoad = $centerOnLoad;
			
			try 
			{
				bgToLoad = bg;
				if (bg == null) imgLoader.unload();
				else 
				{
					var context:LoaderContext = new LoaderContext( true );	// this is needed -- when doing BitmapData.draw to avoid error 2122
					imgLoader.load(new URLRequest(bg.url), context);
				}
			}
			catch (e:Error) {
				onError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}			
		}
		
		private function onLoadProgress(evt:ProgressEvent):void {
			trace("onLoadProgress - " + evt.bytesLoaded);
			var percent:Number = (evt.bytesTotal == 0)?0:(evt.bytesLoaded / evt.bytesTotal);
			dispatchEvent(new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.BG, percent));
		}
		
		private function bgUploaded(evt:BGEvent):void {
			startExpiryTimer();
			photoHasExpired = false;
			doLoadBG(evt.bg as WSBackgroundStruct, true);
			dispatchEvent(new SceneEvent(SceneEvent.BG_UPLOADED));
		}
		
		protected function bgLoaded(evt:Event):void
		{
			anti_cache( bgToLoad, false );
			curBG = bgToLoad;
			trace("BGController::bgLoaded curBG = " + curBG.url);
			if (isLoadingCropped)
			{	isLoadingCropped = false;
				var maskBounds:Rectangle = cropArea.getBounds(this);
				//holder.x = maskBounds.x;
				//holder.y = maskBounds.y;
				//holder.rotation = 0;
				holder.x = cropOffset.x;
				holder.y = cropOffset.y;
				dispatchEvent(new SceneEvent(SceneEvent.BG_CROPPED));
			}
			else 
			{	if (centerOnLoad)
				{	centerImage();
				}
				dispatchEvent(new SceneEvent(SceneEvent.BG_LOADED));
			}
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.BG));
			
			if (curBG.is_bg_default)
					zoomer.scale_to_100();
			else	zoomer.new_item_loaded();
		}
		protected function bgUnloaded(evt:Event):void {
			if (bgToLoad==null) {
				curBG = null;
				dispatchEvent(new SceneEvent(SceneEvent.BG_LOADED));
				dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.BG));
				trace("BGController::bgUnloaded curBG = null");
			}
		}
		
		private function centerImage():void {
			var maskBounds:Rectangle = cropArea.getBounds(this);
			var scaleAmt:Number = Math.max(maskBounds.width/imgLoader.width,maskBounds.height/imgLoader.height);
			var offsetX:Number = (maskBounds.width - imgLoader.width * scaleAmt) / 2;
			var offsetY:Number = (maskBounds.height - imgLoader.height * scaleAmt) / 2;
			zoomer.rotation = 0;
			zoomer.scale = scaleAmt;
			zoomer.x = maskBounds.x+offsetX;
			zoomer.y = maskBounds.y + offsetY;
		}
		
		public function crop():void 
		{
			if (curBG == null || curBG.is_bg_default) // make sure we have a bg AND that its not a default from the admin tool
			{
				dispatchEvent(new SceneEvent(SceneEvent.BG_CROPPED));
				return;
			}
			
			var cropBounds:Rectangle = cropArea.getBounds(holder);
			var cropX:Number=Math.round(cropBounds.x);
			var cropY:Number = Math.round(cropBounds.y);
			var cropW:Number = cropBounds.width;
			var cropH:Number = cropBounds.height;
			var cropRot:Number = Math.round( -holder.rotation);
			
			cropOffset = holder.transform.matrix.transformPoint(new Point(cropX, cropY));
			
			// crop and resize - PROBLEM - doesnt work with PNG files
			var vars:URLVariables = new URLVariables();
			vars.bgURL = curBG.url;
			vars.doorId = ServerInfo.door;
			vars.cropPoints = [cropX, cropY, cropW, cropH, 0].join(",");
			var url:String = ServerInfo.localURL + "imageResize.php";
			XMLLoader.sendAndLoad(url, gotCropResult, vars, URLVariables);
		}

		private function gotCropResult(result:URLVariables):void
		{	if (result == null) 
			{	dispatchEvent(new SceneEvent(SceneEvent.BG_CROP_FAILED));
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t312", "Could not crop image : " + XMLLoader.lastError,{details:XMLLoader.lastError}));
				return;
			}
			var success:Boolean = result.OK == "1";
			if (success) 
			{	anti_cache( bgToLoad, true );
				doLoadBG(bgToLoad, false,true);
			}
			else 
			{	dispatchEvent(new SceneEvent(SceneEvent.BG_CROP_FAILED));
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t312", "Could not crop image : "+result.ERROR,{details:result.ERROR}));
			}
		}
		
		/**
		 * add or remove random anti cache query to prevent... well... caching locally
		 * @param	_bg		bg to modify
		 * @param	_add	true will add, false will remove the current
		 */
		private function anti_cache( _bg:WSBackgroundStruct, _add:Boolean ):void 
		{	_bg.url = bgToLoad.url.split('?')[0];	// remove previous anti cache
			if (_add)	// add new anti cache
			{	var anti_cache_query:String = '?anti_cache=' + (Math.random() * 10000000).toString();
				_bg.url += anti_cache_query;
			}
		}
		
		protected function onError(evt:ErrorEvent):void {
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.BG));
			dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t311", "Could not load BG : "+evt.text));
		}
		
		private function photoExpired(evt:TimerEvent):void {
			stopExpiryTimer();
			photoHasExpired = true;
			dispatchEvent(new SceneEvent(SceneEvent.BG_EXPIRED));
		}
		
		private function uploaderProcessingStarted(evt:ProcessingEvent):void {
			evt.processName = ProcessingEvent.BG;
			dispatchEvent(evt);
		}
		private function uploaderProcessingEnded(evt:ProcessingEvent):void {
			evt.processName = ProcessingEvent.BG;
			dispatchEvent(evt);
		}
		private function uploaderError(evt:AlertEvent):void {
			dispatchEvent(evt);
		}
				
		public function get zoomer():MoveZoomUtil {
			return(_zoomer);
		}
		
		public function get bg():WSBackgroundStruct {
			return(curBG);
		}
		
		public function get bgPosition():Matrix {
			return(zoomer.matrix);
		}
		public function set bgPosition(m:Matrix):void {
			zoomer.matrix = m;
		}
		
		public function get isExpired():Boolean {
			return(photoHasExpired);
		}
	}
	
}
package code.controllers.auto_photo.apc 
{
	import code.HeadStruct;
	import code.models.*;
	import code.skeleton.*;
	
	import com.adobe.images.PNGEncoder;
	import com.oddcast.assets.structures.BackgroundStruct;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.URLRequest;
	import flash.system.*;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import org.casalib.display.CasaSprite;
	import org.casalib.util.RatioUtil;

	/**
	 * ...
	 * @author Me^
	 */
	public class Auto_Photo_APC implements IAuto_Photo_APC
	{
		/** callback when the apc is loaded and initialized */
		private var on_apc_ready_callback:Function;
		/** APC engine */
		private var api_apc		:MovieClip;
		/** true only once loaded and initialized */
		private var api_ready	:Boolean;
		/** the application domain that the apc will be loaded into */
		private var apc_domain			: ApplicationDomain;
		/**	percent for analyzing and converting only	*/
		private var overall_percent		:Number;
		private var model_type			:int;
		private var display_size		:Point = new Point(100, 100);
		private var current_session_id	:String;
		/** we need to track if points were submitted manually or auto figured out by luxend */
		private var points_submitted_tracked_manually:Boolean = false;
		private var photo_expiration	:Event_Expiration = new Event_Expiration();
		/** apc sometimes processes in the background while the user is at a step so we ignore the processing requests */
		private var ignore_apc_processing_updates:Boolean;
		
		private const PROCESS_AUTOPHOTO_GENERIC		:String = 'PROCESS_AUTOPHOTO_GENERIC';
		private const ART_ANCHOR_CLASS_NAME			:String = 'oc_autophoto_anchor';
		private const ART_MASKING_POINT_CLASS_NAME	:String = 'oc_autophoto_maskPoint';
		private const PHOTO_EXPIRED_EVENT_NAME		:String = 'PHOTO_EXPIRED_EVENT_NAME';
		
		public static const MOVE_UP					:String = 'move image up';
		public static const MOVE_DOWN				:String = 'move image down';
		public static const MOVE_RIGTH				:String = 'move image right';
		public static const MOVE_LEFT				:String = 'move image left';
		public static const ZOOM_IN					:String = 'move image in';
		public static const ZOOM_OUT				:String = 'move image out';
		public static const ROT_COUNTER_CLOCKWISE	:String = 'move image counter clockwise';
		public static const ROT_CLOCKWISE			:String = 'move image clockwise';
		public static const RESET_IMAGE				:String = "reset image";
		
		private const APC_PROCESSING_MESSAGE_INITIALIZING:String	= 'APC_PROCESSING_MESSAGE_INITIALIZING';
		private const APC_PROCESSING_MESSAGE_RETRIEVING:String		= 'APC_PROCESSING_MESSAGE_RETRIEVING';
		private const APC_PROCESSING_MESSAGE_SUBMITTING:String		= 'APC_PROCESSING_MESSAGE_SUBMITTING';
		private const APC_PROCESSING_MESSAGE_QUEUED:String			= 'APC_PROCESSING_MESSAGE_QUEUED';
		private const APC_PROCESSING_MESSAGE_ANALYZING:String		= 'APC_PROCESSING_MESSAGE_ANALYZING';
		private const APC_PROCESSING_MESSAGE_CONVERTING:String		= 'APC_PROCESSING_MESSAGE_CONVERTING';
		
		private var _croppedBitmaps:Array;
		private var _photoHasExpired:Boolean = false;
		private var expiryTimer:Timer;

		protected var _defaultHeadThumbs:Array = [];
		
		/*
		[Embed(source="../../src/art/thumbs/01.jpg")]
		private var Default1:Class;
		[Embed(source="../../src/art/thumbs/2.jpg")]
		private var Default2:Class;
		
		[Embed(source="../../src/art/thumbs/3.jpg")]
		private var Default3:Class;
		
		[Embed(source="../../src/art/thumbs/4.jpg")]
		private var Default4:Class;
		
		[Embed(source="../../src/art/thumbs/5.jpg")]
		private var Default5:Class;
		*/
		public function Auto_Photo_APC( _apc_domain:ApplicationDomain ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			apc_domain = _apc_domain;
						
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove(App.mediator, loaded_event, app_initialized);
				// init this after the application has been inaugurated
				init();
			}
		}
		private function init(  ):void 
		{	
			
			/*_imgLoader = new Loader();
			_imgLoader.contentLoaderInfo.addEventListener(Event.INIT, _imageLoaded, false, 0, true);
			_imgLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError,false,0,true);
			_imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			_imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);*/
			var ub:MovieClip = App.ws_art.upload_btns;
			/*_uploadBtns =  [	ub.upload_btn3,
								ub.upload_btn1,
								ub.upload_btn2,
								ub.upload_btn4,
								ub.upload_btn5 ];*/
			_uploadBtns =  [	ub.upload_btn1,
				ub.upload_btn2,
				ub.upload_btn3,
				ub.upload_btn4,
				ub.upload_btn5 ];
			_croppedBitmaps = [];
			_savedHeads = [null,null,null,null,null];
			App.listener_manager.add_multiple_by_object(_uploadBtns, MouseEvent.CLICK, _onUploadBtnsClicked, this);
			App.ws_art.makeAnother.btn_upload.addEventListener(MouseEvent.CLICK, _startUploadProcess);
			//App.ws_art.dancers.visible = true;
			expiryTimer = new Timer(ServerInfo.sessionTimeoutSeconds*1000, 1);
			//_setInitialPersistantImages();
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
		private function photoExpired(evt:TimerEvent):void {
			stopExpiryTimer();
			_photoHasExpired = true;
			
		}
		private function _onUploadBtnsClicked(e:MouseEvent):void
		{
			
			_currentHeadIndex = _uploadBtns.indexOf( e.target );
			var ub:MovieClip = App.ws_art.upload_btns;
			var lr:Array =  [	ub.upload_btn1,
				ub.upload_btn2,
				ub.upload_btn3,
				ub.upload_btn4,
				ub.upload_btn5 ];
			//App.mediator.autophoto_mode_browse();
			//WSEventTracker.event("ce"+(lr.indexOf( e.target )+2));
			App.mediator.autophoto_open_mode_selector();
		}
		public function zoomTo(val:Number):void
		{
			_zoomer.scaleTo(val);
		}
		public function rotateTo(degrees:Number):void
		{
			_zoomer.rotateTo(degrees);
		}
		protected function _startUploadProcess(e:MouseEvent):void
		{
			App.mediator.autophoto_open_mode_selector();
		//	_currentHeadIndex++;
			
		}
		protected var _imgLoader:Loader;
		public function beginMasking(url:String):void
		{
			_loadUploadedImage(url);
		}
		protected static const LOADING_UPLOADED_BITMAP:String = "loadingUploadedBitmap";
		private function _loadUploadedImage(url:String):void {
			try 
			{
				//f ( _imgLoader.content ) _imgLoader.unload();
				
				//var context:LoaderContext = new LoaderContext( true );	// this is needed -- when doing BitmapData.draw to avoid error 2122
				//_imgLoader.load(new URLRequest(url), context);
				Gateway.retrieve_Bitmap( url, new Callback_Struct(_imageLoaded) );
				App.mediator.processing_start(LOADING_UPLOADED_BITMAP, "");
			}
			catch (e:Error) {
				onError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}			
		}
		
		/**
		 * 
		 * @param	evt
		 */
		private function onLoadProgress(evt:ProgressEvent):void
		{
			trace("onLoadProgress - " + evt.bytesLoaded);
			//var percent:Number = (evt.bytesTotal == 0)?0:(evt.bytesLoaded / evt.bytesTotal);
			
			//	dispatchEvent(new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.BG, percent));
		}
		protected function onError(evt:ErrorEvent):void {
			///	dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.BG));
			//	dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9tp311", "Could not load BG : "+evt.text));
		}
		public function imageLoaded( bitmap:Bitmap ):void
		{
			if(bitmap) _imageLoaded(bitmap);
			else App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "0001", "Your image has a problem, please try again"));
		}
		protected function _imageLoaded( bmp:Bitmap ):void
		{
			trace("BITMAP LOADED BEFORE RESIZE: width:"+bmp.width);
			
			//var bmp:Bitmap = new Bitmap(((evt.target as LoaderInfo).content as Bitmap).bitmapData, "auto", true);
			if(_zoomer) 	_zoomer.destroy();
			if(_photoHold) 	_photoHold.destroy();
			
			_photoHold = new CasaSprite();
			
			var scaled:Rectangle = RatioUtil.scaleToFill(bmp.bitmapData.rect, new Rectangle(0,0,display_size.x, display_size.y));
			// create a new smooth guy
			bmp = new Bitmap(bmp.bitmapData.clone(), "auto", true);
			bmp.width = scaled.width;
			bmp.height = scaled.height;
			
			bmp.x = -Math.round((bmp.width/2) );
			bmp.y = -Math.round(bmp.height/2);
			_photoHold.x = Math.round(display_size.x/2);
			_photoHold.y = Math.round(display_size.y/2);
			
			_photoHold.addChild(bmp);
			
			
			_zoomer = new MoveZoomUtil( _photoHold );
			_uploadedBitmap = bmp;
			
			App.mediator.autophoto_position_photo();
			App.mediator.processing_ended(LOADING_UPLOADED_BITMAP);
			
		}
		
		/**
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** interface calls */
		/**
		 * changes the masking property based on the type of OA1 file
		 * @param	_type	wsmodelstruct oa1 type
		 */
		public function set_model_type( _type:int ):void 
		{	
			/* DECIDED ON 2010.06.10 THAT MODELS OA1 TYPE SHOULD NOT DETERMINE AUTOPHOTO MASKING MODE
			model_type = _type;
			if (
					api_apc &&	// pass commands to the APC only if its loaded
					ServerInfo.autoPhoto_mask_mode > 0	// masking has to be turned on via admin for this
				)
			{	switch (model_type) 
				{	case WSModelStruct.OA1TYPE_FULLPHOTO:	api_apc.setMaskingStepActive(false);	break;
					case WSModelStruct.OA1TYPE_MASKEDPHOTO:	api_apc.setMaskingStepActive(true);		break;
					case WSModelStruct.OA1TYPE_FACEONLY:	api_apc.setMaskingStepActive(false);	break;
				}
			}*/
		}
		public function load_and_init( _apc_url:String, _callback:Callback_Struct ):void 
		{	
			//do this so we can loop through later
			
			ignore_apc_processing_updates = false;
			_apc_url += "&w=" + display_size.x + "&h=" + display_size.y;
			if (api_ready)
			{	_callback.fin();
				return;
			}
			var app_domain:ApplicationDomain = apc_domain;	// application domain of the swf that has the art classes in it
			var context:LoaderContext = new LoaderContext(false, app_domain );
			var load_retries:int = 1;
			//Gateway.download_Object( new Gateway_Request( _apc_url, new Callback_Struct( apc_loaded, _callback.progress, error ), load_retries, context ) );
			Gateway.retrieve_Loader( new Gateway_Request( _apc_url, new Callback_Struct( apc_loaded, _callback.progress, error ), load_retries, context ) );
			
			function error(_msg:String):void 
			{	_callback.error();
			}
			function apc_loaded( _loader:Loader ):void 
			{	if (_loader.content)
				{	api_apc = _loader.content as MovieClip;
					configure_apc();
					
					App.mediator.processing_start( APC_PROCESSING_MESSAGE_INITIALIZING );
					on_apc_ready_callback = _callback.fin;
					
					function configure_apc():void 
					{	add_apc_listeners();
						// TELL APC WHAT CUSTOM ART TO USE
							api_apc.setPointPlacementIcon(app_domain, ART_ANCHOR_CLASS_NAME);
							api_apc.setMaskPointIcon(app_domain, ART_MASKING_POINT_CLASS_NAME);
						api_apc.setUploadLimits(10, 6 * 1024); //10Kb min 6Mb max
						// set up model type to be produced
							set_model_type( model_type );
					}
				}
				else 
					_callback.error();
			}
		}
		public function get_display_obj():DisplayObject 
		{	
			return _photoHold;
			api_apc.buttonMode=true;
			return api_apc as DisplayObject;
		}
		public function get uploadedBitmap():Bitmap
		{
			return _uploadedBitmap;
		}
		public function analyze_photo( _url:String ):void 
		{	
			points_submitted_tracked_manually = false;
			App.mediator.processing_start( PROCESS_AUTOPHOTO_GENERIC );
			ignore_apc_processing_updates = false;
			api_apc.uploadImageUrl( _url );
		}
		public function set_display_size( _size:Point ):void
		{	display_size = _size;
		}
		public function get_display_size( ):Point 
		{	return display_size;
		}
		public function position_photo( _dir:String, _amount:int ):void 
			
		{	
			switch (_dir)
			{	case MOVE_UP:					_zoomer.moveBy(0, 0-_amount); break;//	api_apc.startPanning( 0 - _amount, true );	api_apc.stopPanning();		break;
				case MOVE_DOWN:					_zoomer.moveBy(0, _amount); break;//api_apc.startPanning( _amount, true );		api_apc.stopPanning();		break;
				case MOVE_RIGTH:				_zoomer.moveBy(_amount, 0); break;//api_apc.startPanning( _amount, false );		api_apc.stopPanning();		break;
				case MOVE_LEFT:					_zoomer.moveBy(0-_amount, 0); break;//api_apc.startPanning( 0 - _amount, false );	api_apc.stopPanning();		break;
				case ZOOM_IN:					_zoomer.scaleTo(_zoomer.scale+(_zoomer.scale*.035)); break;//api_apc.startZooming( _amount );			api_apc.stopZooming();		break;
				case ZOOM_OUT:					_zoomer.scaleTo(_zoomer.scale-(_zoomer.scale*.035)); break;//api_apc.startZooming( 0 - _amount );		api_apc.stopZooming();		break;
				case ROT_CLOCKWISE:				_zoomer.rotateBy(_amount); break;//api_apc.rotate( _amount );					break;
				case ROT_COUNTER_CLOCKWISE:		
					_zoomer.rotateBy(0-_amount); 
					break;//api_apc.rotate( 0 - _amount );				break;
				case RESET_IMAGE:				_resetZoomer(); break;
				default:
			}
			
		}
		protected function _resetZoomer():void
		{
			//_photoHold.x = -bmp.x;
			//_photoHold.y = -bmp.y;
			_zoomer.x = -_photoHold.getChildAt(0).x;
			_zoomer.y = -_photoHold.getChildAt(0).y;
			_zoomer.scale = 1;
			_zoomer.rotation = 0;
		}
		protected var _zoomer			:MoveZoomUtil;
		protected var _photoHold		:CasaSprite;
		protected var _uploadedBitmap	:Bitmap;
		protected var _positionedBitmap	:Bitmap;
		protected var _currentHeadIndex	:Number = -1;	
		protected var _uploadBtns:Array;
		public function get headIndex():Number
		{
			return _currentHeadIndex;
		}
		public function submit_photo_position(  ):void
		{	
			//ignore_apc_processing_updates = false;
			//api_apc.submit();
			//current_session_id = api_apc.getSessionId();
			
			var data:BitmapData = new BitmapData(display_size.x, display_size.y, true, 0x000000);
			data.draw(_photoHold.parent);
			
			_positionedBitmap = new Bitmap(data, "auto", true);
			
			//App.ws_art.stage.addChild(new Bitmap(_positionedBitmap.bitmapData.clone(), "auto", true));
			App.mediator.autophoto_mask( _positionedBitmap );
		}
		public function submit_photo_points(  ):void
		{
			ignore_apc_processing_updates = false;
			points_submitted_tracked_manually = true;
			api_apc.submitWithPoints();
			WSEventTracker.event("edapps");
		}
		public function submit_mask_points(  ):void
		{
			ignore_apc_processing_updates = false;
			//handle_apc_processing( '', 0 );
			//api_apc.submitMask();
		}
		public function is_loaded(  ):Boolean
		{	return (api_apc != null && api_ready);
		}
		public function restart_apc(  ):void
		{
			_photoHold = null;
			_uploadedBitmap = null;
			_positionedBitmap = null;
			_zoomer = null;
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** PRIVATEERS */
		/**
		 *	handler for all the events dispatched from the APC.swf module 
		 * @param _e
		 * 
		 */		
		private function apc_event_handler( _e:Object ):void 
		{	
			switch( _e.type )
			{	
				case AutophotoEvent.ON_APC_READY:					// starting point, everything before this is fatal
																	ignore_apc_processing_updates = true;
																	api_ready = true;
																	App.mediator.processing_ended( APC_PROCESSING_MESSAGE_INITIALIZING );
																	if (on_apc_ready_callback != null)
																		on_apc_ready_callback();
																	break;
																	
				case AutophotoEvent.PROCESSING_PROGRESS:			// retrive indicative params
																		var message:String	= _e.data.msg;
																		var percent:int		= _e.data.percent;
																	if (!ignore_apc_processing_updates)
																		handle_apc_processing( message, percent );
																	break;
																	
				case AutophotoEvent.PHOTO_FILE_DOWNLOADED:			ignore_apc_processing_updates = true;
																	App.mediator.processing_ended( PROCESS_AUTOPHOTO_GENERIC );
																	App.mediator.autophoto_position_photo();
																	WSEventTracker.event("edapu");
																	photo_expiration_start_timer();
																	break;
				
				case AutophotoEvent.ON_DONE:						ignore_apc_processing_updates = true;
																	App.mediator.processing_ended( PROCESS_AUTOPHOTO_GENERIC );
																	if (!points_submitted_tracked_manually)
																		WSEventTracker.event("edapps");	// points were submitted either manually or figured out by luxend
																	load_autophoto_generated_model();
																	WSEventTracker.event("edap");
																	photo_expiration_stop_timer();
																	break;
				
				case AutophotoEvent.ON_POINTS:						ignore_apc_processing_updates = true;
																	App.mediator.processing_ended( PROCESS_AUTOPHOTO_GENERIC );
																	App.mediator.autophoto_position_points();
																	WSEventTracker.event("edappp");
																	break;
				
				case AutophotoEvent.OVERALL_PROCESSING_PROGRESS:	overall_percent = _e.data.percent;
																	break;
																	
				case AutophotoEvent.ON_MASK:						ignore_apc_processing_updates = true;
																	App.mediator.processing_ended( PROCESS_AUTOPHOTO_GENERIC );
																	App.mediator.autophoto_position_mask_points();
																	break;
				
				case AutophotoEvent.PHOTO_FILE_UPLOAD_ERROR:		
				case AutophotoEvent.ON_REDO_POSITION:				
				case AutophotoEvent.ON_ERROR:						ignore_apc_processing_updates = true;
																	App.mediator.processing_ended( PROCESS_AUTOPHOTO_GENERIC );
																	apc_error( _e.data.id, _e.data.msg );
																	break;
			}
		}
		/**
		 * handle locally what the message and percent should be displayed to the user
		 * @param	_message	message from the APC
		 * @param	_percent	percent from the APC
		 */
		private function handle_apc_processing( _message:String, _percent:int ):void 
		{
			var matched_expression:String;
			// match it with one of the expected values
				if		(_message.toLowerCase().indexOf('retrieving') >= 0)	matched_expression = APC_PROCESSING_MESSAGE_RETRIEVING;
				else if	(_message.toLowerCase().indexOf('submitting') >= 0)	matched_expression = APC_PROCESSING_MESSAGE_SUBMITTING;
				else if	(_message.toLowerCase().indexOf('queued') >= 0)		matched_expression = APC_PROCESSING_MESSAGE_QUEUED;
				else if	(_message.toLowerCase().indexOf('analyzing') >= 0)	matched_expression = APC_PROCESSING_MESSAGE_ANALYZING;
				else if	(_message.toLowerCase().indexOf('converting') >= 0)	matched_expression = APC_PROCESSING_MESSAGE_CONVERTING;

			// handle the different cases... 
				var processing_message:String;
				var processing_percent:int;
				switch (matched_expression) 
				{
					case APC_PROCESSING_MESSAGE_RETRIEVING:
								processing_message = App.settings.APC_PROCESSING_MESSAGE_RETRIEVING;
								processing_percent = _percent;
								stop_fake_processing();
								App.mediator.processing_start( PROCESS_AUTOPHOTO_GENERIC, processing_message, processing_percent );
								break;
					case APC_PROCESSING_MESSAGE_SUBMITTING:
					case APC_PROCESSING_MESSAGE_QUEUED:
								processing_message = App.settings.APC_PROCESSING_MESSAGE_QUEUED;
								start_fake_processing( processing_message );
								break;
					case APC_PROCESSING_MESSAGE_ANALYZING:
								processing_message = App.settings.APC_PROCESSING_MESSAGE_ANALYZING;
								processing_percent = overall_percent / 2; // we want this to be from 0-50%
								stop_fake_processing();
								App.mediator.processing_start( PROCESS_AUTOPHOTO_GENERIC, processing_message, processing_percent );
								break;
					case APC_PROCESSING_MESSAGE_CONVERTING:
								processing_message = App.settings.APC_PROCESSING_MESSAGE_CONVERTING;
								processing_percent = (overall_percent / 2) + 50; // we want this to be from 50-100%
								stop_fake_processing();
								App.mediator.processing_start( PROCESS_AUTOPHOTO_GENERIC, processing_message, processing_percent );
								break;
					default:	
								processing_message = _message;	// no case present for this type of message
								stop_fake_processing();
								App.mediator.processing_start( PROCESS_AUTOPHOTO_GENERIC, processing_message, processing_percent );
				}
		}
		/* indicates if the fake processing is currently running */
		private var fake_apc_processing_running:Boolean = false
		private function start_fake_processing( _message:String ):void 
		{
			if (!fake_apc_processing_running) // already started
			{
				fake_apc_processing_running = true;
				App.mediator.processing_start( PROCESS_AUTOPHOTO_GENERIC, _message, 99, 30 );
			}
			else
			{
				// dont do anything since were faking it.. woop woop
			}
		}
		private function stop_fake_processing():void 
		{
			if (fake_apc_processing_running)
			{
				fake_apc_processing_running = false;
				App.mediator.processing_ended( PROCESS_AUTOPHOTO_GENERIC );
			}
		}
		private function add_apc_listeners():void 
		{	
			App.listener_manager.add_listeners_for_all_event_types( api_apc, AutophotoEvent, apc_event_handler, this );
		}
		private function load_autophoto_generated_model(  ):void
		{
			App.mediator.autophoto_close( true );
			api_apc.getCharXML( char_xml_loaded );
			function char_xml_loaded( _xml:XML ) : void
			{
				if (_xml &&
					_xml.name() == 'fgchar')
				{
					App.mediator.build_model_from_xml( _xml, false, current_session_id, model_type );
					App.mediator.autophoto_track_image_source_type();
				}
				else
				{
					App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9tp203', 'Error loading autophoto model', { details:_xml } ) );
				}	
			}
		}
		private function apc_error( _id:String, _msg:String ):void 
		{
			if (!api_ready)	// this is an error prior to the apc being ready therefore this was a fatal error
			{
				App.mediator.processing_ended( APC_PROCESSING_MESSAGE_INITIALIZING );
				destroy_apc();
				App.mediator.autophoto_close(true);
			}	
			App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, _id, _msg, { sessionId:current_session_id } ));
			WSEventTracker.event("edaper");
		}
		private function destroy_apc():void
		{
			App.listener_manager.remove_all_listeners_on_object(api_apc);
			if (api_apc.parent)
				api_apc.parent.removeChild(api_apc);
			api_apc = null;
		}
		private function photo_expiration_start_timer():void 
		{
			var timeout_ms:Number	= ServerInfo.sessionTimeoutSeconds * 1000;
			var expired_fn:Function	= photo_has_expired;
			photo_expiration.add_event( PHOTO_EXPIRED_EVENT_NAME, timeout_ms, expired_fn );
		}
		public function photo_expiration_stop_timer():void 
		{
			photo_expiration.remove_event(PHOTO_EXPIRED_EVENT_NAME);
		}
		private function photo_has_expired():void 
		{
			App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t204", "Your photo has expired.  Please submit the photo again."));
			App.mediator.autophoto_back_to_upload();
		}
		private const PROCESS_UPLOADING			:String = 'PROCESS_UPLOADING uploading autophoto image';
		public function saveHead( bmp:Bitmap, makePersistant:Boolean = true, cutPoint:Number = -1 ):void
		{
			_currentHeadIndex++;
			if(_currentHeadIndex > 4 ) _currentHeadIndex = 0;
			
			var img_data:ByteArray = PNGEncoder.encode( bmp.bitmapData );
			var saver:HeadSaver = new HeadSaver(_currentHeadIndex, cutPoint);
			saver.addEventListener(Event.COMPLETE, onSaved);
			
//			var clip:* = App.ws_art.dancers.getChildByName("face_"+(_currentHeadIndex+1));
//			var hold:MovieClip= (clip.getChildByName("head_hold") as MovieClip);
//			for(var i:Number = 0; i<hold.numChildren; i++)
//			{
//				if(hold.getChildAt(i) != null) hold.removeChildAt(i);
//			}
//			hold.addChild(bmp);
			
			function onSaved(e:Event):void
			{
				var struct:HeadStruct = new HeadStruct(bmp, (e.target as HeadSaver).url, null, (e.target as HeadSaver).cutPoint);
				_savedHeads[(e.target as HeadSaver).index] =  struct;
				App.asset_bucket.last_mid_saved = null;
				App.ws_art.processing.authored_creation.visible = false;
				
				if(makePersistant)	addPersistantImage( struct );	
				
				App.mediator.gotoPreview();
				App.mediator.processing_ended( PROCESS_UPLOADING );
			}
			
			if (img_data == null)
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t201', 'Error saving image.'));
			else
			{
				App.mediator.processing_start( PROCESS_UPLOADING);
				App.utils.image_uploader.upload_binary( new Callback_Struct( saver.fin, saver.progress, saver.error ), img_data, "png");
				App.ws_art.processing.authored_creation.visible = true;
			}
		}
		public function addPersistantImage(head:HeadStruct):void
		{
			if( _persistantImages == null ) _persistantImages = [];
			
			var add:Boolean = true;
			
			for( var i:Number = 0; i< _persistantImages.length; i++)
			{
				var h:HeadStruct = _persistantImages[i];
				if(h) 
					if (h.url == head.url) add = false;
			}
			if(add) 
			{
				//var mouth:* = head.mouth;
				//App.ws_art.addChild(mouth);
				_persistantImages.unshift( head );
				
			}
		}
		
		public function setInitialPersistantImages(heads:Array):void
		{
			
			// this needs to be rethought;
			_persistantImages = [];
			//if(_defaultHeadThumbs.length == 0)	_defaultHeadThumbs = [new default_1(), new default_2(), new default_3(), new default_4(), new default_5()];
			for(var i:Number = 0; i<heads.length; i++)
			{
				var bmp:* = heads[i]
				var hstruct:HeadStruct = new HeadStruct(bmp, "head"+(i+1));
				addPersistantImage(hstruct);
			}
			
		
		}
		protected var _savedHeads:Array;
		public function get croppedBitmaps():Array
		{
			return _croppedBitmaps;
		}

		public function set croppedBitmaps(value:Array):void
		{
			_croppedBitmaps = value; 
		}

		public function get savedHeads():Array
		{
			return _savedHeads;
		}

		public function set savedHeads(value:Array):void
		{
			_savedHeads = value;
		}

		public function get photoHasExpired():Boolean
		{
			return _photoHasExpired;
		}

		public function set photoHasExpired(value:Boolean):void
		{
			_photoHasExpired = value;
		}
		protected var _persistantImages:Array;
		public function get persistantImages():Array
		{
			return _persistantImages;
		}

		public function get currentHeadIndex():Number
		{
			return _currentHeadIndex;
		}

		public function set currentHeadIndex(value:Number):void
		{
			_currentHeadIndex = value;
		}


		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		*/
		
	}

}
import code.skeleton.App;

import com.oddcast.assets.structures.BackgroundStruct;
import com.oddcast.event.AlertEvent;

import flash.events.Event;
import flash.events.EventDispatcher;

class HeadSaver extends EventDispatcher
{
	public var index:Number;
	public var url	:String;
	public var cutPoint:Number = -1;
	
	public function HeadSaver(_index:Number, _cutPoint:Number):void
	{
		index = _index;
		cutPoint = _cutPoint;
	}
	public function fin(_bg:*):void 
	{	//App.mediator.processing_ended( PROCESS_UPLOADING );
		url = _bg.url;
		dispatchEvent( new Event(Event.COMPLETE) );
		
	}
	public function progress(_percent:int):void 
	{	//App.mediator.processing_start( PROCESS_UPLOADING, null, _percent );
		App.ws_art.processing.authored_creation.visible = true;
	}
	public function error(_e:AlertEvent):void 
	{	//App.mediator.processing_ended( PROCESS_UPLOADING );
		App.mediator.alert_user(_e);
	}
	
}
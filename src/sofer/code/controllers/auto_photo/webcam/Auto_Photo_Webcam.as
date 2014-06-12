package code.controllers.auto_photo.webcam 
{
	import code.controllers.auto_photo.Auto_Photo_Constants;
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.assets.structures.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.system.*;
	import flash.utils.*;
	
	import org.casalib.util.AlignUtil;
	import org.casalib.util.RatioUtil;

	/**
	 * ...
	 * @author Me^
	 */
	public class Auto_Photo_Webcam implements IAuto_Photo_Webcam
	{
		private var ui							:Webcam_UI;
		private var webcam_capture				:WebcamCapture;
		private var scaled_width				:Number;
		private var scaled_height				:Number;
		private var webcam_is_initialized		:Boolean = false;
		private var webcam_is_available			:Boolean = false;
		private const WEBCAM_HEIGHT				:int = 768;
		private const WEBCAM_WIDTH				:int = 1024;
		private const USE_USERS_DEFAULT_CAMERA	:Boolean = true;
		private const SAVED_IMAGE_TYPE			:String = 'jpg';
		private const PROCESS_UPLOADING			:String = 'PROCESS_UPLOADING uploading autophoto image';
		
		
		public function Auto_Photo_Webcam( _ui:Webcam_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui		= _ui;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				init();
			}
		}
		protected var _displaySize:Rectangle;
		private function init(  ):void 
		{	
			App.listener_manager.add_multiple_by_object([	ui.btn_next,
															ui.btn_capture,
															ui.btn_recapture,
															ui.btn_close,
															ui.btn_back] , MouseEvent.CLICK, btn_handler, this);
			_displaySize = new Rectangle(0,0,ui.placeholder_webcam.width, ui.placeholder_webcam.height);
			build_webcam_component();
			prepare_webcam_size( true );
			center_camera();
		}
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERFACE */
		public function open_win(  ):void
		{
			App.localizer.localize(this.ui, "webcam");
			clear_webcam();
			toggle_capture_btn( ui.btn_capture );
			if (!webcam_is_initialized)
			{	webcam_is_available = webcam_capture.init(WEBCAM_WIDTH, WEBCAM_HEIGHT, USE_USERS_DEFAULT_CAMERA);
				webcam_is_initialized = true;
			}
			// clearing current webcam (if it's there)
			
			
			WSEventTracker.event("uiwci");
			track_webcam_usage( webcam_is_available );
			
			if (!webcam_is_available)
			{
				if (!webcam_capture.cameraAvailable)
					App.mediator.alert_user( new AlertEvent(AlertEvent.ALERT, 'f9t200', 'Camera not available.'));
				else
					App.mediator.alert_user( new AlertEvent(AlertEvent.ALERT, 'f9t205', 'Your camera model is not supported by Adobe.', { cameras:webcam_capture.cameraNames.join(',') } ));
				
				// destroy so that next time this is requested it can reinitialize since the user might have plugged in their webcam
					webcam_capture.destroy();
					webcam_is_initialized = false;
					close_win();
					App.mediator.autophoto_open_mode_selector();
			}
			else
			{
				ui.visible = true;
				App.listener_manager.add(Camera.getCamera(), StatusEvent.STATUS, onStatus, this);
				App.listener_manager.add(Camera.getCamera(), ActivityEvent.ACTIVITY, onStatus, this);
				App.listener_manager.add(webcam_capture, Webcamera.WEBCAM_ACTIVATE, webcam_active_handler, this);
				App.listener_manager.add(webcam_capture, Webcamera.WEBCAM_DEACTIVATE, webcam_active_handler, this);
				webcam_capture.activate( true );
				prepare_webcam_size(false);
				//webcam_capture.width 	= scaled_width;
				//webcam_capture.height	= scaled_height;
				center_camera();
				webcam_capture.bitmap = null;
				if (webcam_capture.activated)	activate_camera_ui( true );
				else
				{
					Security.showSettings( SecurityPanel.PRIVACY );
					activate_camera_ui( false );
					App.mediator.autophoto_open_mode_selector();
				}
			}
		}
		public function close_win(  ):void
		{
			ui.visible = false;
			if (webcam_is_initialized && webcam_capture)
				webcam_capture.activate(false);
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
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERNALS */
		private function btn_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case ui.btn_next:				
											upload_captured_image();
											break;
				case ui.btn_capture:			capture_webcam_image();
												
											break;
				case ui.btn_recapture:				clear_webcam();
												capture_webcam_image();
												
											break;
				case ui.btn_back:				close_win();
												App.mediator.autophoto_open_mode_selector();
												break;
				case ui.btn_close:
					App.mediator.autophoto_close(true);
					break;
			}
		}
		public function onStatus(event:Event):void
		{
			
			webcam_capture.activate( Camera.getCamera() != null );
			
			if(Camera.getCamera() == null || !webcam_capture.activated )
			{
			//	close_win();
			//	App.mediator.autophoto_open_mode_selector();
			//	return;
			}
			activate_camera_ui( webcam_capture.activated );
		}
		private function toggle_capture_btn( _btn:InteractiveObject ):void
		{
			ui.btn_capture.visible		= _btn == ui.btn_capture;
			ui.btn_recapture.visible		= _btn == ui.btn_recapture;
		}
		/**
		 *instantiate a new webcam, and size it to the size of the placeholder
		 * 
		 */		
		private function build_webcam_component(  ):void
		{
			webcam_capture			= new WebcamCapture();
			// cant set width and height of an empty display obj... you need something in it
			webcam_capture.graphics.beginFill(0xa3a3a3,0);
			webcam_capture.graphics.drawRect(0,0,ui.placeholder_webcam.width,ui.placeholder_webcam.height);
			webcam_capture.graphics.endFill();
			ui.placeholder_webcam.addChild(webcam_capture);
		}
		/**
		 * prepares the webcam for initialization (size)
		 * @param	_force_ratio if to prevent distorion of the image by keeping it a 4:3 ratio
		 */
		private function prepare_webcam_size( _force_ratio:Boolean ):void
		{
			_force_ratio=  false;
			if (_force_ratio)
			{
				var w_ratio:Number	= webcam_capture.width / 4;		// width ratio of 4
				var h_ratio:Number	= webcam_capture.height / 3;	// width ratio of 3
				
				// base on smallest of the ratios
					//if (w_ratio > h_ratio)	webcam_capture.width	= h_ratio * 4;
					//else					webcam_capture.height	= w_ratio * 3;
			}
			var scaler:Rectangle = RatioUtil.scaleToFill( new Rectangle(0,0,webcam_capture.width, webcam_capture.height),_displaySize);
			
			
			scaled_width	= scaler.width;
			scaled_height	= scaler.height;
		}
		/**
		 *center the webcam inside the placeholder 
		 * 
		 */		
		private function center_camera(  ):void
		{
			webcam_capture.y = (_displaySize.height - webcam_capture.height) / 2;
			webcam_capture.x = (_displaySize.width - webcam_capture.width)/2;
		}
		private function clear_webcam(  ):void
		{
			webcam_capture.clear();
		}
		private function track_webcam_usage( _cam_is_available:Boolean ):void
		{
			var webcam_name:String = _cam_is_available ? webcam_capture.cameraName : '';
			var camera_event:AlertEvent = new AlertEvent(AlertEvent.EVENT, '', '', { Available:_cam_is_available, Name:webcam_name } );
			App.mediator.report_error(camera_event, 'Webcam Initialization Information');
		}
		private function activate_camera_ui( _active:Boolean ):void
		{
			if(_active)
			{
				App.ws_art.auto_photo_mode_selector.visible = false;
				App.ws_art.dancers.visible = false; 
			//	close_win();
			}
			ui.visible = 
			ui.placeholder_webcam.visible	=
			ui.btn_capture.visible			= 
			ui.btn_next.visible = _active;
		}
		private function webcam_active_handler( _e:Event ):void
		{
			switch ( _e.type )
			{	
				case Webcamera.WEBCAM_ACTIVATE:		activate_camera_ui(true);	break;
				case Webcamera.WEBCAM_DEACTIVATE:	
					activate_camera_ui(false);	
					//close_win();
					App.mediator.autophoto_open_mode_selector();
					break;
			}
		}
		
		private function capture_webcam_image( continueAfter:Boolean = false ):void
		{
			ui.shutter.addEventListener("shoot", _onShutter);
			ui.shutter.gotoAndPlay(2);
			toggle_capture_btn( ui.btn_recapture );
			ui.btn_capture.visible = false;
			ui.btn_recapture.mouseEnabled = ui.btn_next.mouseEnabled = ui.btn_back.mouseEnabled = false;
			ui.btn_recapture.alpha = ui.btn_next.alpha = ui.btn_back.alpha = .5;
			//ui.btn_recapture.visible = false;
			function _onShutter(e:Event = null):void
			{
				ui.shutter.removeEventListener("shoot", _onShutter);
				webcam_capture.capture();
				ui.shutter.gotoAndStop(1);
				ui.btn_recapture.mouseEnabled = ui.btn_next.mouseEnabled = ui.btn_back.mouseEnabled = true;
				ui.btn_recapture.alpha = ui.btn_next.alpha = ui.btn_back.alpha = 1;
				WSEventTracker.event('uiwcc');
				if(continueAfter)  upload_captured_image();
			}
		}
		
		private function upload_captured_image():void
		{
			if( webcam_capture.bitmap == null ) 
			{	
				capture_webcam_image(true);
				return;
			}
			//var img_data:ByteArray = webcam_capture.getJPG();
			
			if (webcam_capture.bitmap.bitmapData == null)
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t201', 'Error capturing image.'));
			else
			{
				//App.mediator.processing_start( PROCESS_UPLOADING );
				
			
				
				App.mediator.autophoto_begin_process(webcam_capture.bitmap);
				
				/*App.utils.image_uploader.upload_binary( new Callback_Struct( fin, progress, error ), img_data, SAVED_IMAGE_TYPE);
				function fin(_bg:BackgroundStruct):void 
				{	App.mediator.processing_ended( PROCESS_UPLOADING );
					App.mediator.autophoto_analyze_photo( _bg.url );
					App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_WEBCAM );
				}
				function progress(_percent:int):void 
				{	App.mediator.processing_start( PROCESS_UPLOADING, null, _percent );
				}
				function error(_e:AlertEvent):void 
				{	App.mediator.processing_ended( PROCESS_UPLOADING );
					App.mediator.alert_user(_e);
				}*/
			}
			clear_webcam();
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
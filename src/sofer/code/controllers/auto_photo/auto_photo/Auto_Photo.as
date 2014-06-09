package code.controllers.auto_photo.auto_photo 
{
	import code.controllers.auto_photo.Auto_Photo_Constants;
	import code.models.*;
	import code.skeleton.*;
	import code.skeleton.mediator.Mediator;
	
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.throttle.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Auto_Photo implements IAuto_Photo
	{
		private var btn_open			:DisplayObject;
		
		private const PROCESS_LOADING_APC			:String = 'PROCESS_LOADING_APC';
		private const PROCESS_LOADING_APC_MSG		:String = 'Loading component...';
		
		/** current image source type used */
		private var current_image_source_type:String;
		
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INITIALIZATION */
		public function Auto_Photo( _btn_open:InteractiveObject ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			btn_open	= _btn_open;
			
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
		protected var _uploadBtns:Array;
		private function init(  ):void 
		{	
			App.listener_manager.add(btn_open, MouseEvent.CLICK, btn_handler, this);
			
			_imgLoader = new Loader();
			_imgLoader.contentLoaderInfo.addEventListener(Event.INIT, _imageLoaded, false, 0, true);
			_imgLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError,false,0,true);
			_imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			_imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			
		}
		protected var _imgLoader:Loader
		public function beginMasking(url:String):void
		{
			_loadUploadedImage(url);
		}
		private function _loadUploadedImage(url:String):void {
			try 
			{
				if ( _imgLoader.content ) _imgLoader.unload();
			
				var context:LoaderContext = new LoaderContext( true );	// this is needed -- when doing BitmapData.draw to avoid error 2122
				_imgLoader.load(new URLRequest(url), context);
				
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
			var percent:Number = (evt.bytesTotal == 0)?0:(evt.bytesLoaded / evt.bytesTotal);
		//	dispatchEvent(new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.BG, percent));
		}
		protected function onError(evt:ErrorEvent):void {
		///	dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.BG));
		//	dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9tp311", "Could not load BG : "+evt.text));
		}
		protected function _imageLoaded(evt:Event):void
		{
			var bmp:Bitmap = new Bitmap(((evt.target as LoaderInfo).content as Bitmap).bitmapData, "auto", true);
			App.mediator.autophoto_mask( bmp );
			
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
		***************************** INTERFACE METHODS */
		public function image_source_type( _type:String ):void 
		{
			current_image_source_type = _type;
		}
		public function track_image_source_type():void 
		{
			if (current_image_source_type)
				WSEventTracker.event
				(
					current_image_source_type == Auto_Photo_Constants.IMAGE_SOURCE_TYPE_HARD_DRIVE 		? 'edsrhd' :
					current_image_source_type == Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SEARCH 			? 'edsrse' :
					current_image_source_type == Auto_Photo_Constants.IMAGE_SOURCE_TYPE_SOCIAL_MEDIA 	? 'edsrsm' :
					current_image_source_type == Auto_Photo_Constants.IMAGE_SOURCE_TYPE_PHOTOBUCKET 	? 'edsrpb' :
					current_image_source_type == Auto_Photo_Constants.IMAGE_SOURCE_TYPE_PERSISTENT 		? 'edsrpp' :
					current_image_source_type == Auto_Photo_Constants.IMAGE_SOURCE_TYPE_STATIC_LIBRARY 	? 'edsrpl' :
					current_image_source_type == Auto_Photo_Constants.IMAGE_SOURCE_TYPE_WEBCAM		 	? 'edsrwc' :
					''
				);
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
		***************************** PRIVATE METHODS */
		private function btn_handler( _e:MouseEvent = null ):void
		{
			switch ( _e.target )
			{	
				case btn_open:		
					open_win();		
					break;
			}
		}
		private function open_win(  ):void 
		{	
			/*if (autophoto_allowed_to_open())
			{
				if (!App.mediator.autophoto_is_apc_loaded())	// only if its not loaded already
				{	Throttler.autophoto_open_allowed( load_apc, no_capacity, no_capacity);
					function no_capacity():void
					{	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, null, "Server capacity surpassed.  Please try again later."));
					}
				}
				else
					apc_ready_open_default_views();
			}
			
			function autophoto_allowed_to_open(  ):Boolean
			{
				if (
						!ServerInfo.is3D ||
						!App.mediator.scene_editing.model ||
						!App.mediator.scene_editing.model.has_head_data()
					)
				{
					App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t536', "This feature is not available") );
					return false;
				}
				return true;
			}
		*/
		}
		private function apc_ready_open_default_views(  ) : void
		{
			App.mediator.autophoto_open_mode_selector();
			App.mediator.autophoto_mode_browse();	// open this by default
		}
		private function load_apc():void 
		{	// check if the apc is set up to be loaded
			
				if (ServerInfo.autophotoAppId == ServerInfo.NO_VALUE_NUM || ServerInfo.autoPhotoURL == ServerInfo.NO_VALUE_STRING )
				{	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, null, "Autophoto is not set up properly for this application"));
					return;
				}
			
			//Bridge_Engine.logic_mediator.processing_start( PROCESS_LOADING_APC, PROCESS_LOADING_APC_MSG );
			//APC parameters
				var dragOffCenter	:Boolean		= false; //set this to true if you don't want to constrain the photo to the APC box
			var apc_url:String = ServerInfo.autoPhotoURL + "APC.swf" +
									"?appId=" + ServerInfo.autophotoAppId + 
									"&output=1" +
									"&pd=" + ServerInfo.contentURL + 
									"&dragOffCenter=" + (dragOffCenter?1:0) + 
									"&loadFUC=0" + 
									'&erVer=2.0' +
									'&apd=' + ServerInfo.autoPhoto_param_apd +
									'&apad=' + ServerInfo.autoPhoto_param_apad + 
									'&poll=' + App.settings.APC_POLLING_TIME + 
									'&threshold=' + ( ServerInfo.luxand_threshold ? ServerInfo.luxand_threshold : '' ) + // threshold for going to the points step - a number between 0-100, for testing of luxand at runtime
									get_masking_query() + 
									'&rand=' + Math.floor(Math.random() * 100000).toString();
			App.mediator.autophoto_init_apc( apc_url, new Callback_Struct( loaded, progress, error ));
			function loaded():void 
			{	apc_ready_open_default_views();
			}
			function error():void 
			{	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t531', 'Autophoto could not be loaded at the moment.  Please try again later'));
			}
			function progress( _percent:int ):void 
			{	
			}
			
			/** query specifying masking */
			function get_masking_query(  ):String
			{	var query:String = '';
				if (ServerInfo.autoPhoto_mask_mode > 0) // if 1 or 2 then we mask it
				{	var masking_mode:String;
					switch( ServerInfo.autoPhoto_mask_mode )
					{	case 1:		masking_mode = '';			break;
						case 2:		masking_mode = 'simple';	break;
						case 3:		masking_mode = 'body';		break;
						default:	masking_mode = '';
					}
					query += "&maskingStep=1";
					query += "&maskingStepMode=" + masking_mode;
					query += "&ears=" + (App.settings.APC_MASKING_INCLUDING_EARS?"1":"0");
				}
				else query += "&maskingStep=0";
					
				return query;
			}
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
		*/
		
	}

}
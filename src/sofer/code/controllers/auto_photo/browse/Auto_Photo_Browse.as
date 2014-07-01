package code.controllers.auto_photo.browse 
{
	import code.controllers.auto_photo.Auto_Photo_Constants;
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.assets.structures.*;
	import com.oddcast.event.*;
	import com.oddcast.workshop.*;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Auto_Photo_Browse implements IAuto_Photo_Browse
	{
		private var ui				:Browse_UI;
		private var file_ref				:FileReference;
		private var file_ready				:Boolean;
		private const PROCESS_UPLOADING		:String = 'PROCESS_UPLOADING uploading autophoto image';
		private const PROCESSING_WAITING_FOR_USER	:String = 'Waiting for file selection';
		
		public function Auto_Photo_Browse( _ui:Browse_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui	= _ui;
			
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
		private function init(  ):void 
		{	ui.tf_filename.text = '';
			App.listener_manager.add_multiple_by_object( [	//ui.btn_browse,
															ui.btn_upload
															 ] , MouseEvent.CLICK, btn_handler, this);
			
			init_file_ref();
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
		 ***************************** INTERFACE API */
		public function open_win():void 
		{	//if (ui.visible)	return;	// already displayed
			//ui.visible = true;
			WSEventTracker.event("edbgu");
			init_file_ref();
			file_ref.browse(App.utils.image_uploader.get_file_upload_filter());
			toggle_processing_on_waiting(true);
		}
		public function close_win():void 
		{	ui.visible = false;
			clear_selected_file();
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
		 ***************************** INTERNALS */
		private function toggle_processing_on_waiting( _start:Boolean ):void
		{
			var processing_text:String = App.asset_bucket.model_store.list_errors.get_error_text('f9t546', PROCESSING_WAITING_FOR_USER);
			
			if (_start)
				App.mediator.processing_start( processing_text, processing_text );
			else
				App.mediator.processing_ended( processing_text );
		}
		private function btn_handler( _e:MouseEvent ):void 
		{	switch (_e.target)
			{	case ui.btn_browse:	//	try 			
										//		{	
												file_ref.browse(App.utils.image_uploader.get_file_upload_filter());
												
												toggle_processing_on_waiting(true);
											//	}
												//catch (e:Error) 
												//{	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t502", "Error opening browse window for file upload : "+e.message,{details:e.message}));		}
												break;
				
				case ui.btn_upload:		
												file_ref.browse(App.utils.image_uploader.get_file_upload_filter());
												toggle_processing_on_waiting(true);
												
												if ( file_ready )	// check if the user selected a file
												{	//App.mediator.processing_start( PROCESS_UPLOADING );
													_uploadFileLocally();
												}
												else App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, "f9t210", App.localizer.getTranslation(Localizer.ALERT_FILE_SELECT_BEFORE_PRECEDING) ) );
												break;
				case ui.btn_close:
					App.mediator.autophoto_close(true);
					break;
			}
		}
		private function init_file_ref(  ):void 
		{	
			file_ref = new FileReference();
			App.listener_manager.add( file_ref, Event.SELECT, user_selected_file, this );
			App.listener_manager.add( file_ref, Event.CANCEL, user_cancelled_upload, this );
			App.listener_manager.add( file_ref, IOErrorEvent.IO_ERROR, browse_io_error , this );
			file_ready = false;
			
			
		}
		
		protected function _uploadFileLocally():void
		{
				file_ref.addEventListener ( Event.COMPLETE, _onDataLoaded ) ;
				file_ref.load();
				//_browseTxt.text = String ( evt.target.name ) ;
				
				
				function _onDataLoaded ( evt : Event ) : void
				{
					var tempFileRef : FileReference = FileReference ( evt.target ) ;
					var _loader:Loader = new Loader ( ) ;
					_loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, _onImageLoaded ) ;
					_loader.loadBytes ( tempFileRef.data ) ;
				}
				
				function _onImageLoaded ( evt : Event ) : void
				{
					var _bitmap:Bitmap = Bitmap ( evt.target.content ) ;
					_bitmap.smoothing = true;
					//_bitmap.x = 5;
					App.mediator.autophoto_begin_process(_bitmap);
					close_win();
					//_bitmap.y = _browseTxt.y + _browseTxt.height + 5;
				}
			
		}
		private function user_selected_file( _e:Event ):void 
		{	
			toggle_processing_on_waiting(false);
			ui.tf_filename.text = (file_ref.name) ? file_ref.name : '';
			file_ready = true;
		//	ui.visible = true;
			if ( file_ready )	// check if the user selected a file
			{	
				
				_uploadFileLocally();
				
				/*App.mediator.processing_start( PROCESS_UPLOADING );
				App.utils.image_uploader.upload_file_ref( file_ref, new Callback_Struct(fin, progress, error) );
				function fin(_bg:WSBackgroundStruct):void 
				{	App.mediator.processing_ended( PROCESS_UPLOADING );
					App.mediator.autophoto_analyze_photo( _bg.url );
					App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_HARD_DRIVE );
					close_win();
				}
				function progress(_percent:int):void 
				{	App.mediator.processing_start( PROCESS_UPLOADING, null, _percent );
				}
				function error(_e:AlertEvent):void 
				{	App.mediator.processing_ended( PROCESS_UPLOADING );
					App.mediator.alert_user(_e);
				}*/
			}
			else App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, "f9t210", App.localizer.getTranslation(Localizer.ALERT_FILE_SELECT_BEFORE_PRECEDING)) );
		}
		private function user_cancelled_upload( _e:Event ):void
		{
			toggle_processing_on_waiting(false);
			App.mediator.autophoto_open_mode_selector();
		}
		private function browse_io_error( _e:IOErrorEvent ):void 
		{
			App.utils.image_uploader.upload_failed();
			App.mediator.processing_ended( PROCESS_UPLOADING );
			App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "fue003", "Error uploading file : "+_e.text,{details:_e.text}));
		}
		private function clear_selected_file(  ):void 
		{	App.listener_manager.remove_all_listeners_on_object( file_ref );
			file_ref = null;
			ui.tf_filename.text = '';
			file_ready = false;
		}
		
	}

}
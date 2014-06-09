package code.controllers.bg_browse 
{
	import code.models.Model_Item;
	import code.skeleton.App;
	
	import com.oddcast.assets.structures.BackgroundStruct;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Error;
	import com.oddcast.utils.gateway.Gateway_FileReference_Result;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.WSBackgroundStruct;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class BG_Browse
	{
		private const PROCESS_UPLOADING		:String = 'PROCESS_UPLOADING uploading autophoto image';
		private const PROCESSING_WAITING_FOR_USER	:String = 'Waiting for file selection';
		
		/** user interface */
		private var ui						:BG_Browse_UI;
		/** button triggering the open for this UI */
		private var btn_open				:DisplayObject;
		/** reference to the file from the users machine to be uploaded */
		private var file_ref				:FileReference;
		/** true when a file is successfully selected and ready for upload */
		private var file_ready_for_upload	:Boolean;
		/** shared model with the rest of the App of backgrounds */
		private var model_bg				:Model_Item;
		
		/*******************************************************
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
		 * ******************************** INIT */
		/**
		 * Constructor
		 */
		public function BG_Browse( _btn_open:DisplayObject, _ui:BG_Browse_UI) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
//			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE;
//			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui				= _ui;
			btn_open		= _btn_open;
			model_bg		= App.asset_bucket.model_store.list_backgrounds.model;
			
			// provide the mediator a reference to communicate with this controller
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
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	
			init_ui();
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
		 ***************************** PUBLIC INTERFACE */
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
		 ***************************** PRIVATE */
		
		private function init_file_ref(  ):void 
		{	
			file_ref = new FileReference();
			App.listener_manager.add( file_ref, Event.SELECT, user_selected_file, this );
			App.listener_manager.add( file_ref, Event.CANCEL, user_cancelled_upload, this );
			App.listener_manager.add( file_ref, IOErrorEvent.IO_ERROR, browse_io_error , this );
			file_ready_for_upload = false;
		}
		private function user_selected_file( _e:Event ):void 
		{	
			toggle_processing_on_waiting(false);
			ui.tf_filename.text = (file_ref.name) ? file_ref.name : '';
			file_ready_for_upload = true;
		}
		private function user_cancelled_upload( _e:Event ):void
		{
			toggle_processing_on_waiting(false);
		}
		private function browse_io_error( _e:IOErrorEvent ):void 
		{
			App.utils.image_uploader.upload_failed();
			App.mediator.processing_ended( PROCESS_UPLOADING );
			App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "fue003", "Error uploading file : "+_e.text,{details:_e.text}));
		}
		
		
		
		
		private function browse_for_file():void 
		{
			try 			
			{	
				file_ref.browse(App.utils.image_uploader.get_file_upload_filter());
				toggle_processing_on_waiting(true);
			}
			catch (e:Error) 
			{	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t502", "Error opening browse window for file upload : " + e.message, { details:e.message } ));		}
		}
		private function upload_selected_file():void 
		{
			if (file_ready_for_upload)
			{	
				App.mediator.processing_start( PROCESS_UPLOADING );				
				Gateway.upload_FileReference( new Callback_Struct(fin, progress, error), null, null, file_ref );
				
				function fin( _result:Gateway_FileReference_Result ):void
				{
					App.mediator.processing_ended( PROCESS_UPLOADING );
					var unique_id:int = --App.asset_bucket.bg_counter_id;
					var bg:WSBackgroundStruct = new WSBackgroundStruct( _result.full_url, unique_id, _result.thumb_url );
					//model_bg.add_item( bg );
					App.mediator.scene_editing.loadBG( bg );
				}
				function progress(_percent:int):void 
				{	App.mediator.processing_start( PROCESS_UPLOADING, null, _percent );
				}
				function error( _error:Gateway_Error ):void
				{
					App.mediator.processing_ended( PROCESS_UPLOADING );
					App.mediator.alert_user( new AlertEvent( AlertEvent.ERROR, _error.error_code, _error.error_message, _error.error_text_params ));
				}
			}
			else 
				App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, "f9t210", "Please select an image before proceeding.") );
		}
		
		private function toggle_processing_on_waiting( _start:Boolean ):void
		{
			var processing_text:String = App.asset_bucket.model_store.list_errors.get_error_text('f9t546', PROCESSING_WAITING_FOR_USER);
			
			if (_start)
				App.mediator.processing_start( processing_text, processing_text );
			else
				App.mediator.processing_ended( processing_text );
		}
		/*******************************************************
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
		 * ******************************** VIEW MANIPULATION - PRIVATE */
		private function init_ui():void 
		{
			ui.tf_filename.text = '';
			init_shortcuts();
			set_ui_listeners();
		}
		/**
		 * displays the UI
		 * @param	_e
		 */
		private function open_win(  ):void 
		{	
			ui.tf_filename.text = '';
			init_file_ref();
			ui.visible = true;
			set_tab_order();
			set_focus();
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		private function close_win(  ):void 
		{	
			ui.visible = false;
		}
		private function set_ui_listeners():void 
		{
			App.listener_manager.add_multiple_by_object( 
				[
					btn_open, 
					ui.btn_browse,
					ui.btn_upload,
					ui.btn_close 
				], MouseEvent.CLICK, mouse_click_handler, this );
		}
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case btn_open:		
					open_win();		
					break;
				case ui.btn_browse:
					browse_for_file();
					break;
				case ui.btn_upload:
					upload_selected_file();
					break;
				case ui.btn_close:	
					close_win();	
					break;
			}
		}
		/**
		 *sets the tab order of ui elements 
		 * 
		 */		
		private function set_tab_order():void
		{
			App.utils.tab_order.set_order( [ ui.btn_browse, ui.btn_upload, ui.btn_close ] );
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
		 ***************************** KEYBOARD SHORTCUTS */
		/**
		 * sets stage focus to the UI
		 */
		private function set_focus():void
		{	
			ui.stage.focus = ui;
		}
		/**
		 * initializes keyboard shortcuts
		 */
		private function init_shortcuts():void
		{	
			App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}
		private function shortcut_close_win(  ):void 		
		{	
			if (ui.visible)		
				close_win();	
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
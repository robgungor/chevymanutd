package code.controllers.bg_multiple_upload 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.oc3d.content.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Error;
	import com.oddcast.utils.gateway.Gateway_FileReference_Result;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.throttle.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class BG_Multiple_Upload
	{
		private var btn_open			:InteractiveObject;
		private var model_bgs			:Model_Item;
		private const PROCESSING_WAITING_FOR_USER:String = 'Waiting for file selection';
		
		
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INIT */
		/**
		 * Constructor
		 */
		public function BG_Multiple_Upload( _btn_open:InteractiveObject ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			btn_open		= _btn_open;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			
			
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
		{	App.listener_manager.add( btn_open, MouseEvent.CLICK, btn_handler, this );
			model_bgs = App.asset_bucket.model_store.list_backgrounds.model;
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
		private function btn_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{	
				case btn_open:		browse_multiple();	 break;
			}
		}
		private function toggle_processing_on_waiting( _start:Boolean ):void
		{
			var processing_text:String = App.asset_bucket.model_store.list_errors.get_error_text('f9t546', PROCESSING_WAITING_FOR_USER);
			if (_start)
				App.mediator.processing_start( processing_text, processing_text );
			else
				App.mediator.processing_ended( processing_text );
		}
		private function browse_multiple(  ):void
		{
			Throttler.autophoto_upload_allowed( upload_files, capacity_surpassed, capacity_surpassed );
			function upload_files(  ):void
			{
				if (Throttler.last_response_was_instant)
					build_request(true);
				else
				{
					var alert:AlertEvent = new AlertEvent(AlertEvent.CONFIRM, 'f9t542', 'Click ok to continue', false, build_request);
					alert.report_error = false;
					App.mediator.alert_user( alert );
				}
					
				function build_request(_ok:Boolean):void 
				{
					if (_ok)
					{
						toggle_processing_on_waiting(true);
						Gateway.upload_fileReferenceList( new Callback_Struct( fin, null, error ), App.settings.UPLOAD_MAX_FILES, null, user_cancelled );
					}
				}
				function fin( _gateway_results:Array ):void 
				{	
					toggle_processing_on_waiting(false);
					for (var n:int = _gateway_results.length, i:int = 0; i < n; i++)
					{
						var gr:Gateway_FileReference_Result = _gateway_results[i];
						var unique_id:int = --App.asset_bucket.bg_counter_id;
						model_bgs.add_item( new WSBackgroundStruct( gr.full_url, unique_id, gr.thumb_url ) );
					}
						
					App.listener_manager.add( App.asset_bucket.bg_controller, SceneEvent.BG_LOADED, open_bgs, this);
					var workshop_bgs:Array = model_bgs.get_all_items();
					var last_bg:WSBackgroundStruct = workshop_bgs[workshop_bgs.length - 1];
					App.mediator.scene_editing.loadBG( last_bg );
					
			
					function open_bgs(_e:SceneEvent):void
					{
						App.listener_manager.remove( App.asset_bucket.bg_controller, SceneEvent.BG_LOADED, open_bgs);
						App.mediator.backgrounds_open_win();
					}
				}
				function user_cancelled():void
				{
					toggle_processing_on_waiting(false);
				}
				function error( _error:Gateway_Error ):void
				{
					toggle_processing_on_waiting(false);
					App.mediator.alert_user( new AlertEvent( AlertEvent.ERROR, _error.error_code, _error.error_message, _error.error_text_params ));
				}
			}
			function capacity_surpassed(  ):void
			{
				App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, "", "Server capacity surpassed.  Please try again later."));
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
		* 
		* 
		***************************** KEYBOARD SHORTCUTS */
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
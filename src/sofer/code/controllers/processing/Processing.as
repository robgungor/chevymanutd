package code.controllers.processing 
{
	import code.controllers.auto_photo.search.Auto_Photo_Search;
	import code.controllers.facebook_friend.Facebook_Friend_Search;
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.*;
	
	import custom.DanceScene;
	
	import flash.display.*;
	import flash.events.Event;

	/**
	 * ...
	 * @author Me^
	 */
	public class Processing implements IProcessing
	{
		public var ui				:Processing_UI;
		private var process_queue	:Array = new Array();
		private var tf_tweener		:TexfField_Number_Tweener = new TexfField_Number_Tweener();
		private const OVERALL_PERCENT		:String = 'OVERALL_PERCENT';
		private const OVERALL_PERCENT_MSG	:String = 'Loading...';
		
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
		public function Processing( _ui:Processing_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui = _ui;
			ui.authored_creation.visible = false;
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// settings needed prior to inauguration running
			init_pre_inauguration();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				init_post_inauguration();
			}
		}
		private function init_pre_inauguration():void
		{
			close_win();
			tf_tweener.init( '', '%', ui.tf_percent, 0 );
		}
		private function init_post_inauguration(  ):void 
		{	
			Gateway.init
				(
					gateway_overall_progress, 
					1000, 
					1, 
					ServerInfo.localURL + "api/upload_v3.php",
					ServerInfo.localURL + "api/getUploaded_v3.php",
					App.settings.BG_MAX_SIZE_MB * 1024 * 1024,
					App.settings.BG_MIN_SIZE_KB * 1024,
					5000,
					64,
					ServerInfo.convert_uploaded_images
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
		***************************** INTERFACE API */
		/**
		 * shows the processing window
		 * @param	_process_name		the current process name as there can be others were waiting for (eg: Win_Processing.PROCESS_SAVING_MESSAGE)
		 * @param	_display_process	what process to display to the user
		 * @param	_display_percent	(0-100) what percent to display to the user
		 */
		public function processing_start( _process_name:String, _display_process:String = null, _display_percent:int = -1, _time_to_animate:Number = -1, _show_authored_creation:Boolean = false ):void 
		{	
			App.ws_art.oddcast.visible = true;
			//ui.authored_creation.visible = _show_authored_creation;
			// add process only if its not already present... it can be an update
			if (process_queue.indexOf( _process_name ) < 0)
				process_queue.push( _process_name );
			open_win();
			var window_processes:Array = [Auto_Photo_Search.PROCESS_SEARCHING, 
											DanceScene.DANCES_LOADED, 
											Facebook_Friend_Search.PROCESSING_LOADING_FRIENDS]
			
			// process name
			ui.tf_process.visible = _display_process != null;
			if ( _display_process )
				ui.tf_process.htmlText = _display_process;
				
			// percentage
			ui.tf_percent.visible = _display_percent != -1;
			if (_display_percent != -1 )
			{
				var animation_duration:Number = _time_to_animate == -1 ? 0.5 : _time_to_animate;
				tf_tweener.update_current_tween( _display_percent, animation_duration );//Bridge.modules.processing_UI.tf_percent.text = _display_percent.toString() + '%';
			}
		}
		/**
		 * hides the processing window if all processes in the queue are finished
		 * @param	_process_name the current process name as there can be others were waiting for (eg: Win_Processing.PROCESS_SAVING_MESSAGE)
		 */
		public function processing_ended( _process_name:String ):void 
		{	
			//App.ws_art.oddcast.visible = false;
			var item_index:int = process_queue.indexOf(_process_name);
			if (item_index >= 0)
			{
				process_queue.splice(item_index, 1);
				if (process_queue.length == 0)
				{
					close_win();
					tf_tweener.update_current_tween(0, 0);	// reset the percent to zero so next time it starts from 0 not from the previous value it had (100%);
				}
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
		***************************** PRIVATE */
		/**
		 * displays the overall percent
		 * @param	_percent	0-100%
		 */
		private function gateway_overall_progress( _percent:int ):void 
		{	
			if (_percent == 100)
					processing_ended( OVERALL_PERCENT );
			else	processing_start( OVERALL_PERCENT, OVERALL_PERCENT_MSG, _percent);
		}
		private function close_win(  ):void 
		{	ui.visible = false;
			App.shortcut_manager.enable_shortcuts();
		}
		private function open_win(  ):void 
		{	ui.visible = true;
			App.shortcut_manager.enable_shortcuts( false );
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
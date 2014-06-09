package code.controllers.player 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.workshop.*;
	
	import fl.controls.Button;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Player 
	{
		private var ui			:Player_UI;
		
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
		public function Player( _ui:Player_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			App.listener_manager.add(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED, app_initialized, this);
			
			// reference to controllers UI
			ui = _ui;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED,app_initialized);
				// init this after the application has been inaugurated
				init();
			}
		}
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	show_loader( false );
			App.listener_manager.add( App.mediator.scene_editing, ProcessingEvent.STARTED, processing_started, this);
			App.listener_manager.add( App.mediator.scene_editing, ProcessingEvent.DONE, processing_ended, this);
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
		private function processing_started( _e:ProcessingEvent ):void 
		{	switch ( _e.processName )
			{	case ProcessingEvent.MODEL:		show_loader();	break;
				case ProcessingEvent.BG:		show_loader();	break;
				default:
			}
		}
		private function processing_ended( _e:ProcessingEvent ):void 
		{	switch ( _e.processName )
			{	case ProcessingEvent.MODEL:		show_loader( false );	break;
				case ProcessingEvent.BG:		show_loader( false );	break;
				default:
			}
		}
		private function show_loader( _show:Boolean = false ):void 
		{	ui.loadingBar.visible = _show;
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
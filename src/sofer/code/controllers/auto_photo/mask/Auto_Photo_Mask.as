package code.controllers.auto_photo.mask 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	
	import flash.events.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Auto_Photo_Mask implements IAuto_Photo_Mask
	{
		private var ui			:Mask_UI;
		
		public function Auto_Photo_Mask( _ui:Mask_UI ) 
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
		private function init(  ):void 
		{	
			App.listener_manager.add_multiple_by_object( [ 	ui.btn_next,
															ui.btn_change_photo,
															ui.btn_close ] , MouseEvent.CLICK, btn_step_handler, this);
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
			ui.visible = true;
			ui.placeholder_apc.addChild( App.mediator.autophoto_get_apc_display() );
		}
		public function close_win(  ):void
		{
			ui.visible = false;
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
		private function btn_step_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{	
				case ui.btn_change_photo:		App.mediator.autophoto_change_photo();
												break;
				case ui.btn_next:				App.mediator.autophoto_submit_mask_position();
												break;
				case ui.btn_close:
					App.mediator.autophoto_close();
					break;
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
		*/
		
		
	}

}
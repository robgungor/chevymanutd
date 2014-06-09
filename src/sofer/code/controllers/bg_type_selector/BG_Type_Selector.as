package code.controllers.bg_type_selector 
{
	import code.models.*;
	import code.skeleton.*;
	
	import flash.events.*;
	/**
	 * @about controller for some testing features needed by QA
	 * @author Me^
	 */
	public class BG_Type_Selector
	{
		private var ui		:Background_Type_Selector_UI;
		
		public function BG_Type_Selector( _ui:Background_Type_Selector_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui = _ui;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
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
			App.listener_manager.add_multiple_by_object([	ui.btn_scene_bg,
															ui.btn_face_mask] , MouseEvent.CLICK, test_bg_callback, this );
			ui.btn_scene_bg.selected	= true;
			ui.btn_face_mask.selected	= !ui.btn_scene_bg.selected;
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
		private function test_bg_callback( _e:MouseEvent ):void
		{
			switch( _e.target )
			{
				case ui.btn_scene_bg:		App.asset_bucket.bg_controller.isUploadPhoto = false;		ui.btn_scene_bg.selected = true;		break;
				case ui.btn_face_mask:		App.asset_bucket.bg_controller.isUploadPhoto = true;		ui.btn_scene_bg.selected = false;		break;
			}
			App.mediator.updateMoveZoom();
			ui.btn_face_mask.selected = !ui.btn_scene_bg.selected;
		}
		
	}

}
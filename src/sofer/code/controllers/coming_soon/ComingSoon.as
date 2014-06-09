package code.controllers.coming_soon
{
		import code.skeleton.App;
		
		import flash.display.DisplayObject;
		import flash.events.Event;
		import flash.events.MouseEvent;
		import flash.ui.Keyboard;
		
		
		/**
		 * ...
		 * @author Rob^
		 */
		public class ComingSoon
		{
			/** user interface for this controller */
			private var ui					:ComingSoon_UI;
			/** button, generally outside of the UI which opens this view */
			private var btn_open			:DisplayObject;
			
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
			public function ComingSoon( _ui:ComingSoon_UI) 
			{
				// listen for when the app is considered to have loaded and initialized all assets
				var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
				//			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE;
				//			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
				App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
				
				// reference to the controllers UI
				ui			= _ui;
				
				
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
				init_shortcuts();
				set_ui_listeners();
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
			/**
			 * displays the UI
			 * @param	_e
			 */
			private function open_win(  ):void 
			{	
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
			/**
			 * adds listeners to the UI
			 */
			private function set_ui_listeners():void 
			{
				App.listener_manager.add_multiple_by_object( 
					[
						ui.btn_ok, 
						ui.btn_close 
					], MouseEvent.CLICK, mouse_click_handler, this );
			}
			/**
			 * handler for Click MouseEvents from the UI
			 * @param	_e
			 */
			private function mouse_click_handler( _e:MouseEvent ):void
			{
				switch ( _e.currentTarget )
				{	
					case ui.btn_ok:		
						close_win();		
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
			//	App.utils.tab_order.set_order( [ ui.tf_one, ui.tf_two, ui.btn ] );// SAMPLE
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
			/**
			 * hides the UI
			 */
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
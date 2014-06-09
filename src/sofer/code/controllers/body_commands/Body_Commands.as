package code.controllers.body_commands 
{
	import code.skeleton.*;
	import code.models.*;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.fb3d.dataStructures.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Body_Commands
	{
		private var ui					:Body_Commands_UI;
		private var btn_open			:InteractiveObject;
		
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
		public function Body_Commands() 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui				= Bridge.views.body_commands_UI;
			btn_open		= Bridge.views.panel_buttons_UI.btn_body_commands as InteractiveObject;
			
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
			init_shortcuts();
			//Bridge_Engine.listener_manager.add( btn_open, MouseEvent.CLICK, mouse_click_handler, this );
			App.listener_manager.add( ui.btn_close, MouseEvent.CLICK, mouse_click_handler, this );
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
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{	
				case btn_open:		open_win();		break;
				case ui.btn_close:	close_win();	break;
			}
		}
		/**
		 * displays the UI
		 * @param	_e
		 */
		private function open_win(  ):void 
		{	
			if ( App.mediator.scene_editing.full_body_ready() )
			{	
				App.mediator.scene_editing.full_body.get_commands
				(
					parseInt( App.mediator.scene_editing.model.full_body_struct.scene_id ),
					new Callback_Struct( fin, null, error )
				);
				function fin( _obj:Vector.<CommandData> ):void
				{
					for (var n:int = _obj.length, i:int = 0; i < n; i++)
					{
						var command:CommandData = _obj[i];
						var com_description:String = command.description;
						var com_name:String = command.name;
					}
					if (
							!_obj ||
							_obj.length == 0
						)
						error( 'no commands available' );
					else
					{
						ui.visible = true;
						set_focus();
					}
				}
				function error( _msg:String ):void
				{
					App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t536', 'There are no categories available', {details:_msg}));
				}
			}
			else	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, '', 'Full Body controller not initialized'));
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		private function close_win(  ):void 
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
			if (ui.visible)		close_win();	
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
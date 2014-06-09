package code.controllers.player_holder 
{
	import code.skeleton.App;
	
	import com.oddcast.workshop.SceneEvent;
	
	import fl.controls.Button;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Player_Holder
	{
		private var ui				:Player_Holder_UI;
		private var ui_player		:Player_UI;
		private var btn_play		:DisplayObject;
		private var btn_stop		:DisplayObject;
		
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
		public function Player_Holder( _ui:Player_Holder_UI, _player_ui:Player_UI, _btn_play:DisplayObject, _btn_stop:DisplayObject ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui			= _ui;
			ui_player	= _player_ui;
			btn_play	= _btn_play;
			btn_stop 	= _btn_stop;
			
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
			App.listener_manager.add( App.mediator.scene_editing, SceneEvent.AUDIO_UPDATED, audio_updated_handler, this);
			App.listener_manager.add_multiple_by_event( App.mediator.scene_editing, 
				[	SceneEvent.TALK_ENDED,
					SceneEvent.TALK_ERROR,
					SceneEvent.TALK_STARTED ], talk_event_handler, this );
			App.listener_manager.add_multiple_by_object( 
				[ 
					btn_play, 
					btn_stop ], MouseEvent.CLICK, mouse_click_handler, this );
			audio_updated_handler();
			open_win();
			set_player_for_small_show();
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
		private function set_player_for_small_show(  ) : void
		{
			ui.addChild(ui_player);
			
			// mask items
			ui_player.fb_holder.mask = ui_player.fb_mask;	// full body masking
			ui_player.bgHolder.mask = ui_player.bgMask;	// background
			App.mediator.scene_editing.getHostMC().mask = ui_player.hostMask; // host masking
		}
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{
				case btn_play :
					App.mediator.playScene();
					break;
				case btn_stop :
					App.mediator.stopScene();
					break;
				default:
					
			}
		}
		private function talk_event_handler(_e:SceneEvent):void
		{
			btn_play.visible = _e.type != SceneEvent.TALK_STARTED;
			btn_stop.visible = _e.type == SceneEvent.TALK_STARTED;
		}
		private function audio_updated_handler( _e:SceneEvent = null ):void
		{
			if (btn_play is Button)
				Button(btn_play).enabled = App.mediator.scene_editing.audio != null;
		}
		/**
		 * displays the UI
		 * @param	_e
		 */
		private function open_win(  ):void 
		{	
			ui.visible = true;
			talk_event_handler(new SceneEvent('bogus event to set initial btn state'));
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		private function close_win(  ):void 
		{	
			ui.visible = false;
			btn_play.visible = false;
			btn_stop.visible = false;
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
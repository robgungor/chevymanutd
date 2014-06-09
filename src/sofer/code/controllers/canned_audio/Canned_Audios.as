package code.controllers.canned_audio 
{
	import code.component.skinners.Custom_Scrollbar_Skinner;
	import code.component.skinners.Custom_TileList_Skinner;
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.ui.ComponentStyle;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Canned_Audios
	{
		private var ui								:Canned_Audio_UI;
		private var btn_open						:InteractiveObject;
		private var model_canned_audios				:Model_Item;
		
		public function Canned_Audios( _btn_open:InteractiveObject, _ui:Canned_Audio_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui					= _ui;
			btn_open			= _btn_open;
			model_canned_audios = App.asset_bucket.model_store.list_canned_audio.model;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();

			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener(_e, arguments);
				// init this after the application has been inaugurated
				init();
			}
		}
		private function init(  ):void 
		{
			App.listener_manager.add_multiple_by_object( [	btn_open, 
															ui.btn_play,
															ui.btn_stop,
															ui.closeBtn,
															ui.btn_save ] , MouseEvent.CLICK, mouse_click_handler, this );
			
			App.listener_manager.add_multiple_by_event( App.mediator.scene_editing, [ 	SceneEvent.TALK_ENDED,
																						SceneEvent.TALK_ERROR,
																						SceneEvent.TALK_STARTED ], talk_event_handler, this );
			
			App.listener_manager.add( ui.tileList, Event.CHANGE, audio_selected, this );
			init_shortcuts();
			
			talk_event_handler(new SceneEvent(SceneEvent.TALK_ENDED));// make sure the toggle button state is correct
			new Custom_TileList_Skinner( ui.tileList, Canned_Audios_TileList_CellRenderer );
			new Custom_Scrollbar_Skinner( ui.tileList );
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
		private function talk_event_handler( _e:SceneEvent ):void
		{
			if (_e.type == SceneEvent.TALK_STARTED )
			{
				ui.btn_play.visible = false;
				ui.btn_stop.visible = true;
			}	
			else
			{
				ui.btn_play.visible = true;
				ui.btn_stop.visible = false;
			}
		}
		private function mouse_click_handler( _e:MouseEvent ) : void
		{
			switch ( _e.target )
			{
				case btn_open :
					open_win();
					break;
				case ui.btn_play :
					play_audio();
					break;
				case ui.btn_stop :
					stop_audio();
					break;
				case ui.btn_save :
					save_audio();
					break;
				case ui.closeBtn:
					close_win();
					break;
				default:
					
			}
		}
		private function close_win(  ):void 
		{
			if (App.mediator.scene_editing)
				App.mediator.scene_editing.stopAudio();
			ui.visible = false;
		}
		private function open_win(  ):void 
		{
			ui.visible					= true;
			ui.btn_play.enabled			= false;
			ui.btn_save.enabled			= false;
			load_populate_audios();
		}
		private function load_populate_audios():void
		{
			App.asset_bucket.model_store.list_canned_audio.load(null,new Callback_Struct(loaded, null, error) );
			
			function loaded(  ):void 
			{
				populate_audios();
				set_focus();
				
				function populate_audios():void
				{
					ui.tileList.removeAll();
					var audios:Array = model_canned_audios.get_all_items();
					for (var i:int = 0, n:int=audios.length; i < n; i++)
					{	
						var audio:AudioData = audios[i];
						ui.tileList.addItem({label:audio.name, data:audio.id});
					}
					
					// auto select audio based on saved audio in the scene
					var preselected_audio:AudioData = App.mediator.scene_editing.audio;
					if (preselected_audio && preselected_audio.type == AudioData.PRERECORDED)
					{	
						var audio_index:int = model_canned_audios.get_all_items().indexOf( preselected_audio );
						ui.tileList.selectedIndex = audio_index;
					}
					
					// enable or disable the buttons based on if the selector is autoselected
					ui.btn_play.enabled		= ui.tileList.selectedItem != null;
					ui.btn_save.enabled		= ui.tileList.selectedItem != null;
				}
			}
			function error( _e:AlertEvent ):void 
			{
				App.mediator.alert_user( _e );
				close_win();
			}
		}
		private function audio_selected(_e:Event):void
		{
			if (cur_audio != null) 
			{
				App.mediator.scene_editing.previewAudio(cur_audio);
				WSEventTracker.event("ap");
			}
			ui.btn_play.enabled = true;
			ui.btn_save.enabled = true;
		}
		
		private function play_audio():void
		{
			stop_audio();
			if (cur_audio)
				App.mediator.scene_editing.previewAudio(cur_audio);
		}
		private function stop_audio():void
		{
			App.mediator.scene_editing.stopAudio();
		}
		
		private function save_audio():void
		{
			if (cur_audio == null) {
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t361", "You must select a prerecorded audio before pressing save"));
				return;
			}

			App.mediator.scene_editing.selectAudio(cur_audio);
			WSEventTracker.event("ap");
			close_win();
		}
		
		private function get cur_audio():AudioData 
		{
			if (ui.tileList.selectedItem) 
			{	
				var selected_id:int=ui.tileList.selectedItem.data;
				var audio_list:Array=model_canned_audios.get_items_by_property('id',selected_id);
				if (audio_list && audio_list.length > 0)
					return audio_list[0];
			}
			return null;
		}
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{
			ui.stage.focus = ui;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}	
		private function shortcut_close_win(  ):void 		
		{	
			if (ui.visible)
				close_win();	
		}
		 /*******************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
	}

}
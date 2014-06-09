package code.controllers.backgrounds 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.data.ThumbSelectorData;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class BG_Selector implements IBG_Selector
	{
		private var ui						:Background_Selector_UI;
		private var btn_open				:InteractiveObject;
		private var model_bg				:Model_Item;
		
		private const NO_BG					:int = -3737;
		private const PROCESS_LOADING_LIST	:String = 'PROCESS_LOADING_LIST';
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
		public function BG_Selector( _btn_open:InteractiveObject, _ui:Background_Selector_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui				= _ui
			btn_open		= _btn_open;
			model_bg		= App.asset_bucket.model_store.list_backgrounds.model;	
			
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
			App.listener_manager.add( btn_open, MouseEvent.CLICK, btn_handler, this );
			App.listener_manager.add( ui.bgSelector, SelectorEvent.SELECTED, bg_selected, this);
			ui.bgSelector.addScrollBtn( ui.prevBtn, -3 );
			ui.bgSelector.addScrollBtn( ui.nextBtn, 3 );
			
			if (ui.closeBtn)
				App.listener_manager.add(ui.closeBtn, MouseEvent.CLICK, btn_handler, this);
				
			init_shortcuts();
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
		* 
		***************************** INTERFACE */
		public function open_win(  ):void
		{
			if (model_bg &&
				model_bg.get_all_items() &&
				model_bg.get_all_items().length > 0)
			{
				ui.visible = true;
				set_focus();
				populate_selector();
			}
			else	
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t313', 'There are no backgrounds present.'));
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
		private function btn_handler( _e:MouseEvent ):void 
		{	
			switch ( _e.target )
			{	
				case btn_open:		open_win();		break;
				case ui.closeBtn:	close_win();	break;
			}
		}
		private function close_win(  ):void 
		{
			ui.visible = false;
		}
		private function populate_selector(  ):void 
		{
			var bgs:Array = model_bg.get_all_items();
			
			ui.bgSelector.clear();
			ui.bgSelector.add(NO_BG, "None");
			
			for (var n:int = bgs.length, i:int = 0; i < n; i++)
			{
				var bg		:WSBackgroundStruct=bgs[i];
				var thumb	:ThumbSelectorData	= (App.settings.LOAD_BG_THUMBS) ? new ThumbSelectorData(bg.thumbUrl) : null;
				ui.bgSelector.add(bg.id, bg.name, thumb, false);
			}
				
			// auto select the current bg on the scene
			var cur_loaded_bg:WSBackgroundStruct = App.mediator.scene_editing.bg;
			if (cur_loaded_bg)
				ui.bgSelector.selectById( cur_loaded_bg.id );
			else
				ui.bgSelector.selectById( NO_BG )
			
			setTimeout(update_selector, 100);// fixes a bug in the selector where the thumbs wont show up bc the items are considerred hidden
			function update_selector():void
			{
				ui.bgSelector.update();
			}
		}
				
		private function bg_selected(_e:SelectorEvent):void
		{
			var scene:ISceneController = App.mediator.scene_editing;
			if (_e.id == NO_BG) 
				scene.unloadBG();
			else 
			{
				App.listener_manager.add( scene, SceneEvent.BG_LOADED, loaded, this );
				var bgs:Array, bg:WSBackgroundStruct;
				bgs=model_bg.get_items_by_property('id',_e.id);
				if (bgs)
					bg=bgs[0];
				if (bg)
					scene.loadBG(bg);
			}
			
			function loaded( _e:SceneEvent ):void
			{
				App.listener_manager.remove( scene, SceneEvent.BG_LOADED, loaded );
				selectBG( App.mediator.scene_editing.bg );
			}
		
		}
		private function selectBG(in_bg:WSBackgroundStruct):void
		{
			if (model_bg == null) 
				return;
			var id:int = model_bg.get_all_items().indexOf(in_bg);				// find the background in the current default bg list, if -1 then its not found
			if		(id >= 0)			ui.bgSelector.selectById(id);			// select one of the listed IDs
			else if	(in_bg != null)		ui.bgSelector.deselect();				// unselect all, possibly a new background was uploaded thats not on the list
			else						ui.bgSelector.selectById(NO_BG);		// select the "none" item since there is no background selected now
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
		* ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}	
		private function shortcut_close_win(  ):void 		
		{	if (ui.visible)
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
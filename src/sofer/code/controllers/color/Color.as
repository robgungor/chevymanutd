package code.controllers.color 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class Color
	{
		private var ui						:Color_UI;
		private var btn_open				:InteractiveObject;
		
		/* array of HostColorData */
		private var color_list				:Array;
		private var selectedId				:int;
		
		public function Color( _btn_open:InteractiveObject, _ui:Color_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui				= _ui;
			btn_open		= _btn_open;
			
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
			selectedId = -1;
			App.listener_manager.add( btn_open, MouseEvent.CLICK, open_win, this );
			App.listener_manager.add( ui.groupSelector, SelectorEvent.SELECTED, groupSelected, this );
			App.listener_manager.add( ui.cp, ColorEvent.SELECT, colorChanged, this );
			App.listener_manager.add( ui.cp, ColorEvent.RELEASE, colorChanged, this );
			if (ui.closeBtn)
				App.listener_manager.add( ui.closeBtn, MouseEvent.CLICK, close_win, this );
			init_shortcuts();
			ui.groupSelector.addScrollBtn(ui.upBtn, -1);
			ui.groupSelector.addScrollBtn(ui.downBtn, 1);
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
		private function close_win( _e:MouseEvent = null ):void 
		{
			ui.visible = false;
		}
		private function open_win( _e:MouseEvent ):void 
		{
			if (App.mediator.scene_editing &&
				App.mediator.scene_editing.model &&
				App.mediator.scene_editing.model.has_head_data())
			{
				update_colors_based_on_current_model();
				
				if (color_list == null || color_list.length == 0)
					App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "f9t320", "Nothing available to color"));
				else
				{	ui.visible = true;
					set_focus();
				}
			}
			else	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t536', 'This feature is not available'));
		}
		/**
		 * retrieves the available colorable items from the current loaded model 
		 */
		private function update_colors_based_on_current_model(  ):void 
		{
			var curGroup:HostColorData = null;
			if (color_list != null && color_list[selectedId] != undefined) 
				curGroup = color_list[selectedId];
			var newGroupId:int = 0;
			
			color_list = App.mediator.scene_editing.getColors() as Array;
			ui.groupSelector.clear();
			var editColor:HostColorData;
			for (var i:int = 0; i < color_list.length; i++) {
				editColor = color_list[i];
				ui.groupSelector.add(i, editColor.name, new ColorData(editColor.value), true);
				if (curGroup!=null&&editColor.name == curGroup.name && editColor.type == curGroup.type) newGroupId = i;
			}
			selectGroup(newGroupId);
			ui.groupSelector.selectById(newGroupId);	
		}
		
		private function selectGroup(in_id:int):void
		{
			selectedId		= in_id;
			var hex:uint	= color_list[selectedId].value;
			ui.cp.selectColor(hex)
		}
		
		private function groupSelected(evt:SelectorEvent):void
		{
			selectGroup(evt.id);
		}
		
		private function colorChanged(evt:ColorEvent):void
		{
			color_list[selectedId].value = evt.color.hex;
			ui.groupSelector.getSelectedItem().data = evt.color;
			App.mediator.scene_editing.setHexColor(color_list[selectedId], evt.color.hex);
		}
		/**
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
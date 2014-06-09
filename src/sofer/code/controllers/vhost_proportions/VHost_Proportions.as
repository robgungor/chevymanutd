package code.controllers.vhost_proportions 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.vhost.ranges.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class VHost_Proportions
	{
		private var ui						:VHost_Proportions_UI;
		private var btn_open				:InteractiveObject;
		
		private var rangeArr				:Array;
		private static const rangeNames		:Object = { "nose":"Nose", "mouth":"Jaw", "body":"Shoulders", "Scene Dolly":"Dolly - in / out" };
		
		public function VHost_Proportions( _btn_open:InteractiveObject, _ui:VHost_Proportions_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui			= _ui;
			btn_open	= _btn_open;
			
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
			if (ui.closeBtn != null) 
				App.listener_manager.add( ui.closeBtn, MouseEvent.CLICK, close_win, this );
			App.listener_manager.add( btn_open, MouseEvent.CLICK, open_win, this );
			
			ui.scrollbar.disableDraggerResize = true;	// force scrollbar to be the same size as the component
			ui.sliders.addItemEventListener(ScrollEvent.SCROLL, scrollChanged);
			ui.sliders.addScrollBar(ui.scrollbar);
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
			remove_listeners();
			ui.visible = false;
		}
		private function open_win( _e:MouseEvent ):void 
		{
			if (App.mediator.scene_editing &&
				App.mediator.scene_editing.model &&
				App.mediator.scene_editing.model.has_head_data())
			{
				ui.visible = true;
				add_listeners();
				update_slider_based_on_current_model();
				set_focus();
			}
			else	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t536', 'This feature is not available'));
		}
		
		private function add_listeners():void
		{
			App.listener_manager.add( App.mediator.scene_editing, SceneEvent.MODEL_LOADED, model_updated, this );
			App.listener_manager.add( App.mediator.scene_editing, SceneEvent.ACCESSORY_LOADED, model_updated, this );
		}
		
		private function remove_listeners():void
		{
			if (App.mediator.scene_editing)
			{
				App.listener_manager.remove( App.mediator.scene_editing, SceneEvent.MODEL_LOADED, model_updated );
				App.listener_manager.remove( App.mediator.scene_editing, SceneEvent.ACCESSORY_LOADED, model_updated );
			}
		}
		
		private function model_updated(evt:Event):void
		{
			update_slider_based_on_current_model();
		}
		
		private function update_slider_based_on_current_model():void {
			ui.sliders.clear();
			rangeArr = App.mediator.scene_editing.getRanges();
			
			var rangeName:String;
			var rangeObj:RangeData;
			for (var i:int = 0; i < rangeArr.length; i++)
			{
				rangeObj = rangeArr[i];
				rangeName = rangeObj.name;
				if (rangeNames[rangeName] != null) 
					rangeName = rangeNames[rangeName];
				ui.sliders.add(i, rangeName, rangeObj.value, false);
			}
			ui.sliders.update();
		}
		
		private function scrollChanged(evt:ScrollEvent):void
		{
			var rangeObj:RangeData = rangeArr[evt.currentTarget.id];
			App.mediator.scene_editing.setScale(rangeObj.name,evt.percent,rangeObj.type);
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
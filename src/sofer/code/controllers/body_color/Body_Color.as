package code.controllers.body_color 
{
	import code.skeleton.*;
	import code.models.*;
	import com.oddcast.event.*;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.utils.ColorData;
	import com.oddcast.workshop.fb3d.dataStructures.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Body_Color
	{
		private var ui					:Body_Color_UI;
		private var btn_open			:InteractiveObject;
		private var selected_color_id	:int;
		private var color_categories	:Vector.<CategoryData>;
		
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
		public function Body_Color() 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui				= Bridge.views.body_color_UI;
			btn_open		= Bridge.views.panel_buttons_UI.btn_body_color as InteractiveObject;
			
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
			App.listener_manager.add( btn_open, MouseEvent.CLICK, open_win, this );
			App.listener_manager.add( ui.btn_close, MouseEvent.CLICK, close_win, this );
			App.listener_manager.add( ui.color_picker, ColorEvent.SELECT, color_changed, this);
			App.listener_manager.add( ui.color_picker, ColorEvent.RELEASE, color_changed, this);
			ui.selector_group.addScrollBtn( ui.btn_selector_up, -1 );
			ui.selector_group.addScrollBtn( ui.btn_selector_down, 1 );
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
		/**
		 * displays the UI
		 * @param	_e
		 */
		private function open_win( _e:MouseEvent = null ):void 
		{	
			if ( App.mediator.scene_editing.full_body_ready() )
			{	ui.visible = true;
				populate_groups();
				set_focus();
			}
			else	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, '', 'Full Body controller not initialized'));
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		private function close_win( _e:MouseEvent = null ):void 
		{	ui.visible = false;
		}
		private function populate_groups(  ):void 
		{	ui.selector_group.clear();
			var color_list		:ColorableListData 		= App.mediator.scene_editing.full_body.get_color_list();
			if (color_list)
			{
				color_categories = color_list.getCategories();
				if (color_categories && color_categories.length > 0)
				{	for (var i:int = 0; i < color_categories.length; i++) 
					{	var cat		:CategoryData	= color_categories[i];
						var id		:int			= i;
						var text	:String			= cat.name;
						var color	:ColorData		= new ColorData( cat.color.rgb() );
						ui.selector_group.add( id, text, color, true );
					}
					ui.selector_group.update();
					
					// auto select the first item
					ui.selector_group.selectById(0);
				}
				else no_categories_available();
			}
			else no_categories_available();
			
			function no_categories_available(  ):void 
			{	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t536', 'There are no categories available'));
				close_win();
			}
		}
		private function color_changed( _e:ColorEvent ):void
		{
			var selected_item:SelectorItem = ui.selector_group.getSelectedItem();
			selected_item.data = _e.color;	// update the color in the color panel button
			var fb_color:CategoryData = color_categories[ selected_item.id ];	// get the full body color data information
			App.mediator.scene_editing.full_body.set_color_category( fb_color.name, _e.color.hex );// update the color on the model
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
		{	ui.stage.focus = ui;
		}
		/**
		 * initializes keyboard shortcuts
		 */
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}
		private function shortcut_close_win(  ):void 		
		{	if (ui.visible)		close_win();	
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
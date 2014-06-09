package code.controllers.body_material_conf 
{
	import code.skeleton.*;
	import code.models.*;
	import com.oddcast.data.*;
	import com.oddcast.event.*;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.fb3d.dataStructures.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Body_Material_Conf
	{
		private var ui					:Body_Material_Conf_UI;
		private var btn_open			:DisplayObject;
		private const PROCESS_EVENT_LOADING_MATERIAL		:String = 'PROCESS_EVENT_LOADING_MATERIAL';
		private const PROCESS_EVENT_LOADING_MATERIAL_MSG	:String = 'Loading Body Material Configuration';
		
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
		public function Body_Material_Conf() 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui	= Bridge.views.body_material_conf_UI;
			btn_open			= Bridge.views.panel_buttons_UI.btn_body_material as DisplayObject;
			
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
		{	init_shortcuts();
			App.listener_manager.add( btn_open, MouseEvent.CLICK, open_win, this );
			App.listener_manager.add( ui.btn_close, MouseEvent.CLICK, close_win, this );
			App.listener_manager.add( ui.selector_group, SelectorEvent.SELECTED, group_selected, this );
			App.listener_manager.add( ui.selector_thumb, SelectorEvent.SELECTED, item_selected, this );
			
			var auto_size_scrollbar:Boolean = true;
			ui.selector_thumb.addScrollBar( ui.scrollbar, auto_size_scrollbar );
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
		{	if ( App.mediator.scene_editing.full_body_ready() )
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
			var material_list		:MaterialConfigurationListData 		= App.mediator.scene_editing.full_body.get_material_config() as MaterialConfigurationListData;
			if (material_list)
			{	var material_categories	:Vector.<CategoryData>				= material_list.getCategories();
				if (material_categories && material_categories.length > 0)
				{	for (var i:int = 0; i < material_categories.length; i++) 
					{	var cat		:CategoryData	= material_categories[i];
						var id		:int			= i;
						var text	:String			= cat.name;
						ui.selector_group.add( id, text, cat );
					}
					ui.selector_group.update();
					
					// auto select the first item
					ui.selector_group.selectById(0);
					populate_items();
				}
				else no_categories_available();
			}
			else no_categories_available();
			
			function no_categories_available(  ):void 
			{	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t536', 'There are no categories available'));
				close_win();
			}
		}
		private function populate_items(  ):void 
		{	ui.selector_thumb.clear();
			if (ui && ui.selector_group && ui.selector_group.getSelectedItem() && ui.selector_group.getSelectedItem().data as CategoryData)
			{	var selected_item	:CategoryData	= ui.selector_group.getSelectedItem().data as CategoryData;
				var material_confs	:Array			= App.mediator.scene_editing.full_body.get_material_config().getMaterialConfigurations( selected_item.name );
				for (var i:int = 0; i < material_confs.length; i++) 
				{	var material:MaterialConfigurationData 	= material_confs[i];
					var id		:int						= material.id;
					var text	:String						= material.name;
					var thumb	:ThumbSelectorData			= new ThumbSelectorData( material.thumbUrl, material );
					ui.selector_thumb.add( id, text, thumb, false );
				}
				ui.selector_thumb.update();
			}
		}
		
		private function group_selected( _e:SelectorEvent ):void 
		{	populate_items();
		}
		private function item_selected( _e:SelectorEvent ):void 
		{	var selected_material:MaterialConfigurationData = _e.obj.obj as MaterialConfigurationData;
			if (selected_material)
			{	App.mediator.processing_start( PROCESS_EVENT_LOADING_MATERIAL, PROCESS_EVENT_LOADING_MATERIAL_MSG, 0 );
				App.mediator.scene_editing.full_body.load_material_conf( selected_material.id, new Callback_Struct( fin, progress, error ) );
				function fin():void 
				{	App.mediator.processing_ended( PROCESS_EVENT_LOADING_MATERIAL );
				}
				function progress( _percent:int ):void 
				{	App.mediator.processing_start( PROCESS_EVENT_LOADING_MATERIAL, PROCESS_EVENT_LOADING_MATERIAL_MSG, _percent );
				}
				function error( _msg:String ):void 
				{	App.mediator.processing_ended( PROCESS_EVENT_LOADING_MATERIAL );
					App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, '', 'Error loading material configuration', {details:_msg} ));
				}
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
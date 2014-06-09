package code.controllers.body_decals 
{
	import code.skeleton.*;
	import code.models.*;
	import com.oddcast.data.*;
	import com.oddcast.event.*;
	import com.oddcast.ui.SelectorItem;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.fb3d.dataStructures.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Body_Decals
	{
		private var ui					:Body_Decals_UI;
		private var btn_open			:DisplayObject;
		private const PROCESS_EVENT_LOADING_DECALS		:String = 'PROCESS_EVENT_LOADING_DECALS';
		private const PROCESS_EVENT_LOADING_DECALS_MSG	:String = 'Loading Body Decals';
		private const NONE_ITEM							:int = -373737;
		
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
		public function Body_Decals() 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui			= Bridge.views.body_decals_UI;
			btn_open	= Bridge.views.panel_buttons_UI.btn_body_decal as DisplayObject;
			
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
			App.listener_manager.add( ui.selector_group, SelectorEvent.SELECTED, group_selected, this );
			App.listener_manager.add( ui.selector_thumb, SelectorEvent.SELECTED, item_selected, this );
			
			var auto_size_scrollbar:Boolean = true;
			ui.selector_thumb.addScrollBar( ui.scrollbar, auto_size_scrollbar );
			ui.selector_thumb.allowMultiple = true;
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
			var material_list		:DecalConfigurationListData 		= App.mediator.scene_editing.full_body.get_decals() as DecalConfigurationListData;
			if (material_list)
			{	var material_categories	:Vector.<CategoryData>				= material_list.getCategories();
				if (material_categories && material_categories.length > 0 )
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
			ui.selector_thumb.add( NONE_ITEM, 'none', null, false );
			if (ui && ui.selector_group && ui.selector_group.getSelectedItem() && ui.selector_group.getSelectedItem().data as CategoryData)
			{	var selected_item	:CategoryData	= ui.selector_group.getSelectedItem().data as CategoryData;
				var decals			:Array			= App.mediator.scene_editing.full_body.get_decals().getDecalConfigurations( selected_item.name );
				for (var i:int = 0; i < decals.length; i++) 
				{	var decal	:DecalConfigurationData 	= decals[i];
					var id		:int						= decal.id;
					var text	:String						= decal.name;
					var thumb	:ThumbSelectorData			= new ThumbSelectorData( decal.thumbUrl, decal );
					ui.selector_thumb.add( id, text, thumb, false );
				}
				ui.selector_thumb.update();
			}
			
			// highlight the ids that were selected previously
			var body_loaded_decal_ids	:Array = App.mediator.scene_editing.full_body.get_loaded_decal_ids();
			var selector_items_lists	:Array = ui.selector_thumb.getItemArray();
			var no_ids_matched			:Boolean	= true;
			for (var n:int = selector_items_lists.length, i = 0; i < n; i++)
			{
				var selector_item:SelectorItem = selector_items_lists[i];
				if ( body_loaded_decal_ids.indexOf( selector_item.id ) >= 0 )	// if it matches
				{
					ui.selector_thumb.selectById( selector_item.id ); // select the already loaded decals
					no_ids_matched = false;
				}
			}
			if (no_ids_matched)	// select the none
				ui.selector_thumb.selectById( NONE_ITEM );
		}
		
		private function group_selected( _e:SelectorEvent ):void 
		{	populate_items();
		}
		private function item_selected( _e:SelectorEvent ):void 
		{	
			if (
					_e && 
					_e.id && 
					_e.id == NONE_ITEM
				)
				remove_all_decals();
			else if (
						_e && 
						_e.obj && 
						_e.obj.obj && 
						_e.obj.obj as DecalConfigurationData 
					)
			{	
				ui.selector_thumb.deselectById(NONE_ITEM);//deselect the none since something valid is selected
				var selected_decal:DecalConfigurationData = _e.obj.obj as DecalConfigurationData;
				App.mediator.processing_start( PROCESS_EVENT_LOADING_DECALS, PROCESS_EVENT_LOADING_DECALS_MSG, 0 );
				App.mediator.scene_editing.full_body.load_decal( selected_decal.id, new Callback_Struct( fin, progress, error ) );
				function fin():void 
				{	
					App.mediator.processing_ended( PROCESS_EVENT_LOADING_DECALS );
				}
				function progress( _percent:int ):void 
				{	
					App.mediator.processing_start( PROCESS_EVENT_LOADING_DECALS, PROCESS_EVENT_LOADING_DECALS_MSG, _percent );
				}
				function error( _msg:String ):void 
				{	
					App.mediator.processing_ended( PROCESS_EVENT_LOADING_DECALS );
					App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, '', 'Error loading decals', {details:_msg} ));
				}
			}
		}
		private function remove_all_decals(  ):void
		{
			// deselect all IDS from the selector
			var selected_items:Array = ui.selector_thumb.getSelectedIdArr();
			while (selected_items.length > 0)
				ui.selector_thumb.deselectById( selected_items[0] );
			
			// remove all loaded decals from the body
			var body_loaded_decal_ids:Array = App.mediator.scene_editing.full_body.get_loaded_decal_ids();
			while (body_loaded_decal_ids.length > 0)
				App.mediator.scene_editing.full_body.unload_decal( body_loaded_decal_ids[0] );
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
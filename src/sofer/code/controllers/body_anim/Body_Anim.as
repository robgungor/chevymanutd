package code.controllers.body_anim 
{
	import code.models.*;
	import code.skeleton.*;
	
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
	public class Body_Anim
	{
		private var ui				:Body_Anim_UI;
		private var btn_open		:DisplayObject;
		private const PROCESS_EVENT_LOADING_ANIM		:String = 'PROCESS_EVENT_LOADING_ANIM';
		private const PROCESS_EVENT_LOADING_ANIM_MSG	:String = 'Loading Body Animation';
		
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
		public function Body_Anim() 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui			= Bridge.views.body_anim_UI;
			btn_open	= Bridge.views.panel_buttons_UI.btn_body_anim as DisplayObject;
			
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
			App.listener_manager.add( ui.btn_save, MouseEvent.CLICK, save_selected_animation, this );
			
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
			var anim_list		:AnimationListData 		= App.mediator.scene_editing.full_body.get_anim();
			if (anim_list)
			{	var anim_categories	:Vector.<CategoryData>	= anim_list.getCategories();
				if (anim_categories && anim_categories.length > 0)
				{	for (var i:int = 0; i < anim_categories.length; i++) 
					{	var cat		:CategoryData	= anim_categories[i];
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
				var anims			:Array			= App.mediator.scene_editing.full_body.get_anim().getAnimations( selected_item.name );
				for (var i:int = 0; i < anims.length; i++) 
				{	var anim	:AnimationData 				= anims[i];
					var id		:int						= anim.id;
					var text	:String						= anim.name;
					var thumb	:ThumbSelectorData			= new ThumbSelectorData('', anim );
					ui.selector_thumb.add( id, text, thumb, false );
				}
				ui.selector_thumb.update();
			}
		}
		
		private function group_selected( _e:SelectorEvent ):void 
		{	populate_items();
		}
		private function item_selected( _e:SelectorEvent ):void 
		{	var selected_anim:AnimationData = _e.obj.obj as AnimationData;
			if (selected_anim)
			{	App.mediator.processing_start( PROCESS_EVENT_LOADING_ANIM, PROCESS_EVENT_LOADING_ANIM_MSG, 0 );
				var loop_anim					:Boolean = false;
				var interrupt_current_animation	:Boolean = true;
				App.mediator.scene_editing.full_body.load_anim( 	selected_anim.id, 
																					new Callback_Struct( fin, progress, error ), 
																					animation_finished, 
																					loop_anim, 
																					interrupt_current_animation );
				function animation_finished(  ):void 
				{	
				}
				function fin():void 
				{	App.mediator.processing_ended( PROCESS_EVENT_LOADING_ANIM );
				}
				function progress( _percent:int ):void 
				{	App.mediator.processing_start( PROCESS_EVENT_LOADING_ANIM, PROCESS_EVENT_LOADING_ANIM_MSG, _percent );
				}
				function error( _msg:String ):void 
				{	App.mediator.processing_ended( PROCESS_EVENT_LOADING_ANIM );
					App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, '', 'Error loading animations', {details:_msg} ));
				}
			}
		}
		private function save_selected_animation( _e:MouseEvent ):void 
		{	var selected_item:* = ui.selector_thumb.getSelectedItem();
			if (selected_item)
			{	var selected_anim:AnimationData = !selected_item ? null : ui.selector_thumb.getSelectedItem().data.obj as AnimationData;
				if (selected_anim)
				{	App.mediator.scene_editing.full_body.save_anim( selected_anim.id );
					close_win();
				}
			}
			else	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, '', 'Please select an animation before saving' ));
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
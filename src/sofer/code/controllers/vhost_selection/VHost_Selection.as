package code.controllers.vhost_selection 
{
	import code.controllers.auto_photo.*;
	import code.models.*;
	import code.models.items.List_Vhosts;
	import code.skeleton.*;
	
	import com.oddcast.data.*;
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
	public class VHost_Selection implements IVhost_Selection
	{
		private var ui					:VHost_Front_Selector_UI;
		private var btn_open			:InteractiveObject;
		private var vhosts_type			:String = VHOSTS_TYPE_FRONT;
		private var vhost_list			:List_Vhosts;
		
		public static const TITLE_MODEL_BACK	:String			= 'Select a head:';
		public static const TITLE_MODEL_FRONT	:String			= 'Select a face:';
		
		private const VHOSTS_TYPE_FRONT	:String = 'MODELS_TYPE_FRONT';
		private const VHOSTS_TYPE_BACK	:String = 'MODELS_TYPE_BACK';
		private const INDEX_NOT_FOUND	:int = -3737;
		
		/**
		 * constructor
		 */
		public function VHost_Selection( _btn_open:InteractiveObject, _ui:VHost_Front_Selector_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui			= _ui;
			btn_open	= _btn_open;
			vhost_list	= App.asset_bucket.model_store.list_vhosts;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();

			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				init();
			}
		}
		private function init(  ):void 
		{	
			ui.tf_title.text = TITLE_MODEL_FRONT;	
			App.listener_manager.add( btn_open, MouseEvent.CLICK, open_win, this );
			App.listener_manager.add( ui.modelSelector, SelectorEvent.SELECTED, vhost_selected, this );
			App.listener_manager.add( ui.btn_close, MouseEvent.CLICK, close_win, this );
			App.listener_manager.add( vhost_list, Event.CHANGE, vhost_list_changed, this );
			
			ui.modelSelector.addScrollBtn(ui.prevBtn, -1);
			ui.modelSelector.addScrollBtn(ui.nextBtn, 1);
			
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
		/**
		 * only visually highlight a model in the model selector
		 * @param	_vhost
		 */
		public function select_vhost(_vhost:WSModelStruct):void
		{	
			ui.modelSelector.selectById( get_vhost_index(_vhost) );
		}
		/**
		 * returns the current user selected model 
		 * @return 
		 */		
		public function get_selected_vhost(  ):WSModelStruct
		{	
			var selected_vhost:WSModelStruct = get_vhost_by_index( ui.modelSelector.getSelectedId() );
			
			// if there is no selected model, visually select and return by default the first model
			if (selected_vhost == null)
			{	var def_vhost:WSModelStruct = vhost_list.get_default_vhost();//get_vhosts_array()[0];
				select_vhost( def_vhost );
				return def_vhost;
			}
			
			return selected_vhost;
		}
		public function open_win( _e:MouseEvent = null ):void 
		{	
			ui.visible = true;
			auto_select_current_loaded_vhost();
			set_focus();
		}
		public function close_win( _e:MouseEvent = null ):void 
		{	
			ui.visible = false;
		}
		/**
		 * build the UI selector with the models
		 */
		public function populate_vhosts(  ):void
		{	var vhosts:Array = get_vhosts_array();
			ui.modelSelector.clear();
			
			for (var i:int = 0; i < vhosts.length; i++) 
			{	var vhost		:WSModelStruct		= vhosts[i];
				var thumb_data	:ThumbSelectorData	= (App.settings.LOAD_MODEL_THUMBS) ? new ThumbSelectorData(vhost.thumbUrl) : null;
				var index		:int				= get_vhost_index( vhost );
				ui.modelSelector.add(i, vhost.name, thumb_data, false);
			}
			ui.modelSelector.update();
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
		private function vhost_list_changed(_e:Event):void
		{
			if (ui.visible)
				populate_vhosts();
		}
		private function auto_select_current_loaded_vhost():void
		{
			var vhost:WSModelStruct = App.mediator.scene_editing.model;
			ui.modelSelector.selectById( get_vhost_index( vhost ));
		}
		/**
		 * gets a unique index for that model 
		 * @param _vhost	vhost in list
		 * @return  index of the vhost in list
		 * 
		 */		
		private function get_vhost_index( _vhost:WSModelStruct ):int
		{
			var vhosts:Array = get_vhosts_array();
			if (vhosts == null || vhosts.length == 0) 
				return INDEX_NOT_FOUND;
			
			var index:int = vhosts.indexOf(_vhost);
			if (index >= 0)
				return index;
			
			return INDEX_NOT_FOUND;
		}
		/**
		 * gets a vhost by an index which is the ID used in the selector
		 * @param _vhost	vhost in list
		 * @return  index of the vhost in list
		 * 
		 */		
		private function get_vhost_by_index( _index:int ):WSModelStruct
		{
			var vhosts:Array = get_vhosts_array();
			return vhosts[ _index ];
		}
		private function get_vhosts_array(  ):Array
		{	switch( vhosts_type)
			{	case VHOSTS_TYPE_BACK:		return vhost_list.model_back.get_all_items();
				case VHOSTS_TYPE_FRONT:		return vhost_list.model_front.get_all_items();
			}
			return [];
		}
		/**
		 * callback when a model is selected
		 * @param	_e
		 */
		private function vhost_selected(_e:SelectorEvent):void
		{	var vhost:WSModelStruct = get_vhost_by_index(_e.id);
			App.mediator.model_selected_in_panel( vhost );
			App.mediator.autophoto_image_source_type( Auto_Photo_Constants.IMAGE_SOURCE_TYPE_STATIC_LIBRARY );
			App.mediator.autophoto_track_image_source_type();
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
		{	close_win();	
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
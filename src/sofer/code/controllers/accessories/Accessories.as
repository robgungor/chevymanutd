package code.controllers.accessories 
{
	import code.component.skinners.Custom_Scrollbar_Skinner;
	import code.component.skinners.Custom_TileList_Skinner;
	import code.models.items.List_Vhost_Accessories;
	import code.skeleton.App;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ISceneController;
	import com.oddcast.workshop.SceneEvent;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	/**
	 * ...
	 * @author Me^
	 */
	public class Accessories
	{
		private const REMOVE_ALL_TYPE_ID	:int = -1;
		private const NO_ACCESSORY_ID		:int = -1;
		private const PROCESSING_ACC_LOAD	:String = 'LOADING ACCESSORIE LOADING';
		private const MSG_ACC_LOAD			:String = 'Loading accessory';
		
		private var ui					:Accessories_UI;
		private var btn_open			:InteractiveObject;
		/** loaded model data for the current loaded vhost id */
		private var list_accessories	: List_Vhost_Accessories;
		
		private var cur_type_id			:int;
		
		/*******************************************************
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
		 * ******************************** INIT */
		public function Accessories( _btn_open:InteractiveObject, _ui:Accessories_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui				= _ui;
			btn_open		= _btn_open;
			list_accessories= App.asset_bucket.model_store.list_vhost_accessories;
			
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
		{	if (ui.closeBtn != null) 
				App.listener_manager.add( ui.closeBtn, MouseEvent.CLICK, close_win, this );
			App.listener_manager.add( btn_open, MouseEvent.CLICK, open_win, this );
			App.listener_manager.add( ui.tileList_group, Event.CHANGE, groupSelected, this );
			App.listener_manager.add( ui.tileList_accessories, Event.CHANGE, accSelected, this );
			App.listener_manager.add( App.mediator.scene_editing, SceneEvent.MODEL_LOADED, model_loaded_handler, this);

			cur_type_id = 4;	// why??
			
			init_shortcuts();
			
			// skin components
			new Custom_TileList_Skinner(ui.tileList_group, Accessories_Group_TileList_CellRenderer);
			new Custom_TileList_Skinner(ui.tileList_accessories, Accessories_Acc_TileList_CellRenderer);
			new Custom_Scrollbar_Skinner(ui.tileList_accessories);
			new Custom_Scrollbar_Skinner(ui.tileList_group);
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
		 ***************************** PUBLIC INTERFACE */
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
		 ***************************** PRIVATE */
		private function model_loaded_handler( _e:SceneEvent ) : void
		{
			if (ui.visible)	// do this only if the window is open
				load_accessories();
		}
		
		private function load_accessories(  ) : void
		{
			var model_id:int = App.mediator.scene_editing.model.id;
			list_accessories.load( model_id, null, new Callback_Struct(loaded, null, load_error)  );
			
			function loaded():void
			{
				populateAccessories();
				updateGroups();	
				set_focus();
			}
			function load_error( _e:AlertEvent ):void 
			{
				App.mediator.alert_user( _e );
			}
		}
		/*******************************************************
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
		 * ******************************** VIEW CONTROL - PRIVATE */
		private function open_win( _e:MouseEvent ):void 
		{	if 
			(
				App.mediator.scene_editing &&
				App.mediator.scene_editing.model &&
				App.mediator.scene_editing.model.has_head_data()
			)
			{
				ui.visible = true;
				load_accessories();
			}
			else
				App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t536', 'This feature is not available'));
		}
		private function close_win( _e:MouseEvent = null ):void 
		{
			ui.visible = false;
			// clear selectors for next open win
			ui.tileList_accessories.removeAll();
			ui.tileList_group.removeAll();
		}
		
		private function updateGroups():void
		{
			ui.tileList_group.removeAll();
			var availableTypes:Array = list_accessories.get_available_type_ids();
			
			if (App.mediator.scene_editing.model.is3d) 
				ui.tileList_group.addItem( { label:'remove', data:REMOVE_ALL_TYPE_ID } );
			var typeId:int;
			var typeName:String;
			for (var i:int = 0; i < availableTypes.length; i++) {
				typeId = availableTypes[i];
				typeName = list_accessories.get_type_name(typeId);
				ui.tileList_group.addItem( {label:typeName, data:typeId} );
			}
		}
		private function populateAccessories():void
		{
			ui.tileList_accessories.removeAll();
			var acc:AccessoryData;
			
			var acc_on_model:Object = App.mediator.scene_editing.getAccessories();
			
			// populate the accessory selector based on available accessories
			var accArr:Array = list_accessories.model.get_items_by_property('typeId',cur_type_id);
			if (accArr == null) 
				return;
			
			// show the selected accessory in the model
			var selected_acc_id:int = -1;
			var accData:AccessoryData;
			if (App.mediator.scene_editing.getAccessories() != null) 
				accData = App.mediator.scene_editing.getAccessories()[cur_type_id];
			if (accData != null) 
				selected_acc_id = accData.id;
			
			
			if (App.mediator.scene_editing.model.is3d) 
				ui.tileList_accessories.addItem({label:'none', data:NO_ACCESSORY_ID});
			for (var i:int = 0; i < accArr.length; i++) 
			{
				acc = accArr[i];
				var thumb_url:String = App.settings.LOAD_ACC_THUMBS ? acc.thumbUrl : null;
				if ( is_compatible( acc, acc_on_model ) )
					ui.tileList_accessories.addItem( { label:acc.name, data:acc.id, thumb:thumb_url } );
				// select if on vhost
				if ( acc.id == selected_acc_id )
					ui.tileList_accessories.selectedIndex = i;
			}
				
			function is_compatible( _acc:AccessoryData, _acc_on_model:Object ):Boolean
			{	for (var prop:String in _acc_on_model) 
  					if (_acc.typeId == (_acc_on_model[prop] as AccessoryData).incompatibleWith)
						return false;
				return true;
			}
		}
		private function groupSelected(evt:Event):void
		{
			var selected_id:int = ui.tileList_group.selectedItem.data;
			if (selected_id == REMOVE_ALL_TYPE_ID)  
			{
				App.mediator.scene_editing.removeAllAccessories();
				ui.tileList_group.selectedIndex = -1;
			}
			else 
			{
				cur_type_id = selected_id;
				populateAccessories();
			}
		}
		private function accSelected(evt:Event):void
		{
			var selected_id:int = ui.tileList_accessories.selectedItem.data;
			var scene:ISceneController = App.mediator.scene_editing;
			if (selected_id == NO_ACCESSORY_ID) 
			{
				scene.removeAccessory(cur_type_id);
				return;
			}
			
			var accs:Array = list_accessories.model.get_items_by_property('id',selected_id);
			if (accs && accs.length>0 )
			{
				add_listeners();
				App.mediator.processing_start(PROCESSING_ACC_LOAD, MSG_ACC_LOAD);
				scene.loadAccessory(accs[0]);		
			}
			
			function acc_loaded( _e:SceneEvent ):void
			{
				remove_listeners();
				App.mediator.processing_ended(PROCESSING_ACC_LOAD);
			}
			function acc_error( _e:SceneEvent ):void
			{
				remove_listeners();
				App.mediator.processing_ended(PROCESSING_ACC_LOAD);
			}
			function add_listeners():void
			{
				App.listener_manager.add( scene, SceneEvent.ACCESSORY_LOADED, acc_loaded, this );
				App.listener_manager.add( scene, SceneEvent.ACCESSORY_LOAD_ERROR, acc_error, this );
			}
			function remove_listeners():void
			{
				App.listener_manager.remove( scene, SceneEvent.ACCESSORY_LOADED, acc_loaded );
				App.listener_manager.remove( scene, SceneEvent.ACCESSORY_LOAD_ERROR, acc_error );
			}
		}
		 /*******************************************************
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
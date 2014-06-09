package code.controllers.vhost_type_selection 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.ui.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class VHost_Type_Selection
	{
		private var ui		:VHost_Type_Selector_UI;
		private var btnArr	:Array = new Array();
		private var mc		:MovieClip;
		
		public function VHost_Type_Selection( _ui:VHost_Type_Selector_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui			= _ui;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
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
			for (var i:int=0;i<ui.numChildren;i++)
				if (ui.getChildAt(i) is StickyButton) 
					btnArr.push(ui.getChildAt(i));
			
			for (i = 0; i < btnArr.length; i++) 
			{	btnArr[i].selected = false;
				App.listener_manager.add( btnArr[i], MouseEvent.CLICK, onClick, this );
			}
			init_btns();
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
		 ***************************** INTERNAL */
		private function onClick(evt:MouseEvent):void {
			var btn:StickyButton = evt.currentTarget as StickyButton;
			if (!btn.selected) btn.selected = true;
			else 
			{	for (var i:int = 0; i < btnArr.length; i++) 
				{	if (btnArr[i] == btn)
						App.mediator.autophoto_update_model_type( i + 1 );
					else 	btnArr[i].selected = false;
				}
			}
		}

		private function init_btns():void 
		{
			var n:int = chooseDefaultAutoPhotoModelType();
			var i:int;
			for (i = 0; i < btnArr.length; i++)
			{	if (i == n - 1) 
						btnArr[i].selected=true;
				else	btnArr[i].selected=false;
			}
		}
		private function chooseDefaultAutoPhotoModelType():int 
		{
			var default_vhost:WSModelStruct = App.asset_bucket.model_store.list_vhosts.get_default_vhost();
			if (!ServerInfo.is3D || default_vhost == null)
				return 0;
			App.mediator.autophoto_update_model_type( default_vhost.oa1Type );
			return default_vhost.oa1Type;
		}
		
	}

}
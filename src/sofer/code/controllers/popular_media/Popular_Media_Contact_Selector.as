package code.controllers.popular_media 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.SelectorItem;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Popular_Media_Contact_Selector implements IPopular_Media_Contact_Selector
	{
		private var ui					:Popular_Media_Contact_Selector_UI;
		private var model_contacts		:Model_Item;
		/** array of contact items */
		private var cur_selected_contacts:Array;
		
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
		public function Popular_Media_Contact_Selector() 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui				= Bridge.views.popular_media_contact_selector_UI;
			model_contacts	= App.asset_bucket.model_store.list_popular_media_contacts.model;
			
			// provide the mediator a reference to send data to this controller
			var registerred:Boolean = App.mediator.register_controller( this );
			
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
			App.listener_manager.add_multiple_by_object( [
				ui.btn_all,
				ui.btn_done,
				ui.btn_none,
				ui.btn_close], MouseEvent.CLICK, mouse_click_handler, this );
			
			ui.selector_email.addScrollBar(ui.scrollbar,true);
			App.listener_manager.add_multiple_by_event(ui.selector_email, [ 
				SelectorEvent.SELECTED, 
				SelectorEvent.DESELECTED ] , email_deselected_handler, this);
			ui.selector_email.keyEnabled = false;
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
		public function open_win(_currently_selected_recipient_list:Array):void
		{
			ui.visible = true;
			cur_selected_contacts=new Array();
			set_focus();
			ui.selector_email.clear();
			
			var all_contacts:Array=model_contacts.get_all_items();
			for (var i:int=0, n:int=all_contacts.length; i<n; ++i)
			{
				// add items
				var contact:Popular_Media_Contact_Item=all_contacts[i];
				var name:String=contact.name;
				var email:String=contact.email;
				ui.selector_email.add(i,email, name, false);
				// preselect if its present in the email selector
				if (_currently_selected_recipient_list && _currently_selected_recipient_list.indexOf(email)>=0)
				{	
					ui.selector_email.selectById(i);
					cur_selected_contacts.push(contact);
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
		***************************** INTERNALS */
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case ui.btn_done:
				case ui.btn_close:	
					close_win();	
					break;
				case ui.btn_all:
					select_all();
					break;
				case ui.btn_none:
					select_none();
					break;
			}
		}
		private function select_all():void
		{
			var success:Boolean=true;
			var all_contacts:Array=model_contacts.get_all_items();
			for (var i:int=0, n:int=all_contacts.length; i<n && success; ++i)
			{
				// add items
				var contact:Popular_Media_Contact_Item=all_contacts[i];
				var item:SelectorItem = ui.selector_email.getItemByName(contact.email);
				success=App.mediator.email_add_recipient(contact);
				if (success)
				{
					ui.selector_email.selectById(item.id);
					cur_selected_contacts.push(contact);
				}
			}
		}
		private function select_none():void
		{
			while (cur_selected_contacts.length>0)
			{
				var contact:Popular_Media_Contact_Item=cur_selected_contacts.pop();
				App.mediator.email_remove_recipient(contact);
				var item:SelectorItem = ui.selector_email.getItemByName(contact.email);
				if (item)
					ui.selector_email.deselectById(item.id);
			}
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		private function close_win(  ):void 
		{	
			ui.visible = false;
		}
		private function email_selected_handler(_e:SelectorEvent):void
		{
			var name:String=_e.obj as String;
			var email:String=_e.text;
			var contact:Popular_Media_Contact_Item=new Popular_Media_Contact_Item(name,email);
			var success:Boolean = App.mediator.email_add_recipient(contact);
			if (!success)// deselect it since email could not actually add it
				ui.selector_email.deselectById(_e.id);
			if (success)
				cur_selected_contacts.push(contact);
		}
		private function email_deselected_handler(_e:SelectorEvent):void
		{
			var name:String=_e.obj as String;
			var email:String=_e.text;
			var contact:Popular_Media_Contact_Item=new Popular_Media_Contact_Item(name,email);
			App.mediator.email_remove_recipient(contact);
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
		{	
			ui.stage.focus = ui;
		}
		/**
		 * initializes keyboard shortcuts
		 */
		private function init_shortcuts():void
		{	
			App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}
		private function shortcut_close_win(  ):void 		
		{	
			if (ui.visible)		
				close_win();	
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
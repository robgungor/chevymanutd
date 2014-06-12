package code.controllers.facebook_friend 
{
	import code.component.skinners.Custom_Scrollbar_Skinner;
	import code.component.skinners.Custom_TileList_Skinner;
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.data.*;
	import com.oddcast.event.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;
	
	import workshop.fbconnect.Facebook_Friend_Item;
	import workshop.ui.Facebook_Friend_Post_Selector_Item;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Facebook_Friend_Post
	{
		private const FILTER_LIST			:Array	= ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
		/* spacing between letters in the filter */
		private const FILTER_SPACE			:String = ' ';
		private const PROCESSING_LOADING_FRIENDS:String = 'PROCESSING_LOADING_FRIENDS';
		
		private var friends_list			:Array;
		private var btn_open				:InteractiveObject;
		private var ui						:*;
		private var selected_list			:Array	= new Array();
		private var select_friend_callback	:Function;
		
		public function Facebook_Friend_Post( _btn_open:InteractiveObject, _ui:* ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui 					= _ui;
			btn_open 			= _btn_open;
			
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
		private function init() : void
		{ 
			App.listener_manager.add_multiple_by_object([	btn_open,							
				ui.btn_close,
				ui.tf_filter, 
				ui.btn_all,
				ui.btn_none, 
				ui.btn_post_to_wall,
				ui.btn_clear_search//,
				 ], MouseEvent.CLICK, click_event_handler, this);
			
			
			/*var _ui:* =  App.ws_art.facebook_friend_upload;
			App.listener_manager.add_multiple_by_object([ 
			_ui.btn_close,
			_ui.tf_filter, 
			_ui.btn_all,
			_ui.btn_none, 
			_ui.btn_clear_search,
			_ui.btn_back ], MouseEvent.CLICK, click_event_handler_upload, this);*/
			
			
			App.listener_manager.add(ui.tf_search, Event.CHANGE, populate_selector_by_search, this );
			App.listener_manager.add(ui.tileList, Event.CHANGE, friend_selected, this);
			clear_search(true);
			//filter_by_char( FILTER_LIST[0] );	// select the first item for searching
			ui.tf_search.maxChars = 50;
			init_shortcuts();
			
			new Custom_TileList_Skinner( ui.tileList, Facebook_Friends_Post_TileList_CellRenderer );
			new Custom_Scrollbar_Skinner( ui.tileList );
		}
		private function click_event_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{	
				case btn_open:				optInConfirm(); break; //App.mediator.checkOptIn(optInConfirm);	break;
				case App.ws_art.mainPlayer.facebook_btn: return;//optInConfirm(); break; //App.mediator.checkOptIn(optInConfirm);	break;
				case ui.btn_close:			close_win();		break;
				case ui.tf_filter:			filter_clicked();	break;
				case ui.btn_clear_search:	clear_search(true);		break;
				case ui.btn_post_to_wall:	App.mediator.postToOwnWall();		break;
				case ui.btn_all:			select_filter_all();	break;
				case ui.btn_none:			select_filter_none();	break;
				case ui.btn_back:			close_win();
					App.mediator.autophoto_open_mode_selector();
					break;
			}
		}
		protected function optInConfirm():void
		{
			open_win( post_to_user );
		}
		/**
		 * selects all the characters in the filter and populates the list
		 */
		private function select_filter_all():void 
		{
			selected_list = [];
			for (var i:int = 0; i < FILTER_LIST.length; i++) 
				selected_list.push( FILTER_LIST[i] );
			populate_selector_by_filer();
			refresh_filter();
		}
		/**
		 * populates an empty selector
		 */
		private function select_filter_none():void 
		{
			selected_list = [];
			populate_selector_by_filer();
			refresh_filter();
		}
		public function close_win( ):void
		{
			ui.visible = false;
			App.ws_art.facebook_friend.visible = false;
		}
		public function open_win( _callback:Function, isAutoPhoto:Boolean = false ) : void
		{
			
			//App.mediator.scene_editing.stopAudio();
			//ui.btn_back.visible = ui.autophoto_header.visible = isAutoPhoto;
			ui.search_header.visible = !isAutoPhoto;			
			
			select_friend_callback = _callback;
			ui.visible = true;
			ui.tileList.removeAll();
			retrieve_friends_list();
			set_focus();
			
			function retrieve_friends_list() : void
			{
				if (App.mediator.facebook_connect_is_logged_in())
					user_logged_in();
				else
					App.mediator.facebook_connect_login(user_logged_in);
				
				function user_logged_in() : void
				{
					App.mediator.processing_start( PROCESSING_LOADING_FRIENDS );
					App.mediator.facebook_connect_get_friends_info(friends_ready);
					function friends_ready(_friends_list:Array) : void
					{
						App.mediator.processing_ended( PROCESSING_LOADING_FRIENDS );
						friends_list = _friends_list
						if (friends_list == null ||
							friends_list.length == 0)
						{	App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t555", "There are no friends available"));
							close_win();
						}
						else
						{	
							friends_list.sortOn('name');
							if (App.settings.FACEBOOK_CONNECT_USER_FRONT_OF_LIST)
								move_user_to_start_of_list( App.mediator.facebook_connect_user_id(), friends_list );
							
							if (ui.tf_search.text.length > 0)		// user had a search set previously
								populate_selector_by_search();
							else									// no search so show whatever is selected in the filter
								populate_selector_by_filer();
						}
						
						function move_user_to_start_of_list( _user_id:String, _friends_list:Array ) : void
						{
							var user:Facebook_Friend_Item;
							loop1: for (var i:int = 0, n:int = _friends_list.length; i<n; i++ )
							{
								user = _friends_list[i];
								if (user.user_id == _user_id)
								{
									 _friends_list.splice( i, 1 ).pop();
									break loop1;
								}
							}
						}
					}
				}
			}
		}
		private function friend_selected( _e:Event ):void
		{
			var selected_item:Object = ui.tileList.selectedItem;
			if (selected_item)
			{
				var cur_friend:Facebook_Friend_Item = selected_item.data as Facebook_Friend_Item;
				if (select_friend_callback != null)	
					select_friend_callback( cur_friend );
			}
		}
		private function post_to_user( _user:Facebook_Friend_Item ):void
		{
			//if (App.settings.FACEBOOK_POST_GENERATE_IMAGE)
			//App.mediator.screenshot_host( new Callback_Struct(thumb_ready,null,thumb_error) );
			//else
			//thumb_ready( App.settings.FACEBOOK_POST_IMAGE_URL );
			//
			//function thumb_ready(_thumb_url:String):void
			//{
			//App.mediator.facebook_post_new_mid_to_user( _user.user_id, _thumb_url );
			//}
			//function thumb_error( _e:AlertEvent ):void 
			//{	
			//App.mediator.alert_user( _e );
			//}
			App.mediator.facebook_post_new_mid_to_user( _user.user_id );
		}
		private function clear_search( _select_all:Boolean = false ):void 
		{	
			ui.tf_search.text = '';
			if (_select_all)
				select_filter_all();
		}
		private function populate_selector_by_search( _e:Event = null ):void 
		{	
			if (ui.tf_search.text=='')	// search is empty so show all 
				select_filter_all();
			else
			{
				// unselect anything in the filter
				selected_list = [];
				refresh_filter();
				
				if (friends_list)
				{
					var list:Array = new Array()
					// build list by search string
					for (var i:int = 0; i < friends_list.length; i++) 
					{	var cur_friend	:Facebook_Friend_Item 	= friends_list[i];
						if ( cur_friend.name.toLowerCase().indexOf( ui.tf_search.text.toLowerCase()) >= 0 )
							list.push(cur_friend);
					}
					populate_tileList( list );
				}
			}
		}
		private function populate_selector_by_filer(  ):void
		{	
			if (friends_list == null)
				return;
			// build list by filter string
			var list:Array = new Array();
			for (var i:int = 0; i < friends_list.length; i++) 
			{	var cur_friend	:Facebook_Friend_Item 	= friends_list[i];
				if ( selected_list.indexOf(cur_friend.filter_str.toLowerCase()) >= 0 )
					list.push(cur_friend);
			}
			populate_tileList( list );
		}
		
		private function populate_tileList( _list:Array ):void
		{
			ui.tileList.removeAll();
			//ui.tileList.columnCount = 4;
			//ui.tileList.columnWidth = 140;
			ui.tileList.setSize(435, 128);
			ui.tileList.verticalScrollBar.x = 430;
			for (var i:int = 0, n:int = _list.length; i<n; i++ )
			{
				var friend:Facebook_Friend_Item = _list[ i ];
				ui.tileList.addItem( {label:friend.name, thumb:friend.img_large_url, data:friend } );
				// break LOOP1;
			}
		}
		
		private function filter_by_char( _char:String ):void 
		{	var tf				:TextField	= ui.tf_filter;
			var char_to_toggle	:String		= _char;
			
			// remove or add selected
			if (selected_list.indexOf( char_to_toggle )>=0)	// in list
				selected_list.splice( selected_list.indexOf( char_to_toggle ), 1 );
			else	// not in list
				selected_list.push( char_to_toggle );
			
			selected_list.sort();
			refresh_filter();
		}
		private function refresh_filter(  ):void 
		{	var tf				:TextField	= ui.tf_filter;
			tf.htmlText = '';
			for ( var i:int; i < FILTER_LIST.length; i++ )
			{	var to_add:String;
				if (selected_list.indexOf( FILTER_LIST[i] ) >= 0 )
					to_add = '<font color="#006600"><b>' + FILTER_LIST[i] + '</b></font>';
				else	to_add = '<font color="#ff0000">' + FILTER_LIST[i] + '</font>';
				tf.htmlText += to_add + FILTER_SPACE;
			}
		}
		private function filter_clicked(  ):void 
		{	clear_search();
			var tf				:TextField	= ui.tf_filter;
			var clicked_on_index:int		= tf.getCharIndexAtPoint(tf.mouseX, tf.mouseY);	// find index of char clicked on in string
			var clicked_on_char	:String		= tf.text.substr( clicked_on_index, 1 );		// find char clicked on from textfield
			var filter_index	:int		= FILTER_LIST.indexOf(clicked_on_char);			// find that character index in array
			if (filter_index < 0)
				return;	// not found in filter list
			var filter_char		:String		= FILTER_LIST[ filter_index ];					// find that character in the array
			filter_by_char( filter_char );
			populate_selector_by_filer();
		}
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui.tf_search;
		}
		private function init_shortcuts():void
		{	
			App.shortcut_manager.api_add_shortcut_to( ui				, Keyboard.ESCAPE	, shortcut_close_win );
		}	
		private function shortcut_close_win(  ):void 		{	close_win();	}
		/*******************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
	}
	
}
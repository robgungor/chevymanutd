package com.oddcast.utils 
{
	import flash.events.Event;
	import flash.utils.describeType;
	import flash.xml.XMLNode;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Listener_Manager 
	{
		private var listener_list	:Listener_List	= new Listener_List();
		
		public function Listener_Manager() 
		{
			
		}
		/**
		 * adds a listener
		 * @param	_attach_obj the specific object such as a button or loader
		 * @param	_event		the event to listen for eg MouseEvent.CLICK
		 * @param	_callback	callback function when event is fired
		 * @param	_child_of	what is the parent of this object, used for clearing up all listeners children of something.
		 */
		public function add( _attach_obj:*, _event:String, _callback:Function, _child_of:* ):void 
		{
			if (listener_list.is_already_in_list( _attach_obj, _event, _callback ))
			{	// silent errors... dont throw this as it should be allowed to add it twice... bad coding tho
				//throw new Error( "LISTENER EVENT ALREADY PRESENT" );
			}
			else
			{
				_attach_obj.addEventListener( _event, _callback );
				listener_list.add_to_list( _attach_obj, _event, _callback, _child_of );
			}
		}
		/**
		 * adds an Event Type to an array of objects with the same callback handler 
		 * @param _attach_objs	 the specific object such as a button or loader eg: [button, loader]
		 * @param _event	the event to listen for eg MouseEvent.CLICK
		 * @param _callback	callback function when event is fired
		 * @param _child_of	what is the parent of this object, used for clearing up all listeners children of something.
		 * 
		 */		
		public function add_multiple_by_object( _attach_objs:Array, _event:String, _callback:Function, _child_of:* ) : void
		{
			var attach_obj:*;
			for (var i:int = 0, n:int = _attach_objs.length; i<n; i++ )
			{
				attach_obj = _attach_objs[ i ];
				add( attach_obj, _event, _callback, _child_of );
			}
		}
		/**
		 * add an array of Event Types to the same object with the same callback handler 
		 * @param _attach_obj the specific object such as a button or loader
		 * @param _events	the event to listen for eg [MouseEvent.CLICK, MouseEvent,MOUSE_OVER]
		 * @param _callback	callback function when event is fired
		 * @param _child_of	what is the parent of this object, used for clearing up all listeners children of something.
		 * 
		 */		
		public function add_multiple_by_event( _attach_obj:*, _events:Array, _callback:Function, _child_of:* ) : void
		{
			var event:String;
			for (var i:int = 0, n:int = _events.length; i<n; i++ )
			{
				event = _events[ i ];
				add( _attach_obj, event, _callback, _child_of );
			}
		}
		
		/**
		 * adds all event types by class to an object with the same callback handler 
		 * @param _attach_obj the specific object such as a button or loader
		 * @param _event_clazz class of different event types eg: TextEvent
		 * @param _callback	callback function when event is fired
		 * @param _child_of	what is the parent of this object, used for clearing up all listeners children of something.
		 * 
		 */		
		public function add_listeners_for_all_event_types(_attach_obj:*, _event_clazz:Class, _callback:Function, _child_of:*):void 
		{ 
			var xml:XML = describeType(_event_clazz); 
			var event_type:String, constant_type:String, constant_name:String;
			for (var i:int = 0, n:int = xml.constant.length(); i < n; i++) 
			{
				constant_type = xml.constant[i].@type;
				if (constant_type == "String")
				{
					constant_name = xml.constant[i].@name;
					event_type = _event_clazz[constant_name];
					add( _attach_obj, event_type, _callback, _child_of ); 
				}
			} 
		}
		
		/**
		 * removes all event types by class to an object with the same callback handler 
		 * @param _attach_obj the specific object such as a button or loader
		 * @param _event_clazz class of different event types eg: TextEvent
		 * @param _callback	callback function when event is fired
		 * 
		 */		
		public function remove_listeners_for_all_event_types(_attach_obj:*, _event_clazz:Class, _callback:Function):void 
		{ 
			var xml:XML = describeType(_event_clazz); 
			var event_type:String, constant_type:String, constant_name:String;
			for (var i:int = 0, n:int = xml.constant.length(); i < n; i++) 
			{
				constant_type = xml.constant[i].@type;
				if (constant_type == "String")
				{
					constant_name = xml.constant[i].@name;
					event_type = _event_clazz[constant_name];
					remove( _attach_obj, event_type, _callback ); 
				}
			} 
		}
		
		
		/**
		 * removes a listener
		 * @param	_attach_obj the specific object such as a button or loader
		 * @param	_event		the event to listen for eg MouseEvent.CLICK
		 * @param	_callback	callback function when event is fired
		 */
		public function remove( _attach_obj:*, _event:String, _callback:Function ):void 
		{
			_attach_obj.removeEventListener( _event, _callback );
			listener_list.remove_from_list( _attach_obj, _event, _callback, null );
		}
		/**
		 * removes all listeners attached to a specific object
		 * @param	_attach_obj object with listeners
		 * @return how many listeners were removed for this object
		 */
		public function remove_all_listeners_on_object( _attach_obj:* ):int
		{
			var matching_indexes:Array = listener_list.list_of_indexes_for_specific_object( _attach_obj );
			for (var i:int = 0; i < matching_indexes.length; i++) 
			{
				var item_index	:int			= matching_indexes[i];
				var cur_item	:Listener_Item	= listener_list.get_item( item_index );
				cur_item.attach_obj.removeEventListener( cur_item.event, cur_item.callback );
			}
			listener_list.remove_indexes( matching_indexes );
			return matching_indexes.length;
		}
		/**
		 * removes all listeners attached to a specific objects children (only those that were created with specific child_of)
		 * (only one level deep )
		 * @param	_parent_obj the parent object contaning children with listeners
		 * @return how many listeners were removed for this object
		 */
		public function remove_all_listeners_on_children_of( _parent_obj:* ):int
		{
			var matching_indexes:Array = listener_list.list_of_indexes_for_specific_object_whos_parent_is( _parent_obj );
			for (var i:int = 0; i < matching_indexes.length; i++) 
			{
				var item_index	:int			= matching_indexes[i];
				var cur_item	:Listener_Item	= listener_list.get_item( item_index );
				cur_item.attach_obj.removeEventListener( cur_item.event, cur_item.callback );
			}
			listener_list.remove_indexes( matching_indexes );
			return matching_indexes.length;
		}
		/**
		 * NOTE this call will remove listeners added from ALL classes from ALL objects that used this manager class
		 * NOTE if a listener was added not using this class it will NOT be removed
		 */
		public function remove_all_listeners_ever_added(  ):void 
		{
			for (var i:int = 0; i < listener_list.entire_list().length; i++) 
			{
				var cur_item	:Listener_Item	= listener_list.entire_list()[i];
				cur_item.attach_obj.removeEventListener( cur_item.event, cur_item.callback );
			}
			listener_list = null;
			listener_list = new Listener_List();
		}
		
		/**
		 * removes whatever event was dispatched from whatever called it
		 * @param	_event			event that is caught
		 * @param	_arguments		arguments parameter to access the callee
		 */
		public function remove_caught_event_listener( _event:Event, _arguments:Object ):void 
		{	
			remove( _event.currentTarget, _event.type, _arguments.callee);
		}
	}
	
}







internal class Listener_List
{
	/* array of Listener_Item */
	private var list		:Array;
	private const NOT_FOUND	:int		= -3737;
	
	public function Listener_List()	
	{
		list = new Array();
	}
	/**
	 * checks if a duplicate is already in the list
	 * @param	_attach_obj
	 * @param	_event
	 * @param	_callback
	 * @return	true if already in the list
	 */
	public function is_already_in_list( _attach_obj:*, _event:String, _callback:Function ):Boolean
	{
		var new_item:Listener_Item = new Listener_Item( _attach_obj, _event, _callback, null );
		return index_in_list( new_item ) != NOT_FOUND;
	}
	/**
	 * add new item to the list
	 * @param	_attach_obj
	 * @param	_event
	 * @param	_callback
	 * @param	_child_of
	 */
	public function add_to_list( _attach_obj:*, _event:String, _callback:Function, _child_of:* ):void
	{
		var new_item:Listener_Item = new Listener_Item( _attach_obj, _event, _callback, _child_of );
		var arr_index:int = index_in_list( new_item );
		if ( arr_index == NOT_FOUND )
			list.push( new Listener_Item( _attach_obj, _event, _callback, _child_of ) );
	}
	/**
	 * remove and item from the list
	 * @param	_attach_obj
	 * @param	_event
	 * @param	_callback
	 * @param	_child_of
	 */
	public function remove_from_list( _attach_obj:*, _event:String, _callback:Function, _child_of:* ):void
	{
		var find_this_item:Listener_Item = new Listener_Item( _attach_obj, _event, _callback, _child_of);
		var arr_index:int = index_in_list( find_this_item );
		if ( arr_index != NOT_FOUND )
		{
			var temp:Array = list.splice(arr_index, 1);	// remove item specified
		}
	}
	/**
	 * find the index of an item in the list
	 * @param	_item
	 * @return
	 */
	private function index_in_list( _item:Listener_Item ):int
	{
		for (var i:int = 0; i < list.length; i++)
		{
			var cur:Listener_Item = list[i];
			if ( 	cur.attach_obj == _item.attach_obj &&
					cur.event == _item.event &&
					cur.callback == _item.callback )
			{
				return i;
			}
		}
		return NOT_FOUND;
	}
	/**
	 * finds items indexes in the list
	 * @param	_attach_obj
	 * @return array of indexes that match the object
	 */
	public function list_of_indexes_for_specific_object( _attach_obj:* ):Array
	{
		var matching_indexes:Array = new Array();
		for (var i:int = 0; i < list.length; i++)
		{
			var cur:Listener_Item = list[i];
			if ( cur.attach_obj == _attach_obj )
				matching_indexes.push( i );
		}
		return matching_indexes;
	}
	/**
	 * finds items indexes in the list who are children of...
	 * @param	_parent_obj parent object
	 * @return array of indexes that match the object
	 */
	public function list_of_indexes_for_specific_object_whos_parent_is( _parent_obj:* ):Array
	{
		var matching_indexes:Array = new Array();
		for (var i:int = 0; i < list.length; i++)
		{
			var cur:Listener_Item = list[i];
			if ( cur.child_of == _parent_obj )
				matching_indexes.push( i );
		}
		return matching_indexes;
	}
	public function get_item( _index:int ):Listener_Item
	{
		return list[_index] as Listener_Item;
	}
	/**
	 * removes a list of indexes from the list
	 * @param	_indexes array of indexes
	 */
	public function remove_indexes( _indexes:Array ):void
	{
		for (var i:int = ( _indexes.length - 1) ; i >= 0 ; i-- ) // has to be done backwards
		{
			var index_to_remove:int = _indexes[i];
			var temp:Array = list.splice(index_to_remove, 1);	// remove item specified
		}
	}
	/**
	 * returns a reference to the entire list of items and listeners
	 * @return
	 */
	public function entire_list(  ):Array
	{
		return list;
	}
}






internal class Listener_Item
{
	public var attach_obj:*;
	public var event:String;
	public var callback:Function;
	public var child_of:*;
	
	public function Listener_Item( _attach_obj:*, _event:String, _callback:Function, _child_of:* )	
	{
		attach_obj	= _attach_obj;
		event		= _event
		callback	= _callback;
		child_of	= _child_of;
	}
}
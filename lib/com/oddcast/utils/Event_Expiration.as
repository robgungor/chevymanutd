package com.oddcast.utils 
{
	/**
	 * keeps track of events that might time out/expire
	 * @author Me^
	 */
	public class Event_Expiration
	{
		// array of Event_Item
		private var event_list		:Array;
		private const NOT_IN_LIST	:int = -1;
		
		public function Event_Expiration() 
		{	event_list = [];
		}
		
		/**
		 * adds a new Event which has the possibility of expiring
		 * @param	_event_key			custom specific ID for this event eg: "my facebook connect event" NOTE:KEEP THIS KEY FOR REMOVAL OF EVENT
		 * @param	_timeout_millisec	milliseconds for when this event times out
		 * @param	_expired			callback when this event has finished (passes NO parameters)
		 */
		public function add_event( _event_key:String, _timeout_millisec:int, _expired:Function ):void 
		{	// validate values
				if ( !_event_key
					||
					_event_key.length == 0
					||
					isNaN(_timeout_millisec)
					||
					_timeout_millisec < 1
					||
					_expired == null)
				{	
					throw new Error('Event_Expiration.add_event() failed due to invalid parameters');
				}
				else if (event_key_exists(_event_key))
						throw new Error('Event_Expiration.add_event() failed: event already exists');
				else	event_list.push( new Event_Item( _event_key, _timeout_millisec, _expired, remove_event ));
		}
		/**
		 * remove an event from the expiration list in case that event has occurred and we dont want it to expire anymore
		 * @param	_event_key			custom specific ID for this event eg: "my facebook connect event"
		 */
		public function remove_event( _event_key:String ):void 
		{	if (event_key_exists(_event_key))
			{	var index	:int	= event_key_index( _event_key );	// index in the list
				(event_list[index] as Event_Item).stop_event();			// stop the event timer
				var temp	:Array	= event_list.splice( index, 1 );	// remove it from the queue
			}
		}
		private function event_key_exists( _event_key:String ):Boolean
		{	return event_key_index( _event_key ) != NOT_IN_LIST;
		}
		private function event_key_index( _event_key:String ):int
		{	for (var i:int = 0; i < event_list.length; i++) 
			{	var cur_event:Event_Item = event_list[i];
				if (cur_event.key == _event_key)
					return i;
			}
			return NOT_IN_LIST;
		}
		
	}

}





import flash.events.*;
import flash.utils.*;
internal class Event_Item
{
	public var key			:String;
	public var timeout_ms	:int;
	public var expired		:Function;
	public var remove_event	:Function;
	
	private var timer		:Timer;
	
	/**
	 * creates a new event and starts a timer for its timeout
	 * @param	_event_key			event specific key
	 * @param	_timeout_millisec	timout in milliseconds
	 * @param	_expired			clients expired function
	 * @param	_remove_event		function to remove the event based on key from the factory class
	 */
	public function Event_Item( _event_key:String, _timeout_millisec:int, _expired:Function, _remove_event:Function )
	{	key				= _event_key;
		timeout_ms		= _timeout_millisec;
		expired			= _expired;
		remove_event	= _remove_event;
		start_timer();
	}
	public function stop_event(  ):void 
	{	timer.stop();
		timer.removeEventListener(TimerEvent.TIMER, timed_out);
		timer = null;
	}
	private function start_timer(  ):void 
	{	timer = new Timer( timeout_ms, 0 );
		timer.addEventListener(TimerEvent.TIMER, timed_out);
		timer.start();
	}
	private function timed_out( _e:TimerEvent ):void 
	{	remove_event( key );
		expired();
	}
}
package com.oddcast.host.api.events {
	import flash.events.Event;
	
	public class Event3D extends flash.events.Event {
		public function Event3D(type : String = null,event : flash.events.Event = null) : void {  {
			this.event = event;
			super(type);
		}}
		
		public var event : flash.events.Event;
	}
}

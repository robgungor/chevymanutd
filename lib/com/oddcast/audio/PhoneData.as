/**
* ...
* @author Sam
* @version 2.0
* adapted from AS2 otc/classes/phone.as
*/

package com.oddcast.audio {
	import com.oddcast.event.PhoneRecorderEvent;

	public class PhoneData {
		public var passCode:String;
		public var phoneNum:String;
		public var useCaptcha:Boolean;
		public var appId:int;
		private var eventsDispatched:Object;
		
		public function PhoneData() {
			eventsDispatched=new Object();
		}
		
		public function addCallback(evtName:String) {
			eventsDispatched[evtName]=true;
		}
		
		public function removeCallback(evtName:String) {
			eventsDispatched[evtName]=false;			
		}
		
		public function hasCallback(evtName:String):Boolean {
			return (eventsDispatched[evtName]==true);
		}
	}
	
}
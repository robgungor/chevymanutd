/**
* ...
* @author Sqam
* @version 0.1
* 
* This is a class to coordinate multiple asynchronous events.
* 
* eg
* you want to call function allComplete when obj1 and obj2 have both dispatched the event Event.Complete
* the listener for obj1 would be : obj1.addEventListener(Event.COMPLETE,obj1complete)
* 
* to use ConditionGate:
* 
* gate=new ConditionGate()
* gate.addEventListener(Event.COMPLETE,addComplete);
* gate.addEvent(obj1,Event.COMPLETE)
* gate.addEvent(obj2,Event.COMPLETE)
*/

package com.oddcast.workshop {
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class ConditionGate extends EventDispatcher {
		public var evtList:Array;
		public var callbackFn:Function;
		
		public function ConditionGate() {
			evtList=new Array();
		}
		
		public function addEvent(obj:EventDispatcher,evtName:String) {
			evtList.push({target:obj,type:evtName});
			obj.addEventListener(evtName,onEvent,false,0,true);
		}
		
		public function addCallback(fn:Function) {
			callbackFn=fn;
		}
		
		private function onEvent(evt:Event) {
			if (evtList.length==0) return;
			for (var i:int=0;i<evtList.length;i++) {
				if (evtList[i].target==evt.currentTarget&&evtList[i].type==evt.type) {
					evtList[i].target.removeEventListener(evtList[i].type,onEvent);
					evtList.splice(i,1);
					i--;
				}
			}
			if (evtList.length==0) {
				var fn:Function=callbackFn;
				dispatchEvent(new Event(Event.COMPLETE));
				callbackFn=null;
				trace("calling function : "+fn);
				if (fn!=null) fn();
			}
		}
	}
	
}
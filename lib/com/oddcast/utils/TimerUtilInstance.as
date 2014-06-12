/**
* @author Sam Myer
* 
* This class is used by TimerUtil to implement timers using callbacks instead of listeners
*/
package com.oddcast.utils {
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class TimerUtilInstance extends EventDispatcher {
		public var timer:Timer;
		public var callback:Function;
		
		public function TimerUtilInstance($callback:Function, $timer:Timer) {
			timer = $timer;
			callback = $callback;
		}
		
		public function start() : void {
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			timer.reset();
			timer.start();
		}
		
		public function onTimer(evt:TimerEvent) : void {
			callback();
		}
		
		private function onTimerComplete(evt:TimerEvent) : void {
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			dispatchEvent(evt);
		}
		
		public function stop() : void {
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
	}
	
}
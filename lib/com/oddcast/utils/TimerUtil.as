/**
* @author Sam Myer
* 
* Static class that simplifies using timers and setInterval and takes care of listeners for you
* 
* Usage:
* function callFunctionFInOneSecond() {
* 	TimerUtil.setInterval(f,1000);
* }
* 
* function f() {
*   TimerUtil.stopInterval(f)
* }
*/
package com.oddcast.utils {
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class TimerUtil {
		private static var timerArr:Dictionary=new Dictionary(true);
		
		public static function setInterval(fn:Function, intervalMs:Number,repeatCount:uint=0) : void {
			//if (intervalMs < 20) intervalMs = 20; //sanity check
			
			var existing:TimerUtilInstance = timerArr[fn];
			if (existing == null) {
				var t:TimerUtilInstance = new TimerUtilInstance(fn, new Timer(intervalMs, repeatCount));
				t.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				t.start();
				timerArr[fn] = t;
			}
			else existing.timer.delay = intervalMs;
		}
		
		public static function setTimeout(fn:Function, intervalMs:Number) : void {
			setInterval(fn, intervalMs, 1);
		}

		private static function onTimerComplete(evt:TimerEvent) : void {
			var t:TimerUtilInstance = evt.currentTarget as TimerUtilInstance;
			t.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			delete timerArr[t.callback];
		}
		
		public static function stopInterval(fn:Function) : void {
			var existing:TimerUtilInstance = timerArr[fn];
			if (existing == null) return;
			existing.stop();
			existing.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			delete timerArr[fn];
		}
	}
	
}
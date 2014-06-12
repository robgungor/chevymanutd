/**
* ...
* @author Sam
* @version 0.1
* 
* Simple tweening class
* 
* addTween - adds a property to tween
* play(time,startFromCurrentPos) - plays the tween.
* time is the number of seconds the tween plays for.  If you provide a negative number
* the tween will play in reverse.
* startFromCurrentPos - the tween starts from it's current position
* for example, if you have a menu popping up, and you pop in down before it is finished popping up, it will start popping
* down from where it is, instead of jumping to the popped-up position
* 
* easeIn,easeOut - are static Functions you can pass to addTween as variables to do easing.
* 
* e.g.
* var mc:MovieClip;
* var tween:SimpleTween=new SimpleTween(mc);
* tween.addTween("x",-50,0,SimpleTween.easeIn);
* 
* //on mouse over
* tween.play(0.5);
* 
* //on mouse out
* tween.play(-0.5,true)
*/

package com.oddcast.utils {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	public class SimpleTween extends EventDispatcher {
		private var mc:DisplayObject;
		private var tweens:Object;
		private var totalTime:Number;
		private var startTime:int;
		private var reverse:Boolean=false;
		private var curPos:Number = 0;
		public var callback:Function;
		
		public function SimpleTween($mc:DisplayObject) {
			mc=$mc;
			tweens=new Object();
		}
		
		public function addTween(propertyName:String,startVal:Number,endVal:Number,easing:Function=null) {
			tweens[propertyName]={startVal:startVal,endVal:endVal,easing:easing};
		}
		
		public function removeTween(propertyName:String) {
			delete tweens[propertyName];
		}
		
		public function play($time:Number,startFromCurrentPos:Boolean=false) {
			totalTime=Math.abs($time*1000);
			reverse=($time<0);
			if (!startFromCurrentPos) {
				curPos=reverse?1:0;
				startTime=getTimer();
			}
			else {
				startTime=getTimer()-totalTime*(reverse?(1-curPos):curPos);
			}
			update(curPos);
			mc.addEventListener(Event.ENTER_FRAME,enterFrame,false,0,true);
		}
				
		public function stop() {
			mc.removeEventListener(Event.ENTER_FRAME,enterFrame);
		}
		
		private function enterFrame(evt:Event) {
			var t:Number=getTimer()-startTime;
			if (t>totalTime) {
				update(reverse?0:1);
				mc.removeEventListener(Event.ENTER_FRAME,enterFrame);
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else update(reverse?(1-t/totalTime):t/totalTime);
		}
		
		private function update(perc:Number) {
			var tw:Object;
			var easePerc:Number;
			curPos=perc;
			
			for (var property:String in tweens) {
				tw=tweens[property];
				if (mc[property]==null) continue;
				if (tw.easing!=null) easePerc=tw.easing(perc);
				else easePerc=perc;
				
				mc[property]=(1-easePerc)*tw.startVal+easePerc*tw.endVal;
			}			
		}
		
		public static function easeIn(n:Number) {
			return((2-n)*n);
		}
		
		public static function easeOut(n:Number) {
			return(n*n);
		}
		
		public function get target():DisplayObject {
			return(mc);
		}
	}
	
}
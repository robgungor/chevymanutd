/**
* ...
* @author Default
* @version 0.1
*/

package workshop.ui {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;

	public class AudioTimer extends MovieClip {
		private var timeLimit:Number=60;
		private var startTime:Number,startTimerPos:Number;
		public var tf_timeLimit:TextField;
		public var bar:MovieClip;
		
		//if time limit is eg 60sec, stop at 55.5 sec instead of risking going over 60 sec
		public var margin:Number=0.5;
		
		public function AudioTimer() {
			tf_timeLimit=getChildByName("tf_timeLimit") as TextField;
			bar=getChildByName("bar") as MovieClip;
			
			resetTimer();
		}
		
		public function setTimeLimit(n:Number):void {
			timeLimit=n;
			tf_timeLimit.text=timeLimit.toString();
		}
		
		public function resetTimer():void {
			removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			startTimerPos=0;
			update(0);
		}
		
		public function startTimer():void {
			startTimerPos=0;
			startTime=getTimer();
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			update(0);
		}
		
		public function stopTimer():void {
			removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			startTimerPos=getTimer()-startTime;
		}
		
		public function resumeTimer():void {
			if ((timeLimit-startTimerPos)>margin) {
				startTime=getTimer();
				addEventListener(Event.ENTER_FRAME,onEnterFrame);
			}
		}
		
		private function onEnterFrame(evt:Event):void {
			var curTime:Number=(startTimerPos+(getTimer()-startTime))/1000;
			update(curTime/timeLimit);
			if ((timeLimit-curTime)<=margin) {
				stopTimer();
				dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			}
		}
		
		private function update(perc:Number):void {
			bar.scaleX=perc;
		}
	}
	
}
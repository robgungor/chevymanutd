package com.oddcast.ui.animation {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AccelerationScroll implements IScrollEasing {
		private var curPos:Number;
		private var targetPos:Number;
		private var isComplete:Boolean = true;
		private var diff:Number;
		private var vel:Number;
		
		public function setStartPos(n:Number):void {
			curPos = n;
			targetPos = Number.NaN;
			isComplete = false;
			vel = 0;
		}
		public function getTargetPos():Number {
			return(targetPos);
		}
		public function setTargetPos(n:Number):void {
			targetPos = n;
			isComplete = (curPos == targetPos);
			diff = targetPos - curPos;
		}
		public function getNextPos(percentMoved:Number):Number {
			//var accel:Number = (targetPos - curPos) * percentMoved * 5;
			var accel:Number = (targetPos - curPos) * 0.25;
			var friction:Number = 0.6;
			vel += accel;
			vel *= friction; //friction
			var newPos:Number = curPos + vel;
			var minDiff:Number = Math.abs(diff * 0.01);
			if (Math.abs(vel) < minDiff&&Math.abs(targetPos-curPos)<minDiff) {
				newPos = targetPos;
				isComplete = true;
			}
			//trace("curPos = " + curPos + "  targetPos=" + targetPos + "  nextPos=" + newPos);
			curPos = newPos;
			return(curPos);
		}
		public function getComplete():Boolean {
			return(isComplete);
		}
	}
	
}
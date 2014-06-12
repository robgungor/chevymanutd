package com.oddcast.ui.animation {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class EasingScroll implements IScrollEasing {
		private var curPos:Number;
		private var targetPos:Number;
		private var isComplete:Boolean = true;
		private var diff:Number;
		
		public function setStartPos(n:Number):void {
			curPos = n;
			targetPos = Number.NaN;
			isComplete = false;
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
			var n:Number=1-Math.pow(0.01,percentMoved);
			var d:Number = targetPos - curPos;
			var newPos:Number = curPos + n * d;
			if (Math.abs(targetPos - newPos) < Math.abs(diff * 0.01)) {
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
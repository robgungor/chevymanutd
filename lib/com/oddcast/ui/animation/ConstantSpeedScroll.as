package com.oddcast.ui.animation {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ConstantSpeedScroll implements IScrollEasing {
		private var curPos:Number;
		private var targetPos:Number;
		private var isComplete:Boolean=true;
		
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
		}
		public function getNextPos(percentMoved:Number):Number {
			var curDir:int = getSign(targetPos - curPos);
			var newPos:Number = curPos +  curDir * percentMoved;
			var newDir:int = getSign(targetPos - newPos);
			if (newDir == 0 || curDir != newDir) {
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
		private function getSign(n:Number):int {
			if (n < 0) return( -1);
			else if (n > 0) return(1);
			else return(0);
		}
	}
	
}
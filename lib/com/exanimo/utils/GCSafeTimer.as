/**
 *
 * GCSafeTimer.as
 *
 *     A Timer that refuses to be garbage-collected.
 *
 *     version history:
 *	       2007.07.20
 *             - first draft
 *
 *     @author     matthew at exanimo dot com
 *     @version    2007.07.20
 *
 */

package com.exanimo.utils
{
	import com.exanimo.utils.GarbageCollectionShield;
	import flash.events.TimerEvent;
	import flash.utils.Timer;




	public class GCSafeTimer extends Timer
	{
		private static var _gcShield:GarbageCollectionShield = new GarbageCollectionShield();




		public function GCSafeTimer(delay:Number, repeatCount:int = 0)
		{
			// Add listeners so that we know when to start allowing garbage
			// collection again.
			this.addEventListener(TimerEvent.TIMER_COMPLETE, GCSafeTimer._allowGarbageCollection);
			
			super(delay, repeatCount);
		}




		//
		// public methods
		//


		/**
		 *
		 * Stops the timer, if it is running, and sets the currentCount property back
		 * to 0, like the reset button of a stopwatch.
		 *	
		 */
		public override function reset():void
		{
			GCSafeTimer._gcShield.remove(this);
			super.reset();
		}


		/**
		 *
		 * Starts the timer, if it is not already running.
		 *	
		 */
		public override function start():void
		{
			GCSafeTimer._gcShield.add(this);
			super.start();
		}


		/**
		 *
		 * Stops the timer.
		 *	
		 */
		public override function stop():void
		{
			GCSafeTimer._gcShield.remove(this);
			super.stop();
		}




		//
		// private methods
		//


		/**
		 *
		 * Removes a timer from the shield so that the garbage collector can
		 * grab it.
		 *
		 */
		private static function _allowGarbageCollection(e:TimerEvent):void
		{
			GCSafeTimer._gcShield.remove(e.currentTarget);
		}




	}
}
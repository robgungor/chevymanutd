/**
 *
 * GCSafeAnimator.as
 *
 *     An Animator that refuses to be garbage-collected.
 *
 *     version history:
 *	       2007.07.20
 *             - first draft
 *
 *     @author     matthew at exanimo dot com
 *     @version    2007.07.26
 *
 */

package com.exanimo.motion
{
	import com.exanimo.utils.GarbageCollectionShield;
	import fl.motion.Animator;
	import fl.motion.MotionEvent;
	import flash.display.DisplayObject;




	public class GCSafeAnimator extends Animator
	{
		private static var _gcShield:GarbageCollectionShield = new GarbageCollectionShield();


		
		
		
		/**
		 *
		 * Constructs a tween.
		 *
		 */
		public function GCSafeAnimator(xml:XML = null, target:DisplayObject = null)
		{
			// Add listeners so that we know when to prevent and allow garbage collection.
			this.addEventListener(MotionEvent.MOTION_START, GCSafeAnimator._preventGarbageCollection);
			this.addEventListener(MotionEvent.MOTION_END, GCSafeAnimator._allowGarbageCollection);
			GCSafeAnimator._gcShield.add(this);
			
			super(xml, target);
		}



		
		//
		// private
		//
		

		/**
		 *
		 * Removes an animator from the shield so that the garbage collector
		 * can grab it.
		 *
		 */
		private static function _allowGarbageCollection(e:MotionEvent):void
		{
			GCSafeAnimator._gcShield.remove(e.currentTarget);
		}
		
		
		/**
		 *
		 * Adds an animator to the shield so that the garbage collector doesn't
		 * delete it.
		 *
		 */
		private static function _preventGarbageCollection(e:MotionEvent):void
		{
			GCSafeAnimator._gcShield.add(e.currentTarget);
		}




	}
}
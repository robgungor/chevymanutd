/**
 *
 * GCSafeTween.as
 *
 *     A Tween that refuses to be garbage-collected.
 *
 *     version history:
 *	       2007.07.20
 *             - first draft
 *
 *     @author     matthew at exanimo dot com
 *     @version    2007.07.20
 *
 */

package com.exanimo.transitions
{
	import com.exanimo.utils.GarbageCollectionShield;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;




	public class GCSafeTween extends Tween
	{
		private static var _gcShield:GarbageCollectionShield = new GarbageCollectionShield();


		
		
		
		/**
		 *
		 * Constructs a tween.
		 *
		 */
		public function GCSafeTween(obj:Object, prop:String, func:Function, begin:Number, finish:Number, duration:Number, useSeconds:Boolean = false)
		{
			// Add listeners so that we know when to prevent and allow garbage collection.
			this.addEventListener(TweenEvent.MOTION_START, GCSafeTween._preventGarbageCollection);
			this.addEventListener(TweenEvent.MOTION_RESUME, GCSafeTween._preventGarbageCollection);
			this.addEventListener(TweenEvent.MOTION_STOP, GCSafeTween._allowGarbageCollection);
			this.addEventListener(TweenEvent.MOTION_FINISH, GCSafeTween._allowGarbageCollection);
			GCSafeTween._gcShield.add(this);
			
			super(obj, prop, func, begin, finish, duration, useSeconds);
		}



		
		//
		// private
		//
		

		/**
		 *
		 * Removes a tween from the shield so that the garbage collector can
		 * grab it.
		 *
		 */
		private static function _allowGarbageCollection(e:TweenEvent):void
		{
			GCSafeTween._gcShield.remove(e.currentTarget);
		}
		
		
		/**
		 *
		 * Adds a tween to the shield so that the garbage collector doesn't
		 * delete it.
		 *
		 */
		private static function _preventGarbageCollection(e:TweenEvent):void
		{
			GCSafeTween._gcShield.add(e.currentTarget);
		}




	}
}
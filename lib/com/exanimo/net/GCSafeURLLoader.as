/**
 *
 * GCSafeURLLoader.as
 *
 *     A URLLoader that refuses to be garbage-collected.
 *
 *     version history:
 *	       2007.07.20
 *             - first draft
 *
 *     @author     matthew at exanimo dot com
 *     @version    2007.07.20
 *
 */

package com.exanimo.net
{
	import com.exanimo.utils.GarbageCollectionShield;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;




	public class GCSafeURLLoader extends URLLoader
	{
		private static var _gcShield:GarbageCollectionShield = new GarbageCollectionShield();




		public function GCSafeURLLoader(request:URLRequest = null)
		{
			// Add listeners so that we know when to start allowing garbage
			// collection again.
			this.addEventListener(Event.COMPLETE, GCSafeURLLoader._allowGarbageCollection);
			this.addEventListener(IOErrorEvent.IO_ERROR, GCSafeURLLoader._allowGarbageCollection);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, GCSafeURLLoader._allowGarbageCollection);

			super(request);
		}




		//
		// public methods
		//


		/**
		 *
		 * Closes the load operation in progress.
		 *	
		 */
		public override function close():void
		{
			GCSafeURLLoader._gcShield.remove(this);
			super.close();
		}
		
		
		/**
		 *
		 * Sends and loads data from the specified URL.
		 *	
		 */
		public override function load(request:URLRequest):void
		{
			GCSafeURLLoader._gcShield.add(this);
			super.load(request);
		}




		//
		// private methods
		//


		/**
		 *
		 * Removes a loader from the shield so that the garbage collector can
		 * grab it.
		 *
		 */
		private static function _allowGarbageCollection(e:Event):void
		{
			GCSafeURLLoader._gcShield.remove(e.currentTarget);
		}




	}
}
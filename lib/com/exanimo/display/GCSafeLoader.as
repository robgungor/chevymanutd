/**
 *
 * GCSafeLoader.as
 *
 *     A Loader that refuses to be garbage-collected.
 *
 *     version history:
 *	       2007.07.20
 *             - first draft
 *
 *     @author     matthew at exanimo dot com
 *     @version    2007.07.20
 *
 */

package com.exanimo.display
{
	import com.exanimo.utils.GarbageCollectionShield;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;




	public class GCSafeLoader extends Loader
	{
		private static var _gcShield:GarbageCollectionShield = new GarbageCollectionShield();




		public function GCSafeLoader()
		{
			// Add listeners so that we know when to start allowing garbage
			// collection again.
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, GCSafeLoader._allowGarbageCollection);
			this.contentLoaderInfo.addEventListener(Event.UNLOAD, GCSafeLoader._allowGarbageCollection);
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, GCSafeLoader._allowGarbageCollection);
			
			super();
		}




		//
		// public methods
		//


		/**
		 *
		 * Loads from binary data stored in a ByteArray object.
		 *	
		 */
		public override function close():void
		{
			GCSafeLoader._gcShield.remove(this);
			super.close();
		}
		
		
		/**
		 *
		 * Loads a SWF, JPEG, progressive JPEG, unanimated GIF, or PNG file
		 * into an object that is a child of this Loader object.
		 *	
		 */
		public override function load(request:URLRequest, context:LoaderContext = null):void
		{
			GCSafeLoader._gcShield.add(this);
			super.load(request, context);
		}


		/**
		 *
		 * Loads from binary data stored in a ByteArray object.
		 *	
		 */
		public override function loadBytes(bytes:ByteArray, context:LoaderContext = null):void
		{
			GCSafeLoader._gcShield.add(this);
			super.loadBytes(bytes, context);
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
			GCSafeLoader._gcShield.remove(e.currentTarget);
		}




	}
}
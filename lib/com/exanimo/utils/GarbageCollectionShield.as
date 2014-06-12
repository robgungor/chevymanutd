/**
 *
 * GarbageCollectionShield.as
 *
 *     Protects objects from garbage collection.
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
	import flash.utils.Dictionary;




	public class GarbageCollectionShield
	{
		private static var _dict:Dictionary = new Dictionary();


		/**
		 * 
		 * Protects an object from garbage collection.	
		 *	
		 * @param obj    the object to protect
		 *	
		 */
		public function add(obj:Object):void
		{
			GarbageCollectionShield._dict[obj] = true;
		}


		/**
		 * 
		 * Stops protecting an object from garbage collection. If there are no
		 * references to the object, it will be eligible for collection.
		 *	
		 * @param obj    the object to stop protecting
		 *	
		 */		
		public function remove(obj:Object):void
		{
			delete GarbageCollectionShield._dict[obj];
		}




	}
}
/*
 * Author - David Segal
 * Date - 02.20.09
 *
*/

package com.oddcast.player
{
	public class PlayerInitFlags
	{
		/**
		 * stops the event tracker from reporting
		 */
		public static var TRACKING_OFF:int = 1; 
		
		/**
		 * stops the scene from playing on load
		 */
		public static var IGNORE_PLAY_ON_LOAD:int = 2;
		
		/**
		 * stops the export xml from loading. by default the player will attempt to load the export xml
		 * from it's own directory 200ms after init if no "doc" parameter is set
		 */
		public static var SUPPRESS_EXPORT_XML:int = 4; 
		
		/**
		 * stops the host holder from using the default offset value for x, y, and scale of 
		 * 3D characters 
		 */
		public static var SUPPRESS_3D_OFFSET:int = 8;
		
		/** 
		 * suppress play on click if it is set in the scene xml
		 */
		public static var SUPPRESS_PLAY_ON_CLICK:int = 16;
		
		/**
		 * suppress the target link if it is set in the xml 
		 */
		public static var SUPPRESS_LINKS:int = 32;
		
		/**
		 * suppress auto-advance if it is set in the scene xml
		 */
		public static var SUPPRESS_AUTO_ADV:int = 64;
		
		/**
		 * Prevents the vhss player from writing any cookies to the shared object
		 */
		public static var DISABLE_SHARED_OBJECT_COOKIES:int = 128;
	}
}

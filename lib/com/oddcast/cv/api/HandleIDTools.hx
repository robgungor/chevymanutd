
/**
 * ...
 * @author Jake Lewis
 * copyright Oddcast Inc. 2010  All rights reserved
 * 5/4/2010 4:24 PM
 **/

package  com.oddcast.cv.api;
//import com.oddcast.cv.api.HandleIDTools;

	import com.oddcast.cv.util.HandleID;
	

	
	class HandleIDTools {
		public static function setNull():ID { return HandleID.NULL_ID; }
		public static function isNotNull(id:ID):Bool { return id != HandleID.NULL_ID; }
		public static function isNull(id:ID):Bool { return !isNotNull(id); }
	}


	/**
	 * ...
	 * @author Jake Lewis
	 *  4/14/2010 6:03 PM
	 */
	package  com.oddcast.cv.util;
	//import com.oddcast.cv.util.Radians;  using com.oddcast.cv.util.Radians;
	
	class Radians
	{
		public static function toDegrees(rad:Float):Float { return rad * 360 / ( 2 * Math.PI); }
		public static function toRadians(deg:Float):Float { return deg *  2 * Math.PI /360 ; }
	}

	

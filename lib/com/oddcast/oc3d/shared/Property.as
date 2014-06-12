package com.oddcast.oc3d.shared
{
	public class Property
	{
		public static var jakeDummy:Number = 0.0;  //this is necc to aid the as3 import process. Jake		
		public static const REQUIRE_RENDER_FN:String = "require-render-fn"	// Function<>
		public static const RENDERER:String = "renderer";					// Function<renderer:IRenderer>
		public static const UPDATER:String = "updater";						// Function<updater:Number> 
		public static const LIGHT_MATRIX:String = "light-matrix"; 			// Array<Number>[16]
		public static const LIGHT_COLOR:String = "light-color"; 			// uint
		public static const LIGHT_AMBIENT_SHADE:String = "light-ambient";	// Number{0-1}
		public static const LIGHT_INTENSITY:String = "light-intensity";		// Number{0-1}
		public static const HEAD_MATRIX:String = "head-matrix";				// Array<Number>[16]
		public static const LIGHTING_ENABLED:String = "light-enabled";		// Boolean
		public static const PICKER:String = "picker";						// IPicker
	}
}
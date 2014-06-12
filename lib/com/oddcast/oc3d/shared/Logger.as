package com.oddcast.oc3d.shared
{
	public class Logger
	{
		public static var Enabled:Boolean = true;
		public static function log(s:String):void { if (Enabled) trace(s); }
	}
}
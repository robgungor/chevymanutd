package com.oddcast.oc3d.core
{
	public interface IBitmapFileMaterialAttribute extends IMaterialAttribute
	{
		function uri():String;
		function setUri(v:String):void;
		function dispose():void;
	}
}
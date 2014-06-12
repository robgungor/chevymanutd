package com.oddcast.oc3d.core
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	public interface ILODConverter
	{
		function entries():Dictionary;
		
		function convert(stage:Stage):void;
		function revert():void;
		function isConverted():Boolean;
		function hasConverted():Boolean;
		
		function find2dGenBitmap():BitmapData;	
	}
}
package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.display.BitmapData;
	
	public interface IMaterialObject3D extends IIdentifiable
	{
		function materialManager():IMaterialManager;
		
		function name():String;
		
		function requireUpdate():void;
		
		function setPerspectiveCorrectionEnabled(b:Boolean):void;
		function perspectiveCorrectionEnabled():Boolean;
		
		function newBitmapFileMaterialAttribute(name:String, mode:CompositeMode, url:String, failedFn:Function=null, progressedFn:Function=null):IBitmapFileMaterialAttribute;
		function newSolidMaterialAttribute(name:String, mode:CompositeMode, color:Color):ISolidMaterialAttribute;
		
		function replaceMaterialAttribute(oldAttr:IMaterialAttribute, newAttr:IMaterialAttribute):void;
		
		// continuationFn<>
		function preload(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
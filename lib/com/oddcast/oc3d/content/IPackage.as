package com.oddcast.oc3d.content
{
	import flash.utils.Dictionary;
	
	public interface IPackage extends INode
	{
		function open(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function contentIds():Array; // Array<int>
		function setContentIds(v:Array):void;
		
		function autoUpdatingEnabled():Boolean;
		function setAutoUpdatingEnabled(b:Boolean):void;
	}
}
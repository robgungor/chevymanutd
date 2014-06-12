package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.IContentBuilder;
	
	public interface INodeProxy
	{
		function collectPackageIds2(results:Vector.<int>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function nodeSetId():int;
		function impl():INodeProxy;
		function owner():INodeProxy;

		function id():int;
		function name():String;
		function toString():String;
		
		// onlyTheseTypes:Array<Classes> categories:Array<categoryName:String>
		function parents(onlyTheseTypes:Array=null, categories:Array=null):Array;
		// onlyTheseTypes:Array<Classes> categories:Array<categoryName:String>
		function peers(onlyTheseTypes:Array=null, categories:Array=null):Array;
		// onlyTheseTypes:Array<Classes> categories:Array<categoryName:String>
		function children(onlyTheseTypes:Array=null, categories:Array=null):Array;
		
		function equals(n1:*):Boolean;
		
		function addChild(node:INodeProxy):void;
		function removeChild(node:INodeProxy):void;
	}
}
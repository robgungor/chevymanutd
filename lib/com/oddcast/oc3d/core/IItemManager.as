package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.IContentManager;
	
	public interface IItemManager extends IContentManager
	{
		function loadItemSet(itemSetId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
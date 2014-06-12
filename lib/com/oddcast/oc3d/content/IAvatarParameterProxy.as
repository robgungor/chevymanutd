package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;
	import com.oddcast.oc3d.core.IScene3D;

	public interface IAvatarParameterProxy extends INodeProxy
	{
		function accessorySetId():uint;
		function avatarId():uint;
		// continuationFn:Function<void()>
		function load(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		function unload():void
		function instantiate(scene:IScene3D, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}
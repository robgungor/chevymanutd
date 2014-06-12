package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.geom.Point;
	
	public interface IAvatar
	{
		function builder():ISceneBuilder;
		function configuration():XML;
		function name():String;
		function id():uint;
		function accessorySetId():int;
		function modelId():int;
		function supportsLowResMode():Boolean;
		
		function tryFindInstance(instanceId:uint):IAvatarInstance;
		// continuationFn:Function<IAvatarInstance>
		function instantiate(scene:IScene3D, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function dispose():void;
	}
}
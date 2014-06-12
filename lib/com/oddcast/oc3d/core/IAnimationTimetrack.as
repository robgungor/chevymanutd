package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.IIdentifiable;
	import com.oddcast.oc3d.data.AnimationData;

	public interface IAnimationTimetrack extends IIdentifiable
	{
		function placeClip(target:IInstance3D, position:Number, clip:AnimationData, completedFn:Function):IAnimationPlacement;

		function currentFrame():Number;
		function unplaceClip(placement:IAnimationPlacement):void;
		
		function scene():IScene3D;
		
		function dispose():void;
	}
}
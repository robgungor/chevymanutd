package com.oddcast.oc3d.content
{
	import flash.display.Sprite;

	public interface IHitSpot
	{
		function setRollOverCallback(fn:Function):void;		// Function<void(e:MouseEvent)>
		function setRollOutCallback(fn:Function):void;		// Function<void(e:MouseEvent)>
		function setMouseUpCallback(fn:Function):void;		// Function<void(e:MouseEvent)>
		function setMouseDownCallback(fn:Function):void;	// Function<void(e:MouseEvent)>

		function setButtonMode(b:Boolean):void;
		function buttonMode():Boolean;
	}
}
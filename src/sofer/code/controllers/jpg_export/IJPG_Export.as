package code.controllers.jpg_export
{
	import com.oddcast.workshop.Callback_Struct;
	
	import flash.display.MovieClip;
	import flash.geom.Point;

	public interface IJPG_Export
	{
		function screenshot_host(_callbacks:Callback_Struct = null, _scale:Number = Number.NaN, _dimensions:Point = null, _offset:Point = null):void;
		function screenshot_target( _target:MovieClip, _callbacks:Callback_Struct, _scale:Number = Number.NaN, _dimensions:Point = null, _offset:Point = null ):void
	}
}
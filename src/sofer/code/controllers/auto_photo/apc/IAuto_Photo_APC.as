package code.controllers.auto_photo.apc 
{
	import com.oddcast.workshop.*;
	import flash.display.*;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Me^
	 */
	public interface IAuto_Photo_APC 
	{
		function load_and_init( _apc_url:String, _callback:Callback_Struct ):void;
		function analyze_photo( _url:String ):void;
		function set_model_type( _type:int ):void;
		function get_display_obj():DisplayObject;
		function set_display_size( _size:Point ):void;
		function position_photo( _dir:String, _amount:int ):void;
		function submit_photo_position(  ):void;
		function submit_photo_points(  ):void;
		function submit_mask_points(  ):void;
		function is_loaded(  ):Boolean;
		function restart_apc(  ):void;
		function photo_expiration_stop_timer():void;
	}
	
}
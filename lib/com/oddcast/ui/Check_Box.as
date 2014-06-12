package com.oddcast.ui 
{
	
	/**
	 * ...
	 * @author Me^
	 */
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	 
	public class Check_Box extends MovieClip
	{
		public var check				:Sprite;
		public var tf_title				:TextField;
		private var on_click_callback	:Function;
		
		public function Check_Box() 
		{
			tf_title	.autoSize		= TextFieldAutoSize.LEFT;
			this		.buttonMode		= true;
			this		.addEventListener(MouseEvent.CLICK, clicked, false, 0, true);
		}
		/*	function doesnt need to be called, click callback needs to accept boolean	*/
		public function init_params( _title:String = '', _on_click_callback:Function = null ):void 
		{
			tf_title.text		= _title;
			on_click_callback	= _on_click_callback;
		}
		
		/*	click action	*/
		private function clicked( e:MouseEvent ):void 
		{
			check.visible = !check.visible;
			if (on_click_callback != null) on_click_callback( get_is_selected() );
		}
		/*	set if the checkbox is on or off	*/
		public function set_check( _on_or_off:Boolean ):void 
		{
			check.visible = _on_or_off;
		}
		/*	get if this is selected or not	*/
		public function get_is_selected(  ):Boolean 
		{
			return check.visible;
		}
		
	}
	
}
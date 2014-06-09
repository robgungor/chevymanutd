package code.controllers.body_position 
{
	import code.skeleton.*;
	import code.models.*;
	import com.oddcast.ui.*;
	import com.oddcast.workshop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Body_Position implements IBody_Position
	{
		private var ui					:Body_Position_UI;
		private var orig_camera			:Body_Original_Camera;
		private var target_transform	:MovieClip;
		private var orig_position		:Matrix;
		private const ZOOM_AMOUNT		:Number = 0.1;
		private const MOVE_AMOUNT		:Number = 10;
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INIT */
		/**
		 * Constructor
		 */
		public function Body_Position() 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui					= Bridge.views.body_position_UI;
			target_transform	= Bridge.views.player_UI.fb_holder.placeholder;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				init();
			}
		}
		private function init(  ):void 
		{	
			if (is_fullbody())
			{
				App.asset_bucket.is_playback_mode ? close_win() : open_win();
														
				var btn_list:Array = [ui.btn_up, ui.btn_down, ui.btn_right, ui.btn_left, ui.btn_zoom_in, ui.btn_zoom_out];
				for (var n:int = btn_list.length, i:int = 0; i < n; i++)
				{
					App.listener_manager.add( btn_list[i], BaseButton.MOUSE_HOLD, ui_btn_handler, this );
					App.listener_manager.add( btn_list[i], MouseEvent.CLICK, ui_btn_handler, this );
				}
				App.listener_manager.add( ui.btn_reset, MouseEvent.CLICK, ui_btn_handler, this );
				App.listener_manager.add( App.mediator.scene_editing, ProcessingEvent.DONE, save_default_camera, this );
				orig_position = target_transform.transform.matrix.clone();
			}
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERFACE API */
		/**
		 * displays the UI
		 * @param	_e
		 */
		public function open_win(  ):void 
		{	if (is_fullbody())
				ui.visible = true;
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		public function close_win(  ):void 
		{	ui.visible = false;
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERNALS */
		private function is_fullbody(  ):Boolean
		{
			return (ServerInfo.app_type == ServerInfo.APP_TYPE_Flash_10_FB_3D);
		}
		/**
		 * saves the default position of a model on every body load
		 * @param	_e
		 */
		private function save_default_camera( _e:ProcessingEvent ):void
		{
			if (_e.processName == ProcessingEvent.FULL_BODY)
			{
				orig_camera = new Body_Original_Camera( App.mediator.scene_editing.full_body );
			}
			reset_position();
		}
		private function ui_btn_handler( _e:MouseEvent ):void
		{		
			var updated_matrix:Matrix = target_transform.transform.matrix;
			switch ( _e.target )
			{	
				case ui.btn_up:				updated_matrix.translate( 0, -MOVE_AMOUNT);					target_transform.transform.matrix = updated_matrix;	break;
				case ui.btn_down:			updated_matrix.translate( 0, MOVE_AMOUNT);					target_transform.transform.matrix = updated_matrix;	break;
				case ui.btn_right:			updated_matrix.translate( MOVE_AMOUNT, 0);					target_transform.transform.matrix = updated_matrix;	break;
				case ui.btn_left:			updated_matrix.translate( -MOVE_AMOUNT, 0);					target_transform.transform.matrix = updated_matrix;	break;
				case ui.btn_zoom_in:		updated_matrix.scale(1 + ZOOM_AMOUNT, 1 + ZOOM_AMOUNT);		target_transform.transform.matrix = updated_matrix;	break;
				case ui.btn_zoom_out:		updated_matrix.scale(1 - ZOOM_AMOUNT, 1 - ZOOM_AMOUNT);		target_transform.transform.matrix = updated_matrix;	break;
				case ui.btn_reset:			reset_camera();
											reset_position();
											break;
			}
		}
		private function reset_camera(  ):void
		{
			orig_camera.reset_to_originals( App.mediator.scene_editing.full_body );
		}
		private function reset_position(  ):void
		{
			target_transform.transform.matrix = orig_position;
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** KEYBOARD SHORTCUTS */
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		*/
		
	}

}







import com.oddcast.workshop.*;

class Body_Original_Camera
{
	public var cam_pos_x:Number;
	public var cam_pos_y:Number;
	public var cam_pos_z:Number;
	public var cam_aim_x:Number;
	public var cam_aim_y:Number;
	public var cam_aim_z:Number;
	public function Body_Original_Camera( _fb_controller:IBody_Controller )
	{
		cam_pos_x = _fb_controller.camera_pos_x;
		cam_pos_y = _fb_controller.camera_pos_y;
		cam_pos_z = _fb_controller.camera_pos_z;
		cam_aim_x = _fb_controller.camera_aim_x;
		cam_aim_y = _fb_controller.camera_aim_y;
		cam_aim_z = _fb_controller.camera_aim_z;
	}
	public function reset_to_originals( _fb_controller:IBody_Controller ):void
	{
		_fb_controller.camera_pos_x = cam_pos_x;
		_fb_controller.camera_pos_y = cam_pos_y;
		_fb_controller.camera_pos_z = cam_pos_z;
		_fb_controller.camera_aim_x = cam_aim_x;
		_fb_controller.camera_aim_y = cam_aim_y;
		_fb_controller.camera_aim_z = cam_aim_z;
	}
}
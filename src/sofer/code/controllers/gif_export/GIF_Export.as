package code.controllers.gif_export 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.host.api.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class GIF_Export
	{
		private var btn_open				:InteractiveObject;
		private var gif_target				:MovieClip;
		private const TARGET_SIZE			:Number = 300;	// its asked that its square but it doesnt have to be
		private const FINAL_SIZE			:Number = 100;	// also square, if changing this make sure its proportional to the TARGET_SIZE to maintain aspect ratio
		/* offset from registration point 0,0 where to take the snapshot */
		private const OFFSET_FROM_OO		:Point = new Point( 0, -50 );
		/* number of frames for the animated gif to be recorded */
		private const SNAPSHOT_FRAMES		:int = 7;
		private const SNAPSHOT_DELAY_ms		:int = 200;
		private const IS_LOOPING_GIF		:Boolean = true;
		/* if you play the frames backwards after playing them forward you make a nice loop animation */
		private const INVERSE_FRAMES		:Boolean = true;
		private const PROCESS_RECORDING		:String = 'PROCESS_RECORDING_GIF';
		private const PROCESS_BUILDING		:String = 'PROCESS_BUILDING_GIF';
		private const MSG_BUILDING_GIF		:String = 'Building animation... \n <i>please wait as this may take a minute</i>';
		private const MSG_RECORDING			:String = 'Recording';
		
		public function GIF_Export( _btn_open:InteractiveObject, _scene_player:MovieClip ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			btn_open	= _btn_open;
			gif_target	= _scene_player;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
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
			App.listener_manager.add( btn_open, MouseEvent.CLICK, build_gif, this );
		}
		public function build_gif( _e:MouseEvent ):void 
		{
			App.mediator.scene_editing.stopAudio();
			App.mediator.processing_start( PROCESS_RECORDING, MSG_RECORDING, 0 );
			animate_for_gif();
			var frames_list		:Array = new Array();
			var snapshot_timer	:Timer = new Timer( SNAPSHOT_DELAY_ms, SNAPSHOT_FRAMES );
			App.listener_manager.add( snapshot_timer, TimerEvent.TIMER, snapshot_host, this );
			App.listener_manager.add( snapshot_timer, TimerEvent.TIMER_COMPLETE, all_frames_captured, this );
			snapshot_timer.start();
			
			/**
			 * animate something for the gif to capture
			 */
			function animate_for_gif(  ):void 
			{
				if (App.mediator.scene_editing &&
					App.mediator.scene_editing.getHostMC() &&
					App.mediator.scene_editing.getHostMC().api)
				{
					var host_api:* = App.mediator.scene_editing.getHostMC().api;	// leave it as * since 3d and 2d are different types
					host_api.followCursor( false );
					
					host_api.setGaze( 90, 1, 100);//set_host_angle( 180, 1 );	// these numbers dont do anything... the host just goes to the center... i dont think setGaze works well in 3d
					setTimeout( release_host, 3000 );
					
					function set_host_angle( _angle:Number, _sec:Number ):void 
					{	host_api.setGaze( _angle, _sec, 100);		}
					function release_host( ):void
					{	host_api.followCursor( true );			}
				}
			}
			
			function snapshot_host( _e:TimerEvent ):void 
			{
				// update processing screen
				App.mediator.processing_start( PROCESS_RECORDING, MSG_RECORDING, (snapshot_timer.currentCount * 100 / SNAPSHOT_FRAMES) );
				var bmp				:BitmapData	= new BitmapData( FINAL_SIZE, FINAL_SIZE, true, 0x00FFFFFF);
				var scale			:Number 	= FINAL_SIZE / TARGET_SIZE;
				var scale_matrix	:Matrix 	= new Matrix(1, 0, 0, 1, OFFSET_FROM_OO.x, OFFSET_FROM_OO.y);
				scale_matrix.scale( scale, scale );
				try 
				{
					bmp.draw( gif_target, scale_matrix );
				}
				catch (e:Error)
				{
					App.mediator.processing_ended( PROCESS_RECORDING );
					App.mediator.alert_user( new AlertEvent( AlertEvent.ERROR, '', 'Cannot create animated GIF :\n\n' + e.message ));
				}
				frames_list.push( bmp );
			}
			function all_frames_captured( _e:TimerEvent ):void 
			{
				App.mediator.processing_ended( PROCESS_RECORDING );
				App.mediator.processing_start( PROCESS_BUILDING, MSG_BUILDING_GIF );
				App.listener_manager.remove_all_listeners_on_object( snapshot_timer );
				snapshot_timer = null;
				setTimeout( build_gif, 10 );	// time for screen to render the new processing message above
				
				function build_gif(  ):void 
				{	var gif_builder				:GIF_Builder = new GIF_Builder();
				
					var gif_individual_frames	:Array = new Array();
					if (INVERSE_FRAMES)
						gif_individual_frames = frames_list.concat(frames_list.concat().reverse());
					else
						gif_individual_frames = frames_list.concat();
						
					gif_builder.create_gif( gif_individual_frames, SNAPSHOT_DELAY_ms, IS_LOOPING_GIF );
					gif_builder.upload_current_gif( ServerInfo.localURL + "api/imageUploader.php", ServerInfo.door.toString(), uploaded );
					
					function uploaded( _response:String ):void 
					{	
						App.mediator.processing_ended( PROCESS_BUILDING );
						var alert:AlertEvent = new AlertEvent( AlertEvent.CONFIRM, '', 'Click ok to download your animated GIF:\n\n' + _response, null, user_response );
						alert.report_error = false;
						App.mediator.alert_user( alert );
						
						function user_response( _ok:Boolean ):void 
						{	if (_ok)
							{	var filename:String = App.mediator.appropriate_filename( _response );
								App.asset_bucket.video_downloader.downloadFile( _response, filename );
								WSEventTracker.event('eddlph');
							}
						}
					}
				}
			}
			
		}
		
	}

}
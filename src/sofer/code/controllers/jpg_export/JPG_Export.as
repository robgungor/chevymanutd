package code.controllers.jpg_export 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.ui.*;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class JPG_Export implements IJPG_Export
	{
		private var btn_open			:InteractiveObject;
		private var scene_player		:*;
		private var scene_mask			:Sprite
		private const PROCESS_SCREENSHOT_HOST	:String = 'PROCESS_SCREENSHOT_HOST';
		private const MSG_SCREENSHOT_HOST		:String = 'Capturing the image';
		
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
		public function JPG_Export( _btn_open:InteractiveObject, _player:*, _mask:Sprite ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			btn_open		= _btn_open;
			scene_player	= _player;
			scene_mask		= _mask;
			
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
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	
			App.listener_manager.add( btn_open, MouseEvent.CLICK, mouse_click_handler, this );
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
		 * screenshot the model and background and prompt the user to download an image
		 * @param	_callbacks	use this to override the default behaviour (save on fin, alert on error)
		 * @param	_scale		scale down or up the screenshot.
		 * @param	_dimensions	dimensions of the capture, x=width y=height
		 * @param	_offset		offset from the registration point of the target
		 */
		public function screenshot_host( _callbacks:Callback_Struct = null, _scale:Number = Number.NaN, _dimensions:Point = null, _offset:Point = null ):void 
		{	
			App.mediator.scene_editing.stopAudio();
			App.mediator.processing_start(PROCESS_SCREENSHOT_HOST, MSG_SCREENSHOT_HOST );
			setTimeout(take_it, 400);	// time to show processing screen since this is cpu intensive
			
			function take_it():void
			{	add_listeners();
				var player	:MovieClip 	= scene_player;
				var img_mask:Sprite		= scene_mask;
				App.asset_bucket.video_downloader.captureMC(player, img_mask, null, 100, "jpg", _scale, _dimensions, _offset);
				
				function fin( _e:SendEvent ):void 
				{	remove_listeners();
					end_processing();
					var screenshot_url:String = App.asset_bucket.video_downloader.capturedSceneUrl;
					if (_callbacks && _callbacks.fin != null)
						_callbacks.fin( screenshot_url );
					else
						App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "f9t150", "Click OK to continue...", null, downloadCapturedScene ));
					WSEventTracker.event("eddlph");
					
					function downloadCapturedScene(_ok:Boolean):void
					{	if (!_ok)
						return;
						var filename:String = App.mediator.appropriate_filename( screenshot_url );
						App.asset_bucket.video_downloader.downloadFile(App.asset_bucket.video_downloader.capturedSceneUrl, filename);
					}
				}
				function error( _e:AlertEvent ):void 
				{	remove_listeners();
					end_processing();
					if (_callbacks && _callbacks.error != null)
						_callbacks.error( _e );
					//					else	// alert is handled outside of this scope
					//						Bridge_Engine.mediator.alert_user( _e );
				}
				function add_listeners(  ):void 
				{	App.listener_manager.add(App.asset_bucket.video_downloader, SendEvent.DONE, fin , this );
					App.listener_manager.add(App.asset_bucket.video_downloader, AlertEvent.EVENT, error , this );
				}
				function remove_listeners(  ):void 
				{	App.listener_manager.remove(App.asset_bucket.video_downloader, SendEvent.DONE, fin );
					App.listener_manager.remove(App.asset_bucket.video_downloader, AlertEvent.EVENT, error );
				}
				function end_processing(  ):void 
				{	App.mediator.processing_ended( PROCESS_SCREENSHOT_HOST );
				}
			}
		}
		/**
		 * takes a snapshot and uploads the image to the server
		 * @param	_target		what to capture
		 * @param	_callbacks	use this to override the default behaviour (save on fin, alert on error)
		 * @param	_scale		scale down or up the screenshot.
		 * @param	_dimensions	dimensions of the capture, x=width y=height
		 * @param	_offset		offset from the registration point of the target
		 */
		public function screenshot_target( _target:MovieClip, _callbacks:Callback_Struct, _scale:Number = Number.NaN, _dimensions:Point = null, _offset:Point = null ):void 
		{	
			App.mediator.processing_start(PROCESS_SCREENSHOT_HOST, MSG_SCREENSHOT_HOST );
			setTimeout(take_it, 400);	// time to show processing screen since this is cpu intensive
			
			function take_it():void
			{	add_listeners();
				App.asset_bucket.video_downloader.captureMC(_target, _target, null, 100, "jpg",_scale,_dimensions,_offset);
				
				function fin( _e:SendEvent ):void 
				{	remove_listeners();
					end_processing();
					if (_callbacks && _callbacks.fin!=null)
						_callbacks.fin( App.asset_bucket.video_downloader.capturedSceneUrl );
				}
				function error( _e:AlertEvent ):void 
				{	remove_listeners();
					end_processing();
					if (_callbacks&&_callbacks.error!=null)
						_callbacks.error( _e );
				}
				function add_listeners(  ):void 
				{	App.listener_manager.add(App.asset_bucket.video_downloader, SendEvent.DONE, fin , this );
					App.listener_manager.add(App.asset_bucket.video_downloader, AlertEvent.EVENT, error , this );
				}
				function remove_listeners(  ):void 
				{	App.listener_manager.remove(App.asset_bucket.video_downloader, SendEvent.DONE, fin );
					App.listener_manager.remove(App.asset_bucket.video_downloader, AlertEvent.EVENT, error );
				}
				function end_processing(  ):void 
				{	App.mediator.processing_ended( PROCESS_SCREENSHOT_HOST );
				}
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
		***************************** INTERNALS */
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
				case btn_open:		
					screenshot_host();		
					break;
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
		*/
		
	}

}
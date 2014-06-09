package code.controllers.audio_volume 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	
	import flash.events.*;
	import flash.media.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class Audio_Volume
	{
		private var ui					:Audio_Volume_UI;
		/* when unmuting what to unmute to */
		private var unmuted_user_volume	:Number = 1;
		/* anything below this point is considered muted */
		private const MUTE_LIMIT		:Number = 0.01;
		
		public function Audio_Volume( _ui:Audio_Volume_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui		= _ui;
			
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
		{	App.listener_manager.add( ui.slider_volume, ScrollEvent.SCROLL, slider_volume_changed	, this );
			App.listener_manager.add( ui.btn_mute		, MouseEvent.CLICK	, mute_pressed			, this );
			override_volume( unmuted_user_volume );
			ui.mute_art.mouseEnabled = false;
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
		private function override_volume( _volume:Number ):void 
		{	if (_volume < 0)	_volume = 0;
			if (_volume > 1)	_volume = 1;
			ui.slider_volume.percent = _volume;
			toggle_mute_art( _volume < MUTE_LIMIT );
			apply_volume( _volume );
		}
		private function mute_pressed( _e:MouseEvent ):void 
		{	if ( ui.slider_volume.percent > MUTE_LIMIT )	// not currently muted
			{	unmuted_user_volume = ui.slider_volume.percent;
				ui.slider_volume.percent = 0;
				toggle_mute_art( true );
			}
			else
			{	ui.slider_volume.percent = unmuted_user_volume;
				toggle_mute_art( false );
			}
			apply_volume( ui.slider_volume.percent );
		}
		private function toggle_mute_art( _muted:Boolean ):void 
		{	ui.mute_art.gotoAndStop( _muted ? 2 : 1 );
		}
		private function slider_volume_changed( _e:ScrollEvent ):void 
		{	apply_volume( ui.slider_volume.percent );
			toggle_mute_art (ui.slider_volume.percent < MUTE_LIMIT );
		}
		private function apply_volume( _volume:Number ):void
		{	var transform:SoundTransform = new SoundTransform();
			transform.volume = _volume;
			flash.media.SoundMixer.soundTransform = transform;
		}
		
	}

}
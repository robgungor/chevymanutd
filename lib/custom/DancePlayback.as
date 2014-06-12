package custom
{
	
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.VisiblePlugin;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.casalib.events.RemovableEventDispatcher;
	
	public class DancePlayback extends RemovableEventDispatcher
	{
		protected var _ui				:*;
		protected var _currentDanceClip	:MovieClip;
		protected var _progressBar		:ProgressBar;
		protected var _muted			:Boolean;
		protected var _lastMousePos:Point = new Point(0, 0);
		protected var _autoHideTimeout:uint = 0;
		protected var _playing			:Boolean;
		
		public function DancePlayback(ui:*, danceClip:MovieClip)
		{
			super();
			TweenPlugin.activate([VisiblePlugin]);
			_ui = ui;
			_currentDanceClip = danceClip;
			_ui.visible = false;
			_ui.alpha = 0;
			_init();
		}
		protected function _init():void
		{
			_progressBar = new ProgressBar(_ui.progress);
			_addListeners();
			_updateUI();
		}
		protected var _forceShow:Boolean;
		public function forceShowControls():void
		{
			_forceShow = true;
		//	_ui.
			show();
		}
		protected function _addListeners():void
		{
			_currentDanceClip.addEventListener(Event.ENTER_FRAME, _onFrame);
		
			_ui.btn_unmute.addEventListener(MouseEvent.CLICK, 		_onUnMuteClicked);
			_ui.btn_mute.addEventListener(MouseEvent.CLICK, 		_onMuteClicked);
			_ui.small_play_button.addEventListener(MouseEvent.CLICK, _onPlayClicked);
			_ui.small_pause_button.addEventListener(MouseEvent.CLICK, _onPauseClicked);
			_ui.btn_replay.addEventListener(MouseEvent.CLICK, 		_onReplayClicked);
			
			_progressBar.addEventListener(Event.CHANGE, _onProgressBarChanged);
			
		}
		
		protected function _onFrame(e:Event):void
		{
			_progressBar.update(_currentDanceClip.currentFrame/_currentDanceClip.totalFrames);
			
			if(_forceShow) return;
			if(_currentDanceClip.parent == null) return;
			var newPos:Point = new Point(_currentDanceClip.mouseX, _currentDanceClip.mouseY);
			var dist:Number = Point.distance(newPos, _lastMousePos);
			
			// Touchin' buttons, force to show
			if (_ui.getRect(_currentDanceClip).containsPoint(newPos))
			{
				dist = 777;
			}
				// If not within content viewer
			else if (!_currentDanceClip.parent.getRect(_currentDanceClip).containsPoint(newPos))
			{
				dist = 0;
			}
			
			_lastMousePos.x = newPos.x;
			_lastMousePos.y = newPos.y;
			
			if (dist > 1)
			{
				clearTimeout(_autoHideTimeout);
				_autoHideTimeout = setTimeout(hide, 1700);
				
				if (!_ui.visible) show();
			} 

		}
		public function hide(quick:Boolean = false):void
		{
			if(quick){ 
				_ui.visible = false; 
				_ui.alpha = 0;
				return;
			}
			TweenLite.to(_ui, .5, {alpha:0, visible:false});
		}
		public function show():void
		{
			_ui.visible = true;
			TweenLite.to(_ui, .35, {alpha:1, visible:true});
		}
		protected function _onReplayClicked(e:MouseEvent):void
		{
			replay();
			
		}
		protected function _onPlayClicked(e:MouseEvent):void
		{
			if(_currentDanceClip.currentFrame < _currentDanceClip.totalFrames)	play();
			else replay();
		}
		protected function _onPauseClicked(e:MouseEvent):void
		{
			pause();
		}
		protected function _onMuteClicked(e:MouseEvent):void
		{
			mute();
			
		}
		protected function _onUnMuteClicked(e:MouseEvent):void
		{
			unmute();
		}
		protected function _onProgressBarChanged(e:Event):void
		{
			play(_progressBar.progress);
		}		
		public function play(playHeadPercent:Number = -1):void
		{
			_playing = true;
			_updateUI();
			_forceShow = false;
			if(playHeadPercent > -1){
				_currentDanceClip.gotoAndPlay(Math.round(playHeadPercent*_currentDanceClip.totalFrames));
			}else
			{
				_currentDanceClip.play();
			}
		}
		public function replay(e:Event = null):void
		{
			_playing = true;
			_forceShow = false;
			if(_ui.parent.getChildByName("btn_play"))
			{
				_ui.parent.getChildByName("btn_play").visible= false;
			}
			_updateUI();
			_currentDanceClip.gotoAndPlay(2);
		}
		public function pause(e:Event = null):void
		{
			_playing = false;
			_currentDanceClip.stop();
			_updateUI();
			SoundMixer.stopAll();
		}
		public function mute(e:Event = null):void
		{
			var transform:SoundTransform = new SoundTransform(0);
			SoundMixer.soundTransform = transform;	
			_muted = true;
			_updateUI();
		}
		public function unmute(e:Event = null):void
		{
			var transform:SoundTransform = new SoundTransform(1);
			SoundMixer.soundTransform = transform;
			_muted = false;
			_updateUI();
		}
		protected function _updateUI():void
		{
			_ui.btn_unmute.visible = _muted;
			_ui.btn_mute.visible = !muted;
			_ui.small_play_button.visible = !_playing;
			_ui.small_pause_button.visible = _playing;
		}
		
		public function get muted():Boolean
		{
			return _muted;
		}
		override public function destroy():void
		{
			_progressBar.removeEventListener(Event.CHANGE, _onProgressBarChanged);
			
			_ui.btn_unmute.removeEventListener(MouseEvent.CLICK, 		_onUnMuteClicked);
			_ui.btn_mute.removeEventListener(MouseEvent.CLICK, 		_onMuteClicked);
			_ui.small_play_button.removeEventListener(MouseEvent.CLICK, _onPlayClicked);
			_ui.small_pause_button.removeEventListener(MouseEvent.CLICK, _onPauseClicked);
			_ui.btn_replay.removeEventListener(MouseEvent.CLICK, 		_onReplayClicked);
			if(_progressBar) _progressBar.destroy();
			if(_currentDanceClip)
			{
				if(_currentDanceClip.hasEventListener(Event.ENTER_FRAME))	_currentDanceClip.removeEventListener(Event.ENTER_FRAME, _onFrame);
				_currentDanceClip = null;
			}
			super.destroy();		
		}
	}
}
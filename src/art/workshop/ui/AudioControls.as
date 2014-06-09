/**
* ...
* @author Sam, Me^
* @version 2
*/

package workshop.ui {
	import com.oddcast.event.AudioEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.ToggleButton;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class AudioControls extends MovieClip {
		public var playBtn		:ToggleButton;
		public var recBtn		:ToggleButton;
		public var saveBtn		:BaseButton;
		public var processing	:MovieClip;
		
		public static const PLAYING		:String = "playing";
		public static const RECORDING	:String = "recording";
		public static const STOPPED		:String = "stopped";
		public static const NOAUDIO		:String = "noAudio";
		public static const PROCESSING	:String = "processing";
		
		public static const EVENT_PLAY		:String = "play";
		public static const EVENT_STOP		:String = "stop";
		public static const EVENT_REC		:String = "rec";
		public static const EVENT_STOPREC	:String = "stopRec";
		public static const EVENT_SAVE		:String = "save";
		
		public function AudioControls() {
			playBtn.getChildByName("playBtn").addEventListener(MouseEvent.CLICK,playAudio);
			playBtn.getChildByName("pauseBtn").addEventListener(MouseEvent.CLICK,pauseAudio);
			recBtn.getChildByName("recBtn").addEventListener(MouseEvent.CLICK,recAudio);
			recBtn.getChildByName("stopRecBtn").addEventListener(MouseEvent.CLICK,stopRecAudio);
			saveBtn.addEventListener(MouseEvent.CLICK,saveAudio);
			setState(NOAUDIO);
		}
		
		private function playAudio(evt:MouseEvent):void {
			dispatchEvent(new Event(EVENT_PLAY));
		}
		private function pauseAudio(evt:MouseEvent):void {
			dispatchEvent(new Event(EVENT_STOP));
		}
		private function recAudio(evt:MouseEvent):void {
			dispatchEvent(new Event(EVENT_REC));
		}
		private function stopRecAudio(evt:MouseEvent):void {
			dispatchEvent(new Event(EVENT_STOPREC));
		}
		private function saveAudio(evt:MouseEvent):void {
			dispatchEvent(new Event(EVENT_SAVE));
		}
		
		public function setState(s:String):void {
			if (s==NOAUDIO) {
				saveBtn.disabled=true;
				playBtn.disabled=true;
				recBtn.disabled=false;
				recBtn.btn="recBtn";
				processing.visible=false;
			}
			else if (s==RECORDING) {
				saveBtn.disabled=true;
				playBtn.disabled=true;
				recBtn.disabled=false;
				recBtn.btn="stopRecBtn";
				processing.visible=false;				
			}
			else if (s==STOPPED) {
				saveBtn.disabled=false;
				playBtn.disabled=false;
				playBtn.btn="playBtn";
				recBtn.disabled=false;
				recBtn.btn="recBtn";
				processing.visible=false;				
			}
			else if (s==PLAYING) {
				saveBtn.disabled=true;
				playBtn.disabled=false;
				playBtn.btn="pauseBtn";
				recBtn.disabled=true;
				processing.visible=false;				
			}
			else if (s==PROCESSING) {
				saveBtn.disabled=true;
				playBtn.disabled=true;
				recBtn.disabled=true;
				processing.visible=true;
			}
		}
	}
	
}
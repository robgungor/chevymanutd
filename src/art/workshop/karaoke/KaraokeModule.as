/**
* @author Sam Myer, Me^
* this remains to be fully implemented in the template
*/
package workshop.karaoke {
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import flash.events.*;
	
	public class KaraokeModule extends EventDispatcher {
		public var bgTrack:AudioData;
		private var player:AudioPlayer;
		
		public function KaraokeModule() {
			player = new AudioPlayer();
			player.addEventListener(AlertEvent.EVENT, onError);
		}
		
		public function addDispatcher(disp:EventDispatcher) {
			disp.addEventListener(KaraokeEvent.START, karaokeStart);
			disp.addEventListener(KaraokeEvent.STOP, karaokeStop);
			disp.addEventListener(KaraokeEvent.CLOSE, close);
		}
		
		public function karaokeStart(evt:KaraokeEvent=null) {
			if (bgTrack != null) player.play(bgTrack.url);
		}
		
		public function karaokeStop(evt:KaraokeEvent=null) {
			if (bgTrack != null) player.stop();
		}
		
		private function close(evt:KaraokeEvent) {
			
		}
		
		public function selectAudio($audio:AudioData) {
			bgTrack = $audio;
			player.load(bgTrack.url);
		}
		
		private function onError(evt:AlertEvent) {
			dispatchEvent(evt);
		}
	}
	
}
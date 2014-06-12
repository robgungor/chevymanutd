/**
* ...
* @author Sam Myer
* @version 0.1
* 
* Events:
* PREVIEW - the host should speak the audio without selecting it for the scene
* property: audio to preview
* 
* STOP - the host should stop speaking.
* properties: none
* 
* SELECT - audio is selected for the scene
* property: audio to select
*/

package com.oddcast.event {
	import com.oddcast.audio.AudioData;
	import flash.events.Event;

	public class AudioEvent extends Event {
		public static var PREVIEW:String="preview";
		public static var STOP:String="stop";
		public static var SELECT:String="select";
		
		public var audio:AudioData;
		
		public function AudioEvent(type:String,in_audio:AudioData=null) {
			super(type);
			audio=in_audio;
		}
		
		public override function clone():Event {
			return new AudioEvent(type,audio);
		}
		
	}
	
}
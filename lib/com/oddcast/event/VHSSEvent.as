/**
* ...
* @author Dave Segal
* @version 0.1
* @date 02.25.2008
*/

package com.oddcast.event{
	import flash.events.Event;

	public class VHSSEvent extends Event{
		
		/**
		 * Constant that defines the ai response event. Associated with a successful sayAIResponse api call.
		 * 
		 * @eventType vh_aiResponse
		 */
		public static const AI_RESPONSE:String = "vh_aiResponse";
		/**
		 * Constant that defines the audio loaded event. Associated with the loadAudio api call.
		 * 
		 * @eventType vh_audioLoaded
		 */
		public static const AUDIO_LOADED:String = "vh_audioLoaded";
		/**
		 * Constant that defines the audio progress event. Associated with the setStatus method. Dispatched at the
		 * frequency defined in the progress interval parameter.
		 * 
		 * @eventType vh_audioProgress
		 */
		public static const AUDIO_PROGRESS:String = "vh_audioProgress";
		/**
		 * Constant that defines the audio ended event. Associated with the completion of a spoken audio.
		 * 
		 * @eventType vh_audioEnded
		 */
		public static const AUDIO_ENDED:String = "vh_audioEnded";
		/**
		 * Constant that defines the audio started event. Associated with the beginning of a spoken audio.
		 * 
		 * @eventType vh_audioStarted
		 */
		public static const AUDIO_STARTED:String = "vh_audioStarted";
		/**
		 * Constant that defines the scene loaded event. Associated with the completed loading and display of a scene.
		 * 
		 * @eventType vh_sceneLoaded
		 */
		public static const SCENE_LOADED:String = "vh_sceneLoaded";
		/**
		 * Constant that defines the scene preloaded event. Associated with the completed loading of a scene.
		 * 
		 * @eventType vh_scenePreloaded
		 */
		public static const SCENE_PRELOADED:String = "vh_scenePreloaded";
		/**
		 * Constant that defines the tts loaded event. Associated with the completed caching of a tts audio.
		 * 
		 * @eventType vh_ttsLoaded
		 */
		public static const TTS_LOADED:String = "vh_ttsLoaded";
		/**
		 * Constant that defines the talk ended event. Associated with end of the host speaking a single or series of audios.
		 * 
		 * @eventType vh_talkEnded
		 */
		public static const TALK_ENDED:String = "vh_talkEnded";
		/**
		 * Constant that defines the talk started event. Associated with start of the host speaking a single or series of audios.
		 * 
		 * @eventType vh_talkStarted
		 */
		public static const TALK_STARTED:String = "vh_talkStarted";
		
		/**
		 * Constant that defines the config done event. Associated with completion of host loading and initialization. Host is ready for 
		 * interaction.
		 * 
		 * @eventType config_done
		 */
		public static const CONFIG_DONE:String = "config_done";
		/**
		 * Constant that defines the skin loaded event. Associated with the completion of the loadSkin method.
		 * 
		 * @eventType skin_loaded
		 */
		public static const SKIN_LOADED:String = "skin_loaded";
		/**
		 * Constant that defines the bg loaded event. Associated with the completion of the loadBackground method.
		 * 
		 * @eventType bg_loaded
		 */
		public static const BG_LOADED:String = "bg_loaded";
		/**
		 * Constant that defines the engine loaded event. Associated with the completion of the engine loading method. 
		 * Dispatched whenever the engine loads for the first time either with the loadHost method or with the loading
		 * of a character during scene start.
		 * 
		 * @eventType engine_loaded
		 */
		public static const ENGINE_LOADED:String = "engine_loaded";
		
		/**
		 * Constant that defines a player xml load error.
		 * 
		 * @eventType player_xml_error 
		 */
		public static const PLAYER_XML_ERROR:String = "player_xml_error";
		
		/**
		 * Constant that defines the player ready string
		 * 
		 * @eventType player_ready
		 */
		public static const PLAYER_READY:String = "player_ready";
		/**
		 * Constant that defines a model load error
		 * 
		 * @eventType model_load_error
		 */
		public static const MODEL_LOAD_ERROR:String = "model_load_error";
		/**
		 * Constant that defines when a scene has complete playback. Includes audio, video
		 * and background slideshow
		 *
		 * @eventType scene_playback_complete
		 */
		public static const SCENE_PLAYBACK_COMPLETE:String = "scene_playback_complete";
		/**
		 * Constant that defines an error related to the loading of some data the player
		 * is attempting to load
		 * 
		 * @eventType player_data_error
		 */
		public static const PLAYER_DATA_ERROR:String = "player_data_error";
		/**
		 * Constant that defines an audio error
		 * 
		 * @eventType audio_error
		 */
		public static const AUDIO_ERROR:String = "audio_error";
		/**
		 * Constant that defines an accessory load error
		 * 
		 * @eventType accessory_load_error
		 */
		public static const ACCESSORY_LOAD_ERROR:String = "accessory_load_error";
		
		public var data:Object;
		
		public function VHSSEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false):void
		{
			super($type, $bubbles, $cancelable);
			this.data = $data;
		}
		
		public override function clone():Event
		{
			return new VHSSEvent(type, this.data, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("VHSSEvent", "data", "type", "bubbles", "cancelable");
		}
	
	}
	
}
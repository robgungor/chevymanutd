/**
* ...
* @author Sam, Me^
* @version 1.1
* 
* @usage
* These are the events thrown by the SceneController whenever a scene asset is changed (model,bg,audio,etc.)
* 
* 
*/

package com.oddcast.workshop {
	import flash.events.Event;

	public class SceneEvent extends Event 
	{
		public static const MODEL_LOADED		:String = "configDone";
		public static const MODEL_LOAD_ERROR	:String = "modelLoadError";
		public static const CONFIG_DONE			:String = "configDone";
		public static const BG_LOADED			:String = "bgUpdated";
		public static const BG_UPLOADED			:String = "bgUploaded";
		public static const BG_CROPPED			:String = "bgCropped";
		public static const BG_CROP_FAILED		:String = "bgCropFailed";
		public static const BG_EXPIRED			:String = "bgExpired";
		public static const AUDIO_UPDATED		:String = "audioUpdated";
		public static const COLOR_UPDATED		:String = "colorUpdated";
		public static const SIZING_UPDATED		:String = "sizingUpdated";
		public static const ACCESSORY_LOADED	:String = "accessoryLoaded";
		public static const ACCESSORY_LOAD_ERROR:String = "accessoryLoadError";
		public static const TALK_STARTED		:String = "talkStarted";
		public static const TALK_ENDED			:String = "talkEnded";
		public static const TALK_ERROR			:String = "talkError";
		public static const FULL_BODY_LOAD_ERROR:String = 'FULL_BODY_LOAD_ERROR';

		public var data:Object;
		
		public function SceneEvent($type:String,$data:Object=null) {
			super($type);
			data = $data;
		}
		
		public override function clone():Event {
			return new SceneEvent(type,data);
		}
		
	}
	
}
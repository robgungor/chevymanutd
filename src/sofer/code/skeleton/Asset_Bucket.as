package code.skeleton 
{
	import code.models.Model_Store;
	
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.player.*;
	import com.oddcast.workshop.*;
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	import workshop.uploadphoto.*;

	/**
	 * @contains	contains data structs to be referenced by UI components for selectors etc.
	 * @author		Me^
	 */
	public class Asset_Bucket
	{
		/** last audio object saved */
		public var last_audio_saved			:AudioData;
		/** last message ID created in this session */
		public var last_mid_saved			:String;
		/** status of the application is in playback or editing mode */
		public var is_playback_mode			:Boolean;
		/** background IDs are supposed to be unique so when creating a new one increment this counter for unique ids */
		public var bg_counter_id			:int = -1;
		
		public var video_downloader			:DownloadVideo;
		public var bg_controller			:BGController;
		public var bg_uploader				:BGUploader;
		public var profanity_validator		:BadWordChecker		= new BadWordChecker();
		public var gallery_topics_list		:GalleryTopicList	= new GalleryTopicList();
		
		/** stores downloaded data such as accessories lists and tts voices */
		public var model_store : Model_Store = new Model_Store();
		
		public var danceScenes:Array = [];
		public var idleScenes:Array = [];
		public var idleScene:MovieClip;
		public var mid_message:WorkshopMessage;
		public function Asset_Bucket() 
		{}
		
	}

}
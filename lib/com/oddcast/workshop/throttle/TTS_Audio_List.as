package com.oddcast.workshop.throttle 
{
	/**
	 * ...
	 * @about: 	class which stores previously LOADED urls
	 * 			and provides api for comparing and adding
	 * @author Me^
	 */
	public class TTS_Audio_List
	{
		/* list of audios that have successfully been loaded (on talk_started its added here) */
		private var arr_played_tts_urls:Array;
		
		public function TTS_Audio_List()
		{	arr_played_tts_urls = [];
		}
		/**
		 * checks if a new request has already been previously loaded and therefore cached
		 * (caching can be in the engine, browser, akamai, or on oddcast)
		 * @param	_request_url	new url that is attempted to be loaded
		 * @return	true if it has been previously loaded
		 */
		public function has_audio_played( _request_url:String ):Boolean
		{	for (var i:int = 0; _request_url && i < arr_played_tts_urls.length; i++) 
			{	var cur_url:String = arr_played_tts_urls[i];
				if (cur_url == _request_url)
					return true;
			}
			return false;
		}
		/**
		 * adds the loaded audio url to the list if it has not been previously added
		 * @param	_audio_url	url that has already been loaded
		 */
		public function audio_successfully_loaded( _audio_url:String ):void 
		{	if ( _audio_url && !has_audio_played( _audio_url ))	// not currently in the array
				arr_played_tts_urls.push( _audio_url );
		}
		
	}

}
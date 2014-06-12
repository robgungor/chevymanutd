﻿package com.oddcast.workshop.throttle 
{
	import com.oddcast.workshop.*;
	
	/**
	 * @description factory class for all throttle limits to be applied to workshops and videostar
	 * @about high traffic applicatins require certain capping in place like TTS and Autophoto uploading... so all the logic is consolidated to this class
	 * @applications TTS, Autophoto Image Uploading, Autophoto component loading
	 * @author Me^
	 * @version 1.1
	 * 
	 * @update: 10.01.03 added check to not throttle previously loaded audio urls.
	 * @update: 10.03.12 added on off switch so it can be deactivated in playback mode
	 */
	public class Throttler 
	{
		/* time in milliseconds to store the last php response values in case of a fail */
		private static const STORE_LAST_RESPONSE_FAIL		:int					= 30000;
		/* time in milliseconds to store the last php response values in case of a pass */
		private static const STORE_LAST_RESPONSE_PASS		:int					= 10000;
		
		private static var tts_api							:Throttling_Logic;
		private static var autophoto_upload_api				:Throttling_Logic;
		private static var autophoto_open_api				:Throttling_Logic;
		private static var microphone_recording_api			:Throttling_Logic;
		
		private static var played_tts_audio_urls			:TTS_Audio_List = new TTS_Audio_List();
		/* indicates if throttling is turned on or off... for example it should be off in playback mode */
		public static var turned_on							:Boolean = true;
		/* true if response is in the same thread, 
		* then an UIA can be called without a secondary alert */
		public static var last_response_was_instant			:Boolean = false;
		
		/**************************************************** API CALLS */
		
		/**
		 * if there is a limit for this workshop we append it to the end of the mp3 query string
		 * @return
		 */
		public static function append_tts_limit(  ):String
		{
			last_response_was_instant = true;
			if (!turned_on || ServerInfo.throttle_tts_max_count == ServerInfo.NO_VALUE_NUM)
				return "";
			return "&apsQueueLimit=" + ServerInfo.throttle_tts_max_count;
		}
		/**
		 * adds the loaded audio url to the list if it has not been previously added
		 * @param	_audio_url	url that has ALREADY been loaded
		 */
		public static function audio_successfully_loaded( _audio_url:String ):void 
		{	played_tts_audio_urls.audio_successfully_loaded( _audio_url );
		}
		/**
		 * check if we are allowed to make the tts request
		 * @param	_audio audio to be played which needs to be checked if it was played in this session.. if so then its allowes
		 * @param	_allowed callback if there is enough capacity
		 * @param	_rejected callback if there is NOT enough capacity
		 * @param	_max_uploads_reached callback when the user surpassed the number of allowed uploads per session
		 */
		public static function tts_request_allowed( _audio_url:String, _allowed:Function, _rejected:Function, _max_uploads_reached:Function ):void
		{
			if 
				(
					!turned_on ||
					played_tts_audio_urls.has_audio_played( _audio_url ) ||
					ServerInfo.throttle_tts_low_traffic_index == ServerInfo.NO_VALUE_NUM || 
					ServerInfo.throttle_tts_allowance == ServerInfo.NO_VALUE_NUM
				)
			{	
				last_response_was_instant = true;
				_allowed();
			}
			else
			{	
				last_response_was_instant = false;
				init_tts();
				tts_api.check_server_capacity( _allowed, _rejected, _max_uploads_reached );
			}
		}
		/**
		 * checks if there is enough server capacity for an upload in the case that a threshold is set
		 * NOTE a response is not immediate but delayed until the server responds
		 * @param	_allowed callback if there is enough capacity
		 * @param	_rejected callback if there is NOT enough capacity
		 * @param	_max_uploads_reached callback when the user surpassed the number of allowed uploads per session
		 */
		public static function autophoto_upload_allowed( _allowed:Function, _rejected:Function, _max_uploads_reached:Function ):void 
		{
			if (!turned_on || ServerInfo.throttle_autophoto_upload_max_count == ServerInfo.NO_VALUE_NUM)
			{
				last_response_was_instant = true;
				_allowed();
			}
			else
			{
				last_response_was_instant = false;
				init_autophoto_upload();
				autophoto_upload_api.check_server_capacity( _allowed, _rejected, _max_uploads_reached );
			}
		}
		/**
		 * checks if there is enough server capacity for loading the APC component
		 * NOTE a response is not immediate but delayed until the server responds
		 * @param	_allowed callback if there is enough capacity
		 * @param	_rejected callback if there is NOT enough capacity
		 * @param	_max_uploads_reached callback when the user surpassed the number of allowed uploads per session
		 */
		public static function autophoto_open_allowed( _allowed:Function, _rejected:Function, _max_uploads_reached:Function ):void 
		{
			if (!turned_on || ServerInfo.throttle_autophoto_upload_max_count == ServerInfo.NO_VALUE_NUM)
			{
				last_response_was_instant = true;
				_allowed();
			}
			else
			{
				last_response_was_instant = false;
				init_autophoto_open();
				autophoto_open_api.check_server_capacity( _allowed, _rejected, _max_uploads_reached );
			}
		}
		public static function microphone_recording_allowed( _allowed:Function, _rejected:Function ):void 
		{
			if (!turned_on || ServerInfo.throttle_microphone_max_count == ServerInfo.NO_VALUE_NUM)
			{
				last_response_was_instant = true;
				_allowed();
			}
			else
			{
				last_response_was_instant = false;
				init_microphone_recording();
				microphone_recording_api.check_server_capacity( _allowed, _rejected, _rejected);
			}
		}
		
		/*****************************************************/
		
		private static function init_tts():void
		{
			if (tts_api == null)
			{
				var low_traffic_index	:int = ( ServerInfo.throttle_tts_low_traffic_index == ServerInfo.NO_VALUE_NUM ) ? Throttling_Logic.NO_VALUE : ServerInfo.throttle_tts_low_traffic_index;
				var request_count		:int = ( ServerInfo.throttle_tts_allowance == ServerInfo.NO_VALUE_NUM ) ? Throttling_Logic.NO_VALUE : ServerInfo.throttle_tts_allowance;
				var over_load			:int = ( ServerInfo.throttle_max_load == ServerInfo.NO_VALUE_NUM ) ? Throttling_Logic.NO_VALUE : ServerInfo.throttle_max_load;
				tts_api = new Throttling_Logic
					( 
						STORE_LAST_RESPONSE_FAIL, 
						STORE_LAST_RESPONSE_PASS, 
						request_count, 
						low_traffic_index, 
						ServerInfo.throttle_capacity_url + '?cap=tts', 
						Throttling_Logic.NO_VALUE, over_load 
					);	// high num so we never reject over capacity limit requests, this is handled by engine
			}
		}
		
		private static function init_autophoto_upload():void
		{
			if (autophoto_upload_api == null)
			{
				var low_traffic_index	:int = ( ServerInfo.throttle_autophoto_upload_low_traffic_index == ServerInfo.NO_VALUE_NUM ) ? Throttling_Logic.NO_VALUE : ServerInfo.throttle_autophoto_upload_low_traffic_index;
				var request_count		:int = ( ServerInfo.throttle_autophoto_upload_allowance == ServerInfo.NO_VALUE_NUM ) ? Throttling_Logic.NO_VALUE : ServerInfo.throttle_autophoto_upload_allowance;
				var over_load			:int = ( ServerInfo.throttle_max_load == ServerInfo.NO_VALUE_NUM ) ? Throttling_Logic.NO_VALUE : ServerInfo.throttle_max_load;
				autophoto_upload_api = new Throttling_Logic
					( 
						STORE_LAST_RESPONSE_FAIL, 
						STORE_LAST_RESPONSE_PASS, 
						request_count, 
						low_traffic_index, 
						ServerInfo.throttle_capacity_url + '?cap=apb', 
						ServerInfo.throttle_autophoto_upload_max_count, over_load 
					);
			}
		}
		
		private static function init_autophoto_open(  ):void 
		{
			if (autophoto_open_api == null)
			{
				var request_count		:int = ( ServerInfo.throttle_autophoto_upload_allowance == ServerInfo.NO_VALUE_NUM ) ? Throttling_Logic.NO_VALUE : ServerInfo.throttle_autophoto_upload_allowance;
				var over_load			:int = ( ServerInfo.throttle_max_load == ServerInfo.NO_VALUE_NUM ) ? Throttling_Logic.NO_VALUE : ServerInfo.throttle_max_load;
				autophoto_open_api = new Throttling_Logic
					( 
						STORE_LAST_RESPONSE_FAIL, 
						STORE_LAST_RESPONSE_PASS, 
						request_count, 
						Throttling_Logic.NO_VALUE, 
						ServerInfo.throttle_capacity_url + '?cap=apb', 
						ServerInfo.throttle_autophoto_upload_max_count, 
						over_load 
					);
			}
		}
		
		private static function init_microphone_recording(  ):void 
		{
			if (microphone_recording_api == null)
			{
				var over_load			:int = ( ServerInfo.throttle_max_load == ServerInfo.NO_VALUE_NUM ) ? Throttling_Logic.NO_VALUE : ServerInfo.throttle_max_load;
				microphone_recording_api = new Throttling_Logic
					( 
						STORE_LAST_RESPONSE_FAIL, STORE_LAST_RESPONSE_PASS, 
						Throttling_Logic.NO_VALUE, 
						Throttling_Logic.NO_VALUE, 
						ServerInfo.throttle_capacity_url + '?cap=fms', 
						ServerInfo.throttle_microphone_max_count, 
						over_load 
					);
			}
		}
	}
	
}
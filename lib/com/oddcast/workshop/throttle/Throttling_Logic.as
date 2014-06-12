package com.oddcast.workshop.throttle
{
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	
	import flash.net.URLVariables;
	import flash.utils.setTimeout;
	
	
	/**
	 * ...
	 * @author Me^
	 * @description decision is made based on threshold values from server
	 * 				if capacity is below {low threshold} user has unlimited uploads
	 * 				if capacity is at {low threshold}-{max threshold} user has limited uploads
	 * 				if capacity is above {max threshold} upload is rejected
	 */
	public class Throttling_Logic 
	{
		/* if the threshold limit is above the low traffic index then we have to limit the user uploads */
		private var limit_user_uploads				:Boolean = false;
		/* value of the last request for capacity from the server */
		private var last_response_allowed			:Boolean;
		/* last value stores for how many session there are */
		private var last_session_count				:int;
		/* last value stores for how much server percentage used there are */
		private var last_server_percentage_load		:int;
		/* we dont check the capacity all the time we need to allow it once in a while */
		private var check_capacity_interval_allowed	:Boolean = true;
		/* time in milliseconds to store the last upload capacity for autophoto in case of success */
		private var save_response_time_success		:int;
		/* time in milliseconds to store the last upload capacity for autophoto in case of failure */
		private var save_response_time_fail		:int;
		private var low_threshold					:int;
		/* how many uploads are allowed per session */
		private var max_uploads						:int;
		/* how many uploads were allowed during a high traffic time,
		* think of this as allowance which is used up with every request */
		private var current_upload_count			:int = 0;
		private var capacity_url					:String;
		private var max_upload_threshold			:int;
		private var max_server_percentage_load		:int;
		public static const NO_VALUE				:int = -373737;
		
		
		/**
		 * constructor
		 * @param	_save_response_time_fail how long to save the server value when response is rejected
		 * @param	_save_response_time_success how long to save the server value when response is allowed
		 * @param	_max_uploads how many uploads are allowed per session
		 * @param	_low_threshold what limit is considered to separate high traffic and low traffic
		 * @param	_capacity_url url for checking capacity
		 * @param	_max_upload_threshold max number of sessions allowed at once
		 */
		public function Throttling_Logic( _save_response_time_fail:int, _save_response_time_success:int, _max_uploads:int, _low_threshold:int, _capacity_url:String, _max_upload_threshold:int, _max_server_percentage_load:int = NO_VALUE ) 
		{
			save_response_time_fail		= _save_response_time_fail;
			save_response_time_success	= _save_response_time_success;
			low_threshold				= _low_threshold;
			max_uploads					= _max_uploads;
			capacity_url				= _capacity_url;
			max_upload_threshold		= _max_upload_threshold;
			max_server_percentage_load	= _max_server_percentage_load;
		}
		public function check_server_capacity( _success:Function, _fail:Function, _max_uploads_reached:Function ):void 
		{
			download_server_active_sessions( got_server_active_sessions, _fail );
			
			function got_server_active_sessions( _session_count:int, _overall_server_percentage:int ):void 
			{
				// check if were in high traffic numbers so we limit the user uploads
				if (low_threshold != NO_VALUE && max_uploads != NO_VALUE)
					limit_user_uploads = (_session_count > low_threshold );
					
				// check of overall system capacity is passed
				var max_overall_server_load_surpassed:Boolean = false;
				if (max_server_percentage_load != NO_VALUE)
					max_overall_server_load_surpassed = (_overall_server_percentage >= max_server_percentage_load);
					
				// check if were over the max limit
					var session_capacity_surpassed:Boolean = false;
					if (max_upload_threshold != NO_VALUE)
						session_capacity_surpassed = (_session_count >= max_upload_threshold);
						
				last_response_allowed = (!session_capacity_surpassed && !max_overall_server_load_surpassed);
				
				if (last_response_allowed)
				{
					if (upload_limit_surpassed())
					{
						temp_disable_checking_for_capacity( false );
						_max_uploads_reached();
					}
					else
					{
						temp_disable_checking_for_capacity( true );
						_success();
					}
				}
				else
				{
					temp_disable_checking_for_capacity( false );
					_fail();
				}
			}
			function upload_limit_surpassed(  ):Boolean
			{
				if (limit_user_uploads)
				{
					if (++current_upload_count > max_uploads)
						return true;
					else
						return false;
				}
				return false;
			}
			/** 
			 * downloads the count
			 * @param	_fin function needs to accept (int)
			 * @param	_fail function if the call fails
			 */
			function download_server_active_sessions( _fin_INT:Function, _fail:Function ):void 
			{
				if (!check_capacity_interval_allowed)
				{
					if (last_response_allowed)
						_fin_INT( last_session_count, last_server_percentage_load );
					else
						_fail();
				}
				else
				{
					var ran:String = '&ran=' + Math.floor(Math.random() * 1000000).toString();
					var url:String = capacity_url + ran;
					Gateway.retrieve_URLVariables(new Gateway_Request(url,new Callback_Struct(fin, null, error)));
					
					function error(_msg:String):void
					{
						_fail();
					}
					function fin( _response:URLVariables ):void 
					{
						if (_response && _response.cnt)
						{
							last_session_count 			= parseInt( _response.cnt );
							last_server_percentage_load = parseInt( _response.load );
							save_response_time_fail		= parseInt( _response.neg ) * 1000;
							save_response_time_success	= parseInt( _response.pos ) * 1000;
							_fin_INT( last_session_count, last_server_percentage_load );
						}
						else
							_fail();
					}
				}
			}
			/**
			 * disables the call for server capacity if its currently running
			 * @param	_request_allowed if the request was allowed or not
			 */
			function temp_disable_checking_for_capacity( _request_allowed:Boolean ):void
			{
				// dont change the timeout if a timeout is already running... this might be getting called while a delay is already in place
				if (check_capacity_interval_allowed)
				{
					check_capacity_interval_allowed = false;
					var time_delay:int = (_request_allowed) ? save_response_time_success : save_response_time_fail;
					setTimeout( reallow_checking_for_capacity, time_delay);
				}
			}
			/**
			 * allow calling of the server for updated figures
			 */
			function reallow_checking_for_capacity():void
			{
				check_capacity_interval_allowed = true;
			}
		}
		
	}
	
}
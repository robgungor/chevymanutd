package com.oddcast.workshop 
{
	import com.dynamicflash.util.Base64;
	import com.oddcast.encryption.md5;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.utils.XMLLoader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	/**
	 * @about: uploads the OA1 bytearray into seperate parts
	 * 
	 * @author Me^
	 */
	public class OA1_Uploader extends EventDispatcher
	{
		/* array holding the individual ByteArray parts as String that need to be uploaded */
		private var packet_list				:Array;
		/* callback for when the full upload finishes */
		private var on_complete_callback	:Function;
		/* callback for when the is an error present */
		private var on_error_callback		:Function;
		/* max size of each bytearray to upload at one time */
		private var packet_max_size			:Number				= 30000;	// bytes
		/* contains the full file byte array which will be broken into smaller parts and uploaded */
		private var full_packet_data		:String;
		/* current index of the array indicating which packet is now uploading */
		private var uploading_index			:int;
		/* session indicating the current upload for all the packets */
		private var uploading_session		:String;
		/* uploader interface */
		private var packet_uploader			:URLLoader;
		private var packet_request			:URLRequest;
		/* redundancy counter */
		private var cur_redundancy_count	:int;
		/* extension of the file on the server to use */
		private var server_file_extension	:String;
		/* how many times to attempt to upload a packet before throwing an error */
		private const redundancy_max_tries	:int				= 3;
		
		public function OA1_Uploader(  ) 
		{
			reset_redundancy_count();
		}
		
		/**
		 * callback function needs to accept string, error fun needs to accept AlertEvent
		 * @param	_OA1 the OA1 byte information
		 * @param	_on_complete_callback callback when process finished correctly
		 * @param	_on_error_callback callback in the event of an error
		 */
		public function upload_OA1( _OA1:ByteArray, _on_complete_callback:Function, _on_error_callback:Function ):void 
		{	init_params();
			init_callbacks( _on_complete_callback, _on_error_callback );
			convert_type( _OA1 );			
			create_packet_list();
			server_file_extension = null;
			upload_packets();
		}
		
		/**
		 * callback function needs to accept string, error fun needs to accept AlertEvent
		 * @param	_avt_byte_arr the full body avatar byte information
		 * @param	_on_complete_callback callback when process finished correctly
		 * @param	_on_error_callback callback in the event of an error
		 */
		public function upload_AVT( _avt_byte_arr:ByteArray, _on_complete_callback:Function, _on_error_callback:Function ):void 
		{	init_params();
			init_callbacks( _on_complete_callback, _on_error_callback );
			convert_type( _avt_byte_arr );
			create_packet_list();
			server_file_extension = 'avt';
			upload_packets();
		}
		private function init_params(  ):void 
		{
			if (!isNaN(ServerInfo.OA1_upload_limit) && ServerInfo.OA1_upload_limit > 1)
				packet_max_size = ServerInfo.OA1_upload_limit * 1000;
		}
		private function init_callbacks( _on_complete_callback:Function, _on_error_callback:Function ):void 
		{
			on_complete_callback	= _on_complete_callback;
			on_error_callback		= _on_error_callback
		}
		private function convert_type( _OA1:ByteArray ):void 
		{
			full_packet_data = Base64.encodeByteArray( _OA1 );
		}
		private function create_packet_list(  ):void 
		{
			// how many packets will we need?
			var num_of_packets:int = Math.ceil( full_packet_data.length / packet_max_size );
			
			// add data for each packet into the container
			packet_list = new Array();
			
			for (var i:int = 0; i < num_of_packets; i++) 
			{
				var start_index	:int	= packet_max_size * i;
				var end_index	:int	= packet_max_size * ( i + 1 );
				
				// check for overflow
				if ( end_index > full_packet_data.length )	end_index = full_packet_data.length;
				
				var new_packet	:String	= full_packet_data.substring ( start_index, end_index );
				
				packet_list.push ( new_packet );
			}
		}
		private function upload_packets(  ):void 
		{
			uploading_session	= new Date().getTime().toString() + Math.ceil(Math.random() * 1000).toString();
			uploading_index		= 0;
			recursive_upload_packet();
		}
		
		protected function getPHP_URL():String {
			return ServerInfo.localURL + "api/oa1Uploader_multi.php?rand=" + Math.floor(Math.random() * 1000000).toString();
		}
		
		protected function setPostVar(post_vars	:URLVariables):void {
			post_vars.doorId				= ServerInfo.door;
			// if this should have a specific extension and not "oa1" then specify it my man!!!
			if (server_file_extension)
				post_vars.ext = server_file_extension;
		}
		
		private function recursive_upload_packet(  ):void 
		{
			var API_url		:String			= getPHP_URL();
			
			// data to be sent
			var cur_packet	:String			= packet_list[ uploading_index ];
			var post_vars	:URLVariables	= new URLVariables();
			post_vars.multi_tot				= packet_list.length;
			post_vars.multi_cur				= uploading_index + 1;
			post_vars.multi_ses				= uploading_session;
			post_vars.multi_md5				= ( new md5() ).hash( cur_packet );
			post_vars.FileDataBase64		= cur_packet;
			setPostVar(post_vars);
			
			
			
			// if this is the last packet add full md5 check
			if ( uploading_index == ( packet_list.length - 1 ) )
				post_vars.multi_md5_final	= ( new md5() ).hash( full_packet_data );
			
			// upload data
			//XMLLoader.sendAndLoad( API_url, single_packet_upload_response, post_vars, String );
			
			var request:Gateway_Request		= new Gateway_Request( API_url, new Callback_Struct( fin, null, error ), 2 )
			request.background = true;
			request.response_eval_method	= function(_response:String):Boolean	
											{
												if (_response == 'ok' ||
													_response.indexOf('http://') >= 0 )
													return true;
												return false;
											};
			Gateway.upload( post_vars, request );
			function fin( _response:String ):void 
			{	/*
				if ( response_is_invalid( _response ) )	
						current_packet_failed_upload( _response );
				else	current_packet_successfully_uploaded( _response );
				*/
				current_packet_successfully_uploaded( _response );
			}
			function error( _msg:String ):void 
			{
				connection_error(
									new AlertEvent(
													AlertEvent.ALERT, 
													'f9t514', 
													'There seems to be a problem with your Internet connection.  Please reconnect and try again.  Error uploading character (oa1) file', 
													{ details:_msg } 
												)
								);
			}
		}
		/**
		 * callback when a packet item successfully uploaded
		 * @param	_response
		 
		private function single_packet_upload_response( _response:String ):void 
		{
			var alert_event:AlertEvent = XMLLoader.checkForAlertEvent("f9t514");
			
			if ( _response == null )						connection_error( alert_event );
			else if ( response_is_invalid( _response ) )	current_packet_failed_upload( _response );
			else if (alert_event == null)					current_packet_successfully_uploaded( _response );
			else											connection_error( alert_event );
			
		}*/
		private function response_is_invalid( _response:String ):Boolean
		{
			/* valid resonses
			 * ok -- on non last packet uploads
			 * http://host.staging.oddcast.com/ccs1/tmp/123758851438817.oa1 -- on last packet upload
			 */
			if (	( _response == 'ok' ) ||
					( _response.indexOf('http://') > -1 ) ) return false;
			return true;
		}
		/**
		 * there was a fatal error communicating with the server
		 * @param	_e
		 */
		private function connection_error( _e:AlertEvent ):void 
		{
			if (on_error_callback != null)		on_error_callback( _e );
			else								throw(new Error('com.oddcast.workshop.OA1_Uploader.connection_error() MISSING ON ERROR CALLBACK.'));
		}
		/**
		 * try to upload the same package again
		 * @param	_response
		 */
		private function current_packet_failed_upload( _response:String ):void 
		{
			if (upload_redundancy_allowed() )	recursive_upload_packet();
			else								on_error_callback( new AlertEvent(AlertEvent.ERROR, 'f9t404', 'Error saving message.  ', { details:'Cannot upload OA1 packet ' + uploading_index + ' of ' + packet_list.length + '.  ' + _response } ) )
		}
		private function current_packet_successfully_uploaded( _response:String ):void 
		{
			update_percent_loaders();
			reset_redundancy_count();
			uploading_index ++;
			if (uploading_index < packet_list.length)		recursive_upload_packet();
			else											all_packets_uploaded( _response );
		}
		/**
		 * percent of upload progress based on the num of packets left
		 */
		private function update_percent_loaders(  ):void
		{
			var percent:Number = uploading_index / ( packet_list.length - 1 );
			dispatchEvent( new ProcessingEvent( ProcessingEvent.PROGRESS, ProcessingEvent.SAVING, percent ) );
		}
		private function reset_redundancy_count(  ):void 
		{
			cur_redundancy_count = 0;
		}
		/**
		 * increments the counter and returns if it should be uploaded again
		 * @return
		 */
		private function upload_redundancy_allowed(  ):Boolean
		{
			cur_redundancy_count ++;
			return (cur_redundancy_count < redundancy_max_tries);
		}
		
		private function all_packets_uploaded( _final_response:String ):void 
		{
			if ( on_complete_callback != null )		on_complete_callback( _final_response );
			else									throw(new Error('com.oddcast.workshop.OA1_Uploader.all_packets_uploaded() MISSING ON COMPLETE CALLBACK.'));
		}
	}
	
}
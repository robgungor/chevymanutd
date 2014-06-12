package com.oddcast.utils 
{
	import com.oddcast.encryption.Base64;
	import com.oddcast.encryption.md5;
	import com.oddcast.event.AlertEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	/**
	 * @about: uploads the OA1 bytearray into seperate parts
	 * 
	 * @author Me^, Jonathan Achai
	 */
	public class ByteArray_Uploader extends EventDispatcher
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
		
		private var _sUploadUrl:String;
		private var _postVars:URLVariables;
		
		public function ByteArray_Uploader(  ) 
		{
			reset_redundancy_count();
		}
		
		/**
		 * callback function needs to accept string, error fun needs to accept AlertEvent
		 * @param	_OA1 the OA1 byte information
		 * @param	_on_complete_callback callback when process finished correctly
		 * @param	_on_error_callback callback in the event of an error
		 */
		public function upload_ByteArray( _ba:ByteArray, uploadUrl:String, extension:String, _on_complete_callback:Function, _on_error_callback:Function, vars:URLVariables = null ):void 
		{	
			_sUploadUrl = uploadUrl;	
			_postVars = vars;
			init_callbacks( _on_complete_callback, _on_error_callback );
			convert_type( _ba );			
			create_packet_list();
			server_file_extension = extension;
			upload_packets();
		}
		
		/**
		 * sets the maximum size of the packets sent
		 * @param	kbytes max size in kilobytes
		 */
		public function setMaxPacketSize(kbytes:Number):void
		{
			packet_max_size = kbytes * 1024;
		}
						
		private function init_callbacks( _on_complete_callback:Function, _on_error_callback:Function ):void 
		{
			on_complete_callback	= _on_complete_callback;
			on_error_callback		= _on_error_callback
		}
		private function convert_type( _ba:ByteArray ):void 
		{
			full_packet_data = Base64.encode( _ba );
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
		private function recursive_upload_packet(  ):void 
		{
			var API_url		:String			= _sUploadUrl +"?rand=" + Math.floor(Math.random() * 1000000).toString();
			
			// data to be sent
			var cur_packet	:String			= packet_list[ uploading_index ];
			var post_vars	:URLVariables	= new URLVariables();
			post_vars.multi_tot				= packet_list.length;
			post_vars.multi_cur				= uploading_index + 1;
			post_vars.multi_ses				= uploading_session;
			post_vars.multi_md5				= ( new md5() ).hash( cur_packet );
			post_vars.FileDataBase64		= cur_packet;
			//post_vars.doorId				= ServerInfo.door;
			if (_postVars!=null)
			{
				for (var k:String in _postVars)
				{
					post_vars[k] = _postVars[k];
				}
			}
			
			// if this should have a specific extension and not "oa1" then specify it my man!!!
			if (server_file_extension)
				post_vars.ext = server_file_extension;
			
			// if this is the last packet add full md5 check
			if ( uploading_index == ( packet_list.length - 1 ) )
				post_vars.multi_md5_final	= ( new md5() ).hash( full_packet_data );
			
			// upload data
			XMLLoader.sendAndLoad( API_url, single_packet_upload_response, post_vars, String );
		}
		/**
		 * callback when a packet item successfully uploaded
		 * @param	_response
		 */
		private function single_packet_upload_response( _response:String ):void 
		{
			//var alert_event:AlertEvent = XMLLoader.checkForAlertEvent("f9tp514");
			
			if ( _response == null )						connection_error( XMLLoader.lastError );
			else if ( response_is_invalid( _response ) )	current_packet_failed_upload( _response );
			else if (XMLLoader.lastError == null)					current_packet_successfully_uploaded( _response );
			else											connection_error( XMLLoader.lastError );
			
		}
		private function response_is_invalid( _response:String ):Boolean
		{
			/* valid resonses
			 * ok -- on non last packet uploads
			 * http://host.staging.oddcast.com/ccs1/tmp/123758851438817.oa1 -- on last packet upload
			 */
			if (	( _response == 'ok' || _response == 'ok=1' ) ||
					( _response.indexOf('http://') > -1 ) ) return false;
			return true;
		}
		/**
		 * there was a fatal error communicating with the server
		 * @param	_e
		 */
		private function connection_error( s:String ):void 
		{
			if (on_error_callback != null)		on_error_callback( s );
			else								throw(new Error('com.oddcast.workshop.OA1_Uploader.connection_error() MISSING ON ERROR CALLBACK.'));
		}
		/**
		 * try to upload the same package again
		 * @param	_response
		 */
		private function current_packet_failed_upload( _response:String ):void 
		{
			if (upload_redundancy_allowed() )	recursive_upload_packet();
			else								on_error_callback('Error saving message. Cannot upload OA1 packet ' + uploading_index + ' of ' + packet_list.length + '.  ' + _response) 
		}
		private function current_packet_successfully_uploaded( _response:String ):void 
		{
			update_percent_loaders();
			reset_redundancy_count();
			uploading_index ++;
			if (uploading_index < packet_list.length)		recursive_upload_packet();
			else												all_packets_uploaded( _response );
		}
		/**
		 * percent of upload progress based on the num of packets left
		 */
		private function update_percent_loaders(  ):void
		{
			var percent:Number = uploading_index / ( packet_list.length - 1 );
			dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS,false,false, uploading_index, ( packet_list.length - 1 )));
			//dispatchEvent( new ProgressEvent(flash.event.ProgressEventProgressEvent ProcessingEvent( ProcessingEvent.PROGRESS, ProcessingEvent.SAVING, percent ) );
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
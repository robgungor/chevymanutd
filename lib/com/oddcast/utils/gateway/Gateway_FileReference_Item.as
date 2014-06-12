package com.oddcast.utils.gateway
{
	import com.oddcast.utils.Listener_Manager;
	import com.oddcast.workshop.Callback_Struct;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	public class Gateway_FileReference_Item implements IGateway_Item
	{
		/* current overall percent of all uploads */
		private var current_percent		:int = 0;
		private var file_reference:FileReference;
		private var pending_file_reference:Gateway_FileReferenceList_Pending_Item;
		/* listener manager for this single location */
		private var listener_manager	:Listener_Manager 	= new Listener_Manager();
		
		public function Gateway_FileReference_Item(  )
		{}
		
		/**
		 * external call to get this processes progress
		 * @return
		 */
		public function get cur_percent(  ):int
		{
			return current_percent;
		}
		
		public function start( 
								_callbacks:Callback_Struct, 
								_cancel_callback:Function,
								_file_filter:FileFilter,
								_progress_updated:Function, 
								_upload_image_script:String,
								_get_uploaded_image_script:String,
								_max_file_byte_size:Number,
								_min_file_byte_size:Number,
								_max_file_pixel_size:Number,
								_min_file_pixel_size:Number,
								_convert_uploaded_images:Boolean,
								_preselected_file_reference:FileReference = null
							):void
		{
			if ( request_is_valid() )
			{
				// if a file refence is already selected and ready to go then just upload it
				if (_preselected_file_reference)
				{
					file_reference = _preselected_file_reference;
					upload_selected_file();
				}
				// create a new file reference and select it
				else
				{
					file_reference = new FileReference();
					manage_browse_listeners( true );
					
					try // usually fails bc its not on a UIA (mouse click)
					{
						file_reference.browse( [_file_filter] );
					}
					catch(_e:Error)
					{
						manage_browse_listeners(false);
						browse_event_handler(new Event(Event.CANCEL));// handle it silently
					}
				}
			}
			else
				error( Gateway_Error.ERROR_FILE_REF_NOT_INITIALIZED );
				
			/**
			 * validates if we have enough information to proceed with the process
			 * @return
			 */
			function request_is_valid(  ):Boolean
			{
				return (
							_callbacks &&
							_callbacks.fin &&
							_file_filter &&
							_upload_image_script &&
							_upload_image_script.indexOf('://') > 0 &&
							_get_uploaded_image_script &&
							_get_uploaded_image_script.indexOf('://') > 0 &&
							_max_file_byte_size &&
							_min_file_byte_size &&
							_max_file_pixel_size &&
							_min_file_pixel_size
						);
			}
			function manage_browse_listeners( _add:Boolean ):void
			{
				if (_add)
				{
					listener_manager.add( file_reference, Event.SELECT, browse_event_handler, this);
					listener_manager.add( file_reference, Event.CANCEL, browse_event_handler, this);
				}
				else
				{
					listener_manager.remove( file_reference, Event.SELECT, browse_event_handler);
					listener_manager.remove( file_reference, Event.CANCEL, browse_event_handler);
				}
			}
			function browse_event_handler( _e:Event ):void
			{
				manage_browse_listeners( false );
				switch ( _e.type )
				{	
					case Event.SELECT:	
						upload_selected_file();	
						break;
					case Event.CANCEL:
						processing_complete();
						if (_cancel_callback != null)
							_cancel_callback();
						destroy();
						break;
				}
			}
			function error( _type:String, _error_msg:String = null, _error_code:String = null ):void
			{
				processing_complete();
				if (_callbacks && _callbacks.error != null)
				{
					var error_msg:String = _error_msg;
					var error_code:String = _error_code;
					var error_param:Object = new Object();
					error_param.details = _type;
					// customize the error for the workshop for convenience
					switch ( _type )
					{	
						case Gateway_Error.ERROR_FILE_REF_NOT_INITIALIZED:		error_code = '';		error_msg = 'Gateway File Reference List not initialized';	break;
						case Gateway_Error.ERROR_FILESIZE_TOO_BIG_BYTES:		error_code = 'fue002';	error_msg = 'File exceeds allowed size'; error_param.maxSizeMb = (_max_file_byte_size/1024/1024); break;
						case Gateway_Error.ERROR_FILESIZE_TOO_SMALL_BYTES:		error_code = 'fue001';	error_msg = 'File size is too small'; error_param.minSizeKb = (_min_file_byte_size/1024);	break;
						case Gateway_Error.ERROR_SECURITY_UPLOADING:			error_code = 'fue005';	error_msg = 'File cannot be opened or read'; break;
						case Gateway_Error.ERROR_UPLOADING_TO_SERVER:			error_code = 'fue003';	error_msg = 'Error uploading file';	break;
					}
					
					var error:Gateway_Error = new Gateway_Error( _type, error_msg, error_code, error_param ); 
					_callbacks.error( error );
				}
				destroy();
			}
			function upload_selected_file(  ):void
			{
				if (selected_file_is_valid())
					store_and_start_pending_file(file_reference);
				
				function store_and_start_pending_file( _file:FileReference ):void
				{
					pending_file_reference = new Gateway_FileReferenceList_Pending_Item(_file);
					manage_file_ref_listeners( _file, true );
					var upload_api:String = _upload_image_script + 
						'?sessId=' + pending_file_reference.session_key() + 
						'&minW=' + _min_file_pixel_size + 
						'&minH=' + _min_file_pixel_size +
						'&maxW=' + _max_file_pixel_size + 
						'&maxH=' + _max_file_pixel_size +
						'&convertImage=' + _convert_uploaded_images.toString();
					_file.upload( new URLRequest(upload_api) );
				}
				
				function manage_file_ref_listeners( _file:FileReference, _add:Boolean ):void
				{
					if (_add)
					{
						listener_manager.add( _file, Event.OPEN, handler_file_ref_open, this);
						listener_manager.add( _file, Event.COMPLETE, handler_file_ref_complete, this);
						listener_manager.add( _file, IOErrorEvent.DISK_ERROR, handler_file_ref_io_error, this);
						listener_manager.add( _file, IOErrorEvent.IO_ERROR, handler_file_ref_io_error, this);
						listener_manager.add( _file, IOErrorEvent.NETWORK_ERROR, handler_file_ref_io_error, this);
						listener_manager.add( _file, IOErrorEvent.VERIFY_ERROR, handler_file_ref_io_error, this);
						listener_manager.add( _file, ProgressEvent.PROGRESS, handler_file_ref_progress, this);
						listener_manager.add( _file, SecurityErrorEvent.SECURITY_ERROR, handler_file_ref_security_error, this);
					}
					else
					{
						listener_manager.remove( _file, Event.OPEN, handler_file_ref_open);
						listener_manager.remove( _file, Event.COMPLETE, handler_file_ref_complete);
						listener_manager.remove( _file, IOErrorEvent.DISK_ERROR, handler_file_ref_io_error);
						listener_manager.remove( _file, IOErrorEvent.IO_ERROR, handler_file_ref_io_error);
						listener_manager.remove( _file, IOErrorEvent.NETWORK_ERROR, handler_file_ref_io_error);
						listener_manager.remove( _file, IOErrorEvent.VERIFY_ERROR, handler_file_ref_io_error);
						listener_manager.remove( _file, ProgressEvent.PROGRESS, handler_file_ref_progress);
						listener_manager.remove( _file, SecurityErrorEvent.SECURITY_ERROR, handler_file_ref_security_error);
					}
				}
				
				function handler_file_ref_open( _e:Event ):void
				{
					var file:FileReference	= FileReference(_e.target);
				}
				function handler_file_ref_complete( _e:Event ):void
				{
					var file:FileReference	= FileReference(_e.target);
					pending_file_reference.retrieve_url( _get_uploaded_image_script, new Callback_Struct(item_url_retrieved, null, error ) );
					
					
					function item_url_retrieved(  ):void
					{
						if (pending_file_reference && pending_file_reference.uploaded_url)
						{
							if (_callbacks && _callbacks.fin != null)
								_callbacks.fin( new Gateway_FileReference_Result(pending_file_reference.uploaded_url, pending_file_reference.uploaded_url_thumb) );
						}
						processing_complete();
						destroy();
					}
				}
				/**
				 * independent files progress has been updated
				 * @param	_e
				 */
				function handler_file_ref_progress( _e:ProgressEvent ):void
				{
					var file:FileReference	= FileReference(_e.target);
					current_percent	= ( _e.bytesLoaded * 100 ) / _e.bytesTotal;
					if (current_percent == 100)	current_percent = 99;	// a little hack to keep the loader on screen
					if (_callbacks && _callbacks.progress != null)	// notify caller
						_callbacks.progress( current_percent );
					if (_progress_updated != null)	// notify gateway of this items progress
						_progress_updated();
				}
				function handler_file_ref_io_error( _e:IOErrorEvent ):void
				{
					error( Gateway_Error.ERROR_UPLOADING_TO_SERVER );
				}
				function handler_file_ref_security_error( _e:SecurityErrorEvent ):void
				{
					error( Gateway_Error.ERROR_SECURITY_UPLOADING );
				}
				
				function selected_file_is_valid(  ):Boolean
				{
					var file_meets_byte_restrictions:Boolean = true;
					if		(file_reference.size <= _min_file_byte_size)	{	error( Gateway_Error.ERROR_FILESIZE_TOO_SMALL_BYTES );	file_meets_byte_restrictions = false; }
					else if (file_reference.size > _max_file_byte_size)		{	error( Gateway_Error.ERROR_FILESIZE_TOO_BIG_BYTES );	file_meets_byte_restrictions = false; }
					return file_meets_byte_restrictions;
				}
			}
			function destroy(  ):void
			{
				if (listener_manager)
					listener_manager.remove_all_listeners_ever_added();
				listener_manager = null;
				file_reference = null;
				pending_file_reference = null;
				_callbacks = null;
				_cancel_callback = null;
				_file_filter = null;
				_progress_updated = null;
			}
			function processing_complete(  ):void 
			{	if (current_percent < 100)	// we dont have to tell them its done if its already at 100... it means factory was already been notified
				{	current_percent = 100;	// indicates that the loading for this item has finished
					if (_progress_updated != null)	_progress_updated();	// notify factory class if available
				}
			}
		}
	}
}
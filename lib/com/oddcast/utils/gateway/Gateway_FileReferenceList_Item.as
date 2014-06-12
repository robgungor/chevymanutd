package com.oddcast.utils.gateway 
{
	import com.oddcast.utils.Listener_Manager;
	import com.oddcast.workshop.*;
	
	import flash.events.*;
	import flash.net.*;

	/**
	 * ...
	 * @author Me^
	 */
	public class Gateway_FileReferenceList_Item implements IGateway_Item
	{
		/* current overall percent of all uploads */
		private var current_percent		:int = 0;
		private var file_ref_list		:FileReferenceList;
		/* listener manager for this single location */
		private var listener_manager	:Listener_Manager 	= new Listener_Manager();
		/* array of Gateway_FileReferenceList_Pending_Item */
		private var pending_files		:Array;
		
		public function Gateway_FileReferenceList_Item() 
		{}
		/**
		 * external call to get this processes progress
		 * @return
		 */
		public function get cur_percent(  ):int
		{
			return current_percent;
		}
		/**
		 * 
		 * @param	_callbacks
		 * @param	_cancel_callback
		 * @param	_max_files
		 * @param	_progress_updated
		 * @param	_upload_image_script
		 * @param	_get_uploaded_image_script
		 * @param	_max_file_byte_size
		 * @param	_min_file_byte_size
		 * @param	_max_file_pixel_size
		 * @param	_min_file_pixel_size
		 */
		public function start(
								_callbacks:Callback_Struct,
								_cancel_callback:Function,
								_file_filter:FileFilter,
								_max_files:int,
								_progress_updated:Function, 
								_upload_image_script:String,
								_get_uploaded_image_script:String,
								_max_file_byte_size:Number,
								_min_file_byte_size:Number,
								_max_file_pixel_size:Number,
								_min_file_pixel_size:Number,
								_convert_uploaded_images:Boolean
							):void
		{
			if ( request_is_valid() )
			{
				//_callbacks.fin(['http://www.freddysrevenge.co.uk/Finny.jpg']); // FAKE CALLBACK
				
				file_ref_list = new FileReferenceList();
				manage_browse_listeners( true );
				try // usually fails bc its not on a UIA (mouse click)
				{
					file_ref_list.browse( [_file_filter] );
				}
				catch(_e:Error)
				{
					manage_browse_listeners(false);
					browse_event_handler(new Event(Event.CANCEL));// handle it silently
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
							_max_files &&
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
					listener_manager.add( file_ref_list, Event.SELECT, browse_event_handler, this);
					listener_manager.add( file_ref_list, Event.CANCEL, browse_event_handler, this);
				}
				else
				{
					listener_manager.remove( file_ref_list, Event.SELECT, browse_event_handler);
					listener_manager.remove( file_ref_list, Event.CANCEL, browse_event_handler);
				}
			}
			function browse_event_handler( _e:Event ):void
			{
				manage_browse_listeners( false );
				switch ( _e.type )
				{	
					case Event.SELECT:	
						upload_selected_files();	
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
					switch ( _type )
					{	
						case Gateway_Error.ERROR_FILE_REF_NOT_INITIALIZED:		error_code = '';		error_msg = 'Gateway File Reference List not initialized';	break;
						case Gateway_Error.ERROR_FILESIZE_TOO_BIG_BYTES:		error_code = 'fue002';	error_msg = 'File exceeds allowed size'; error_param.maxSizeMb = (_max_file_byte_size/1024/1024); break;
						case Gateway_Error.ERROR_FILESIZE_TOO_SMALL_BYTES:		error_code = 'fue001';	error_msg = 'File size is too small'; error_param.minSizeKb = (_min_file_byte_size/1024);	break;
						case Gateway_Error.ERROR_SECURITY_UPLOADING:			error_code = 'fue005';	error_msg = 'File cannot be opened or read'; break;
						case Gateway_Error.ERROR_UPLOADING_TO_SERVER:			error_code = 'fue003';	error_msg = 'Error uploading file';	break;
						case Gateway_Error.ERROR_TOO_MANY_FILES_SELECTED:		error_code = 'fue007';	error_msg = 'Please select less than ' + _max_files + ' files';	error_param.max_files = _max_files; break;
					}
					
					var error:Gateway_Error = new Gateway_Error( _type, error_msg, error_code, error_param ); 
					_callbacks.error( error );
				}
				destroy();
			}
			function cancel_remaining_uploads_due_to_error():void
			{
				
			}
			function upload_selected_files(  ):void
			{
				if (selected_files_are_valid())
				{
					pending_files = new Array();
					for (var n:int = file_ref_list.fileList.length, i:int = 0; i < n; i++)
						store_and_start_pending_file(file_ref_list.fileList[i]);
				}
				
				function store_and_start_pending_file( _file:FileReference ):void
				{
					var pending_file:Gateway_FileReferenceList_Pending_Item = new Gateway_FileReferenceList_Pending_Item( _file );
					pending_files.push( pending_file );
					var file_ref_item:Gateway_FileReference_Item = new Gateway_FileReference_Item();
					file_ref_item.start( 
										new Callback_Struct(item_fin, item_progress, item_error),
										_cancel_callback,
										_file_filter,
										null, // we dont want the gateway to know, we need to tally the progress here and tell the gateway
										_upload_image_script,
										_get_uploaded_image_script,
										_max_file_byte_size,
										_min_file_byte_size,
										_max_file_pixel_size,
										_min_file_pixel_size,
										_convert_uploaded_images,
										_file
										);
					function item_fin(_result:Gateway_FileReference_Result):void
					{
						pending_file.uploaded_url = _result.full_url;
						pending_file.uploaded_url_thumb = _result.thumb_url;
						
						check_all_items_completed();
					}
					function item_progress(_percent:int):void
					{
						pending_file.percent = _percent;
						handler_file_ref_progress();
					}
					function item_error(_error:Gateway_Error):void
					{
						error( _error.type, _error.error_message, _error.error_code );
					}
					function check_all_items_completed():void
					{
						if (pending_files)
						{
							var i:int, n:int;
							LOOP: for (i = 0, n = pending_files.length; i<n; i++ )
							{
								var pending_item:Gateway_FileReferenceList_Pending_Item = pending_files[ i ];
								if (!pending_item.uploaded_url)
									return;// all items are not completed
								// break LOOP;
							}
							
							// all items are completed
							var uploaded_url_list:Array = new Array();
							if (pending_files) // this could have been destroyed previously due to an error
								for (n = pending_files.length, i = 0; i < n; i++)
								{
									var pending_file:Gateway_FileReferenceList_Pending_Item = pending_files[i];
									if (pending_file.uploaded_url)
										uploaded_url_list.push( new Gateway_FileReference_Result(pending_file.uploaded_url, pending_file.uploaded_url_thumb ) );
									else
										return;
								}
							if (_callbacks && _callbacks.fin != null)
								_callbacks.fin( uploaded_url_list );
							processing_complete();
							destroy();
						}
					}
				}
				
				function handler_file_ref_complete( _e:Event ):void
				{
					var file:FileReference	= FileReference(_e.target);
					for (var n:int = pending_files.length, i:int = 0; i < n; i++)
					{
						var pending_file_item:Gateway_FileReferenceList_Pending_Item = pending_files[i];
						if (pending_file_item.file.name == file.name)
						{
							pending_file_item.retrieve_url( _get_uploaded_image_script, new Callback_Struct(item_url_retrieved, null, error ) );
							return;
						}
					}
					
					function item_url_retrieved(  ):void
					{
						var uploaded_url_list:Array = new Array();
						if (pending_files) // this could have been destroyed previously due to an error
							for (var n:int = pending_files.length, i:int = 0; i < n; i++)
							{
								var pending_file:Gateway_FileReferenceList_Pending_Item = pending_files[i];
								if (pending_file.uploaded_url)
									uploaded_url_list.push( { url:pending_file.uploaded_url, thumb:pending_file.uploaded_url_thumb } );
								else
									return;
							}
						if (_callbacks && _callbacks.fin != null)
							_callbacks.fin( uploaded_url_list );
						processing_complete();
						destroy();
					}
				}
				/**
				 * independent files progress has been updated
				 * @param	_e
				 */
				function handler_file_ref_progress(  ):void
				{
					var total_percent:int	= 0;
					if (pending_files)
					{
						for (var n:int = pending_files.length, i:int = 0; i < n; i++)
						{
							// find the file whos progress was update it and save the percent for that file
							var pending_file_item:Gateway_FileReferenceList_Pending_Item = pending_files[i];
							
							// tally up all files percentages
							total_percent += pending_file_item.percent;
						}
						// calculate total percent per how many files exist
						total_percent = total_percent / pending_files.length;
						if (total_percent == 100)	total_percent = 99;	// a little hack to keep the loader on screen
						// save the total percent for querying by the UI
						current_percent = total_percent;
						if (_progress_updated != null)
							_progress_updated();
					}
				}
				function handler_file_ref_io_error( _e:IOErrorEvent ):void
				{
					error( Gateway_Error.ERROR_UPLOADING_TO_SERVER );
				}
				function handler_file_ref_security_error( _e:SecurityErrorEvent ):void
				{
					error( Gateway_Error.ERROR_SECURITY_UPLOADING );
				}
				
				function selected_files_are_valid(  ):Boolean
				{
					var files_meet_byte_restriction:Boolean = true;
					var files_meet_number_restriction:Boolean = true;
					var fileslist:Array = file_ref_list.fileList;		// 4 DEBUGING... REMOVE WHEN DONE
					if (file_ref_list && file_ref_list.fileList)
					{
						for (var n:int = file_ref_list.fileList.length, i:int = 0; i < n; i++)
						{
							var file:FileReference = file_ref_list.fileList[i];
							if		(file.size <= _min_file_byte_size)	{	error( Gateway_Error.ERROR_FILESIZE_TOO_SMALL_BYTES );	files_meet_byte_restriction = false;	break; }
							else if (file.size > _max_file_byte_size)	{	error( Gateway_Error.ERROR_FILESIZE_TOO_BIG_BYTES );	files_meet_byte_restriction = false;	break; }
						}
					}
					if (
							file_ref_list && 
							file_ref_list.fileList && 
							file_ref_list.fileList.length > _max_files
						)
					{
						files_meet_number_restriction = false;
						error( Gateway_Error.ERROR_TOO_MANY_FILES_SELECTED );
					}
					return (
								files_meet_byte_restriction &&
								file_ref_list &&
								file_ref_list.fileList &&
								file_ref_list.fileList.length <= _max_files
							);
				}
			}
			function destroy(  ):void
			{
				if (listener_manager)
					listener_manager.remove_all_listeners_ever_added();
				listener_manager = null;
				file_ref_list = null;
				pending_files = null;
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
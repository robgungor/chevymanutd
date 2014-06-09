package code.utils 
{
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.workshop.*;
	import com.oddcast.workshop.BGUploader;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;

	/**
	 * factory class for the uploader
	 * @author Me^
	 */
	public class Image_Uploader
	{
		/* class doing the uploading */
		private var uploader		:BGUploader;
		/* progress indication callbacks for callee */
		private var callback		:Callback_Struct;
		/* to not interrupt a current process */
		private var uploader_busy	:Boolean = false;
		
		public function Image_Uploader() 
		{}
		
		/**
		 * initialize the single bg uploader,
		 * NOTE using only one to avoid memory cleanup issues
		 */
		private function init_uploader():void 
		{	if (uploader)	return;
			
			uploader = new BGUploader();
			App.listener_manager.add_multiple_by_event(uploader, [
				BGEvent.SELECT, 
				AlertEvent.EVENT,
				ProgressEvent.PROGRESS,
				ProcessingEvent.STARTED,
				ProcessingEvent.DONE ]	, bg_uploader_event_handler, this);
			uploader.setByteSizeLimits(10 * 1024, 6 * 1024 * 1024);
			uploader.set_expiration_timeout(App.settings.UPLOAD_TIMEOUT_SEC);
		}
		private function bg_uploader_event_handler( _e:Event ):void 
		{	switch (_e.type) 
			{	case BGEvent.SELECT:			if(callback) var fin:Function = callback.fin;
												upload_finished_do_cleanup();
												if (fin != null)		fin( (_e as BGEvent).bg );
											break;
												
				case AlertEvent.EVENT:			var error:Function = callback.error;
												upload_finished_do_cleanup();
												if (error != null)		error( _e );
											break;
											
				case ProgressEvent.PROGRESS:	if (callback.progress != null)
												{	var prog_event:ProgressEvent = _e as ProgressEvent;
													var percent:Number = (prog_event.bytesTotal == 0) ? 0 : (prog_event.bytesLoaded / prog_event.bytesTotal) * 100;
													callback.progress( percent );
												}
											break;
											 
				case ProcessingEvent.STARTED:	break;
				case ProcessingEvent.DONE:		break;
			}
		}
		private function validate_and_start_uploader( _callback:Callback_Struct ):void 
		{	if (!_callback)			throw new Error ('Callback_Struct is needed for this operation');
			if (uploader_busy)		_callback.error( new AlertEvent(AlertEvent.ERROR, 'f9t506', 'Uploader is currently busy with another operation'));
			callback		= _callback;
			init_uploader();
			uploader_busy	= true;
		}
		private function upload_finished_do_cleanup():void 
		{	callback		= null;
			uploader_busy	= false;
		}
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** API */
		/**
		 * builds an aray of FileFilter for file reference browse
		 * @return
		 */
		public function get_file_upload_filter():Array 
		{	var filter:Array = new Array();
			filter.push(new FileFilter("Images (*.jpg *.jpeg *.gif *.png)", "*.jpg;*.jpeg;*.gif;*.png"));
			return(filter);
		}
		/**
		 * 
		 * @param	_file_ref
		 * @param	_callback	_fin param {BackgroundStruct}, _progress param {int} 0-100,  _error param  {AlertEvent}
		 */
		public function upload_file_ref( _file_ref:FileReference, _callback:Callback_Struct ):void 
		{	
			validate_and_start_uploader( _callback );
			uploader.uploadFile( _file_ref, true );
		}
		public function upload_binary( _callback:Callback_Struct, _binary:ByteArray, _file_type:String = null ):void
		{
			validate_and_start_uploader( _callback );
			uploader.uploadBinary( _binary, _file_type, true );
		}
		public function upload_url( _callback:Callback_Struct, _url:String, _check_for_server_capacity:Boolean = false ):void
		{
			validate_and_start_uploader( _callback );
			uploader.uploadUrl( _url, _check_for_server_capacity );
		}
		/**
		 * calls and cleans up the upload class for allowing another upload to take place
		 * errors can occur when the upload script 404s
		 */
		public function upload_failed():void 
		{
			upload_finished_do_cleanup();
			uploader.stopUploader();
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		*/
		
	}

}
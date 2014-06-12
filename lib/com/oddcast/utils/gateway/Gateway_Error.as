package com.oddcast.utils.gateway 
{
	
	/**
	 * ...
	 * @author me6
	 */
	public class Gateway_Error
	{
		public static const ERROR_FILESIZE_TOO_SMALL_BYTES	:String = 'ERROR_FILESIZE_TOO_SMALL_BYTES';
		public static const ERROR_FILESIZE_TOO_BIG_BYTES	:String = 'ERROR_FILESIZE_TOO_BIG_BYTES';
		public static const ERROR_FILE_REF_NOT_INITIALIZED	:String = 'ERROR_FILE_REF_NOT_INITIALIZED';
		public static const ERROR_SECURITY_UPLOADING		:String = 'ERROR_SECURITY_UPLOADING';
		public static const ERROR_UPLOADING_TO_SERVER		:String = 'ERROR_UPLOADING_TO_SERVER';
		public static const ERROR_RETRIEVING_FROM_SERVER	:String = 'ERROR_RETRIEVING_FROM_SERVER';
		public static const ERROR_TOO_MANY_FILES_SELECTED	:String = 'ERROR_TOO_MANY_FILES_SELECTED';
		
		/** type of error that occurred */
		public var type:String;
		/** error message */
		public var error_message:String;
		/** error code relative to workshop alert codes */
		public var error_code:String;
		/** error messages need dynamic parameters, eg: need a file larger than XXX */
		public var error_text_params:Object
		
		public function Gateway_Error(_type:String, _error_message:String = '', _error_code:String = '', _error_text_params:Object = null) 
		{
			type = _type;
			error_message = _error_message;
			error_code = _error_code;
			error_text_params = _error_text_params;
		}
		
	}

}
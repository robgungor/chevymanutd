package com.oddcast.utils 
{
	
	/**
	 * evaluates if the php response is valid or not
	 * @author Me^
	 */
	public class Eval_PHP_Response 
	{
		private var php_response : *;
		public var error_code : String;
		public var error_message : String;
		/**
		 * returns true if the php response is valid or not based on Chucks definitions
		 * @param	_php_response
		 */
		public function Eval_PHP_Response( _php_response:* )
		{
			error_code = '';
			error_message = '';
			php_response = _php_response;
		}
		public function is_response_valid(  ):Boolean 
		{
			/*
			sample of error xmls from all oddcast apis:
			<APIERROR CODE="100" ERRORSTR="Missing%20Required%20Data%3A%20Invalid%20door%20id."/>
			*/
			if (php_response == null || php_response == undefined)	return false;
			if (php_response is XML)
			{
				if (php_response == new XML(''))	// empty xml
				{	return false;
				}
				else if (php_response.name().toString() == "APIERROR")
				{	error_code = php_response.@CODE;
					error_message = unescape(php_response.@ERRORSTR);
					return false;
				}
				return true;
			}	
			else if (php_response is String)
			{
				if ( String(php_response).indexOf('Error') == 0 )
				{
					error_code = String(php_response).split('[')[1].split(']')[0];
					error_message = String(php_response).split(']')[1]
					return false;
				}
				return true;
			}
			return true;
		}
		
	}
	
}
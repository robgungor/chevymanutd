package com.oddcast.utils.gateway 
{
	import com.oddcast.workshop.*;
	
	import flash.net.*;
	import flash.system.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class Gateway_Request
	{
		public var url			:String;
		public var cb			:Callback_Struct;
		/** class type that is expected as a return ( Object | XML | String | Bitmap | etc )
		* null will cast the return to whatever is returned by the server */
		public var type			:Class;
		/** number of retries before submitting the error notification */
		public var retries		:int;
		/** for display type objects this will be applied */
		public var context		:LoaderContext;
		/** use a string for identification of this request... meaning... if you create multiple requests and submit them.. all using the same callback
		* this key will be passed with every request for your identification of the request */
		public var key			:*;
		/** flag indicating if this should be a background process not notifying the UI loader of its activity */
		public var background	:Boolean;
		/** on a fail a retry will occur with this delay (ms) */
		public var retry_delay	:Number = 1000;
		/** the data that will be uploaded, type: (  XML  |  URLVariables  |  ByteArray  ) */
		public var data_to_send	:*;
		/*8 requests are expected to timeout after a certain amount of time */
		public var timeout_ms	:Number = 60 * 1000;	// default 60 seconds
		/** get or post -- URLRequestMethod.POST v*/
		public var url_request_method:String = URLRequestMethod.POST;
		/** custom evaluation function for the response.  This method will be used to check the response of the call and if it failed retry if applicable
		* eg	function(_response:String):Boolean	{ return (_response.toLowerCase()=='it worked'); };
		*/
		public var stop_load	:Function;
		
		public var response_eval_method:Function;
		/**
		 * 
		 * @param	_url			url of the item to be loaded
		 * @param	_cb				callbacks for this specific event   [  fin(:Object, :Key(if passed))  |  progress(:int))  |   error(:String)  ]
		 * NOTE: progress function is not mandatory since processing window opens automatically
		 * @param	_retries		(OPTIONAL) retries to load the item if initially failed
		 * @param	_context		(OPTIONAL) loader context to use for the object loaded
		 * @param	_key			(OPTIONAL) a key (string, int etc) that will be passed back to the callbacks for identification in the requested locale
		 * @param	_background		(OPTIONAL) if this loading progress should not invoke visual display to the user, eg: a background process
		 */
		public function Gateway_Request( _url:String, _cb:Callback_Struct, _retries:int = 0, _context:LoaderContext = null, _key:* = null, _background:Boolean = false ) 
		{
			url			= _url;
			cb			= _cb;
			retries		= _retries;
			context		= _context;
			key			= _key;
			background	= _background;
		}
	}
}

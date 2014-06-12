package com.oddcast.workshop 
{
	/**
	 * ...
	 * @author Me^
	 */
	public class Callback_Struct
	{
		public var fin			:Function;
		public var progress		:Function;
		public var error		:Function;
		
		/**
		 * callback structure containing delegate functions
		 * NOTE, parameters passed in the callbacks are defined by the callback acceptor method
		 * @param	_fin		called when the process ends SUCESSFULLY
		 * @param	_progress	called when the progress is updated
		 * @param	_error		called when the process FAILS
		 */
		public function Callback_Struct( _fin:Function, _progress:Function = null, _error:Function = null )
		{	fin			= _fin;
			progress	= _progress;
			error		= _error;
		}
		
	}

}
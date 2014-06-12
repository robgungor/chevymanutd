package com.oddcast.workshop.engines
{
	public interface IWorkshop_Engine
	{
		/**
		 * initializes the engine with the necessary params 
		 * @param _config_data	obj custom build for the specific engine with all the necessary data such sa callbacks and urls
		 * 
		 */
		function set_config( _config_data:Object ):void;
		/**
		 * requests a job from the engine 
		 * @param _request_data	request type as specified in the engine data, eg .type, .callbacks etc.
		 * 
		 */		
		function request( _request_data:Object ):void;
	}
}
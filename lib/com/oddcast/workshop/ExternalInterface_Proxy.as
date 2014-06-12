package com.oddcast.workshop
{
	import flash.external.ExternalInterface;
	/**
	 *  
	 * @author Me^
	 * 
	 */
	public class ExternalInterface_Proxy
	{
		private static var sub_addCallback:Function;
		private static var sub_call:Function;
		private static var sub_available:Function;
		private static var sub_objectID:Function;
		private static var sub_get_marshallExceptions:Function;
		private static var sub_set_marshallExceptions:Function;
		
		
		
		
		
		/**
		 * substatute a specific method instead of the expected ExternalInterface.addCallback 
		 * @param _fun
		 * 
		 * @sample
		 	ExternalInterface_Proxy.substatute_addCallback( addCallback );
			function addCallback(funName:String, callBack:Function):void
			{
				ExternalInterface.addCallback.apply(this, arguments);
			}
		 */		
		public static function substatute_addCallback( _fun:Function ):void
		{
			if (_fun!=null && _fun.length==2)
				sub_addCallback = _fun;
			else
				throw new Error('ExternalInterface_Proxy :: addCallback method is not compliant or needs to accept 2 arguments');
		}
		/**
		 * substatute a specfic method instead of the expected ExternalInterface.call
		 * @param _fun
		 * 
		 * @sample
			ExternalInterface_Proxy.substatute_call( call );
			function call(funName:String, ...args):*
			{
				args.unshift(funName);
				return ExternalInterface.call.apply(this, args);
			}
		 */		
		public static function substatute_call( _fun:Function ):void
		{
			if (_fun!=null )
				sub_call = _fun;
			else
				throw new Error('ExternalInterface_Proxy :: call method is not compliant');
		}
		/**
		 * substatute a specfic method instead of the expected ExternalInterface.available
		 * @param _fun
		 * 
		 */		
		public static function substatute_available( _fun:Function ):void
		{
			if (_fun!=null)
				sub_available = _fun;
			else
				throw new Error('ExternalInterface_Proxy :: available method is not compliant');
		}
		/**
		 * substatute a specific method instead of the expected ExternalInterface.marshallExceptions 
		 * @param _get	get accessor replacement
		 * @param _set	set accessor replacement
		 * 
		 */		
		public static function substatute_marshallExceptions( _get:Function, _set:Function ):void
		{
			if (_get == null)
				throw new Error('ExternalInterface_Proxy :: marshallExceptions get method is not compliant');
			else if (_set == null)
				throw new Error('ExternalInterface_Proxy :: marshallExceptions set method is not compliant');
			else
			{
				sub_get_marshallExceptions = _get;
				sub_set_marshallExceptions = _set;
			}
		}
		
		
		
		
		
		
		/** see ExternalInterface docs */
		public static function get available():Boolean
		{
			if (sub_available!=null)
				return sub_available();
			return ExternalInterface.available;
		}
		/** see ExternalInterface docs */
		public static function addCallback( _fun_name:String, _closure:Function ):void 
		{
			if (sub_addCallback != null)
				sub_addCallback.apply(arguments.callee, arguments );
			else
				ExternalInterface.addCallback.apply(arguments.callee, arguments );
		}
		/** see ExternalInterface docs */
		public static function call( _fun_name:String, ...args ):*
		{
			args.unshift(_fun_name);
			if (sub_call != null)
				return sub_call.apply(args.callee, args );
			return ExternalInterface.call.apply(args.callee, args );
		}
		/** see ExternalInterface docs */
		public static function set marshallExceptions( _value:Boolean ):void
		{
			if (sub_set_marshallExceptions != null)
				sub_set_marshallExceptions( _value );
			else
				ExternalInterface.marshallExceptions = _value;
		}
		/** see ExternalInterface docs */
		public static function get marshallExceptions():Boolean
		{
			if (sub_get_marshallExceptions != null)
				return sub_get_marshallExceptions();
			return ExternalInterface.marshallExceptions;
		}
		/** see ExternalInterface docs */
		public static function get objectID():String
		{
			if (sub_objectID != null)
				return sub_objectID();
			return ExternalInterface.objectID;
		}
	}
}
package com.oddcast.workshop 
{
	import com.oddcast.utils.*;
	
	/**
	 * OddcastSharedObject wrapper designed for workshops
	 * reliant on ServerInfo.door
	 * @author Me^
	 */
	public class Shared_Object
	{
		
		/* shared object class used for IO */
		private var shared_obj			:OddcastSharedObject;
		/* indicate if we shared objects are allowed and accessible for IO on the current machine, default assume yes */
		private var can_access_so		:Boolean	= true;
		/* the date when this so will expire */
		private var expiration_date		:Date;
		
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INIT */
		/**
		 * Constructor
		 */
		public function Shared_Object() 
		{}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
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
		 * writes a shared object for this specific application (door)
		 * @param	_param	param name in the shared object where the data will be saved
		 * @param	_value	value of the param to be saved
		 */
		public function write_data( _param:String, _value:String ):void 
		{	init_so();
			if (can_access_so)
			{	var writeable_obj:Object = shared_obj.getDataObject();
				writeable_obj[_param] = _value;
				shared_obj.write( writeable_obj );
			}
		}
		/**
		 * reads a shared object for this specific application (door)
		 * @param	_param	param name in the shared object where the data will be saved
		 * @param	_value	value of the param to be saved
		 */
		public function read_data( _param:String ):String 
		{	init_so();
			if (can_access_so)
			{	return shared_obj.getDataObject()[_param];
			}
			return null;
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERNALS */
		private function init_so(  ):void 
		{	if (!shared_obj)
			{	var expiration_date	:Date		= new Date();
				expiration_date.setMonth(expiration_date.getMonth() + 1);
				
				try					{	shared_obj		= new OddcastSharedObject(ServerInfo.door.toString(), expiration_date );	}
				catch (_e:Error)	{	can_access_so	= false;
										trace('(Oo) :: Shared_Object.init_so()._e :', _e, typeof(_e));
									}
			}
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
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
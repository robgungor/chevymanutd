package com.oddcast.event 
{
	
	/**
	 * ...
	 * @author jachai
	 */
	public class EventDescription 
	{
		protected var _sDesc:String;
		protected var _oData:Object;
		protected var _nPercent:Number;
		
		public function EventDescription() 
		{
			
		}
		
		public function set percent(n:Number):void
		{
			_nPercent = n;
		}
		
		public function get percent():Number
		{
			return _nPercent;
		}
		
		public function set description(s:String):void
		{
			_sDesc = s;
		}
		
		public function get description():String
		{
			return _sDesc;
		}
		
		public function set obj(o:Object):void
		{
			_oData = o;
		}
		
		public function get obj():Object
		{
			return _oData;
		}
	}
	
}
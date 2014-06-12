package com.oddcast.workshop.fb3d.dataStructures 
{
	
	/**
	 * ...
	 * @author jachai
	 */		
	 
	public class ClickedAccessoryData
	{
		
		protected var _arrCategories:Array;
		protected var _sGeomName:String;
		protected var _iId:int;
		protected var _sName:String;
		
			
		public function ClickedAccessoryData() 
		{			
		}
		
		public function set id(i:int):void
		{
			_iId = i;
		}
		
		public function set name(s:String):void
		{
			_sName = s;
		}
		
		public function get id():int
		{
			return _iId;
		}
		
		public function get name():String
		{
			return _sName;
		}						
		
		public function set categories(arr:Array):void
		{
			_arrCategories = arr;
		}
		
		/**
		 * Gets an array of categories the clicked accessory is in
		 */
		public function get categories():Array
		{
			return _arrCategories;
		}
		
		public function set geomName(s:String):void
		{
			_sGeomName = s;
		}
		
		public function get geomName():String
		{
			return _sGeomName;
		}
		
	}
	
}
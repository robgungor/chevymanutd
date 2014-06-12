package com.oddcast.workshop.fb3d.dataStructures 
{
	import com.oddcast.oc3d.content.ICategoryProxy;
	import com.oddcast.oc3d.shared.Color;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class CategoryData 
	{
		
		private var _category:ICategoryProxy;
		private var _sThumbUrl:String;
		private var _sName:String;
		//applicatble only to colorable layers cateogries
		private var _cColor:Color;
		
		public function CategoryData(category:ICategoryProxy = null) 
		{			
			if (category != null)
			{
				_category = category;
			}
		}
		
		
		
		public function set thumbUrl(s:String):void
		{
			_sThumbUrl = s;
		}
		
		public function get thumbUrl():String
		{
			return _sThumbUrl;
		}
		
		public function get id():int
		{
			if (_category != null)
			{
				return _category.id();
			}
			else
			{
				return -1;
			}
		}
		
		public function get name():String
		{
			if (_category != null)
			{
				return _category.name();
			}
			else
			{
				return _sName;
			}
			
		}
		
		public function set name(s:String):void
		{
			_sName = s;
		}
		
		public function get color():Color
		{
			return _cColor;
			
		}
		
		public function set color(c:Color):void
		{
			_cColor = c;
		}
		
		public function get category():ICategoryProxy
		{
			return _category;
		}
		
	}
	
}
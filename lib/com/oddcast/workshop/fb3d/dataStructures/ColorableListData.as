package com.oddcast.workshop.fb3d.dataStructures 
{		
	import com.oddcast.oc3d.shared.Color;

	/**
	 * ...
	 * @author jachai
	 */
	public class ColorableListData 
	{
				
		private var _arrCategories:Vector.<CategoryData>;
		
		public function ColorableListData() 
		{			
			_arrCategories = new Vector.<CategoryData>();
		}				
		
		public function addCategory(c:CategoryData):void
		{
			//trace("MaterialConfigurationListData::addCategory " + s);
			for (var i:int = 0; i < _arrCategories.length; ++i)
			{
				if (_arrCategories[i].name == c.name)
				{
					return;
				}
			}
			_arrCategories.push(c);			
		}
				
		/**
		 * Get colorable categories
		 * @return Array of CategoryData objects
		 */
		public function getCategories():Vector.<CategoryData>
		{
			return _arrCategories;
		}								
	}
	
}
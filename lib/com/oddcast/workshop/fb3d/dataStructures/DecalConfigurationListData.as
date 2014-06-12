package com.oddcast.workshop.fb3d.dataStructures 
{
	import com.oddcast.oc3d.content.ICategory;
	import com.oddcast.oc3d.content.IDecalConfiguration;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class DecalConfigurationListData 
	{
		
		private var _arrDecalConfigurations:Array;
		private var _arrCategories:Vector.<CategoryData>;
		
		public function DecalConfigurationListData() 
		{
			_arrDecalConfigurations = new Array();
			_arrCategories = new Vector.<CategoryData>();
		}
		
		public function addDecalConfiguration(decalConfigData:DecalConfigurationData, categories:Vector.<CategoryData>):void
		{		
			for (var i:int = 0; i < categories.length;++i)
			{								
				var categoryName:String = categories[i].name;
				if (_arrDecalConfigurations[categoryName] == null)
				{
					_arrDecalConfigurations[categoryName] = new Array();
				}			
				_arrDecalConfigurations[categoryName].push(decalConfigData);
				addCategory(categories[i]);
			}			
		}
		
		private function addCategory(category:CategoryData):void
		{			
			for (var i:int = 0; i < _arrCategories.length; ++i)
			{
				if (_arrCategories[i].name == category.name)
				{
					return;
				}
			}
			_arrCategories.push(category);
		}
		
		/**
		 * Get decal configuration categories
		 * @return Array of CategoryData objects
		 */
		public function getCategories():Vector.<CategoryData>
		{
			return _arrCategories;
		}
				
		/**
		 * Get decal configurations
		 * @param	category - return decal configuration of a certain category or all if null
		 * @return Array of DecalConfigurationData objects or null if empty
		 */
		public function getDecalConfigurations(category:String = null):Array
		{
			if (category != null)
			{
				return _arrDecalConfigurations[category]				
			}
			else
			{
				var retArr:Array = new Array();					
				for (var cat:String in _arrDecalConfigurations)
				{
					for (var i:int = 0; i < _arrDecalConfigurations[cat].length; ++i)
					{
						retArr.push(_arrDecalConfigurations[cat][i]);
					}
				}
				return retArr;
			}
		}
		
	}
	
}
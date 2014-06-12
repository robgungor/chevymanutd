package com.oddcast.workshop.fb3d.dataStructures 
{
	import com.oddcast.oc3d.content.IMaterialConfiguration;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class MaterialConfigurationListData 
	{
		
		private var _arrMaterialConfigurations:Array;
		private var _arrCategories:Vector.<CategoryData>;
		
		public function MaterialConfigurationListData() 
		{
			_arrMaterialConfigurations = new Array();
			_arrCategories = new Vector.<CategoryData>();
		}
		
		public function addMaterialConfiguration(matConfigData:MaterialConfigurationData, category:CategoryData):void
		{
			//trace("MaterialConfigurationListData::addMaterialConfiguration " + matConfigData.name + ", " + category);
			if (_arrMaterialConfigurations[category.name] == null)
			{
				_arrMaterialConfigurations[category.name] = new Array();
			}			
			_arrMaterialConfigurations[category.name].push(matConfigData);
			addCategory(category);
		}
		
		private function addCategory(c:CategoryData):void
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
		 * Get material configuration categories
		 * @return Array of CategoryData objects
		 */
		public function getCategories():Vector.<CategoryData>
		{
			return _arrCategories;
		}
				
		/**
		 * Get material configurations
		 * @param	category - return material configuration of a certain category. if null returns them all
		 * @return Array of MaterialConfigurationData objects or null if empty
		 */
		public function getMaterialConfigurations(category:String = null):Array
		{
			if (category != null)
			{
				return _arrMaterialConfigurations[category]				
			}
			else
			{
				var retArr:Array = new Array();
				for (var cat:String in _arrMaterialConfigurations)
				{					
					for (var i:int = 0; i < _arrMaterialConfigurations[cat].length; ++i)
					{
						retArr.push(_arrMaterialConfigurations[cat][i]);
					}
				}
				return retArr;
			}
		}
		
	}
	
}
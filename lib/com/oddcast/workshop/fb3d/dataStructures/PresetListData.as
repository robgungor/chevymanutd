package com.oddcast.workshop.fb3d.dataStructures 
{
	import com.oddcast.oc3d.content.IPreset;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class PresetListData 
	{
		
		private var _arrPresets:Array;
		private var _arrCategories:Vector.<CategoryData>;
		
		public function PresetListData() 
		{
			_arrPresets = new Array();
			_arrCategories = new Vector.<CategoryData>();
		}
		
		public function addPreset(preset:PresetData, category:CategoryData):void
		{
			//trace("MaterialConfigurationListData::addMaterialConfiguration " + matConfigData.name + ", " + category);
			if (_arrPresets[category.name] == null)
			{
				_arrPresets[category.name] = new Array();
			}			
			_arrPresets[category.name].push(preset);
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
		 * Get presets
		 * @param	category - return presets of a certain category. if null returns them all
		 * @return Array of PresetData objects or null if empty
		 */
		public function getPresets(category:String = null):Array
		{
			if (category != null)
			{
				return _arrPresets[category]				
			}
			else
			{
				var retArr:Array = new Array();
				for (var cat:String in _arrPresets)
				{					
					for (var i:int = 0; i < _arrPresets[cat].length; ++i)
					{
						retArr.push(_arrPresets[cat][i]);
					}
				}
				return retArr;
			}
		}
		
	}
	
}
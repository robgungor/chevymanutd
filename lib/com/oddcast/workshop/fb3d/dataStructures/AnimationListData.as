package com.oddcast.workshop.fb3d.dataStructures 
{
	import com.oddcast.oc3d.content.IAnimationProxy;
	import com.oddcast.oc3d.content.ICategory;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class AnimationListData 
	{
		
		private var _arrAnimations:Array;
		private var _arrCategories:Vector.<CategoryData>;
		
		public function AnimationListData() 
		{
			_arrAnimations = new Array();
			_arrCategories = new Vector.<CategoryData>();
		}
		
		public function addAnimation(animationData:AnimationData, categories:Vector.<CategoryData>):void
		{	
			var categoryName:String;
			if (categories == null || categories.length === 0)
			{
				categoryName = "Unassigned";
				if (_arrAnimations[categoryName] == null)
				{
					_arrAnimations[categoryName] = new Array();
				}			
				_arrAnimations[categoryName].push(animationData);	
				var catData:CategoryData = new CategoryData();
				catData.name = categoryName;
				addCategory(catData);
			}
			else
			{
				for (var i:int = 0; i < categories.length;++i)
				{				
					categoryName = categories[i].name;
					if (_arrAnimations[categoryName] == null)
					{
						_arrAnimations[categoryName] = new Array();
					}			
					_arrAnimations[categoryName].push(animationData);
					addCategory(categories[i]);
				}									
			}
		}
		
		private function addCategory(c:CategoryData):void
		{			
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
		 * Get animation categories (animation bins)
		 * @return Array of CategoryData objects
		 */
		public function getCategories():Vector.<CategoryData>
		{
			return _arrCategories;
		}
				
		/**
		 * Get animations
		 * @param	category - return animations of a certain category. if null returns them all
		 * @return Array of AnimationData objects or null if empty
		 */
		public function getAnimations(category:String = null):Array
		{
			if (category != null && category!="")
			{
				return _arrAnimations[category]				
			}
			else
			{
				var retArr:Array = new Array();
				for (var cat:String in _arrAnimations)
				{
					for (var i:int = 0; i < _arrAnimations[cat].length; ++i)
					{
						retArr.push(_arrAnimations[cat][i]);
					}
				}
				return retArr;
			}
		}
		
	}
	
}
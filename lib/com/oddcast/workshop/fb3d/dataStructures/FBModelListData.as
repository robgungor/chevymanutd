package com.oddcast.workshop.fb3d.dataStructures 
{
	import com.oddcast.oc3d.content.IModel;
	
	/**
	 * ...
	 * @author bcohen
	 */
	public class FBModelListData 
	{
		private var _arrModels:Vector.<FBModelData>;
		
		public function FBModelListData() 
		{
			_arrModels = new Vector.<FBModelData>();
		}
		
		public function addModel(m:FBModelData):void
		{
			// BLAKE: jon, doing things this way will make models
			//        dissapear when there are two different models 
			//        that have the same name.
			//        why have this check at all?
			for (var i:int = 0; i < _arrModels.length; ++i)
			{
				if (_arrModels[i].name == m.name)
				{
					return;
				}
			}
			_arrModels.push(m);
		}
		
		/**
		 * Get models
		 * @return Array of FBModelData objects
		 */
		public function getModels():Vector.<FBModelData>
		{
			return _arrModels;
		}
	}
	
}
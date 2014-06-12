package com.oddcast.workshop.fb3d.dataStructures
{
	import com.oddcast.oc3d.content.IModel;
	import com.oddcast.oc3d.content.IModelProxy;

	/**
	 * ...
	 * @author bcohen
	 */
	public class FBModelData
	{
		private var _arrCategories:Vector.<CategoryData>;
		private var _sThumbUrl:String;
		private var _model:IModelProxy;
		
		public function FBModelData(model:IModelProxy=null)
		{
			_model = model;
			_arrCategories = new Vector.<CategoryData>();
		}
		
		public function get id():int 
		{
			return _model != null ? _model.id() : 0;
		}
		
		public function get name():String
		{
			return _model != null ? _model.name() : "";
		}

		public function set thumbUrl(s:String):void
		{
			_sThumbUrl = s;
		}
		
		public function get thumbUrl():String
		{
			return _sThumbUrl;
		}

		public function get model():IModelProxy
		{
			return _model;
		}

		public function addCategory(c:CategoryData):void
		{
			// BLAKE: jon, doing things this way will make categories
			//        dissapear when there are two different categories 
			//        that have the same name.
			//        why have this check at all?
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
		 * Get model's categories
		 * @return Array of CategoryData objects
		 */
		public function getCategories():Vector.<CategoryData>
		{
			return _arrCategories;
		}
	}
}
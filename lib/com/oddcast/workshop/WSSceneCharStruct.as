package com.oddcast.workshop {
	import com.oddcast.assets.structures.LoadedAssetStruct;
	import com.oddcast.host.api.FileData;
	import flash.geom.Matrix;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class WSSceneCharStruct {
		public var model:WSModelStruct;
		public var pos:Matrix;
		public var oa1File:FileData;
		public var ohUrl:String;
		public var keyFile:LoadedAssetStruct;
		public var id:int;
		protected static var tempCounter:int=1;
		private var _tempId:int=0;
		
		public function WSSceneCharStruct($model:WSModelStruct) {
			model = $model;
			_tempId=tempCounter;
			tempCounter++;
			if (model != null) id = model.charId;
		}
		
		public function get hasFileData():Boolean {
			return(model != null && model.is3d && oa1File != null);
		}
		
		public function get tempId():int {
			return(_tempId);
		}
		
		public function get hasId():Boolean {
			return(id>0);
		}
	}
	
}
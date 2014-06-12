package com.oddcast.vhost.accessories {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AccessoryData3D extends AccessoryData {
		
		private var fragmentArr:Array;
		public var accGroupName:String;
		public var zOrder:Number;
	
		public function AccessoryData3D(in_id:Number, in_name:String = "", in_typeId:int = -1, in_thumbUrl:String = "", incompatWith:int = 0) {
			super(in_id, in_name, in_typeId, in_thumbUrl, incompatWith);
			fragmentArr = new Array();
		}
		
		override public function get is3d():Boolean {
			return(true);
		}
	
		public function addFragment3d(fragment:AccessoryFragment) : void {
			fragmentArr.push(fragment);
		}
		
		override public function addFragment(type:String, url:String) : void {}
		override public function getFragmentUrl(s:String):String {
			return null;
		}
		
		override public function getFragments():Array {
			return(fragmentArr);
		}
	}
	
}
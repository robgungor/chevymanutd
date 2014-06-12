package com.oddcast.host.api {
	import com.oddcast.host.api.IFileProgress;
	import com.oddcast.host.api.FragmentURLs;
	import com.oddcast.host.api.IeditableValue;
	
	public class AccessoryDescription implements com.oddcast.host.api.IFileProgress, com.oddcast.host.api.IeditableValue{
		public function AccessoryDescription(fragmentsArray : Array = null,accessoryType : String = null,accessoryGroup : String = null,zOrder : Number = NaN) : void {  {
			this.fragmentsArray = fragmentsArray;
			this.accessoryType = accessoryType;
			this.accessoryGroup = accessoryGroup;
			this.zOrder = zOrder;
			this._fileProgresss = new Array();
		}}
		
		public var fragmentsArray : Array;
		public var accessoryType : String;
		public var accessoryGroup : String;
		public var zOrder : Number;
		public function getValue() : String {
			return null;
		}
		
		public function setValue(val : String) : void {
			null;
		}
		
		public var _fileProgresss : Array;
		public function getFileProgresss() : Array {
			return this._fileProgresss;
		}
		
		public function toString() : String {
			var retval : String = "Acc TypeID:" + this.accessoryType;
			{
				var _g : int = 0, _g1 : Array = this.fragmentsArray;
				while(_g < _g1.length) {
					var a : com.oddcast.host.api.FragmentURLs = _g1[_g];
					++_g;
					retval += "  " + a.toString();
				}
			}
			return retval;
		}
		
	}
}

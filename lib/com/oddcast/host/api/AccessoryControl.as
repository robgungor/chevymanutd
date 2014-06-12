package com.oddcast.host.api {
	
	public class AccessoryControl {
		public function AccessoryControl(type : String = null,plabel : String = null) : void {  {
			this.controlType = type;
			this.plabel = plabel;
		}}
		
		public var controlType : String;
		public var plabel : String;
		static public var MORPH : String = "MORPH";
		static public var OVERLAY : String = "OVERLAY";
		static public var TRANSPARANCY : String = "TRANSPARANCY";
		static public var COLOR : String = "COLOR";
		static public var INVISIBLE : String = "INVISIBLE";
	}
}

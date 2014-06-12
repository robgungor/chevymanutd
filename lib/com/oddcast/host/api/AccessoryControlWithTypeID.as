package com.oddcast.host.api {
	
	import com.oddcast.host.api.AccessoryControl;
	public class AccessoryControlWithTypeID extends com.oddcast.host.api.AccessoryControl {
		public function AccessoryControlWithTypeID(type : String = null,plabel : String = null,accessoryTypeID : String = null) : void {  {
			super(type,plabel);
			this.accessoryTypeID = accessoryTypeID;
		}}
		
		public var accessoryTypeID : String;
	}
}

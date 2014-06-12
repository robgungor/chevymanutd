package com.oddcast.workshop {
	
	/**
	* @author Sam Myer
	* 
	* data structure used for changing the host color, containing data to be transmitted to the engine
	*/
	public class HostColorData {
		public var name:String;
		public var type:String;
		public var value:uint;
		
		public static const EDITOR_COLOR:String = "__editor";
		
		public function HostColorData(in_name:String,in_type:String,in_value:uint) {
			name=in_name;
			type=in_type;
			value=in_value;
		}
	}
	
}
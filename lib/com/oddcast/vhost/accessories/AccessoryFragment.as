package com.oddcast.vhost.accessories {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AccessoryFragment {
		public var id:int;
		public var baseUrl:String;
		public var type:String;
		public var url:String;
		
		public function AccessoryFragment($type:String, $url:String, $id:int = 0, $baseUrl:String = null) {
			type = $type;
			url = $url;
			id = $id;
			baseUrl = $baseUrl;
		}
	}
	
}
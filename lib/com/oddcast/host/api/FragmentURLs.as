package com.oddcast.host.api {
	public class FragmentURLs {
		public function FragmentURLs() : void {
			null;
		}
		
		public var fragName : String;
		public var baseURL : String;
		public var imageURL : String;
		public function setAllURLs(fragName : String,imageURL : String,baseURL : String) : com.oddcast.host.api.FragmentURLs {
			this.setURL(FRAG_NAME,fragName);
			this.setURL(ACC_IMAGE,imageURL);
			this.setURL(ACC_BASE,baseURL);
			return this;
		}
		
		public function getFragName() : String {
			return this.fragName;
		}
		
		public function getURL(index : int) : String {
			var retval : String = NULL_STRING;
			switch(index) {
			case ACC_IMAGE:{
				retval = this.imageURL;
			}break;
			case ACC_BASE:{
				retval = this.baseURL;
			}break;
			}
			if(retval == NULL_STRING) return null;
			return retval;
		}
		
		public function setURL(index : int,url : String) : void {
			switch(index) {
			case FRAG_NAME:{
				this.fragName = url;
			}break;
			case ACC_IMAGE:{
				this.imageURL = url;
			}break;
			case ACC_BASE:{
				this.baseURL = url;
			}break;
			}
		}
		
		public function toString() : String {
			return "name:" + this.fragName + " base:" + this.baseURL + " image:" + this.imageURL;
		}
		
		static public var FRAG_NAME : int = 0;
		static public var ACC_IMAGE : int = 1;
		static public var ACC_BASE : int = 2;
		static protected var NULL_STRING : String = "null";
	}
}

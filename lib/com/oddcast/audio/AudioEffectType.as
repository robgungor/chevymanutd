package com.oddcast.audio {
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AudioEffectType {
		public var typeId:String;
		public var typeName:String
		
		public function AudioEffectType($typeId:String,$typeName:String) {
			typeId = $typeId;
			typeName = $typeName;
		}
	}
	
}
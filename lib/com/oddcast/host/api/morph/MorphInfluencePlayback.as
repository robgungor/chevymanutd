package com.oddcast.host.api.morph {
	
	public class MorphInfluencePlayback {
		public function MorphInfluencePlayback(globalWeight : Number = NaN) : void {  {
			null;
			this.setGlobalWeight(globalWeight);
		}}
		
		public var globalWeight : Number;
		public var plabel : String;
		public function setGlobalWeight(globalWeight : Number) : void {
			this.globalWeight = globalWeight;
		}
		
	}
}

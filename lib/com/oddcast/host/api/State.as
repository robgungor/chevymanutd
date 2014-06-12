package com.oddcast.host.api {
	import com.oddcast.host.api.AccessoryState;
	import com.oddcast.host.api.Anim;
	import com.oddcast.host.api.AccessoryControlWithTypeID;
	
	public class State {
		public function State(name : String = null) : void {  {
			this.name = name;
			this.aAnim = new Array();
		}}
		
		public var name : String;
		public function fillBlank(accessoryControls : Array,endTime : Number) : void {
			var _g : int = 0;
			while(_g < accessoryControls.length) {
				var acc : com.oddcast.host.api.AccessoryControlWithTypeID = accessoryControls[_g];
				++_g;
				this.aAnim[this.aAnim.length] = new com.oddcast.host.api.Anim(acc,endTime);
			}
		}
		
		public function populate(animLabel : String,weight : Number,endTime : Number,startWeight : * = null,startTime : * = null) : void {
			var anim : com.oddcast.host.api.Anim = this.findAnim(animLabel);
			if(anim != null) {
				anim.endTime = endTime;
				anim.weight = weight;
				if(startWeight != null) anim.startWeight = startWeight;
				if(startTime != null) anim.startTime = startTime;
			}
		}
		
		public function populateOff(animLabel : String,endTime : * = null) : void {
			if(endTime == null) endTime = com.oddcast.host.api.AccessoryState.INSTANTLY;
			this.populate(animLabel,1.0,endTime);
		}
		
		public function populateInstantOn(animLabel : String) : void {
			this.populate(animLabel,0.0,com.oddcast.host.api.AccessoryState.INSTANTLY);
		}
		
		public function trigger() : Array {
			var accTweens : Array = new Array();
			{
				var _g : int = 0, _g1 : Array = this.aAnim;
				while(_g < _g1.length) {
					var a : com.oddcast.host.api.Anim = _g1[_g];
					++_g;
					accTweens[accTweens.length] = a.trigger();
				}
			}
			return accTweens;
		}
		
		protected function findAnim(animLabel : String) : com.oddcast.host.api.Anim {
			{
				var _g : int = 0, _g1 : Array = this.aAnim;
				while(_g < _g1.length) {
					var a : com.oddcast.host.api.Anim = _g1[_g];
					++_g;
					if(a.control.plabel == animLabel) return a;
				}
			}
			null;
			return null;
		}
		
		protected var aAnim : Array;
	}
}

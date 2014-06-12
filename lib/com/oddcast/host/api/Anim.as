package com.oddcast.host.api {
	import com.oddcast.host.api.AccessoryTween;
	
	import com.oddcast.host.api.AccessoryControl;
	public class Anim {
		public function Anim(control : com.oddcast.host.api.AccessoryControl = null,endTime : Number = NaN) : void {  {
			this.control = control;
			this.weight = 0;
			this.endTime = endTime;
			this.startWeight = FROM_CURRENT_POSITION;
			this.startTime = 0.0;
		}}
		
		public var control : com.oddcast.host.api.AccessoryControl;
		public var startWeight : Number;
		public var weight : Number;
		public var startTime : Number;
		public var endTime : Number;
		public function trigger() : com.oddcast.host.api.AccessoryTween {
			var tween : com.oddcast.host.api.AccessoryTween = new com.oddcast.host.api.AccessoryTween(this.control.plabel,this.startTime,this.endTime);
			tween.setValues(this.startWeight,this.weight);
			return tween;
		}
		
		static public var FROM_CURRENT_POSITION : Number = -1.0;
	}
}

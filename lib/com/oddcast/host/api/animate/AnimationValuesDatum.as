package com.oddcast.host.api.animate {
	
	public class AnimationValuesDatum {
		public function AnimationValuesDatum() : void {  {
			this.value = 0;
			this.lastValue = DEFAULT_LAST_VALUE;
		}}
		
		public function set(f : Number) : void {
			this.value = f;
		}
		
		public function get() : Number {
			return this.value;
		}
		
		public function isChanged(diff : Number = 0.01) : Boolean {
			if(Math.abs(this.value - this.lastValue) >= diff) {
				this.lastValue = this.value;
				return true;
			}
			return false;
		}
		
		public function copy(from : com.oddcast.host.api.animate.AnimationValuesDatum) : com.oddcast.host.api.animate.AnimationValuesDatum {
			this.value = from.value;
			this.lastValue = from.lastValue;
			return this;
		}
		
		protected var value : Number;
		protected var lastValue : Number;
		static protected var DEFAULT_LAST_VALUE : Number = -123456.789;
	}
}

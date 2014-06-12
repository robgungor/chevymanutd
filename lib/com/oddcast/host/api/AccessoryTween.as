package com.oddcast.host.api {
	
	public class AccessoryTween {
		public function AccessoryTween(plabel : String = null,startTime : Number = NaN,endTime : Number = NaN) : void {  {
			this.plabel = plabel;
			this.startTime = startTime;
			this.endTime = endTime;
			this.startValue = 0.0;
			this.endValue = 1.0;
		}}
		
		public var plabel : String;
		public var startTime : Number;
		public var endTime : Number;
		public var startValue : Number;
		public var endValue : Number;
		public function setValues(startValue : Number,endValue : Number) : void {
			this.startValue = startValue;
			this.endValue = endValue;
		}
		
		public function setValuesAsColors(startColor : int,endColor : int) : void {
			this.setValues(colorToFloat(startColor),colorToFloat(endColor));
		}
		
		static public function setInstantly(plabel : String,value : Number) : com.oddcast.host.api.AccessoryTween {
			var retval : com.oddcast.host.api.AccessoryTween = new com.oddcast.host.api.AccessoryTween(plabel,0.0,0.0);
			retval.setValues(value,value);
			return retval;
		}
		
		static public var CONVERSION : int = 16777216;
		static public function colorToFloat(color : int) : Number {
			return (color & 16777215) / CONVERSION;
		}
		
		static public function floatToColor(float : Number) : int {
			return Math.round(float * CONVERSION);
		}
		
	}
}

 
	package com.oddcast.event
	{
		import flash.events.Event;
		
		public class ScrollEvent extends Event 
		{    
			private var _percent:Number;
			private var _stepNum:uint;
			
			public static var SCROLL:String="scrollChanged";
			public static var RELEASE:String="scrollReleased";
			
			public function ScrollEvent(type:String,in_percent:Number,in_stepNum:uint=0) 
			{				
				super(type);
				_percent=in_percent;
				_stepNum=in_stepNum;
			}
			
			public function get percent():Number {
				return(_percent);
			}
			
			public function get step():uint {
				return(_stepNum);
			}
			
			public override function clone():Event {
				return new ScrollEvent(type,percent,step);
			}
		}
    }


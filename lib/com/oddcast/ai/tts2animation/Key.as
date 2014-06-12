package com.oddcast.ai.tts2animation
{
	
	/**
	 * ...
	 * @author Jake 
	 * 3/10/2011 11:02 AM
	 */
	public class Key {
		public function Key() {
			
		}
		
		public function init( time			:int,
							  aniName		:String,
							  timeScaler	:Number,
							  interrupts	:Boolean,
							  beforeString  :String = "",
							  afterString   :String = ""):Key {
			this.time = time;
			this.aniName = aniName;
			this.timeScaler = timeScaler;
			setInterrupts(interrupts); 
			this.beforeString = beforeString;
			this.afterString = afterString;
			return this;
		}
		
		public function serialize():String {
						
			var interruptsString = (interrupts)?"t":"f";
			
			return  	"(key " 						+
						time 						+
						" \"" + aniName + "\" " 	+
						timeScaler 					+
						" #" +interruptsString 		+
						" " + beforeString 			+
						" " + afterString			+
						") ";

			//(playlist (key 0 "Fall" 1 #t (before 1 2) (after)) (key 2000 "Fall" 1 #t) (key 2500 "Fall" 0.25 #t))
			  		
		}
		
		public function setInterrupts(v:Boolean) { interrupts = v; }
		
		var time			:int;     public function getTime():int { return time; }
		var aniName			:String;
		var timeScaler		:Number;
		var interrupts	:Boolean;
		var beforeString  	:String;
		var afterString   	:String;
	}
}
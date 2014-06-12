package com.oddcast.util {
	public class FSM {
		public function getState() : int {
			return this.state;
		}
		
		public function setState(state : int) : void {
			this.state = state;
		}
		
		public function incState() : void {
			this.setState(this.state + 1);
		}
		
		protected var state : int;
		static protected var INCREMENTOR : int = 0;
	}
}

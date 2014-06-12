package com.oddcast.host.api {
	import com.oddcast.host.api.State;
	import com.oddcast.host.api.AccessoryTween;
	import com.oddcast.host.api.IEditorAPI;
	
	public class AccessoryState {
		public function AccessoryState(type : String = null) : void {  {
			this.type = type;
			this.currState = -1;
		}}
		
		public function initStates(editorAPI : com.oddcast.host.api.IEditorAPI,defaultTransitionTime : Number) : int {
			this.accessoryControls = editorAPI.getAccessoryControls(this.type);
			this.aStates = new Array();
			return this.aStates.length;
		}
		
		public function getTotalStates() : int {
			return this.aStates.length;
		}
		
		public function getCurrentState() : int {
			return this.currState;
		}
		
		public function getCurrentStateName() : String {
			if(this.currState < 0) return null;
			return this.aStates[this.currState].name;
		}
		
		public function setStateByIndex(editorAPI : com.oddcast.host.api.IEditorAPI,index : int) : int {
			if(index >= 0 && index < this.aStates.length) {
				if(index != this.currState) {
					var state : com.oddcast.host.api.State = this.aStates[index];
					null;
					var accTweens : Array = state.trigger();
					{
						var _g : int = 0;
						while(_g < accTweens.length) {
							var tween : com.oddcast.host.api.AccessoryTween = accTweens[_g];
							++_g;
							if(tween != null) editorAPI.setAccessoryAnimation(this.type,tween);
						}
					}
					this.currState = index;
				}
			}
			return this.currState;
		}
		
		protected function createBlankState(name : String,endTime : Number) : com.oddcast.host.api.State {
			var state : com.oddcast.host.api.State = new com.oddcast.host.api.State(name);
			state.fillBlank(this.accessoryControls,endTime);
			this.aStates[this.aStates.length] = state;
			return state;
		}
		
		protected var type : String;
		protected var accessoryControls : Array;
		protected var aStates : Array;
		protected var currState : int;
		static public var INSTANTLY : Number = 0.0;
	}
}

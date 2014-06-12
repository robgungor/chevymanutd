package com.oddcast.host.api {
	import com.oddcast.host.api.State;
	import com.oddcast.host.api.IEditorAPI;
	
	import com.oddcast.host.api.AccessoryState;
	public class JetHeadphonesAccessoryState extends com.oddcast.host.api.AccessoryState {
		public function JetHeadphonesAccessoryState(type : String = null) : void {  {
			super(type);
		}}
		
		public override function initStates(editorAPI : com.oddcast.host.api.IEditorAPI,defaultTransitionTime : Number) : int {
			super.initStates(editorAPI,defaultTransitionTime);
			var state : com.oddcast.host.api.State = this.createBlankState("state_0",defaultTransitionTime);
			state.populate("jetheadPhones_texture_no_keyboard_overlay",1.0,defaultTransitionTime);
			state.populateOff("jetPipes_invisible",defaultTransitionTime);
			state.populate("pipes_large_zero_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("state_Keyboard_1",defaultTransitionTime);
			state.populateOff("jetPipes_invisible",defaultTransitionTime);
			state.populate("pipes_large_zero_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("state_HalfPipes_2",defaultTransitionTime);
			state.populateInstantOn("jetPipes_invisible");
			state.populate("pipes_large_zero_blend",.30,defaultTransitionTime);
			state = this.createBlankState("state_FullPipes_3",defaultTransitionTime);
			state.populateInstantOn("jetPipes_invisible");
			return this.aStates.length;
		}
		
	}
}

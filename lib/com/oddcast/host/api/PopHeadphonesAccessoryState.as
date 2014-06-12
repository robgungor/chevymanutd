package com.oddcast.host.api {
	import com.oddcast.host.api.State;
	import com.oddcast.host.api.IEditorAPI;
	
	import com.oddcast.host.api.AccessoryState;
	public class PopHeadphonesAccessoryState extends com.oddcast.host.api.AccessoryState {
		public function PopHeadphonesAccessoryState(type : String = null) : void {  {
			super(type);
		}}
		
		public override function initStates(editorAPI : com.oddcast.host.api.IEditorAPI,defaultTransitionTime : Number) : int {
			super.initStates(editorAPI,defaultTransitionTime);
			var instantly : Number = 0.0;
			var state : com.oddcast.host.api.State = this.createBlankState("state_0",defaultTransitionTime);
			state.populate("pop_lights_zero_blend",1.0,defaultTransitionTime);
			state.populateOff("pop_feathers_invisible");
			state.populateOff("pop_lights_invisible");
			state.populate(POP_BUBBLEBUM_FULL_BLEND,0.0,com.oddcast.host.api.AccessoryState.INSTANTLY);
			state = this.createBlankState("bubblegum_1",defaultTransitionTime);
			state.populateOff("pop_feathers_invisible");
			state.populate(POP_BUBBLEBUM_FULL_BLEND,1.0,defaultTransitionTime * 2,0.0);
			state.populate("pop_bubble_invisible",1.0,defaultTransitionTime * 2,0.0,0);
			state.populate("pop_lights_zero_blend",1.0,defaultTransitionTime * 2,null,defaultTransitionTime);
			state.populate("pop_headphone_lights_off_overlay",1.0,defaultTransitionTime);
			state.populate("pop_feathers_zero_blend",1.0,defaultTransitionTime);
			state.populateOff("pop_lights_invisible",defaultTransitionTime * 2);
			state.populate("pop_lights_closed_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("lightsup_2",defaultTransitionTime);
			state.populateOff("pop_bubble_invisible");
			state.populate("pop_bubblegum_zero_blend",1.0,defaultTransitionTime);
			state.populate("pop_lights_closed_blend",0,defaultTransitionTime * 2,null,defaultTransitionTime);
			state.populate("pop_headphone_lights_off_overlay",0.0,defaultTransitionTime * 2,null,defaultTransitionTime);
			state.populate("pop_feathers_zero_blend",1.0,defaultTransitionTime);
			state.populateOff("pop_feathers_invisible",defaultTransitionTime);
			state = this.createBlankState("wings_3",defaultTransitionTime);
			state.populateOff("pop_bubble_invisible");
			state.populate("pop_bubblegum_zero_blend",1.0,defaultTransitionTime);
			state.populate("pop_lights_closed_blend",0,defaultTransitionTime * 2,null,defaultTransitionTime);
			state.populate("pop_headphone_lights_off_overlay",0.0,defaultTransitionTime * 2,null,defaultTransitionTime);
			return this.aStates.length;
		}
		
		static protected var POP_BUBBLEBUM_FULL_BLEND : String = "pop_bubblegum_zero_blend";
	}
}

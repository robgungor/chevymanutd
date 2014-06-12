package com.oddcast.host.api {
	import com.oddcast.host.api.State;
	import com.oddcast.host.api.IEditorAPI;
	
	import com.oddcast.host.api.AccessoryState;
	public class DJHeadphonesAccessoryState extends com.oddcast.host.api.AccessoryState {
		public function DJHeadphonesAccessoryState(type : String = null) : void {  {
			super(type);
		}}
		
		public override function initStates(editorAPI : com.oddcast.host.api.IEditorAPI,defaultTransitionTime : Number) : int {
			super.initStates(editorAPI,defaultTransitionTime);
			var state : com.oddcast.host.api.State = this.createBlankState("state_0",defaultTransitionTime);
			state.populateOff("hiphopSpeakers_invisible",defaultTransitionTime);
			state.populate("dj_speakers_zero_blend",1.0,defaultTransitionTime);
			state.populate("dj_headphones_squash_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("expandedDisks_1",defaultTransitionTime);
			state.populateOff("hiphopSpeakers_invisible",defaultTransitionTime);
			state.populate("dj_speakers_zero_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("halfSpeakers_2",defaultTransitionTime);
			state.populateInstantOn("hiphopSpeakers_invisible");
			state.populate("dj_speakers_mid_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("fullSpeakers_3",defaultTransitionTime);
			state.populateInstantOn("hiphopSpeakers_invisible");
			state = this.createBlankState("goldlSpeakers_4",defaultTransitionTime);
			state.populateInstantOn("hiphopSpeakers_invisible");
			state.populate("dj_headphone_gold_overlay",1.0,defaultTransitionTime);
			state.populate("dj_speakers_gold_overlay",1.0,defaultTransitionTime);
			return this.aStates.length;
		}
		
	}
}

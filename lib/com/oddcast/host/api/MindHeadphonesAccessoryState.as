package com.oddcast.host.api {
	import com.oddcast.host.api.State;
	import com.oddcast.host.api.IEditorAPI;
	
	import com.oddcast.host.api.AccessoryState;
	public class MindHeadphonesAccessoryState extends com.oddcast.host.api.AccessoryState {
		public function MindHeadphonesAccessoryState(type : String = null) : void {  {
			super(type);
		}}
		
		public override function initStates(editorAPI : com.oddcast.host.api.IEditorAPI,defaultTransitionTime : Number) : int {
			super.initStates(editorAPI,defaultTransitionTime);
			var EARPANELS_BLEND : String = "mind_earmuf_pannels_slide_blend";
			var TOPPANELS_BLEND : String = "mind_top_pannels_slide_blend";
			var state : com.oddcast.host.api.State = this.createBlankState("state_0",defaultTransitionTime);
			state.populateOff("mind_EarMufPanels_invisible",defaultTransitionTime);
			state.populate(EARPANELS_BLEND,1.0,defaultTransitionTime);
			state.populateOff("mind_TopPanels_invisible",defaultTransitionTime);
			state.populate(TOPPANELS_BLEND,1.0,defaultTransitionTime);
			state.populateOff("mind_Panels_invisible",defaultTransitionTime);
			state.populate("mind_side_panels_zero_blend",1.0,defaultTransitionTime);
			state.populateOff("mind_Tubes_invisible",defaultTransitionTime);
			state.populate("mind_top_lights_zero_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("state_earPanels_1",defaultTransitionTime);
			state.populateOff("mind_TopPanels_invisible",defaultTransitionTime);
			state.populate(TOPPANELS_BLEND,1.0,defaultTransitionTime);
			state.populateOff("mind_Panels_invisible",defaultTransitionTime);
			state.populate("mind_side_panels_zero_blend",1.0,defaultTransitionTime);
			state.populateOff("mind_Tubes_invisible",defaultTransitionTime);
			state.populate("mind_top_lights_zero_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("state_topPanels_2",defaultTransitionTime);
			state.populateOff("mind_Panels_invisible",defaultTransitionTime);
			state.populate("mind_side_panels_zero_blend",1.0,defaultTransitionTime);
			state.populateOff("mind_Tubes_invisible",defaultTransitionTime);
			state.populate("mind_top_lights_zero_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("state_Lights_3",defaultTransitionTime);
			state.populateOff("mind_Panels_invisible",defaultTransitionTime);
			state.populate("mind_side_panels_zero_blend",1.0,defaultTransitionTime);
			state = this.createBlankState("state_All_4",defaultTransitionTime);
			return this.aStates.length;
		}
		
	}
}

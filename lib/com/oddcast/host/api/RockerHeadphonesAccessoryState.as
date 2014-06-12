package com.oddcast.host.api {
	import com.oddcast.host.api.State;
	import com.oddcast.host.api.IEditorAPI;
	
	import com.oddcast.host.api.AccessoryState;
	public class RockerHeadphonesAccessoryState extends com.oddcast.host.api.AccessoryState {
		public function RockerHeadphonesAccessoryState(type : String = null) : void {  {
			super(type);
		}}
		
		public override function initStates(editorAPI : com.oddcast.host.api.IEditorAPI,defaultTransitionTime : Number) : int {
			super.initStates(editorAPI,defaultTransitionTime);
			var state : com.oddcast.host.api.State = this.createBlankState("ball_0",defaultTransitionTime);
			state.populate("tiger_ball_blend",1.0,defaultTransitionTime);
			state.populate("ball_headphones_overlay",1.0,defaultTransitionTime);
			state.populate("tiger_headBand_studs_zero_blend",1.0,defaultTransitionTime);
			state.populate("tiger_earMuf_studs_zero_blend",1.0,defaultTransitionTime);
			state.populateOff("teethAndStuds_invisible",defaultTransitionTime);
			state = this.createBlankState("kitty_1",defaultTransitionTime);
			state.populate("tiger_kitty_blend",1.0,defaultTransitionTime);
			state.populate("kitten_headphones_overlay",1.0,defaultTransitionTime);
			state.populate("tiger_headBand_studs_zero_blend",1.0,defaultTransitionTime);
			state.populate("tiger_earMuf_studs_zero_blend",1.0,defaultTransitionTime);
			state.populateOff("teethAndStuds_invisible",defaultTransitionTime);
			state = this.createBlankState("closed_tiger_2",defaultTransitionTime);
			state.populate("tiger_close_mouth_blend",1.0,defaultTransitionTime);
			state.populate("tiger_headBand_studs_zero_blend",1.0,defaultTransitionTime);
			state.populateInstantOn("teethAndStuds_invisible");
			state = this.createBlankState("closed_tiger_3",defaultTransitionTime);
			state.populateInstantOn("teethAndStuds_invisible");
			return this.aStates.length;
		}
		
	}
}

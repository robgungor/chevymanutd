package com.oddcast.host.api.morph.spud {
	import com.oddcast.util.Utils;
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.IEditorAPI;
	import flash.Boot;
	import com.oddcast.host.api.morph.FaceMorph;
	public class FaceMorphSpud extends com.oddcast.host.api.morph.FaceMorph {
		public function FaceMorphSpud(editorAPI : com.oddcast.host.api.IEditorAPI = null) : void { if( !flash.Boot.skip_constructor ) {
			super(editorAPI);
		}}
		
		public function setBack(morphInf : com.oddcast.host.api.morph.MorphInfluence) : void {
			this.setInfluence(BACK,morphInf,"Back");
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_GEOM,0.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_TEX,0.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.EYE_COLOR,0.0);
			this.setDefaults();
			morphInf.setGlobalWeight(1.0);
		}
		
		public function setBackCharacter(characterStr : String) : com.oddcast.host.api.morph.MorphInfluence {
			com.oddcast.util.Utils.AS3trace("[ENGINE3W] Morph setBackCharacter" + characterStr);
			var morphInf : com.oddcast.host.api.morph.MorphInfluence = this.setInfluenceCharacter(BACK,characterStr,"Back");
			this.setBack(morphInf);
			return morphInf;
		}
		
		public function setTarget(morphInf : com.oddcast.host.api.morph.MorphInfluence) : void {
			this.setInfluence(TARGET,morphInf,"User");
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.EYE_COLOR,1.0);
			this.setDefaults();
			morphInf.setGlobalWeight(1.0);
		}
		
		public function setTargetCharacter(characterStr : String) : com.oddcast.host.api.morph.MorphInfluence {
			com.oddcast.util.Utils.AS3trace("[ENGINE3W] Morph setTargetCharacter" + characterStr);
			var morphInf : com.oddcast.host.api.morph.MorphInfluence = this.setInfluenceCharacter(TARGET,characterStr,"User");
			this.setTarget(morphInf);
			return morphInf;
		}
		
		public function setDefaults() : void {
			if(this.morphInfs[TARGET] != null) {
				this.morphInfs[TARGET].setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,1.00);
				this.morphInfs[TARGET].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,1);
				this.morphInfs[TARGET].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_OUTER,1);
			}
			else null;
			if(this.morphInfs[BACK] != null) this.morphInfs[BACK].setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,0.0);
		}
		
		static protected var BACK : int = 0;
		static protected var TARGET : int = 1;
	}
}

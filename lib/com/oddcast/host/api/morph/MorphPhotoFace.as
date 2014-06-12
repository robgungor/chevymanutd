package com.oddcast.host.api.morph {
	
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.IEditorAPI;
	
	import com.oddcast.host.api.morph.FaceMorph;
	public class MorphPhotoFace extends com.oddcast.host.api.morph.FaceMorph {
		public function MorphPhotoFace(editorAPI : com.oddcast.host.api.IEditorAPI = null) : void {  {
			super(editorAPI);
		}}
		
		public function setBack(morphInf : com.oddcast.host.api.morph.MorphInfluence) : void {
			this.setInfluence(BACK,morphInf,"Back");
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_GEOM,0.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_TEX,0.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.EYE_COLOR,0.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.EYEWHITE_COLOR,0.0);
			this.setDefaults();
			morphInf.setGlobalWeight(1.0);
		}
		
		public function setBackCharacter(characterStr : String) : com.oddcast.host.api.morph.MorphInfluence {
			trace("[ENGINE3W] Morph setBackCharacter" + characterStr);
			var morphInf : com.oddcast.host.api.morph.MorphInfluence = this.setInfluenceCharacter(BACK,characterStr,"Back");
			this.setBack(morphInf);
			return morphInf;
		}
		
		public function setTarget(morphInf : com.oddcast.host.api.morph.MorphInfluence) : void {
			this.setInfluence(TARGET,morphInf,"User");
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.EYE_COLOR,1.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.EYEWHITE_COLOR,1.0);
			this.setDefaults();
			morphInf.setGlobalWeight(1.0);
		}
		
		public function setTargetCharacter(characterStr : String) : com.oddcast.host.api.morph.MorphInfluence {
			trace("[ENGINE3W] Morph setTargetCharacter" + characterStr);
			var morphInf : com.oddcast.host.api.morph.MorphInfluence = this.setInfluenceCharacter(TARGET,characterStr,"User");
			this.setTarget(morphInf);
			return morphInf;
		}
		
		public function setDefaults() : void {
			if(this.morphInfs[TARGET] != null) {
				this.morphInfs[TARGET].setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,1.00);
				this.morphInfs[TARGET].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,0.00);
				this.morphInfs[TARGET].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_OUTER,0.00);
				if(this.morphInfs[BACK] != null) {
					this.morphInfs[BACK].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,1.0);
					this.morphInfs[BACK].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_OUTER,1.0);
				}
			}
			else {
				this.morphInfs[BACK].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,1.0);
				this.morphInfs[BACK].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_OUTER,1.0);
			}
			if(this.morphInfs[BACK] != null) this.morphInfs[BACK].setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,0.0);
		}
		
		public function setTargetComponent(index : int,value : Number) : void {
			null;
		}
		
		static protected var BACK : int = 0;
		static protected var TARGET : int = 1;
		static protected var BACK_STRING : String = "Back";
		static protected var USER_STRING : String = "User";
	}
}

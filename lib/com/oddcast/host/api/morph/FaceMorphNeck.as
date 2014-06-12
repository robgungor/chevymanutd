package com.oddcast.host.api.morph {
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.IEditorAPI;
	import flash.Boot;
	import com.oddcast.host.api.morph.FaceMorph;
	public class FaceMorphNeck extends com.oddcast.host.api.morph.FaceMorph {
		public function FaceMorphNeck(editorAPI : com.oddcast.host.api.IEditorAPI = null) : void { if( !flash.Boot.skip_constructor ) {
			super(editorAPI);
			editorAPI.setSkinToneBounding(1.0,1.0,1.0);
		}}
		
		public function setCharacter(characterStr : String) : com.oddcast.host.api.morph.MorphInfluence {
			var morphInf : com.oddcast.host.api.morph.MorphInfluence = this.setInfluenceCharacter(0,characterStr,"Character");
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_OUTER,1.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,1.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_OUTER,1.0);
			morphInf.setGlobalWeight(1.0);
			return morphInf;
		}
		
	}
}

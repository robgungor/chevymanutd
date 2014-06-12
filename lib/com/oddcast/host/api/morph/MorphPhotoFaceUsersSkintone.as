package com.oddcast.host.api.morph {
	import com.oddcast.host.api.morph.MorphPhotoFace;
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.IEditorAPI;
	
	public class MorphPhotoFaceUsersSkintone extends com.oddcast.host.api.morph.MorphPhotoFace {
		public function MorphPhotoFaceUsersSkintone(editorAPI : com.oddcast.host.api.IEditorAPI = null) : void {  {
			super(editorAPI);
		}}
		
		public override function setDefaults() : void {
			if(this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.TARGET] != null) {
				this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.TARGET].setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,1.00);
				this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.TARGET].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,1.00);
				this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.TARGET].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_OUTER,1.00);
			}
			if(this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.BACK] != null) {
				this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.BACK].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,0.00);
				this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.BACK].setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_OUTER,0.00);
				this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.BACK].setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,0.0);
			}
		}
		
	}
}

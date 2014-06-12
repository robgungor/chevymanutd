package com.oddcast.host.api.morph.videostar {
	import com.oddcast.host.api.morph.MorphPhotoFace;
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.IEditorAPI;
	
	public class MorphPhotoFaceFlashVideoStar extends com.oddcast.host.api.morph.MorphPhotoFace {
		public function MorphPhotoFaceFlashVideoStar(editorAPI : com.oddcast.host.api.IEditorAPI = null) : void {  {
			super(editorAPI);
		}}
		
		public override function setBack(morphInf : com.oddcast.host.api.morph.MorphInfluence) : void {
			super.setBack(morphInf);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,0.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,0.0);
		}
		
		public override function setTarget(morphInf : com.oddcast.host.api.morph.MorphInfluence) : void {
			super.setTarget(morphInf);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,1.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,1.0);
		}
		
		public override function setDefaults() : void {
			null;
		}
		
	}
}

package com.oddcast.host.api.morph {
	import com.oddcast.host.api.morph.MorphPhotoFace;
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.IEditorAPI;
	
	public class MorphPhotoFaceBalanced extends com.oddcast.host.api.morph.MorphPhotoFace {
		public function MorphPhotoFaceBalanced(editorAPI : com.oddcast.host.api.IEditorAPI = null) : void {  {
			this.targetLevels = new Array();
			{
				var _g1 : int = 0, _g : int = com.oddcast.host.api.morph.MorphInfluence.TOTALINDEX;
				while(_g1 < _g) {
					var index : int = _g1++;
					this.targetLevels[index] = INDEX_NOT_USED;
				}
			}
			this.setTargetComponent(com.oddcast.host.api.morph.MorphInfluence.PHOTOFACE_FACE,1.0);
			this.setTargetComponent(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,0.5);
			this.setTargetComponent(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_OUTER,0.5);
			super(editorAPI);
		}}
		
		protected var targetLevels : Array;
		public override function setTargetComponent(index : int,value : Number) : void {
			value = Math.max(value,0.0);
			value = Math.min(value,1.0);
			this.targetLevels[index] = value;
		}
		
		public override function setDefaults() : void {
			var _g1 : int = 0, _g : int = com.oddcast.host.api.morph.MorphInfluence.TOTALINDEX;
			while(_g1 < _g) {
				var index : int = _g1++;
				if(this.targetLevels[index] > INDEX_NOT_USED) {
					if(this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.TARGET] != null) this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.TARGET].setWeight(index,this.targetLevels[index]);
					if(this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.BACK] != null) this.morphInfs[com.oddcast.host.api.morph.MorphPhotoFace.BACK].setWeight(index,1.0 - this.targetLevels[index]);
				}
			}
		}
		
		static protected var INDEX_NOT_USED : Number = -1.0;
	}
}

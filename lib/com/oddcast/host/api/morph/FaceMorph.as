package com.oddcast.host.api.morph {
	import com.oddcast.host.api.morph.IMorphInfluenceChangeListener;
	import com.oddcast.host.api.morph.MorphInfluence;
	
	import com.oddcast.host.api.IEditorAPI;import flash.utils.getQualifiedClassName;
	
	public class FaceMorph implements com.oddcast.host.api.morph.IMorphInfluenceChangeListener{
		public function FaceMorph(editorAPI : com.oddcast.host.api.IEditorAPI = null) : void {  {
			this.editorAPI = editorAPI;
			this.morphInfs = new Array();
			trace("[ENGINE3W] " + flash.utils.getQualifiedClassName(this) + " compileDate = " + "Tue 03/01/2011 - 16:31:44.80");
		}}
		
		public function morphInfChangedHandler(morphInfluence : com.oddcast.host.api.morph.MorphInfluence,changeType : int) : void {
			null;
		}
		
		public function setInfluence(index : int,morphInf : com.oddcast.host.api.morph.MorphInfluence,plabel : String) : void {
			this.morphInfs[index] = morphInf;
			morphInf.setChangeListener(this);
		}
		
		public function setInfluenceCharacter(index : int,characterStr : String,plabel : String) : com.oddcast.host.api.morph.MorphInfluence {
			if(this.morphInfs[index] != null) {
				trace("[ENGINE3W] removeInfluenceCharacterXML(" + index + ")");
				this.morphInfs[index] = this.editorAPI.removeMorphTarget(this.morphInfs[index]);
			}
			trace("[ENGINE3W] setInfluenceCharacterXML(" + index + ", " + plabel + " " + characterStr + ")");
			var morphInf : com.oddcast.host.api.morph.MorphInfluence = this.editorAPI.setMorphTarget(characterStr,plabel);
			this.setInfluence(index,morphInf,plabel);
			return morphInf;
		}
		
		public function setFgFilter(morphInf : com.oddcast.host.api.morph.MorphInfluence,plabels : String,index : int,weight : Number) : int {
			morphInf.setDirty(index);
			return this.editorAPI.setFgFilter(morphInf,plabels,index,weight);
		}
		
		public function getFgFilter(morphInf : com.oddcast.host.api.morph.MorphInfluence,plabel : String) : Number {
			return this.editorAPI.getFgFilter(morphInf,plabel);
		}
		
		protected var editorAPI : com.oddcast.host.api.IEditorAPI;
		protected var morphInfs : Array;
		public function unload() : void {
			trace("[ENGINE3W] FaceMorph.unload");
			if(this.editorAPI != null) {
				if(this.morphInfs != null) {
					{
						var _g : int = 0, _g1 : Array = this.morphInfs;
						while(_g < _g1.length) {
							var inf : com.oddcast.host.api.morph.MorphInfluence = _g1[_g];
							++_g;
							this.editorAPI.removeMorphTarget(inf);
						}
					}
					this.morphInfs = null;
				}
				this.editorAPI = null;
			}
		}
		
	}
}

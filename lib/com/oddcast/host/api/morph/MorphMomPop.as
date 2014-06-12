package com.oddcast.host.api.morph {
	
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.IEditorAPI;
	
	import com.oddcast.host.api.morph.FaceMorph;
	public class MorphMomPop extends com.oddcast.host.api.morph.FaceMorph {
		public function MorphMomPop(editorAPI : com.oddcast.host.api.IEditorAPI = null,momWeighting : Number = NaN,geomExaggeration : * = null) : void {  {
			super(editorAPI);
			this.momWeighting = momWeighting;
			this.geomExaggeration = 4.8;
			this.skinToneFactor = 0.56;
			editorAPI.setSkinToneBounding(0.07,0.07,0.07);
		}}
		
		public var momWeighting : Number;
		public function setMom(morphInf : com.oddcast.host.api.morph.MorphInfluence,iRace : int) : void {
			this.setParent(MOM,morphInf,"Mom",iRace);
		}
		
		public function setPop(morphInf : com.oddcast.host.api.morph.MorphInfluence,iRace : int) : void {
			this.setParent(POP,morphInf,"Pop",iRace);
		}
		
		protected function applySkinToneFactor(morphInf : com.oddcast.host.api.morph.MorphInfluence,skinToneFactor : Number) : void {
			if(morphInf != null) {
				morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_FACE,skinToneFactor);
				morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.SKIN_TONE_OUTER,skinToneFactor);
			}
		}
		
		protected function setParent(index : int,morphInf : com.oddcast.host.api.morph.MorphInfluence,plabel : String,iRace : int) : void {
			this.setInfluence(index,morphInf,plabel);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_GEOM,this.geomExaggeration);
			morphInf.setClean(com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_TEX,3.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.DETAIL_MODULATION,0.0);
			this.applySkinToneFactor(morphInf,this.skinToneFactor);
			this.setMomWeighting(this.momWeighting);
			morphInf.bGeomNormalizeFG = true;
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_BROW,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,1.55);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_CHEEKBONES,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,0.00);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_CHEEKS,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,1.40);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_CHIN,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,1.65);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_EYES,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,1.75);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_FACE,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,0.75);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_FOREHEAD,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,1.20);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_HEAD,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,1.35);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_JAW,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,2.20);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_MOUTH,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,1.80);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_NOSE,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,5.00);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_NOSTRILS,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,4.75);
			this.setFgFilter(morphInf,com.oddcast.host.api.morph.MorphInfluence.FG_FILTER_TEMPLES,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,1.20);
			if(index == MOM) this.iMomRace = iRace;
			else this.iPopRace = iRace;
		}
		
		public override function morphInfChangedHandler(morphInfluence : com.oddcast.host.api.morph.MorphInfluence,changeType : int) : void {
			if(morphInfluence == this.morphInfs[MOM] || morphInfluence == this.morphInfs[POP]) {
				var _g1 : int = 0, _g : int = eyeControls.length;
				while(_g1 < _g) {
					var i : int = _g1++;
					var c : String = eyeControls[i];
					var val : Number = this.editorAPI.getMorphEditValue(morphInfluence,c);
					if(val < MIN_EYE_CONTROL) this.editorAPI.setMorphEditValue(morphInfluence,c,MIN_EYE_CONTROL);
					trace("[ENGINE3W] RParam Eyes " + morphInfluence.plabel + " before:" + val + " now:" + this.editorAPI.getMorphEditValue(morphInfluence,c));
				}
			}
		}
		
		public function setParentsFgFilter(fgFilterString : String,weight : Number) : int {
			if(this.morphInfs[MOM] != null) this.setFgFilter(this.morphInfs[MOM],fgFilterString,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,weight);
			if(this.morphInfs[POP] != null) return this.setFgFilter(this.morphInfs[POP],fgFilterString,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,weight);
			return 0;
		}
		
		public function getParentsFgFilter(fgFilterString : String) : Number {
			if(this.morphInfs[POP] != null) return this.getFgFilter(this.morphInfs[POP],fgFilterString);
			return 0.0;
		}
		
		public function setParentCharacter(index : int,characterStr : String,iRace : int) : com.oddcast.host.api.morph.MorphInfluence {
			var plabel : String = ((index == MOM)?"Mom":"Pop");
			var morphInf : com.oddcast.host.api.morph.MorphInfluence = this.setInfluenceCharacter(index,characterStr,plabel);
			this.setParent(index,morphInf,plabel,iRace);
			return morphInf;
		}
		
		public function DEBUG_setGeomExaggeration(value : Number) : void {
			this.geomExaggeration = value;
			if(this.morphInfs[POP] != null) this.morphInfs[POP].setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_GEOM,this.geomExaggeration);
			if(this.morphInfs[MOM] != null) this.morphInfs[MOM].setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_GEOM,this.geomExaggeration);
		}
		
		public function DEBUG_getGeomExaggeration() : Number {
			return this.geomExaggeration;
		}
		
		public function setMomWeighting(balance : Number) : void {
			var temp : Number = balance;
			trace("[ENGINE3W] momWeighting:" + this.momWeighting + " balance:" + balance);
			if(temp > 1.0) temp = 1.0;
			if(temp < 0.0) temp = 0.0;
			{
				this.momWeighting = temp;
				null;
				if(this.morphInfs[POP] != null) this.morphInfs[POP].setGlobalWeight(0);
				if(this.morphInfs[MOM] != null) this.morphInfs[MOM].setGlobalWeight(0);
			}
		}
		
		protected var geomExaggeration : Number;
		protected var skinToneFactor : Number;
		protected var iMomRace : int;
		protected var iPopRace : int;
		static public var POP : int = 0;
		static public var MOM : int = 1;
		static protected var eyeControls : Array = ["Eyes - Dark Brown / Light Blue","Eyes - Dark Brown / Light Brown"];
		static protected var MIN_EYE_CONTROL : Number = 2.0;
	}
}

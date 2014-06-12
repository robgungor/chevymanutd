package com.oddcast.host.api.morph {
	
	import com.oddcast.host.api.morph.MorphMomPop;
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.API_Constant;
	import com.oddcast.host.api.morph.babymaker.CalcRace;
	import com.oddcast.host.api.EditLabel;
	
	import com.oddcast.host.api.IEditorAPI;
	public class MorphMomPopBaby extends com.oddcast.host.api.morph.MorphMomPop {
		public function MorphMomPopBaby(editorAPI : com.oddcast.host.api.IEditorAPI = null,momWeighting : Number = NaN,geomExaggeration : * = null) : void {  {
			super(editorAPI,momWeighting,geomExaggeration);
			editorAPI.setEditValue(com.oddcast.host.api.API_Constant.ADVANCED,com.oddcast.host.api.EditLabel.F_EYES_IRIS_SIZE,0.28,0);
			editorAPI.setEditValue(com.oddcast.host.api.API_Constant.ADVANCED,com.oddcast.host.api.EditLabel.F_EYES_IRIS_ASPECT,0.13,0);
		}}
		
		public function setSkinToneFactor(value : Number) : void {
			this.skinToneFactor = value;
			this.applySkinToneFactor(this.morphInfs[com.oddcast.host.api.morph.MorphMomPop.MOM],this.skinToneFactor);
			this.applySkinToneFactor(this.morphInfs[com.oddcast.host.api.morph.MorphMomPop.POP],this.skinToneFactor);
			this.applySkinToneFactor(this.morphInfs[BABY],1 - this.skinToneFactor);
		}
		
		public function getSkinToneFactor() : Number {
			return this.skinToneFactor;
		}
		
		public function calcWhichBabyId() : String {
			var calcRace : com.oddcast.host.api.morph.babymaker.CalcRace = new com.oddcast.host.api.morph.babymaker.CalcRace();
			var race : String = calcRace.calc(this.morphInfs[com.oddcast.host.api.morph.MorphMomPop.MOM],this.morphInfs[com.oddcast.host.api.morph.MorphMomPop.POP],this.editorAPI,this.iMomRace,this.iPopRace);
			return race;
		}
		
		protected function getMomGeneticWeighting() : Number {
			return ((Math.random() > 0.5)?0:1.0);
		}
		
		protected function geneticWeighting(control : String,totalWeight : Number,fFromMom : Number) : void {
			var fFromPop : Number = 1.0 - fFromMom;
			trace("[ENGINE3W]  RParam Genetic Weighting " + control + " mom:" + fFromMom + " pop:" + fFromPop);
			this.setFgFilter(this.morphInfs[com.oddcast.host.api.morph.MorphMomPop.MOM],control,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,totalWeight * fFromMom);
			this.setFgFilter(this.morphInfs[com.oddcast.host.api.morph.MorphMomPop.POP],control,com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM,totalWeight * fFromPop);
		}
		
		public function setBaby(morphInf : com.oddcast.host.api.morph.MorphInfluence) : void {
			this.setInfluence(BABY,morphInf,"Baby");
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_GEOM,1.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.FG_TEX,0.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.DETAIL_MODULATION,0.0);
			morphInf.setWeight(com.oddcast.host.api.morph.MorphInfluence.EYE_COLOR,0.0);
			this.applySkinToneFactor(morphInf,1 - this.skinToneFactor);
			morphInf.setGlobalWeight(1.0);
		}
		
		public function setBabyCharacter(characterStr : String) : com.oddcast.host.api.morph.MorphInfluence {
			this.editorAPI.loadXML(characterStr);
			var plabel : String = "Baby";
			var morphInf : com.oddcast.host.api.morph.MorphInfluence = this.setInfluenceCharacter(BABY,characterStr,plabel);
			this.setBaby(morphInf);
			return morphInf;
		}
		
		static public var BABY : int = 2;
		static protected var EYES_WEIGHT : Number = 0.75;
		static protected var MOUTH_WEIGHT : Number = 3.10;
		static protected var NOSE_WEIGHT : Number = 5.00;
		static protected var NOSTRILS_WEIGHT : Number = 4.75;
	}
}

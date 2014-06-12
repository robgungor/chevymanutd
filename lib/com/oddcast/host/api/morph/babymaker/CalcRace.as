package com.oddcast.host.api.morph.babymaker {
	
	import com.oddcast.host.api.morph.babymaker.RaceParam;
	import com.oddcast.host.api.IEditorAPI;
	import com.oddcast.host.api.morph.MorphInfluence;
	public class CalcRace {
		public function CalcRace() : void {
			null;
		}
		
		public function calc(momMInf : com.oddcast.host.api.morph.MorphInfluence,popMInf : com.oddcast.host.api.morph.MorphInfluence,editorAPI : com.oddcast.host.api.IEditorAPI,iMomRace : int,iPopRace : int) : String {
			if(iMomRace == com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_OTHER) {
				var momRaceParam : com.oddcast.host.api.morph.babymaker.RaceParam = new com.oddcast.host.api.morph.babymaker.RaceParam().read(editorAPI,momMInf);
				iMomRace = momRaceParam.maxIndex();
				trace("[ENGINE3W] RParam mom UNKNOWN: " + momRaceParam.toString());
			}
			trace("[ENGINE3W] RParam mom: " + com.oddcast.host.api.morph.babymaker.RaceParam.raceToEnglish(iMomRace));
			if(iPopRace == com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_OTHER) {
				var popRaceParam : com.oddcast.host.api.morph.babymaker.RaceParam = new com.oddcast.host.api.morph.babymaker.RaceParam().read(editorAPI,popMInf);
				iPopRace = popRaceParam.maxIndex();
				trace("[ENGINE3W] RParam pop UNKNOWN: " + popRaceParam.toString());
			}
			trace("[ENGINE3W] RParam pop: " + com.oddcast.host.api.morph.babymaker.RaceParam.raceToEnglish(iPopRace));
			var babybucket : String = "error";
			switch(iMomRace) {
			case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_AFRO:{
				switch(iPopRace) {
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_AFRO:{
					babybucket = africanAmerican;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_ASIA:{
					babybucket = aa_a;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EIND:{
					babybucket = aa_i;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EURO:{
					babybucket = aa_c;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_LATINO:{
					babybucket = aa_l;
				}break;
				}
			}break;
			case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_ASIA:{
				switch(iPopRace) {
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_AFRO:{
					babybucket = aa_a;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_ASIA:{
					babybucket = asian;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EIND:{
					babybucket = a_i;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EURO:{
					babybucket = a_c;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_LATINO:{
					babybucket = a_l;
				}break;
				}
			}break;
			case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EIND:{
				switch(iPopRace) {
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_AFRO:{
					babybucket = aa_i;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_ASIA:{
					babybucket = a_i;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EIND:{
					babybucket = indian;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EURO:{
					babybucket = c_i;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_LATINO:{
					babybucket = i_l;
				}break;
				}
			}break;
			case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EURO:{
				switch(iPopRace) {
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_AFRO:{
					babybucket = aa_c;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_ASIA:{
					babybucket = a_c;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EIND:{
					babybucket = c_i;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EURO:{
					babybucket = this.calcBabyHairColor(momMInf,popMInf,editorAPI);
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_LATINO:{
					babybucket = c_l;
				}break;
				}
			}break;
			case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_LATINO:{
				switch(iPopRace) {
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_AFRO:{
					babybucket = aa_l;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_ASIA:{
					babybucket = a_l;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EIND:{
					babybucket = i_l;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_EURO:{
					babybucket = c_l;
				}break;
				case com.oddcast.host.api.morph.babymaker.RaceParam.I_RACE_LATINO:{
					babybucket = latino;
				}break;
				}
			}break;
			}
			trace("[ENGINE3W] RParam baby: " + babybucket);
			return babybucket;
		}
		
		protected function calcBabyHairColor(momMInf : com.oddcast.host.api.morph.MorphInfluence,popMInf : com.oddcast.host.api.morph.MorphInfluence,editorAPI : com.oddcast.host.api.IEditorAPI) : String {
			var dadHair : Number = editorAPI.getMorphEditValue(popMInf,"Eyebrows - Dark / Light");
			var momHair : Number = editorAPI.getMorphEditValue(momMInf,"Eyebrows - Dark / Light");
			trace("[ENGINE3W] RParam Dad Hair:" + dadHair + " Mom Hair:" + momHair);
			if(dadHair > DAD_BLONDE) {
				if(Math.random() < BABY_BLONDE) return caucasianBlonde;
			}
			if(Math.random() < BABY_RED) return caucasianRed;
			return caucasianBrunette;
		}
		
		static protected var africanAmerican : String = "africanAmerican";
		static protected var asian : String = "asian";
		static protected var caucasianBlonde : String = "caucasianBlonde";
		static protected var caucasianBrunette : String = "caucasianBrunette";
		static protected var caucasianRed : String = "caucasianRed";
		static protected var indian : String = "indian";
		static protected var latino : String = "latino";
		static protected var aa_a : String = "aa_a";
		static protected var aa_c : String = "aa_c";
		static protected var aa_i : String = "aa_i";
		static protected var aa_l : String = "aa_l";
		static protected var a_c : String = "a_c";
		static protected var a_i : String = "a_i";
		static protected var a_l : String = "a_l";
		static protected var c_i : String = "c_i";
		static protected var c_l : String = "c_l";
		static protected var i_l : String = "i_l";
		static protected var DAD_BLONDE : Number = 0.0;
		static protected var MOM_BLONDE : Number = 0.75;
		static protected var BABY_BLONDE : Number = 0.50;
		static protected var BABY_RED : Number = 0.05;
	}
}

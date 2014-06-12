package com.oddcast.host.api.morph.babymaker {
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.IEditorAPI;
	
	public class RaceParam {
		public function RaceParam() : void {  {
			this.weight = new Array();
			this.weight[I_RACE_AFRO] = 0.0;
			this.weight[I_RACE_ASIA] = 0.0;
			this.weight[I_RACE_EIND] = 0.0;
			this.weight[I_RACE_EURO] = 0.0;
		}}
		
		public var weight : Array;
		public function read(editorAPI : com.oddcast.host.api.IEditorAPI,mInf : com.oddcast.host.api.morph.MorphInfluence) : com.oddcast.host.api.morph.babymaker.RaceParam {
			this.weight[I_RACE_AFRO] = editorAPI.getMorphEditValue(mInf,"Race_All_Afro");
			this.weight[I_RACE_ASIA] = editorAPI.getMorphEditValue(mInf,"Race_All_Asia");
			this.weight[I_RACE_EIND] = editorAPI.getMorphEditValue(mInf,"Race_All_Eind");
			this.weight[I_RACE_EURO] = editorAPI.getMorphEditValue(mInf,"Race_All_Euro");
			return this;
		}
		
		public function add(a : com.oddcast.host.api.morph.babymaker.RaceParam,b : com.oddcast.host.api.morph.babymaker.RaceParam) : com.oddcast.host.api.morph.babymaker.RaceParam {
			{
				var _g1 : int = 0, _g : int = this.weight.length;
				while(_g1 < _g) {
					var i : int = _g1++;
					this.weight[i] = a.weight[i] + b.weight[i];
				}
			}
			return this;
		}
		
		public function maxIndex() : int {
			var retval : int = I_RACE_EURO;
			var maxValue : Number = -900.0;
			{
				var _g1 : int = 0, _g : int = this.weight.length;
				while(_g1 < _g) {
					var i : int = _g1++;
					if(this.weight[i] > maxValue) {
						retval = i;
						maxValue = this.weight[i];
					}
				}
			}
			return retval;
		}
		
		public function toString() : String {
			return this.maxIndex() + " " + this.weight[I_RACE_AFRO] + " " + this.weight[I_RACE_ASIA] + " " + this.weight[I_RACE_EIND] + " " + this.weight[I_RACE_EURO];
		}
		
		static public var I_RACE_AFRO : int = 0;
		static public var I_RACE_ASIA : int = 1;
		static public var I_RACE_EIND : int = 2;
		static public var I_RACE_EURO : int = 3;
		static public var I_RACE_LATINO : int = 4;
		static public var I_RACE_OTHER : int = 5;
		static public function raceToEnglish(i : int) : String {
			switch(i) {
			case I_RACE_AFRO:{
				return "African";
			}break;
			case I_RACE_ASIA:{
				return "Asian";
			}break;
			case I_RACE_EIND:{
				return "East Indian";
			}break;
			case I_RACE_EURO:{
				return "Caucasian";
			}break;
			case I_RACE_LATINO:{
				return "Latino";
			}break;
			case I_RACE_OTHER:{
				return "Other";
			}break;
			}
			return "Unknown";
		}
		
	}
}

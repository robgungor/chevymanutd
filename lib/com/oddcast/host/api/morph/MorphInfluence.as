package com.oddcast.host.api.morph {
	import com.oddcast.host.api.morph.IMorphInfluenceChangeListener;
	import flash.display.BitmapData;
	
	import com.oddcast.host.api.morph.MorphInfluencePlayback;
	public class MorphInfluence extends com.oddcast.host.api.morph.MorphInfluencePlayback {
		public function MorphInfluence(globalWeight : Number = NaN) : void {  {
			super(globalWeight);
			this.weights = new Array();
			this.setWeight(FG_GEOM,1.0);
			this.setWeight(FG_TEX,1.0);
			this.setWeight(DETAIL_MODULATION,1.0);
			this.setWeight(PHOTOFACE_FACE,0.0);
			this.setWeight(PHOTOFACE_OUTER,0.0);
			this.setWeight(SKIN_TONE_FACE,0.0);
			this.setWeight(SKIN_TONE_OUTER,0.0);
			this.setWeight(EYE_COLOR,1.0);
			this.setWeight(EYEWHITE_COLOR,1.0);
			this.bGeomNormalizeFG = false;
		}}
		
		public override function setGlobalWeight(globalWeight : Number) : void {
			this.setDirty(this.getDirtyWeights(1.0));
			super.setGlobalWeight(globalWeight);
		}
		
		public function setWeight(index : int,weight : Number) : void {
			var currentWeight : Number = ((index < this.weights.length)?this.weights[index]:0.0);
			{
				if(Math.abs(currentWeight - weight) > MINIMAL_WEIGHT_CHANGE) this.setDirty(1 << index);
				this.weights[index] = weight;
			}
		}
		
		public function getWeight(index : int) : Number {
			return this.weights[index];
		}
		
		public function getWeightGloballed(index : int) : Number {
			return this.getWeight(index) * this.globalWeight;
		}
		
		public function setDirty(dirty : int) : void {
			this.iDirty |= dirty;
		}
		
		public function isDirty() : Boolean {
			return this.isDirt(DIRTY_ALL);
		}
		
		public function isDirt(dirty : int) : Boolean {
			return (this.iDirty & dirty) != 0;
		}
		
		public function setClean(clean : int) : void {
			this.iDirty &= (clean ^ DIRTY_ALL);
		}
		
		public function getDirtyWeights(gWeight : Number) : int {
			var retval : int = 0;
			if(this.weights != null) {
				var _g1 : int = 0, _g : int = this.weights.length;
				while(_g1 < _g) {
					var i : int = _g1++;
					if(Math.abs(this.getWeight(i) * gWeight) > MINIMAL_WEIGHT_CHANGE) retval |= 1 << i;
				}
			}
			return retval;
		}
		
		public var iDirty : int;
		public var weights : Array;
		public var bGeomNormalizeFG : Boolean;
		protected var changeListener : com.oddcast.host.api.morph.IMorphInfluenceChangeListener;
		public function setChangeListener(listener : com.oddcast.host.api.morph.IMorphInfluenceChangeListener) : void {
			this.changeListener = listener;
		}
		
		public function changed(changeType : int) : void {
			if(this.changeListener != null) this.changeListener.morphInfChangedHandler(this,changeType);
		}
		
		public function setMorphAlphaMaskBitmapData(bitmapData : flash.display.BitmapData,name : String = null) : void {
			null;
		}
		
		public function unload() : void {
			this.changeListener = null;
		}
		
		static public var TOTALINDEX : int = 0;
		static public var FG_GEOM : int = TOTALINDEX;
		static public var DIRTY_FG_GEOM : int = 1 << TOTALINDEX++;
		static public var FG_TEX : int = TOTALINDEX;
		static public var DIRTY_FG_TEX : int = 1 << TOTALINDEX++;
		static public var DIRTY_FG : int = com.oddcast.host.api.morph.MorphInfluence.DIRTY_FG_GEOM | DIRTY_FG_TEX;
		static public var DETAIL_MODULATION : int = TOTALINDEX;
		static public var DIRTY_DETAIL_MODULATION : int = 1 << TOTALINDEX++;
		static public var PHOTOFACE_FACE : int = TOTALINDEX;
		static public var DIRTY_PHOTOFACE_FACE : int = 1 << TOTALINDEX++;
		static public var PHOTOFACE_OUTER : int = TOTALINDEX;
		static public var DIRTY_PHOTOFACE_OUTER : int = 1 << TOTALINDEX++;
		static public var DIRTY_PHOTOFACE : int = com.oddcast.host.api.morph.MorphInfluence.DIRTY_PHOTOFACE_OUTER | DIRTY_PHOTOFACE_FACE;
		static public var SKIN_TONE_FACE : int = TOTALINDEX;
		static public var DIRTY_SKIN_TONE_FACE : int = 1 << TOTALINDEX++;
		static public var SKIN_TONE_OUTER : int = TOTALINDEX;
		static public var DIRTY_SKIN_TONE_OUTER : int = 1 << TOTALINDEX++;
		static public var DIRTY_TONE : int = com.oddcast.host.api.morph.MorphInfluence.DIRTY_SKIN_TONE_FACE | DIRTY_SKIN_TONE_OUTER;
		static public var EYE_COLOR : int = TOTALINDEX;
		static public var DIRTY_EYE_COLOR : int = 1 << TOTALINDEX++;
		static public var EYEWHITE_COLOR : int = TOTALINDEX;
		static public var DIRTY_EYEWHITE_COLOR : int = 1 << TOTALINDEX++;
		static public var DIRTY_EYES : int = com.oddcast.host.api.morph.MorphInfluence.DIRTY_EYEWHITE_COLOR | DIRTY_EYE_COLOR;
		static public var ALPHAMASK : int = TOTALINDEX;
		static public var DIRTY_ALPHAMASK : int = 1 << TOTALINDEX++;
		static public var DIRTY_ALL : int = (1 << TOTALINDEX) - 1;
		static protected var MINIMAL_WEIGHT_CHANGE : Number = 0.01;
		static public var FG_FILTER_ALL : String = "All";
		static public var FG_FILTER_BROW : String = "Brow";
		static public var FG_FILTER_CHEEKBONES : String = "Cheekbones";
		static public var FG_FILTER_CHEEKS : String = "Cheeks";
		static public var FG_FILTER_CHIN : String = "Chin";
		static public var FG_FILTER_EYES : String = "Eyes";
		static public var FG_FILTER_FACE : String = "Face";
		static public var FG_FILTER_FOREHEAD : String = "Forehead";
		static public var FG_FILTER_HEAD : String = "Head";
		static public var FG_FILTER_JAW : String = "Jaw";
		static public var FG_FILTER_MOUTH : String = "Mouth";
		static public var FG_FILTER_NOSE : String = "Nose - down / up";
		static public var FG_FILTER_TEMPLES : String = "Temples";
		static public var FG_FILTER_NOSTRILS : String = "Nose - nostrils wide / thin";
		static public var FG_FILTER_DELIMITER : String = ",";
		static public var CHANGE_TYPE_FG_LOADED : int = 1;
	}
}

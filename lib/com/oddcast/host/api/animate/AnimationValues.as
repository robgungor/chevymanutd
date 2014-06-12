package com.oddcast.host.api.animate {
	import com.oddcast.host.api.animate.AnimationValuesDatum;
	
	public class AnimationValues {
		public function AnimationValues() : void {  {
			this.makeStore();
		}}
		
		public var array : Array;
		public function makeStore() : void {
			this.array = new Array();
		}
		
		protected function keyToIndex(key : String) : int {
			switch(key) {
			case "Pos":{
				return 0;
			}break;
			case "Rot":{
				return 1;
			}break;
			case "Ambient":{
				return 2;
			}break;
			case "Diffuse":{
				return 3;
			}break;
			case "RGB":{
				return 4;
			}break;
			case "Zoom":{
				return 5;
			}break;
			case "Scale":{
				return 6;
			}break;
			case "unused":{
				return 7;
			}break;
			case "RotX":{
				return 8;
			}break;
			case "RotY":{
				return 9;
			}break;
			case "RotZ":{
				return 10;
			}break;
			case "PosXY":{
				return 11;
			}break;
			case "PosZ":{
				return 12;
			}break;
			}
			return -1;
		}
		
		public function clone() : com.oddcast.host.api.animate.AnimationValues {
			var retval : com.oddcast.host.api.animate.AnimationValues = new com.oddcast.host.api.animate.AnimationValues();
			retval.copy(this);
			return retval;
		}
		
		public function copy(from : com.oddcast.host.api.animate.AnimationValues) : void {
			this.array = new Array();
			{
				var _g1 : int = 0, _g : int = from.array.length;
				while(_g1 < _g) {
					var iKey : int = _g1++;
					var k : Array = from.array[iKey];
					var a : Array = new Array();
					this.array[iKey] = a;
					{
						var _g3 : int = 0, _g2 : int = k.length;
						while(_g3 < _g2) {
							var i : int = _g3++;
							var animationValuesDatum : com.oddcast.host.api.animate.AnimationValuesDatum = k[i];
							a[i] = new com.oddcast.host.api.animate.AnimationValuesDatum().copy(animationValuesDatum);
						}
					}
				}
			}
		}
		
		public function setPosition(px : Number = 0.0,py : Number = 0.0,pz : Number = 0.0) : void {
			this.setAnimationValue("PosXY",[px,py]);
			this.setAnimationValue("PosZ",[pz]);
		}
		
		public function setRotationEuler(x : Number = 0.0,y : Number = 0.0,z : Number = 0.0) : void {
			var ax : Number = y * toRADIANS;
			var ay : Number = z * toRADIANS;
			var az : Number = -x * toRADIANS;
			var fSinPitch : Number = Math.sin(ax * 0.5);
			var fCosPitch : Number = Math.cos(ax * 0.5);
			var fSinYaw : Number = Math.sin(ay * 0.5);
			var fCosYaw : Number = Math.cos(ay * 0.5);
			var fSinRoll : Number = Math.sin(az * 0.5);
			var fCosRoll : Number = Math.cos(az * 0.5);
			var fCosPitchCosYaw : Number = fCosPitch * fCosYaw;
			var fSinPitchSinYaw : Number = fSinPitch * fSinYaw;
			this.setAnimationValue("Rot",[fSinRoll * fCosPitchCosYaw - fCosRoll * fSinPitchSinYaw,fCosRoll * fSinPitch * fCosYaw + fSinRoll * fCosPitch * fSinYaw,fCosRoll * fCosPitch * fSinYaw - fSinRoll * fSinPitch * fCosYaw,fCosRoll * fCosPitchCosYaw + fSinRoll * fSinPitchSinYaw]);
		}
		
		public function setColors(r : Number = 1.0,g : Number = 1.0,b : Number = 1.0,a : Number = 1.0) : void {
			this.setAnimationValue("RGB",[r,g,b,a]);
		}
		
		public function setLightStrengths(diffuse : Number = 0.7,ambient : Number = 0.3) : void {
			this.setAnimationValue("Ambient",[ambient]);
			this.setAnimationValue("Diffuse",[diffuse]);
		}
		
		public function setRotationQuaternion(qx : Number = 0.0,qy : Number = 0.0,qz : Number = 0.0,qw : Number = 1.0) : void {
			this.setAnimationValue("Rot",[qx,qy,qz,qw]);
		}
		
		public function setZoom(zoom : Number = 1000.0) : void {
			this.setAnimationValue("Zoom",[zoom]);
		}
		
		public function setScale(scale : Number = 1.0) : void {
			this.setAnimationValue("Scale",[scale]);
		}
		
		public function setAnimationValue(key : String,af : Array) : void {
			var kIndex : int = this.keyToIndex(key);
			var store : Array = this.array[kIndex];
			if(store == null) {
				store = new Array();
				{
					var _g1 : int = 0, _g : int = af.length;
					while(_g1 < _g) {
						var i : int = _g1++;
						store[i] = new com.oddcast.host.api.animate.AnimationValuesDatum();
					}
				}
				this.array[kIndex] = store;
			}
			{
				var _g12 : int = 0, _g2 : int = store.length;
				while(_g12 < _g2) {
					var i2 : int = _g12++;
					store[i2].set(af[i2]);
				}
			}
		}
		
		public function getAnimationValue(key : String) : Array {
			var data : Array = this.getAnimationData(key);
			if(data == null) return null;
			var retval : Array = new Array();
			{
				var _g : int = 0;
				while(_g < data.length) {
					var datum : com.oddcast.host.api.animate.AnimationValuesDatum = data[_g];
					++_g;
					retval.push(datum.get());
				}
			}
			return retval;
		}
		
		public function getAnimationData(key : String) : Array {
			return this.array[this.keyToIndex(key)];
		}
		
		public function getAnimationValueWithDefault(key : String,def : Number) : Number {
			var a : Array = this.getAnimationData(key);
			return ((a == null)?def:a[0].get());
		}
		
		static public var AMB_DEFAULT : Number = 0.3;
		static public var DIF_DEFAULT : Number = 0.7;
		static public var KEY_TYPE_POS : String = "Pos";
		static public var KEY_TYPE_ROT : String = "Rot";
		static public var KEY_TYPE_AMB : String = "Ambient";
		static public var KEY_TYPE_DIF : String = "Diffuse";
		static public var KEY_TYPE_RGB : String = "RGB";
		static public var KEY_TYPE_ZOOM : String = "Zoom";
		static public var KEY_TYPE_SCALE : String = "Scale";
		static public var KEY_TYPE_ROT_X : String = "RotX";
		static public var KEY_TYPE_ROT_Y : String = "RotY";
		static public var KEY_TYPE_ROT_Z : String = "RotZ";
		static public var KEY_TYPE_POS_XY : String = "PosXY";
		static public var KEY_TYPE_POS_Z : String = "PosZ";
		static public var KEY_TYPE_UNUSED : String = "unused";
		static public var toRADIANS : Number = Math.PI / 180;
	}
}

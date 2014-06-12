package com.oddcast.audio {
	import com.oddcast.utils.XMLLoader;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AudioEffectList {
		public var url:String;
		private var isInited:Boolean = false;
		private var effectArr:Array;
		private var effectTypes:Array;
		
		public function AudioEffectList($url:String = null) {
			url = $url;
		}
		
		public function init(callback:Function) {
			if (isInited) callback();
			else XMLLoader.loadXML(url, gotFXList, callback);
		}
		
		private function gotFXList(_xml:XML, callback:Function) {
			parseFXList(_xml);
			isInited=true;
			callback();
		}
		
		//<SOUNDEFFECTS><EFFECT NAME="Pitch" ID="p"><ITEM EFFLEVEL="3" EFFNAME="Highest"/>	
		public function parseFXList(_xml:XML) {
			var i:int;
			var j:int;
			var levelArr:Array;
			var fxXML:XML;
			var levelXML:XML;
			var effect:AudioEffect;
			var typeName:String;
			var typeId:String;
			
			effectTypes = new Array();
			effectArr = new Array();
			
			for (i=0; i < _xml.EFFECT.length(); i++) {
				fxXML = _xml.EFFECT[i];
				typeId = fxXML.@ID;
				typeName = fxXML.@NAME;
				effectTypes.push(new AudioEffectType(typeId,typeName));
				for (j=0;j<fxXML.ITEM.length();j++) {
					levelXML = fxXML.ITEM[j];
					effect = new AudioEffect(typeId, parseInt(levelXML.@EFFLEVEL));
					effect.typeName = typeName;
					effect.levelName = levelXML.@EFFNAME;
					effectArr.push(effect);
				}
			}	
		}
		
		public function getEffectTypes():Array {
			return(effectTypes);
		}
		
		public function getEffectTypeIds():Array {
			var typeIdArr:Array = new Array();
			for (var i:int = 0; i < effectTypes.length; i++) typeIdArr.push(effectTypes[i].typeId);
			return(typeIdArr);
		}
		
		public function getEffectsByType(typeId:String):Array {
			var levelArr:Array = new Array();
			var effect:AudioEffect;
			for (var i:int = 0; i < effectArr.length; i++) {
				effect = effectArr[i];
				if (effect.type == typeId) levelArr.push(effect);
			}
			levelArr.sortOn("level", Array.NUMERIC);
			return(levelArr);
		}
		
		public function getAllEffects():Array {
			return(effectArr);
		}
		
		public function getEffectByCode(code:String):AudioEffect {
			var effect:AudioEffect;
			for (var i:int = 0; i < effectArr.length; i++) {
				effect = effectArr[i];
				if (effect.code == code) return(effect);
			}
			return(null);
		}
	}
	
}
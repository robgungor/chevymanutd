package com.oddcast.vhost
{

	import com.oddcast.utils.ColorConverter;

	public class ConfigString{
		private static var map:Array = new Array(
			{name:"eyes", val:"", type:"color"},
			{name:"hair", val:"", type:"color"},
			{name:"mouth", val:"", type:"color"},
			{name:"skin", val:"", type:"color"},
			{name:"make-up", val:"", type:"color"},
			{name:"hyscale", val:""},
			{name:"hxscale", val:""},
			{name:"mscale", val:""},
			{name:"nscale", val:""},
			{name:"bscale", val:""},
			{name:"age", val:""},
			{name:"blush", val:""},
			{name:"make-up", val:""}
		);

		public static function getMap():Array{
			return map;
		}

		public static function convertOldConfigString(s:String):String{
			var a:Array = s.split("&");
			return new String();
		}

		public static function getString(c_grp:Object, r_grp:Object):String{
			var s:String = new String();
			for (var i:Number = 0; i < c_grp.ar.length; ++i){
				var cl:Object = c_grp.ar[i].getColor();
				addColorValue(c_grp.ar[i].saveStr, cl.rb, cl.gb, cl.bb);
			}
			for (i = 0; i < r_grp.ar.length; ++i){
				addValue(r_grp.ar[i].saveStr, Math.round(r_grp.ar[i].getValue()).toString());
			}
			for (i = 0; i<map.length; ++i){
				s+=map[i].val+":";
			}
			//trace("   from engine CONFIG STRING::::  "+s);
			return s;
		}


		public static function addColorValue(n:String, r:Number, g:Number, b:Number):void{
			var h:Number = createHex(r,g,b);
			//trace(n+" add color value hex: "+h+"  "+h.toString(16)+"   r: "+r+" g: "+ g +" b: "+b);
			for (var i:Number = 0; i<map.length; ++i){
				if (map[i].name == n){
					map[i].val = h.toString(16);
					break;
				}
			}
		}

		public static function addValue(n:String, v:String){
			//trace(n+" add value "+v);
			for (var i:Number = 0; i<map.length; ++i){
				if (map[i].name == n && map[i].type != "color"){
					map[i].val = v;
					break;
				}
			}
		}

		public static function createHex(r:Number, g:Number, b:Number):Number{
			var bn:Number = 0;
			if (r<0) bn+=1;
			if (g<0) bn+=2;
			if (b<0) bn+=4;
			return (ColorConverter.transformToHex(Math.abs(r), Math.abs(g), Math.abs(b)) << 4) | bn;
		}

		public static function createConfigObj(s:String):Object{
			//trace("ENGINE ------- createConfig Obj "+s);
			var a:Array = s.split(":");
			var o:Object = new Object();
			for (var i:Number = 0; i<a.length && i<map.length; ++i){
				if (map[i].type == "color"){
					var to:Object = createColorTransform(a[i]);
					o[map[i].name+"R"] = to["rb"];
					o[map[i].name+"G"] = to["gb"];
					o[map[i].name+"B"] = to["bb"];
				}else{
					o[map[i].name] = a[i];
				}
			}
			//trace("ENGINE ------- createConfig Obj rtn:");
			/*
			for (var j in o){
				trace("    "+j+" = "+o[j]);
			}
			*/
			return o;
		}

		public static function createColorTransform(hex:String):Object{
			var bin:Number = parseInt(hex, 16) & 7;
			var to:Object = ColorConverter.hexToTransform(parseInt(hex, 16) >> 4);
			if (bin & 1) to["rb"] *= -1;
			if (bin & 2) to["gb"] *= -1;
			if (bin & 4) to["bb"] *= -1;
			return to;
		}


	}
}
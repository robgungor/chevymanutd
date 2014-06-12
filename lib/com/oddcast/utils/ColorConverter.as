package com.oddcast.utils
{
	public class ColorConverter{


		public static function transformToHex(r:Number, g:Number, b:Number, offset:Number=0):Number
		{
			if (isNaN(offset)) offset = 0;
			r += offset;
			g += offset;
			b += offset;
			r = Math.max(0, Math.min(255, r));
			g = Math.max(0, Math.min(255, g));
			b = Math.max(0, Math.min(255, b));
			return (r<<16) |  (g<<8) | b;
		}


		public static function hexToTransform(hex:Number, offset:Number=0):Object
		{
			if (isNaN(offset)) offset = 0;
			var to:Object = new Object();
			to["rb"] = ((hex & 0xFF0000) >> 16) - offset;
			to["gb"] = ((hex & 0x00FF00) >> 8) - offset;
			to["bb"] = (hex & 0x0000FF) - offset;
			return to;
		}

	}
}
package com.oddcast.oc3d.shared
{
	public class Color
	{
		public static const HEX_2_UNIT:Number = 1 / 255;
		public static const UNIT_2_HEX:Number = 255;
		public static const CIRCLE_2_UNIT:Number = 1 / 360;
		
		public function get _debug_():String { return toString(); }
		
		private var value_:uint; // 0xaarrggbb
		
		public function Color(value:uint=0x00000000)
		{
			value_ = value;
			setAlpha(0xff);
		}
		
		public function clone():Color
		{
			return new Color(value_);
		}
		
		public static function createWithComponents(r:uint, g:uint, b:uint, a:uint=0xff):Color
		{
			var result:Color = new Color();
			result.setRed(r);
			result.setGreen(g);
			result.setBlue(b);
			result.setAlpha(a);
			return result;
		}
		
		public function toWebString():String
		{
			var fn:Function = function(n:uint):String
			{
				if (n < 10)
					return n.toString();
				else if (n == 10)
					return "A";
				else if (n == 11)
					return "B";
				else if (n == 12)
					return "C";
				else if (n == 13)
					return "D";
				else if (n == 14)
					return "E";
				else if (n == 15)
					return "F";
				else
					throw new Error("invalid hex value");
			};
			
			var redStr:String   = fn(red() >> 4) + fn(red() % 16);
			var greenStr:String = fn(green() >> 4) + fn(green() % 16);
			var blueStr:String  = fn(blue() >> 4) + fn(blue() % 16);
			
			return "#" + redStr + greenStr + blueStr;
		}
		
		public static function createWithWebString(str:String):Color
		{
			if (str.length != 7 || !Str.startsWith(str, "#"))
				throw new Error("invalid hex color \"" + str + "\"");
			
			var fn:Function = function(c:String):uint
			{
				if (c == "A")
					return 10;
				else if (c == "B")
					return 11;
				else if (c == "C")
					return 12;
				else if (c == "D")
					return 13;
				else if (c == "E")
					return 14;
				else if (c == "F")
					return 15;
				else
					return uint(c);
			};
			
			var r:uint = (fn(str.substr(1, 1)) << 4) | fn(str.substr(2, 1));
			var g:uint = (fn(str.substr(3, 1)) << 4) | fn(str.substr(4, 1));
			var b:uint = (fn(str.substr(5, 1)) << 4) | fn(str.substr(6, 1));
			return Color.createWithComponents(r, g, b);
		}
		
		public function assign(v:uint):void
		{
			value_ = v;
		}
		
		public function setRGB(r:uint, g:uint, b:uint):void
		{
			setRed(r);
			setGreen(g);
			setBlue(b);
		}
		public function setRGBA(r:uint, g:uint, b:uint, a:uint):void
		{
			setAlpha(a);
			setRed(r);
			setGreen(g);
			setBlue(b);
		}
		
		
		public function setAlpha(v:uint):void
		{
			if (v >= 0x800000)
				v = 0;
			else
				v = Math.min(v, 255);
			
			value_ &= 0x00ffffff;
			value_ |= (0xff & v) << 24;
		}
		public function setRed(v:uint):void
		{
			if (v >= 0x800000)
				v = 0;
			else
				v = Math.min(v, 255);
			
			value_ &= 0xff00ffff;
			value_ |= (0xff & v) << 16;
		}
		public function setGreen(v:uint):void
		{
			if (v >= 0x800000)
				v = 0;
			else
				v = Math.min(v, 255);
			
			value_ &= 0xffff00ff;
			value_ |= (0xff & v) << 8
		}
		public function setBlue(v:uint):void
		{
			if (v >= 0x800000)
				v = 0;
			else
				v = Math.min(v, 255);

			value_ &= 0xffffff00;
			value_ |= 0xff & v;
		}
		public function unitAlpha():Number
		{
			return Number(0xff & (value_ >> 24)) * HEX_2_UNIT;
		}
		public function alpha():uint
		{
			return 0xff & (value_ >> 24);
		}
		public function red():uint
		{
			return 0xff & (value_ >> 16);
		}
		public function green():uint
		{
			return 0xff & (value_ >> 8);
		}
		public function blue():uint
		{
			return 0xff & value_;
		}
		
		public function setValue(v:uint):void
		{
			value_ = v;
		}

		public function value():uint
		{
			return value_;
		}
		public function rgb():uint
		{
			return 0xffffff & value_;
		}

		public function mul(other:Color):void
		{
			var i:Number = 1.0/255.0;
			
			//var a1:Number = Number(alpha()) * i;
			var r1:Number = Number(red()) * i;
			var g1:Number = Number(green()) * i;
			var b1:Number = Number(blue()) * i;
			//var a2:Number = Number(other.alpha()) * i;
			var r2:Number = Number(other.red()) * i;
			var g2:Number = Number(other.green()) * i;
			var b2:Number = Number(other.blue()) * i;
			
			setRGBA(uint(r1*r2*255), uint(g1*g2*255), uint(b1*b2*255), alpha());//uint(a1*a2*255)); 
		}
		public function add(other:Color):void
		{
			var r:uint = red() + other.red();
			var g:uint = green() + other.green();
			var b:uint = blue() + other.blue();
			//var a:uint = alpha() + other.alpha();
			setRGBA(r>255?255:r, g>255?255:g, b>255?255:b, alpha());//a>255?255:a);
		}
		public function sub(other:Color):void
		{
			var r:int = red() - other.red();
			var g:int = green() - other.green();
			var b:int = blue() - other.blue();
			//var a:int = alpha() = other.alpha();
			setRGBA(r<0?0:r, g<0?0:g, b<0?0:b, alpha());//a<0?0:a);
		}
		public static function mulCopy(c1:Color, c2:Color):Color
		{
			var result:Color = new Color(c1.value_);
			result.mul(c2);
			return result;
		}

		public function toString():String
		{
			return "{a:" + alpha() + ", r:" + red() + ", g:" + green() + ", b:" + blue() + "}";
		}
		
		public static function rgbToHsv(rgb:Color):HSVColor
		{
			var r:Number = rgb.red() * HEX_2_UNIT; 
			var g:Number = rgb.green() * HEX_2_UNIT; 
			var b:Number = rgb.blue() * HEX_2_UNIT;  
			var min:Number = Math.min(r, Math.min(g, b)); 
			var max:Number = Math.max(r, Math.max(g, b)); 
			var delta:Number = max - min;  
			var value:Number = max; 
			var hue:Number, sat:Number;  
			if (max == 0 || delta == 0) 
				hue = sat = 0; 
			else 
			{ 
				sat = delta / max;  
				if (r == max) 
					hue = (g - b) / delta; 
				else if (g == max) 
					hue = 2 + (b - r) / delta; 
				else 
					hue = 4 + (r - g) / delta; 
				hue *= 60; 
				if (hue < 0) 
					hue += 360; 
			}  
			return new HSVColor(hue, sat, value);
		}
		// hue(0-360) sat(0-1) value(0-1)
		public static function hsvToRgb(hsv:HSVColor):Color
		{
			var sat:Number = hsv.sat;
			var value:Number = hsv.value;
			
			var r:Number, g:Number, b:Number;
			if (sat == 0)
				r = g = b = value;
			else
			{
				var hue:Number = hsv.hue * CIRCLE_2_UNIT;
				hue = (hue * 6) % 6;
				var i:Number = Math.floor(hue);
				var v1:Number = value * (1 - sat);
				var v2:Number = value * (1 - sat * (hue - i));
				var v3:Number = value * (1 - sat * (1 - (hue - i)));
				switch (i)                     
				{                        
				case 0:                            
					r = value;
					g = v3;                         
					b = v1;                   
					break;                      
				case 1:                             
					r = v2;                             
					g = value;                             
					b = v1;                             
					break;                                  
				case 2:                             
					r = v1;                             
					g = value;                             
					b = v3;                             
					break;                                  
				case 3:                             
					r = v1;                             
					g = v2;                             
					b = value;                             
					break;                                  
				case 4:                             
					r = v3;                             
					g = v1;                             
					b = value;                             
					break;                                  
				default:                             
					r = value;
					g = v1;
					b = v2;                             
					break;                     
				}                 
			}   
			return Color.createWithComponents(uint(r*255), uint(g*255), uint(b*255));
		}
	}
}














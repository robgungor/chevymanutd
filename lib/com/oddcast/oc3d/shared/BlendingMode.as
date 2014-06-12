package com.oddcast.oc3d.shared
{
	import flash.display.BlendMode;
	
	public class BlendingMode extends Enum
	{
		public function BlendingMode(id:uint){ super(id); }
		
		public static const Add:BlendingMode = new BlendingMode(1);
		public static const Subtract:BlendingMode = new BlendingMode(2);
		public static const Multiply:BlendingMode = new BlendingMode(3);
		public static const Darken:BlendingMode = new BlendingMode(4);
		public static const Difference:BlendingMode = new BlendingMode(5);
		public static const HardLight:BlendingMode = new BlendingMode(6);
		public static const Invert:BlendingMode = new BlendingMode(7);
		public static const Lighten:BlendingMode = new BlendingMode(8);
		public static const Overlay:BlendingMode = new BlendingMode(9);
		public static const Screen:BlendingMode = new BlendingMode(10);
		public static const Replace:BlendingMode = new BlendingMode(11);
		public static const Max:BlendingMode = new BlendingMode(12);
		
		public function convertToBlendMode():String
		{
			if (id == 1)
				return BlendMode.ADD;
			else if (id == 2)
				return BlendMode.SUBTRACT;
			else if (id == 3)
				return BlendMode.MULTIPLY;
			else if (id == 4)
				return BlendMode.DARKEN;
			else if (id == 5)
				return BlendMode.DIFFERENCE;
			else if (id == 6)
				return BlendMode.HARDLIGHT;
			else if (id == 7)
				return BlendMode.INVERT;
			else if (id == 8)
				return BlendMode.LIGHTEN;
			else if (id == 9)
				return BlendMode.OVERLAY;
			else if (id == 10)
				return BlendMode.SCREEN;
			else if (id == 11)
				return BlendMode.NORMAL;
			else
				throw new Error("unknown blend type " + id);
		}
		
		public function toString():String
		{
			if (id == 1)
				return "Add";
			else if (id == 2)
				return "Subtract";
			else if (id == 3)
				return "Multiply";
			else if (id == 4)
				return "Darken";
			else if (id == 5)
				return "Difference";
			else if (id == 6)
				return "HardLight";
			else if (id == 7)
				return "Invert";
			else if (id == 8)
				return "Lighten";
			else if (id == 9)
				 return "Overlay";
			else if (id == 10)
				return "Screen";
			else if (id == 11)
				return "Replace";
			else 
				throw new Error("unknown blend type");
		}
		public static function fromId(id:uint):BlendingMode
		{
			if (id == 1)
				return Add;
			else if (id == 2)
				return Subtract;
			else if (id == 3)
				return Multiply;
			else if (id == 4)
				return Darken;
			else if (id == 5)
				return Difference;
			else if (id == 6)
				return HardLight;
			else if (id == 7)
				return Invert;
			else if (id == 8)
				return Lighten;
			else if (id == 9)
				return Overlay;
			else if (id == 10)
				return Screen;
			else if (id == 11)
				return Replace;
			else
				return Multiply;//throw new Error("unknown blend type");
		}
		
		// fn:Function<BlendingMode>
		public static function forEachEnum(fn:Function):void
		{
			fn(Add);
			fn(Darken);
			fn(Difference);
			fn(HardLight);
			fn(Invert);
			fn(Lighten);
			fn(Multiply);
			fn(Overlay);
			fn(Screen);
			fn(Subtract);
			fn(Replace);
		}
	}
}
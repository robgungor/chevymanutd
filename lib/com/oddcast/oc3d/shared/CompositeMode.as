package com.oddcast.oc3d.shared
{
	public class CompositeMode extends Enum
	{
		public function CompositeMode (id:uint){ super(id); }

		public static const Normal:CompositeMode = new CompositeMode(1);
		public static const Mask:CompositeMode = new CompositeMode(2);
		public static const Decal:CompositeMode = new CompositeMode(3);
		
		public static function fromId(id:uint):CompositeMode 
		{
			if (id == 1)
				return Normal;
			else if (id == 2)
				return Mask;
			else if (id == 3)
				return Decal;
			else
				throw new Error("unknown composite mode");
		}
		
		public function toString():String
		{
			if (id == 1)
				return "Normal";
			else if (id == 2)
				return "Mask";
			else if (id == 3)
				return "Decal";
			else
				throw new Error("unknown composite mode");
		}
	}
}
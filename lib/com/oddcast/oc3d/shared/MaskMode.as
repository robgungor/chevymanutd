package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.shared.Enum;

	public class MaskMode extends Enum
	{
		public function MaskMode(id:uint){ super(id); }
		
		public static const PassThrough:MaskMode = new MaskMode(0);
		public static const Blocking:MaskMode = new MaskMode(1);
		
		public static function fromId(id:uint):MaskMode
		{
			if (id == 0)
				return PassThrough;
			else
				return Blocking;
		}
	}
}
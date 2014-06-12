package com.oddcast.ascom
{
	import com.oddcast.oc3d.external.*;

	public class DummyPropertyBagExchanger implements IPropertyBagExchanger
	{
		public static function init():void {}
		public function exchange(bag:IPropertyBag):IPropertyBag { return null; }
		public function unexchange(bag:IPropertyBag):IPropertyBag { return null; }
	}
}
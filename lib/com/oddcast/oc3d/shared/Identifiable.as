package com.oddcast.oc3d.shared
{
	public class Identifiable
	{
		public function debug__id():uint { return id_; }
		
		private static var counter_:uint = 0;
		private var id_:uint;
		
		public function Identifiable()
		{
			id_ = ++counter_;
		}
		
		public function id():uint
		{
			return id_;
		}
		
		protected function setId(v:uint):void
		{
			id_ = v;
		}
	}
}
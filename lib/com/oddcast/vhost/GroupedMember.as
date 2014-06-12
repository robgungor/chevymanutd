package com.oddcast.vhost
{
	import flash.display.MovieClip;
	
	public class GroupedMember
	{
		private var name:String;
		private var accId:uint;
		private var accUrl:String;
		private var attr:Array;
		private var mc:MovieClip;
		private var extData:Object;
		
		
		function GroupedMember(m:MovieClip,d:Object = null)
		{
			name = m.name;
			mc = m;
			attr = new Array();
			extData = d;			
		}
		
		public function getMC():MovieClip
		{
			return mc;
		}
		
		public function getName():String
		{
			return name;
		}
		
		public function getExtData():Object
		{
			return extData;
		}
	}
}
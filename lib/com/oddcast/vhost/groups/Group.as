package com.oddcast.vhost.groups
{
	import com.oddcast.vhost.GroupedMember;
	import flash.events.EventDispatcher;

	public class Group extends EventDispatcher
	{

		protected var name:String;
		protected var members:Array;
		private var saveStr:String;

		function Group(s:String)
		{
			
			name = s;			
			members = new Array();
		}
		
		public function addMember(hmc:GroupedMember):void
		{
			//Editor.traceOut("added "+hmc.getMC()+" to "+name+" group");
			//trace("added "+hmc.getMC()+" to "+name+" group");
			members.push(hmc);
		}
		
		public function getMembersArr(grp:String):Array
		{
			//trace("in getMembersArr");
			var arr:Array = new Array();
			for (var i in members)
			{
				if (members[i].getMC is Function)
				{
					//trace("in getMembersArr "+members[i].getMC()[grp]);
					if (members[i].getMC()[grp]!=undefined && members[i].getMC().visible)
					{
						arr[members[i].getMC()[grp]] = true;
					}
				}
			}
			return arr;
		}
		
		public function getMemberRefArr(grp:String,accType:String):Array
		{
			var retArr:Array = new Array();
			for (var i in members)
			{
				if (members[i].getMC is Function)
				{
					if (members[i].getMC()[grp]==accType && members[i].getMC().visible)
					{
						retArr.push(members[i].getMC());
					}
				}
			}
			return retArr;
		}
		
		public function getMembers():Array
		{
			var retArr:Array = new Array();
			for (var i in members)
			{
				if (members[i].getMC is Function)
				{
					retArr.push(members[i].getMC());
				}
			}
			return retArr;
		}
		
		public function getSize():uint
		{
			return members.length;
		}
		
		
			

	}
}
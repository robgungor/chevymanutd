package com.oddcast.mmo.data
{
	public class RoomData
	{		
		private var _iId:int;
		private var _sName:String;
		private var _iUsers:int;
		private var _iMaxUsers:int;
		
		public function RoomData(id:int,name:String,users:int=0,max:int=0)
		{
			_iId = id;
			_sName = name;
			_iUsers = users;
			_iMaxUsers = max;
		}
		
		public function getId():int
		{
			return _iId;
		}
		public function getName():String
		{
			return _sName;
		}
		public function getUsersCount():int
		{
			return _iUsers;
		}
		public function getMaxUsers():int
		{
			return _iMaxUsers;
		}	
		
		public function setUsersCount(i:int):void
		{
			_iUsers = i;
		}					

	}
}
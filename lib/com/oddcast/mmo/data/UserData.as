package com.oddcast.mmo.data
{	
	import com.oddcast.data.IThumbSelectorData;
							
	public class UserData implements IThumbSelectorData
	
	{
		private var _iId:int;
		private var _sName:String;	
		private var _sThumbUrl:String = "";
				
		public function UserData(id:int,name:String)
		{
				_iId = id;
				_sName = name;
		}		
		
		public function getId():int
		{
			return _iId;
		}
		
		public function getName():String
		{
			return _sName;
		}
		
		public function get thumbUrl():String
		{
			return _sThumbUrl;
		}
		
		public function set thumbUrl(s:String):void
		{
			_sThumbUrl = s;
		}
	}
}
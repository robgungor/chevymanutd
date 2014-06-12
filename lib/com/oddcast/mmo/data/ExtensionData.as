package com.oddcast.mmo.data
{	
							
	public class ExtensionData
	{
		private var _sCmd:String;
		private var _arrData:Array;		
				
		public function ExtensionData(cmd:String,data:Array)
		{
				_sCmd = cmd;
				_arrData = data;
				/*
				trace("ExtensionData::ExtensionData"); 
				for (var i in _arrData)
				{
					trace(i+"-->"+_arrData[i]);
				}
				*/						
		}		
		
		public function getCmd():String
		{
			return _sCmd;
		}

		public function getData():Array
		{
			return _arrData;
		}
		
		public function getDataByIndex(i:int):String
		{			
			var s:String = String(_arrData[i]);
			trace("ExtensionData::getDataByIndex i="+i+",s="+s); 
			return s;
		}
		
		public function toString():String
		{
			trace("ExtensionData "+_sCmd + ", "+_arrData.toString());
		}
		
	}
}
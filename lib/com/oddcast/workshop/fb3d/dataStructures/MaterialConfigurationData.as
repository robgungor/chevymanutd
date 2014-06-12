package com.oddcast.workshop.fb3d.dataStructures 
{
	import com.oddcast.oc3d.content.IAccessory;
	import com.oddcast.oc3d.content.IMaterialConfiguration;
	
	
	/**
	 * ...
	 * @author jachai
	 */
	public class MaterialConfigurationData 
	{
		
		private var _matConfig:IMaterialConfiguration;
		private var _accessory:IAccessory
		private var _sThumbUrl:String;
		public function MaterialConfigurationData(matConfig:IMaterialConfiguration) 
		{			
			_matConfig = matConfig;
			_accessory = _matConfig.parents([IAccessory])[0];
		}				
		
		public function set thumbUrl(s:String):void
		{
			_sThumbUrl = s;
		}
		
		public function get thumbUrl():String
		{
			return _sThumbUrl;
		}
		
		public function get id():int
		{
			return _matConfig.id();
		}
		
		public function get name():String
		{
			return _matConfig.name();
		}				
		
		public function get materialConfiguration():IMaterialConfiguration
		{
			return _matConfig;
		}
		
		public function get accessory():IAccessory
		{
			return _accessory;
		}
	}
	
}
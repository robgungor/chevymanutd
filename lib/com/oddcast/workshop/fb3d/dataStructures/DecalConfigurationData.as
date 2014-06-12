package com.oddcast.workshop.fb3d.dataStructures 
{	
	import com.oddcast.oc3d.content.IDecalConfiguration;
	
	
	/**
	 * ...
	 * @author jachai
	 */
	public class DecalConfigurationData 
	{
		
		private var _decalConfig:IDecalConfiguration;		
		private var _sThumbUrl:String;
		public function DecalConfigurationData(decalConfig:IDecalConfiguration) 
		{			
			_decalConfig = decalConfig;			
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
			return _decalConfig.id();
		}
		
		public function get name():String
		{
			return _decalConfig.name();
		}				
		
		public function get decalConfiguration():IDecalConfiguration
		{
			return _decalConfig;
		}
		
		public function get isSelected():Boolean
		{
			return _decalConfig.visible();
		}
	}
	
}
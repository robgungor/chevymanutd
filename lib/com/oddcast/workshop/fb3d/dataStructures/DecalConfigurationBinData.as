package com.oddcast.workshop.fb3d.dataStructures 
{	
	import com.oddcast.oc3d.content.IDecalConfigurationBin;
	import com.oddcast.oc3d.content.IDecalConfiguration;
	
	
	/**
	 * ...
	 * @author jachai
	 */
	public class DecalConfigurationBinData 
	{
		
		private var _decalConfigBin:IDecalConfigurationBin;		
		private var _sThumbUrl:String;
		public function DecalConfigurationBinData(decalConfigBin:IDecalConfigurationBin) 
		{			
			_decalConfigBin = decalConfigBin;			
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
			return _decalConfigBin.id();
		}
		
		public function get name():String
		{
			return _decalConfigBin.name();
		}				
		
		public function get decalConfigurationBin():IDecalConfigurationBin
		{
			return _decalConfigBin;
		}
		
		public function get isSelected():Boolean
		{
			var selected:Boolean;
			for each (var decalConfig:IDecalConfiguration in _decalConfigBin.children([IDecalConfiguration]))
			{
				if (decalConfig.visible())
				{
					selected = true;
				}
			}
			return selected;
		}
	}
	
}
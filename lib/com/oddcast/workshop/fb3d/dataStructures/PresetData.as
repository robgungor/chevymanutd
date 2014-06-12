package com.oddcast.workshop.fb3d.dataStructures 
{
	import com.oddcast.oc3d.content.IPreset;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class PresetData 
	{
		
		private var _preset:IPreset;
		private var _sThumbUrl:String;
		public function PresetData(preset:IPreset) 
		{			
			_preset = preset;
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
			return _preset.id();
		}
		
		public function get name():String
		{
			return _preset.name();
		}		
		
		public function get preset():IPreset
		{
			return _preset;
		}
		
	}
	
}
package com.oddcast.oc3d.shared
{
	public class ParameterInfo
	{
		public function ParameterInfo(name:String, type:Class, optional:Boolean)
		{
			this.name = name;
			this.type = type;
			this.optional = optional;
		}
		
		public var name:String;
		public var type:Class;
		public var optional:Boolean;
	}
}
package com.oddcast.oc3d.shared
{
	public class MethodInfo
	{
		public function MethodInfo(name:String, returnType:Class, parameters:Vector.<ParameterInfo>)
		{
			this.name = name;
			this.returnType = returnType;
			this.parameters = parameters;
		}
		
		public var name:String;
		public var returnType:Class;
		public var parameters:Vector.<ParameterInfo>; // Array<ParameterInfo>
	}
}
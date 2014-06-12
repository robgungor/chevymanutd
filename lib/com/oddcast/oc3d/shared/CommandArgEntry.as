package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.shared.CommandArgType;

	public class CommandArgEntry
	{
		private var name_:String;
		private var type_:CommandArgType;
		
		public function CommandArgEntry(name:String, type:CommandArgType)
		{
			name_ = name;
			type_ = type;
		}
		
		public function name():String
		{
			return name_;
		}
		
		public function type():CommandArgType
		{
			return type_;
		}
	}
}
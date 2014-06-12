package com.oddcast.workshop.fb3d.dataStructures 
{
	import com.oddcast.oc3d.shared.CommandArgEntry;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class CommandArgumentData 
	{
		
		private var _commandArg:CommandArgEntry;
		
		public function CommandArgumentData(commandArg:CommandArgEntry) 
		{			
			_commandArg = commandArg;
		}
						
		public function get name():String
		{
			return _commandArg.name();
		}		
		
		public function get typeName():String
		{
			return _commandArg.type().toString();
		}
		
		public function get typeClass():Class
		{
			return _commandArg.type().toReferringType();
		}
		
		public function get argEntry():CommandArgEntry
		{
			return _commandArg;
		}
		
	}
	
}
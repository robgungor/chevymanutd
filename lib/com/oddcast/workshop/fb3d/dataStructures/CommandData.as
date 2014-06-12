package com.oddcast.workshop.fb3d.dataStructures 
{	
	import com.oddcast.oc3d.content.ICommandProxy;
	import com.oddcast.oc3d.shared.CommandArgEntry;
	
	
	/**
	 * ...
	 * @author jachai
	 */
	public class CommandData 
	{
		
		private var _command:ICommandProxy;				
		
		public function CommandData(command:ICommandProxy) 
		{			
			_command = command;			
		}	
		
		public function get args():Vector.<CommandArgumentData>
		{
			var retVec:Vector.<CommandArgumentData> = new Vector.<CommandArgumentData>();
			for (var i:int = 0; i < _command.arguments().length; ++i)
			{
				retVec.push(new CommandArgumentData(_command.arguments()[i]));				
			}
			return retVec;
		}
		
		public function get argDescription():String
		{
			var s:String = "(";
			for (var i:int = 0; i < _command.arguments().length; ++i)
			{
				if (i != 0)
				{
						s += ",";
				}
					var typeName:String = CommandArgEntry(_command.arguments()[i]).type().toString();
					var argName:String = CommandArgEntry(_command.arguments()[i]).name()
					s += argName + ":" + typeName;					
				
			}
			s += ")";
			return s;
		}
		
		/**
		 * the name of the command
		 */		
		public function get name():String
		{
			if (_command != null)
			{
				return _command.name();			
			}
			else
			{
				return null;
			}
		}				
		
		/**
		 * get ICommand object (which you can execute)
		 */
		public function get command():ICommandProxy
		{
			return _command;
		}
		
		public function get description():String
		{
			if (_command != null)
			{
				return _command.description();		
			}
			else
			{
				return null;
			}
		}				
	}
	
}
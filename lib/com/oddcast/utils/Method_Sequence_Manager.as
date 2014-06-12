package com.oddcast.utils
{
	import flash.utils.Dictionary;

	public class Method_Sequence_Manager
	{
		/* method which starts the sequence */
		private var initial_method:Function;
		/* last method to be called once all sequences are completed */
		private var final_method:Function;
		/* holder of all methods */
		private var method_registry:Dictionary = new Dictionary();
		/* methods that have been called and not responded */
		private var methods_out:int;
		/* methods that have been called and responded */
		private var methods_back:int;
		
		// todo Method_Sequence_Manager: cancel
		// todo Method_Sequence_Manager: pause
		// todo Method_Sequence_Manager: chain (single non part of tree)
		// todo Method_Sequence_Manager: parallel (single non part of tree)
		
		/**
		 *  manages the calling sequence of methods
		 * @param _final_method called once the entire sequence is over
		 * 
		 */		
		public function Method_Sequence_Manager( _final_method:Function )
		{
			final_method = _final_method;
		}
		/**
		 * creates a sequence of async and sync callings 
		 * example:
		 	register_sequence( m1, [m2] );
			register_sequence(      m2, [m3, m4, m5] );
			register_sequence(                   m5, [m9] );
			register_sequence(                        m9, [m10] );
			register_sequence(               m4, [m6, m7, m8] );
			register_sequence(                            m8, [m11] );
			start_sequence();
		 * @param _method		starting method (needs to accept these args (_continue:Function, _key:Function)
		 * NOTE: when the method has finished its work it needs to call _continue(_key);
		 * @param _on_complete	array of methods to be called once _method is complete
		 * 
		 */		
		public function register_sequence( _method:Function, _on_complete:Array ):void 
		{
			if (initial_method == null)	
				initial_method = _method;	// starting point
			method_registry[_method] = _on_complete;
		}
		public function start_sequence():void 
		{
			initial_method(following_sequence, initial_method);
		}
		private function following_sequence( _key:Function ):void 
		{
			var continuing_methods:Array = method_registry[_key];
			methods_back++;
			if (continuing_methods)
			{
				var n:int = continuing_methods.length;
				methods_out += continuing_methods.length;
				for (var i:int; i < n; i++) 
					continuing_methods[i](following_sequence, continuing_methods[i]);
			}
			else if (methods_back>methods_out)
			{
				if (final_method!=null)
					final_method();
				final_method = null;
			}
		}
	}
}
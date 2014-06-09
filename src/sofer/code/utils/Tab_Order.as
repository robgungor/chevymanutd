package code.utils 
{
	import flash.display.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class Tab_Order
	{
		
		public function Tab_Order() 
		{}
		
		/**
		 * sets the tab order starting with _starting_index=0
		 * @param _list		array of InteractiveObject types (movieclip, textfield etc)
		 * @param _starting_index	
		 * 
		 */		
		public function set_order( _list:Array, _starting_index:int = 1 ):void 
		{	
			if (_list)
				for (var i:int = 0, n:int = _list.length; i < n; i++) 
				{	var cur:InteractiveObject = _list[i] as InteractiveObject;
					if (cur)	cur.tabIndex = _starting_index++;
				}
		}
		
	}
	
}
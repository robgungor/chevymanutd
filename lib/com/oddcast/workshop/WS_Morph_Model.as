package com.oddcast.workshop 
{
	
	/**
	 * ...
	 * @author Me^
	 */
	public class WS_Morph_Model 
	{
		/* the face of the model */
		public var face_model:WSModelStruct;
		/* the head of the model */
		public var head_model:WSModelStruct;
		
		/**
		 * creates NEW model objects based on the ones passed in
		 * @param	_face the face of the model (this will be cloned)
		 * @param	_head the head of the model (this will be cloned)
		 */
		public function WS_Morph_Model( _face:WSModelStruct, _head:WSModelStruct)
		{
			face_model = _face.clone();
			head_model = _head.clone();
		}
		
	}
	
}
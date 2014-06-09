package code.controllers.myspace_connect 
{
	/**
	 * ...
	 * @author Me^
	 */
	public class User_Images_List
	{
		
		/* array of Image_Item class */
		public var images:Array;
		/**
		 * builds an array if images for a user
		 * @param	_xml myspace xml with data about the users images
		 */
		public function User_Images_List( _xml:XML )
		{
			images = new Array();
			var ns				:Namespace	= _xml.namespace();
			var photos			:XML		= new XML(_xml.ns::photos);
			ns								= photos.namespace();
			var num_of_photos	:int		= photos.ns::photo.length();
			for (var i:int = 0; i < num_of_photos; i++ )
			{
				var cur_photo		:XML		= new XML(photos.ns::photo[i]);
				var photo_ns		:Namespace	= cur_photo.namespace();
				
				var photo_url		:String		= cur_photo.ns::imageuri;
				var thumb_url		:String		= cur_photo.ns::smallimageuri;
				var id				:String		= cur_photo.ns::photoid;
				images.push( new Image_Item( photo_url, thumb_url, id ) );
			}
		} 
		
	}

}
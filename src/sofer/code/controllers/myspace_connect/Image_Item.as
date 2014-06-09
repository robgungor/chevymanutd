package code.controllers.myspace_connect 
{
	/**
	 * ...
	 * @author Me^
	 */
	public class Image_Item
	{
		
		public var image_url:String;
		public var thumb_url:String;
		/* image id or friend id */ 
		public var id:String;
		/**
		 * image struct item
		 * @param	_image_url url of the full size image
		 * @param	_thumb_url url of the thumbnail
		 * @param	_id id of the image or id of the friend
		 */
		public function Image_Item( _image_url:String, _thumb_url:String, _id:String )
		{
			image_url	= _image_url;
			thumb_url	= _thumb_url;
			id			= _id;
		}
		
	}

}
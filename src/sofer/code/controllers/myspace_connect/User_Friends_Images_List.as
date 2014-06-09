package code.controllers.myspace_connect 
{
	/**
	 * ...
	 * @author Me^
	 */
	public class User_Friends_Images_List
	{
		
		/* array of Image_Item class */
		public var images:Array;
		/**
		 * builds an array if images for a users' friends
		 * @param	_xml myspace xml with data about the users friends images
		 */
		public function User_Friends_Images_List( _xml:XML )
		{
			images = new Array();
			var ns				:Namespace	= _xml.namespace();
			var friends			:XML		= new XML(_xml.ns::friends);
			ns								= friends.namespace();
			var num_of_photos	:int		= friends.ns::user.length();
			for (var i:int = 0; i < num_of_photos; i++ )
			{
				var cur_user		:XML		= new XML(friends.ns::user[i]);
				var user_ns			:Namespace	= cur_user.namespace();
				
				var photo_url		:String		= cur_user.ns::largeimageuri;
				var thumb_url		:String		= cur_user.ns::imageuri;
				var id				:String		= cur_user.ns::userid;
				images.push( new Image_Item( photo_url, thumb_url, id ) );
			}
		} 
		
	}

}
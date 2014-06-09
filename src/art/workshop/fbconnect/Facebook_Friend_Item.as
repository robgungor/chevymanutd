package workshop.fbconnect 
{
	/**
	 * ...
	 * @author Me^
	 */
	public class Facebook_Friend_Item
	{
        public var img_thumb_url:String;
        public var name:String;
        public var user_id:String;
        public var filter_str:String;
        public var img_large_url:String;
		
		public function Facebook_Friend_Item(_filter_str:String, _name:String, _img_large_url:String, _img_thumb_url:String, _user_id:String) 
		{
			filter_str 		= _filter_str;
            name 			= _name;
            img_large_url 	= _img_large_url;
            img_thumb_url 	= _img_thumb_url;
            user_id 		= _user_id;
		}
		
	}

}
package code.controllers.myspace_connect 
{
	/**
	 * ...
	 * @author Me^
	 */
	public class Myspace_User
	{
		
		/* needed for getting logged in users info */
		public var token				:String;
		/* needed for getting logged in users info */
		public var token_secret			:String;
		/* display name of the user */
		public var name					:String;
		/* myspace user id */
		public var user_id				:String;
		/* large image url */
		public var image_url			:String;
		/* thumnail image of the user */
		public var thumb_url			:String;
		/* user is logged in or not */
		public var is_logged_in			:Boolean = false;
		
		public function Myspace_User() { }
	}

}
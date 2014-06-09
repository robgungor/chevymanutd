package code.controllers.facebook_connect
{
	public interface IFacebook_Connect
	{
		function open_win(  ):void;
		function close_win(  ):void;
		function is_logged_in():Boolean;
		function login( _on_logged_in_callback:Function = null ):void;
		function fbcGetFriendsInfo( _fin:Function, _include_self:Boolean = true, _max_return:int = -1 ):void
		function getUserPictures($callback:Function):void;
		function fbcGetFriendsPictures( _fin:Function, _friends_id:String ):void;
		function fbcGetPicturesFromAlbums( _fin:Function, _user_id:String = null, _max_photos:Number=300 ):void;
		function fbcGetUserPicturesTaggedAndAlbumsCombo( _fin:Function, _user_id:String = null, _max_photos:Number=300 ):void;
		function user_id():String;
		function post_new_mid_to_user( _user_id:String = null, _thumb_url:String = null ):void;
	}
}
package com.oddcast.workshop.Persistent_Image 
{
	/**
	 * ...
	 * @author Me^
	 */
	public interface IPersistent_Image
	{
		/**
		 * initialize the engine for usage
		 * @param	_fg_param FG params from getWorkshopInfo
		 * @param	_api_stem_url what domain are the scripts on (eg: http://host.staging.oddcast.com)
		 * @param	_fb_username facebook username that the user is loggen in with now
		 * @param	_ready_callback operation completed callback
		 * @param	_update_images_needed_callback callback when the current displayed images have to be removed
		 */
		function initialize( _fg_param:String, _api_stem_url:String, _fb_username:String, _ready_callback:Function, _update_images_needed_callback:Function ):void
		function save_image( _autophoto_xml:XML, _ready_callback:Function ):void
		/**
		 * downloads the photo list from the server 
		 * @param	_list_ready_callback callback when the list is ready for access
		 */
		function prepare_photo_list( _list_ready_callback:Function ):void
		/**
		 * notify the server that a specific image was used
		 * @param	_image_id id of the image needed for identifiaction
		 * @param	_ready_callback callback when everything is finished
		 */
		function image_selected( _image_id:String, _ready_callback:Function ):void
		/**
		 * delete the image from the server db for this user
		 * @param	_image_id id of the image needed for identifiaction
		 * @param	_ready_callback callback when everything is finished
		 */
		function remove_image( _image_id:String, _ready_callback:Function ):void
		/**
		 * user has logged into facebook with a new username
		 * @param	_facebook_user_name username of the new login
		 * @param	_ready_callback callback when everything is finished
		 */
		function user_logged_into_facebook( _facebook_user_name:String, _ready_callback:Function ):void
		/**
		 * once a list is prepared this will return an item in that list
		 * @param	_image_index array index for the specified item
		 * @return
		 */
		function get_image( _image_index:int ):IPersistent_Image_Item
		/**
		 * returns the length of the array of images
		 * @return
		 */
		function get_num_of_images(  ):int
	}
	
}
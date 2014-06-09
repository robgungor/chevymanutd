package code.controllers.email
{
	import code.controllers.popular_media.Popular_Media_Contact_Item;

	public interface IEmail
	{
		function add_recipient(_contact:Popular_Media_Contact_Item):Boolean;
		function remove_recipient(_contact:Popular_Media_Contact_Item):void;
		function get_recipient_list():Array;
	}
}
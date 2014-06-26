package code.skeleton.mediator
{
	import code.controllers.MakeAnother;
	import code.controllers.alert.IAlert;
	import code.controllers.auto_photo.apc.Auto_Photo_APC;
	import code.controllers.auto_photo.apc.IAuto_Photo_APC;
	import code.controllers.auto_photo.auto_photo.IAuto_Photo;
	import code.controllers.auto_photo.browse.IAuto_Photo_Browse;
	import code.controllers.auto_photo.mask.Auto_Photo_Mask;
	import code.controllers.auto_photo.mask.IAuto_Photo_Mask;
	import code.controllers.auto_photo.mode_selector.IAuto_Photo_Mode_Selector;
	import code.controllers.auto_photo.points.IAuto_Photo_Points;
	import code.controllers.auto_photo.position.Auto_Photo_Position;
	import code.controllers.auto_photo.position.IAuto_Photo_Position;
	import code.controllers.auto_photo.search.IAuto_Photo_Search;
	import code.controllers.auto_photo.webcam.IAuto_Photo_Webcam;
	import code.controllers.backgrounds.IBG_Selector;
	import code.controllers.bigshow.BigShow;
	import code.controllers.bitly_url.IBitly_Url;
	import code.controllers.body_position.IBody_Position;
	import code.controllers.email.IEmail;
	import code.controllers.facebook_connect.Facebook_Connect;
	import code.controllers.facebook_connect.IFacebook_Connect;
	import code.controllers.facebook_friend.Facebook_Friend_Post;
	import code.controllers.facebook_friend.IFacebook_Friend_Search;
	import code.controllers.google_connect.Google_Connect;
	import code.controllers.jpg_export.IJPG_Export;
	import code.controllers.main_loader.IMain_Loader;
	import code.controllers.message_player.IMessage_Player;
	import code.controllers.myspace_connect.IMyspace_Connect;
	import code.controllers.persistent_image.IPersistent_Image;
	import code.controllers.preview.Preview;
	import code.controllers.processing.IProcessing;
	import code.controllers.renren_connect.RenRen_Connect;
	import code.controllers.terms_conditions.Terms_Conditions;
	import code.controllers.twitter_connect.Twitter_Connect;
	import code.controllers.vhost_back_selection.IVhost_Back_Selection;
	import code.controllers.vhost_selection.IVhost_Selection;
	import code.controllers.weibo_connect.Weibo_Connect;
	
	import custom.DanceScene;
	import custom.PhotoMaskingScreen;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	/**
	 * Stores developer predefined references to controllers for access
	 * 
	 * @author Me^
	 * 
	 */
	public class Controller_Pool
	{
		// NOTE declare the controllers here that you will need a reference to
		
		// autophoto
		public var auto_photo_apc			:Auto_Photo_APC;
		public var auto_photo				:IAuto_Photo;
		public var auto_photo_browse		:IAuto_Photo_Browse;
		public var auto_photo_mask			:PhotoMaskingScreen;
		public var auto_photo_mode_selector	:IAuto_Photo_Mode_Selector;
		public var auto_photo_points		:IAuto_Photo_Points;
		public var auto_photo_position		:Auto_Photo_Position;
		public var auto_photo_search		:IAuto_Photo_Search;
		public var auto_photo_webcam		:IAuto_Photo_Webcam;
		
		// full body
		public var body_position			:IBody_Position;
		
		// generic
		public var alert					:IAlert;
		public var bg_selection				:IBG_Selector;
		public var bitly_url				:IBitly_Url;
		public var email					:IEmail;
		public var facebook_connect			:Facebook_Connect;
		public var facebook_friend_search	:IFacebook_Friend_Search;
		public var jpg_export				:IJPG_Export;
		public var main_loader				:IMain_Loader;
		public var message_player			:IMessage_Player;
		public var vhost_selection_back		:IVhost_Back_Selection;
		public var vhost_selection			:IVhost_Selection;
		public var myspace_connect			:IMyspace_Connect;
		public var persistent_image			:IPersistent_Image;
		public var processing				:IProcessing;
		public var terms_conditions			:Terms_Conditions;
		public var dance_scene				:DanceScene;
		public var facebook_friend_post		:Facebook_Friend_Post;
		public var makeAnother				:MakeAnother;
		public var preview					:Preview;
		public var google_connect			:Google_Connect;
		public var renren_connect			:RenRen_Connect;
		public var weibo_connect			:Weibo_Connect;
		public var twitter_connect			:Twitter_Connect;
		public var bigShow					:BigShow;
		// popular media
//		public var pupular_media_contact_selector	:IPopular_Media_Contact_Selector;
//		public var pupular_media_login				:IPopular_Media_Login;
		
		public function Controller_Pool()
		{
		}
		
		/**
		 * stores a reference to a class if one is declared properly* for the mediator to communicate with
		 * @param _interface if youre adding code.controllers.Alert make sure there is a local variable in Controller_Pool of type Alert or whatever Interface it implements IAlert for example
		 * @return true if the class was registerred
		 * 
		 */		
		public function register_controller( _interface:* ) : Boolean
		{
			/*
			<type name="code.skeleton::Controller_Pool" base="Object" isDynamic="false" isFinal="false" isStatic="false">
				<extendsClass type="Object"/>
				<variable name="bg_selection" type="code.controllers.backgrounds::IBackgrounds"/>
				<variable name="search" type="code.controllers.auto_photo::IAuto_Photo_Search"/>
				<variable name="points" type="code.controllers.auto_photo::IAuto_Photo_Points"/>
				...
			</type>
			*/
			var controller_pool_properties:XML = describeType(this);
			var var_name:String, var_type:String, var_node:XML, var_claz:Class, var_found:Boolean = false;
				
			loop1: for (var i:int = 0, n:int = controller_pool_properties.variable.length(); i<n; i++ )
			{
				var_node = controller_pool_properties.variable[i];		// <variable name="search" type="code.controllers.auto_photo::IAuto_Photo_Search"/>
				var_name = var_node.@name;								// search : String
				var_type = var_node.@type.split('::').join('.');		// code.controllers.auto_photo.IAuto_Photo_Search : String
				var_claz = getDefinitionByName( var_type ) as Class;	// IAuto_Photo_Search : Class
				
				if (_interface is var_claz)
				{	
					this[ var_name ] = _interface;
					var_found = true;
					break loop1;
				}
			}
			
			return var_found;	// indicate to the controller that this class was registerred or not
		}
	}
}
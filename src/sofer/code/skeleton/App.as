package code.skeleton 
{
	import code.skeleton.mediator.Mediator;
	
	import com.oddcast.utils.Keyboard_Shortcuts;
	import com.oddcast.utils.Listener_Manager;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class App 
	{
		public static var listener_manager	:Listener_Manager			= new Listener_Manager();
		public static var shortcut_manager	:Keyboard_Shortcuts			= new Keyboard_Shortcuts();
		/** application mediator btw controllers, since controllers are not meant to communicate with each other they are connected via the mediator */
		public static var mediator			:Mediator					= new Mediator();
		/** contains all the workshops data structs */
		public static var asset_bucket		:Asset_Bucket				= new Asset_Bucket();
		/** contains utilities needed by multiple controllers */
		public static var utils				:Utils						= new Utils();
		/**  */
		public static var settings			: Settings					= new Settings();
		/** root of the art holder */
		public static var ws_art			: WS_Art;
		public static var localizer			: Localizer					= new Localizer();
	}
	
}
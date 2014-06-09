package player 
{
	import com.oddcast.player.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.display.MovieClip;
	
	import player.holder.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class App
	{
		public static const COMPILATION_TIME	:String = '1008271444';
		
		public static var scene					:StandaloneDanceScene;
		public static var controls				:VideoControls;
		/* vhss_v5 player at the moment */
		public static var vhss_player			:IInternalPlayerAPI;
		/* will have a value once the message is loaded for your convenience */
		public static var message_data			:WorkshopMessage;
		public static var holder_avatar			:Avatar_Holder;
		public static var holder_bg				:BG_Holder;
		public static var alert					:Alert;
		public static var loader				:Processing;
		public static var my_root				:MovieClip;
		public static var dance_swf				:MovieClip;
		public static var preroll_swf			:MovieClip;
		// components
		public static var tracking_manager		:Tracking_Manager = new Tracking_Manager();
		public static var aps_transmitter		:APS_Transmitter = new APS_Transmitter();
		public static var shared_object			:Shared_Object = new Shared_Object();
		public static var listener_manager		:Listener_Manager = new Listener_Manager();
		public static var shortcut_manager		:Keyboard_Shortcuts = new Keyboard_Shortcuts();
	}

}
package com.oddcast.workshop
{
	import com.oddcast.event.VHSSEvent;
	import com.oddcast.player.IInternalPlayerAPI;
	import com.oddcast.player.PlayerInitFlags;
	import com.oddcast.utils.Listener_Manager;
	import com.oddcast.utils.Method_Sequence_Manager;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;

	public class VHSS_Player_Controller
	{
		public var player_api:IInternalPlayerAPI;
		public var mid_message:WorkshopMessage;
		
		private var config:Config;
		
		public function VHSS_Player_Controller()
		{
			
		}
		
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * **************************************** PUBLIC ***/
		public function load_and_init( _mid:int, 
									   _player_url:String, 
									   _player_holder:Sprite, 
									   _vhost_holder:Sprite, 
									   _bg_holder:Sprite, 
									   _full_body_mask:DisplayObject,
									   _callbacks:Callback_Struct, 
									   _talk_started:Function,
									   _talk_ended:Function,
									   _listener_manager:Listener_Manager,
									   _shared_objects_allowed:Boolean = true):void
		{
			config = new Config( 	_mid, 
									_player_url, 
									_player_holder, 
									_vhost_holder, 
									_bg_holder, 
									_full_body_mask, 
									_callbacks, 
									_talk_started, 
									_talk_ended, 
									_listener_manager,
									_shared_objects_allowed);
			
			var msm:Method_Sequence_Manager = new Method_Sequence_Manager( sequence_complete );
			msm.register_sequence(		load,				[init_loaded_player,
															add_player_to_holder,
															wait_on_scene_to_load,
															add_talk_events
															]);
			msm.register_sequence(	wait_on_scene_to_load,	[create_mid_struct,
															place_bg,
															place_vhost,
															]);
			msm.start_sequence();
			
			function sequence_complete():void
			{
				// player loaded and initialized, waiting on it to load assets
				if (config.callbacks && config.callbacks.fin != null)
					config.callbacks.fin();
			}
		}
		public function destroy():void
		{
			var do_vhss_player:DisplayObject = DisplayObject(player_api);
			var do_host_holder:DisplayObject = player_api.getHostHolder();
			var do_bg_holder:DisplayObject = player_api.getBGHolder();
			
			if (do_vhss_player && do_vhss_player.parent)
				do_vhss_player.parent.removeChild(do_vhss_player);
			if (do_host_holder && do_host_holder.parent)
				do_host_holder.parent.removeChild(do_host_holder);
			if (do_bg_holder && do_bg_holder.parent)
				do_bg_holder.parent.removeChild(do_bg_holder);
			
			config.listener_manager.remove_all_listeners_on_object( player_api );
			config.destroy();
			
			mid_message = null;
			player_api = null;
			config = null;
		}
		/*****************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * **************************************** SEQUENCE METHODS ***/
		private function load( _continue:Function, _key:Function ):void
		{
			var request:Gateway_Request = new Gateway_Request( config.player_url, new Callback_Struct( fin, progress, error ) )
			request.response_eval_method = response_eval;
			Gateway.retrieve_Loader( request );
			
			function response_eval( _content:Loader ):Boolean
			{
				return (_content && _content.content && _content.content is IInternalPlayerAPI);
			}
			function fin( _content:Loader ) : void
			{
				player_api = _content.content as IInternalPlayerAPI;
				_continue(_key);//continue sequence
			}
			function progress( _percent:int ) : void
			{
				if (config.callbacks && config.callbacks.progress != null )
					config.callbacks.progress( _percent );
			}
			function error( _msg:String ) : void 
			{
				player_error( 'cannot load/cast vhss player' );
			}
		}
		private function init_loaded_player( _continue:Function, _key:Function ):void
		{
			player_api.setPlayerInitFlags(	//PlayerInitFlags.IGNORE_PLAY_ON_LOAD | 
											//PlayerInitFlags.SUPPRESS_EXPORT_XML | 
											PlayerInitFlags.TRACKING_OFF | 
											PlayerInitFlags.SUPPRESS_3D_OFFSET | 
											PlayerInitFlags.DISABLE_SHARED_OBJECT_COOKIES );
			
			// full body 3d space
			var fullbody_width:Number = config.full_body_mask.width;
			var fullbody_height:Number = config.full_body_mask.height;
			player_api.set3DSceneSize(fullbody_width, fullbody_height);
			
			_continue(_key);//continue sequence
		}
		private function add_player_to_holder( _continue:Function, _key:Function ):void
		{
			// add vhss player to display list
			if (config.player_holder)
				config.player_holder.addChild(DisplayObject(player_api));
			_continue(_key);//continue sequence
		}
		private function wait_on_scene_to_load( _continue:Function, _key:Function ):void
		{
			config.listener_manager.add_multiple_by_event(player_api, [	VHSSEvent.SCENE_LOADED,
																		VHSSEvent.PLAYER_XML_ERROR,
																		VHSSEvent.MODEL_LOAD_ERROR] , vhss_event_handler, this );
			function vhss_event_handler(_e:VHSSEvent):void
			{
				switch ( _e.type )
				{
					case VHSSEvent.SCENE_LOADED :
						_continue(_key);//continue sequence
						break;
					case VHSSEvent.PLAYER_XML_ERROR :
						player_error(VHSSEvent.PLAYER_XML_ERROR);
						break;
					case VHSSEvent.MODEL_LOAD_ERROR :
						player_error(VHSSEvent.MODEL_LOAD_ERROR);
						break;
				}
			}
		}
		private function add_talk_events( _continue:Function, _key:Function ):void
		{
			if (config.talk_started != null)
				config.listener_manager.add(player_api,VHSSEvent.TALK_STARTED,vhss_event_handler,this);
			if (config.talk_ended != null)
				config.listener_manager.add(player_api,VHSSEvent.TALK_ENDED,vhss_event_handler,this);
				
			_continue(_key);//continue sequence
				
			function vhss_event_handler( _e:VHSSEvent ):void
			{
				switch ( _e.type )
				{
					case VHSSEvent.TALK_ENDED:			
						config.talk_ended();
						break;
					case VHSSEvent.TALK_STARTED:		
						config.talk_started();
						break;
				}
			}
		}
		private function create_mid_struct( _continue:Function, _key:Function ) : void
		{
			mid_message = new WorkshopMessage( config.mid );
			mid_message.parseXML( player_api.getShowXML() );
			_continue(_key);//continue sequence
		}
		private function place_bg( _continue:Function, _key:Function ):void
		{
			if (mid_message.bg &&
				mid_message.extraData && 
				mid_message.extraData.bgPos &&
				config.bg_holder)
			{
				var bg:Sprite = player_api.getBGHolder();
				config.bg_holder.addChild( bg );
				var bgPosArr:Array = mid_message.extraData.bgPos.split(",");
				bg.x 		= bgPosArr[0];
				bg.y 		= bgPosArr[1];
				bg.scaleX	= bgPosArr[2];
				bg.scaleY	= bgPosArr[2];
				bg.rotation = bgPosArr[3];
			}
			_continue(_key);//continue sequence
		}
		private function place_vhost( _continue:Function, _key:Function ):void
		{
			if (config.vhost_holder)
				config.vhost_holder.addChild( player_api.getHostHolder() );
			_continue(_key);//continue sequence
		}
		/*****************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * **************************************** PRIVATE ***/
		private function player_error( _msg:String ):void
		{
			if (config.callbacks && config.callbacks.error != null)
				config.callbacks.error( _msg );
		}
		/*****************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
	}
}










import com.oddcast.utils.Listener_Manager;
import com.oddcast.workshop.Callback_Struct;

import flash.display.DisplayObject;
import flash.display.Sprite;

class Config
{
	/**  */
	public var player_url		: String;
	public var callbacks		: Callback_Struct;
	public var talk_started		: Function;
	public var talk_ended		: Function;
	public var player_holder	: Sprite;
	public var bg_holder		: Sprite;
	public var full_body_mask	: DisplayObject;
	public var vhost_holder		: Sprite;
	public var listener_manager	: Listener_Manager;
	public var mid				: int;
	public var shared_objects_allowed : Boolean;

	public function Config ( _mid:int, 
							 _player_url:String,
							 _player_holder:Sprite, 
							 _vhost_holder:Sprite, 
							 _bg_holder:Sprite, 
							 _full_body_mask:DisplayObject,
							 _callbacks:Callback_Struct, 
							 _talk_started:Function,
							 _talk_ended:Function,
							 _listener_manager:Listener_Manager,
							 _shared_objects_allowed:Boolean = true)
	{
		mid = _mid;
		player_url = _player_url;
		callbacks = _callbacks;
		talk_started = _talk_started;
		talk_ended = _talk_ended;
		player_holder = _player_holder;
		bg_holder = _bg_holder;
		full_body_mask = _full_body_mask;
		vhost_holder = _vhost_holder;
		listener_manager = _listener_manager;
		shared_objects_allowed = _shared_objects_allowed; 
	}
	public function destroy():void
	{
		player_holder = null;
		bg_holder = null;
		vhost_holder = null;
		talk_ended = null;
		talk_started = null;
		listener_manager = null;
		callbacks = null;
	}
}
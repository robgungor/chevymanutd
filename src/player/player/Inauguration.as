package player 
{
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.VHSSEvent;
	import com.oddcast.player.IInternalPlayerAPI;
	import com.oddcast.player.PlayerInitFlags;
	import com.oddcast.utils.Method_Sequence_Manager;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ErrorReporter;
	import com.oddcast.workshop.ExternalInterface_Proxy;
	import com.oddcast.workshop.SceneStruct;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSBackgroundStruct;
	import com.oddcast.workshop.WorkshopMessage;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.media.SoundMixer;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * ...
	 * @author Me^
	 */
	public class Inauguration
	{
		private const VHSS_PLAYER_URL		:String = 'player_vhss.swf';
		private var player_container:MovieClip;
		
		
		/**
		 * Loads all the assets needed for playback
		 * @param	_loader_info		player loaderInfo
		 * @param	_player_container	where the vhss player will be added to the display list
		 * @param	_fin				finished callback
		 */
		public function Inauguration( _loader_info:LoaderInfo, _player_container:MovieClip, _fin:Function ):void
		{
			player_container = _player_container;
			
			ServerInfo.setLoaderInfo(_loader_info);
			
			// for places like facebook where they set scaleMode = NO_SCALE and edges are cut off
		/*	if (_player_container && _player_container.stage)
				_player_container.stage.scaleMode = StageScaleMode.SHOW_ALL;
		*/	
			var msm:Method_Sequence_Manager = new Method_Sequence_Manager( sequence_fin );
			
			msm.register_sequence( set_context_menu,	[ load_gwi] );
			//msm.register_sequence( load_gwi, 			[ load_vhss_player ] );
			//msm.register_sequence( load_message, 			[ load_dance] );
			
			msm.register_sequence( load_gwi, 	[ init_misc,
													load_message]);
			msm.register_sequence( load_message, 		[ load_preroll, load_dance] ); 
														 
														//add_vhss_to_stage,
														//wait_on_message_to_load ] );
			msm.register_sequence( load_dance, [position_background] );
			msm.start_sequence();
			
			function sequence_fin():void
			{
				_fin();
			}
		}
		public function error_initializing( _msg:String ):void
		{
			var text:String = Alert.ERROR_LOADING_PLAYBACK;
			if (App.aps_transmitter.is_in_APS_mode)
				text += '\n\n' + _msg;
			App.alert.alert_user( new AlertEvent(AlertEvent.ERROR, '', text, {details:_msg}));
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
		 * 
		 * 
		 * ********************************** SEQUENCE METHODS *****/
		
		private function set_context_menu(_continue:Function, _key:Function):void
		{
			var myMenu:ContextMenu = new ContextMenu();
			myMenu.hideBuiltInItems();
			
			var menu_item_oddcast:ContextMenuItem 		= new ContextMenuItem("Powered By Oddcast");
			//App.listener_manager.add( menu_item_oddcast, ContextMenuEvent.MENU_ITEM_SELECT, App.controls.open_oddcast, this );
			myMenu.customItems.push(menu_item_oddcast);
			player_container.contextMenu = myMenu;
			
			_continue(_key);// continue sequence
		}
		private function load_gwi( _continue:Function, _key:Function ) : void
		{
			if (ServerInfo.stem_gwi && ServerInfo.stem_gwi.indexOf('://') > 0)
			{
				Gateway.retrieve_XML( ServerInfo.stem_gwi, new Callback_Struct( fin, null, error ));
				function fin( _content:XML ):void 
				{	
					ServerInfo.parseXML( _content );
					_continue(_key);// continue sequence
				}
				function error( _msg:String ):void 
				{	error_initializing( 'Error Initializing (gwi)' );
				}
			}
			else
				error_initializing('invalid get workshop info url');
		}
		private function load_vhss_player( _continue:Function, _key:Function ) : void
		{
			var url:String;
			var play_scene_url:String = ServerInfo.acceleratedURL + "php/api/playScene/doorId=" + ServerInfo.door + "/clientId=" + ServerInfo.client + "/mId=" + ServerInfo.mid;
			
			if (App.aps_transmitter.is_in_APS_mode)
				url = VHSS_PLAYER_URL + '?doc='+play_scene_url;
			else
				url = ServerInfo.default_url + 'swf/' + VHSS_PLAYER_URL + '?doc=' + play_scene_url;	
			
			var request:Gateway_Request = new Gateway_Request( url, new Callback_Struct( fin, null, error ) );
			request.response_eval_method = response_eval;
			Gateway.retrieve_Loader( request );
			function response_eval( _content:Loader ) : Boolean
			{
				return (_content && 
						_content.content &&
						(_content.content is IInternalPlayerAPI) );
			}
			function fin( _content:Loader ) : void
			{
				App.vhss_player = _content.content as IInternalPlayerAPI;
				_continue( _key );// continue sequence
			}
			function error( _msg:String ) : void 
			{
				error_initializing( 'Error initializing (vhss player)' );
			}
		}
		private function init_player( _continue:Function, _key:Function ) : void
		{
			var mask_width:Number = App.holder_avatar.width;
			var mask_height:Number = App.holder_avatar.height;
			App.vhss_player.set3DSceneSize(mask_width, mask_height);
			
			App.vhss_player.setPlayerInitFlags( /*PlayerInitFlags.IGNORE_PLAY_ON_LOAD | PlayerInitFlags.SUPPRESS_EXPORT_XML |*/ PlayerInitFlags.TRACKING_OFF | PlayerInitFlags.SUPPRESS_3D_OFFSET );
			
			_continue( _key );// continue sequence
		}
		private function load_message(_continue:Function, _key:Function):void
		{
			var _mid:String = ServerInfo.mid;
			var doc_query	:String = ServerInfo.acceleratedURL + 'php/api/playScene/doorId=' + ServerInfo.door + '/clientId=' + ServerInfo.client + '/mId=' + _mid;
			Gateway.retrieve_XML( doc_query, new Callback_Struct( fin, progress, error ) );
			
			function fin( _xml:XML ):void 
			{	
				
				var mid_message:WorkshopMessage = new WorkshopMessage( parseInt(_mid) );
				mid_message.parseXML( _xml);
				
				App.message_data = mid_message;
				_continue(_key);
			}	
			function progress(percent:Number):void
			{
				App.loader.load_bar.gotoAndStop(Math.round(percent*.5));
			}
			function error( _msg:String ):void 
			{
				App.alert.alert_user( new AlertEvent(AlertEvent.ERROR, '', doc_query, {details:doc_query}));
				//error_initializing('Could not load message');
			}
		}
		private function load_preroll(_continue:Function, _key:Function):void
		{
			var swfURL:String = ServerInfo.content_url_door + "misc/preroll.swf";
			Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( fin, progress, error ) ) );
			function fin( l:Loader):void
			{
				App.preroll_swf = l.content as MovieClip;
				App.preroll_swf.stop();
				
				SoundMixer.stopAll();
				_continue(_key);
			}
			function progress(percent:Number):void
			{
				App.loader.load_bar.gotoAndStop(20+Math.round(percent*.8));
			}
			function error( _msg:String ):void 
			{
				error_initializing('Could not load dance.');
			}
		}
		private function load_dance(_continue:Function, _key:Function):void
		{
			var mid_message	:WorkshopMessage = App.message_data;
			var headCount	:Number = 0;
			for(var i:Number = 0; i<mid_message.sceneArr.length; i++)
			{
				var scene:SceneStruct 		 = mid_message.sceneArr[i];
				var image:WSBackgroundStruct = mid_message.sceneArr[i].bg as WSBackgroundStruct;
				if(image && image.url) 
				{
					headCount++;
				}
			}
			
			
			var _danceIndex:Number = parseFloat(App.message_data.extraData.danceIndex) || 0;
			var dances:Array = ["Classic","Soul","Hip_Hop","80s","Charleston"];
			var swfURL:String = ServerInfo.content_url_door + "misc/"+dances[_danceIndex]+"_"+headCount+".swf";
			//ExternalInterface_Proxy.call("conole.log", "SWF_URL"+
		//	var swfURL:String = ServerInfo.content_url_door + "misc/dancing_vid0"+String(_danceIndex+1)+".swf";*/
			Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( fin, progress, error ) ) );
			function fin( l:Loader):void
			{
				App.dance_swf = l.content as MovieClip;
				App.dance_swf.stop();
				
				SoundMixer.stopAll();
				_continue(_key);
			}
			function progress(percent:Number):void
			{
				App.loader.load_bar.gotoAndStop(20+Math.round(percent*.8));
			}
			function error( _msg:String ):void 
			{
				error_initializing('Could not load dance.');
			}
		}
		private function wait_on_message_to_load( _continue:Function, _key:Function ) : void
		{
			_continue(_key);
			App.listener_manager.add(App.vhss_player, VHSSEvent.SCENE_LOADED, scene_loaded, this );
			App.listener_manager.add(App.vhss_player, VHSSEvent.PLAYER_XML_ERROR, scene_error, this );
			
			function scene_loaded( _e:Event ) : void
			{
				App.vhss_player.preloadScene(0);
				App.vhss_player.followCursor(1);	// tell host to follow mouse
				App.message_data = new WorkshopMessage( parseFloat(ServerInfo.mid) );
				App.message_data.parseXML( App.vhss_player.getShowXML() );
				_continue( _key );// continue sequence
			}
			function scene_error( _e:Event ) : void
			{
				var alert:AlertEvent = new AlertEvent(AlertEvent.ERROR, 'f9tp545', 'Unable to playback message', {mId:ServerInfo.mid, mode:'Player'});
				ErrorReporter.report(alert,null,App.COMPILATION_TIME);
				error_initializing( 'Cannot load message' );
			}
		}
		private function add_vhss_to_stage( _continue:Function, _key:Function ):void // it needs it to get the stage for the host to follow the mouse
		{
			App.listener_manager.add( App.vhss_player, Event.ADDED_TO_STAGE, added_to_stage, this );
			player_container.addChild( App.vhss_player as DisplayObject );
			
			function added_to_stage( _e:Event ):void 
			{
				DisplayObject(App.vhss_player).visible = false;
				App.listener_manager.remove( App.vhss_player, Event.ADDED_TO_STAGE, added_to_stage);
				_continue( _key );// continue sequence
			}
		}
		private function init_player_for_AIR_video_recording( _continue:Function, _key:Function ) : void
		{
			var arr_transport_events:Array = [
				VHSSEvent.ACCESSORY_LOAD_ERROR,
				VHSSEvent.AI_RESPONSE,
				VHSSEvent.AUDIO_ENDED,
				VHSSEvent.AUDIO_ERROR,
				VHSSEvent.AUDIO_LOADED,
				VHSSEvent.AUDIO_PROGRESS,
				VHSSEvent.AUDIO_STARTED,
				VHSSEvent.BG_LOADED,
				VHSSEvent.CONFIG_DONE,
				VHSSEvent.ENGINE_LOADED,
				VHSSEvent.MODEL_LOAD_ERROR,
				VHSSEvent.PLAYER_DATA_ERROR,
				VHSSEvent.PLAYER_READY,
				VHSSEvent.PLAYER_XML_ERROR,
				VHSSEvent.SCENE_LOADED,
				VHSSEvent.SCENE_PLAYBACK_COMPLETE,
				VHSSEvent.SCENE_PRELOADED,
				VHSSEvent.SKIN_LOADED,
				VHSSEvent.TALK_ENDED,
				VHSSEvent.TALK_STARTED,
				VHSSEvent.TTS_LOADED
			];
			while (arr_transport_events.length > 0 )
				App.listener_manager.add(App.vhss_player, arr_transport_events.pop(), transport_events_to_root, this );
			_continue( _key );// continue sequence
			
			function transport_events_to_root( _e:Event ):void
			{
				App.my_root.dispatchEvent( _e );
			}
		}
		private function init_misc( _continue:Function, _key:Function ) : void
		{
			App.tracking_manager.init();
			App.aps_transmitter.init_listeners();
			_continue( _key ); // continue sequence
		}
		private function position_background( _continue:Function, _key:Function ) : void
		{
			if (App.message_data && App.message_data.extraData && App.message_data.bg && App.message_data.extraData.bgPos)
			{	
				var bgPosArr:Array = App.message_data.extraData.bgPos.split(",");
				App.vhss_player.getBGHolder().x 			= bgPosArr[0];
				App.vhss_player.getBGHolder().y 			= bgPosArr[1];
				App.vhss_player.getBGHolder().scaleX		= bgPosArr[2];
				App.vhss_player.getBGHolder().scaleY		= bgPosArr[2];
				App.vhss_player.getBGHolder().rotation 		= bgPosArr[3];
			}
			_continue( _key );// continue sequence
		}
		
		/************************************************************
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
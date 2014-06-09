package code.controllers.gigya 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Gigya
	{
		private var ui					:Gigya_UI;
		private var btn_open			:InteractiveObject;
		private var loader_api			:Loader;
		private var api_container		:MovieClip;
		private var widget_is_loaded	:Boolean = false;
		/* settings stored in oddcasts door folder */
		private var xml_settings		:XML_Settings = new XML_Settings();
		private const CONFIG_NAME				:String = 'PostModule1'; // pass the module id to Wildfire
		private const GIGYA_EVENT_LOADED		:String = 'load';
		private const GIGYA_EVENT_POSTPROFILE	:String = 'postprofile';
		private const GIGYA_EVENT_CLOSE			:String = 'close';
		private const GIGYA_EVENT_EMAIL			:String = 'email';
		private const GIGYA_EVENT_RENDERDONE	:String = 'renderDone';
		private const GIGYA_EVENT_EMBED_COPY	:String = 'copy';
		private const GIGYA_EVENT_NETWORK		:String = 'networkButtonClicked';
		private const PROCESS_LOADING			:String = 'PROCESS_LOADING gigya interface';
		
		public function Gigya( _btn_open:InteractiveObject, _ui:Gigya_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui					= _ui;
			btn_open			= _btn_open;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();

			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				init();
			}
		}
		private function init(  ):void 
		{	App.listener_manager.add(btn_open, MouseEvent.CLICK, open_win, this);
			App.listener_manager.add(ui.btn_close, MouseEvent.CLICK, close_win, this);
			init_shortcuts();
		}
		private function close_win( _e:MouseEvent = null ):void 
		{	ui.visible = false;
			ui.placeholder.visible = false;	// this should be shown when the Gigya api is loaded and ready
		}
		/**
		 * open the view and also loads or reinitializes the widget
		 * @param	_e
		 */
		private function open_win( _e:MouseEvent ):void 
		{	ui.visible = true;
			App.mediator.scene_editing.stopAudio();
			set_focus();
			// get an MID
			var send_data:SendEvent = new SendEvent(SendEvent.SEND, SendEvent.GIGYA);
			App.utils.mid_saver.save_message( send_data, new Callback_Struct(fin) );
			
			function fin():void 
			{	App.mediator.processing_start( PROCESS_LOADING, 'Loading Gigya');
				if (widget_is_loaded)	re_init_widget();
				else
				{	xml_settings.initialize( new Callback_Struct( load_widget, null, settings_error ) );
					function settings_error():void 
					{	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, '', 'gigya xml is missing'));
						close_win();
					}
				}
			}
		}
		/**
		 * widget is loaded so we just submit new data
		 */
		private function re_init_widget():void 
		{	apply_new_config();
			(loader_api.content as Object).INIT();
		}
		/**
		 * load a fresh instance of the widget
		 */
		private function load_widget():void
		{	widget_is_loaded = true;
				
			Security.allowDomain("cdn.gigya.com");
			Security.allowInsecureDomain("cdn.gigya.com");
			
			loader_api			= new Loader();
			api_container		= new MovieClip();
			api_container.name	= 'mcWF';
			
			var url		:String		= 'http://cdn.gigya.com/Wildfire/swf/WildfireInAS3.swf?ModuleID=' + CONFIG_NAME;
			var urlReq	:URLRequest	= new URLRequest(url);
			apply_new_config();
			ui.placeholder.addChild(api_container);
			api_container.addChild(loader_api);		
			App.listener_manager.add( loader_api.contentLoaderInfo, Event.INIT					, widget_swf_loaded, this );
			App.listener_manager.add( loader_api.contentLoaderInfo, IOErrorEvent.IO_ERROR			, load_error, this );
			App.listener_manager.add( loader_api.contentLoaderInfo, IOErrorEvent.NETWORK_ERROR	, load_error, this );
			loader_api.load(urlReq);
			
			function widget_swf_loaded( _e:Event ):void 
			{	App.listener_manager.remove_all_listeners_on_object( loader_api.contentLoaderInfo );
			}
			function load_error(_e:IOErrorEvent):void 
			{	App.listener_manager.remove_all_listeners_on_object( loader_api.contentLoaderInfo );
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, '', 'Cannot load Gigya'));
				close_win();
			}
		}
		/**
		 * if a new MID or data needs to posted, we rebuild the config param and post it
		 */
		private function apply_new_config():void 
		{	var posting_config:Object = new Object(); // initialize the configuration object
			
			// misc params
				posting_config.width						= ui.placeholder.width;
				posting_config.height						= ui.placeholder.height;
			
				// CID might be overwritten if theres a value in the gigya XML
					var CID_delimiter	:String				= ' - ';
					var environment		:String				= ServerInfo.stem_gwi.indexOf('staging') > 0 ? 'staging' : 'live';
					posting_config.CID						= ServerInfo.door + CID_delimiter + environment + CID_delimiter + ServerInfo.app_folder_name	// [APPID - LOC(staging OR Live) - APP NAME]
					
				// embed posting params
					var mid		:String = App.asset_bucket.last_mid_saved + '.4';
					var swf_url	:String;
					switch( xml_settings.get_embed_param('swf_to_embed') )	// developer can choose here which of the 3 swfs they can embed
					{	case 'workshop':	swf_url = ServerInfo.default_url + 'swf/editor_art.swf?mId=' 		+ mid + '&stem=' + ServerInfo.stem_gwi;	break;
						case 'player_html':	swf_url = ServerInfo.default_url + 'swf/player_embed_html.swf?mId=' + mid + '&stem=' + ServerInfo.stem_gwi;	break;
						case 'player':		swf_url = ServerInfo.default_url + 'swf/player_embed.swf?mId=' 		+ mid + '&stem=' + ServerInfo.stem_gwi;	break;
						default:			swf_url = ServerInfo.default_url + 'swf/player_embed.swf?mId=' 		+ mid + '&stem=' + ServerInfo.stem_gwi;	break;
					}
					var embed_width				:String	= xml_settings.get_embed_param('width');
					var embed_height			:String = xml_settings.get_embed_param('height');
					var embed_quality			:String = xml_settings.get_embed_param('quality');
					var embed_allowScriptAccess	:String = xml_settings.get_embed_param('allowScriptAccess');
					var embed_allowNetworking	:String = xml_settings.get_embed_param('allowNetworking');
					var embed_wmode				:String = xml_settings.get_embed_param('wmode');
					var embed_allowFullScreen	:String = xml_settings.get_embed_param('allowFullScreen');
					var embed_name				:String = xml_settings.get_embed_param('name');
						
			// methods
				posting_config.onPostProfile				= api_event_handler;  
				posting_config.onLoad						= api_event_handler;
				posting_config.onPostProfile				= api_event_handler; 
				posting_config.onClose						= api_event_handler; 
				posting_config.onEmail						= api_event_handler; 
				posting_config.onRenderDone					= api_event_handler; 
				posting_config.onNetworkButtonClicked		= api_event_handler; 
				posting_config.onCopy						= api_event_handler; 
				posting_config.defaultContent				= get_default_content();
				posting_config.blackplanetContent			= get_blackplanet_migente_embed();
				posting_config.migenteContent				= get_blackplanet_migente_embed();
				posting_config.defaultBookmarkURL			= ServerInfo.pickup_url + '?mId=' + App.asset_bucket.last_mid_saved + '.3';
				
			
			xml_settings.add_params_from_xml( posting_config );
			
			api_container[CONFIG_NAME]					= posting_config;
			
			function get_default_content():String 
			{	var full_embed:String = 	'<object ' +
												'classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" ' +
												'codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,28,0" ' +
												'width="' + embed_width + '" ' +
												'height="' + embed_height + '" ' +
												'id="' + embed_name + '">' +
													'<param name="movie" value="' + swf_url + '" />' +
													'<param name="quality" value="' + embed_quality + '" />' +
													'<param name="allowScriptAccess" value="' +  embed_allowScriptAccess+ '" />' +
													'<param name="allowNetworking" value="' + embed_allowNetworking + '"/>' +
													'<param name="wmode" value="' + embed_wmode + '" />' +
													'<param name="allowFullScreen" value="' + embed_allowFullScreen + '" />' +
													'<embed ' +
														'src="' + swf_url + '" ' +
														'quality="' + embed_quality + '" ' +
														'allowScriptAccess="' + embed_allowScriptAccess + '" ' +
														'allowNetworking="' + embed_allowNetworking + '" ' +
														'wmode="' + embed_wmode + '" ' +
														'allowFullScreen="' + embed_allowFullScreen + '" ' +
														'pluginspage="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" ' +
														'type="application/x-shockwave-flash" ' +
														'width="' + embed_width + '" ' +
														'height="' + embed_height + '" ' +
														'name="' + embed_name + '">' +
													'</embed>' +
											'</object>';
														
				trace('(Oo) :: Gigya.apply_new_config().full_embed :', full_embed );
				return full_embed;
			}
			function get_blackplanet_migente_embed(  ):String
			{	var full_embed:String = 	'<object ' +
												'codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,28,0" ' +
												'width="' + embed_width + '" ' +
												'height="' + embed_height + '" ' +
												'id="' + embed_name + '">' +
													'<param name="movie" value="' + swf_url + '" />' +
													'<param name="quality" value="' + embed_quality + '" />' +
													'<param name="allowScriptAccess" value="' +  embed_allowScriptAccess+ '" />' +
													'<param name="allowNetworking" value="' + embed_allowNetworking + '"/>' +
													'<param name="wmode" value="' + embed_wmode + '" />' +
													'<param name="allowFullScreen" value="' + embed_allowFullScreen + '" />' +
											'</object>';
														
				trace('(Oo) :: Gigya.get_blackplanet_migente_embed().full_embed :', full_embed );
				return full_embed;
			}
		}
		/**
		 * calls made from the Gigya widget
		 * @param	_obj	object containing the type of event and other parameters specified below
		 */
		private function api_event_handler( _obj:Object ):void 
		{	trace('(Oo) :: Gigya.api_event_handler()._obj :', _obj.type, typeof(_obj));
			switch (_obj.type)
			{	case GIGYA_EVENT_LOADED:		/*	type 		string 	The name of the event: "load".
													ModuleID 	string 	The ID of the module that triggered the event. */
												break;
												
				case GIGYA_EVENT_POSTPROFILE:	/* 	type 		string 	The name of the event: "postprofile".
													ModuleID 	string 	The ID of the module that triggered the event.
													network 	string 	The social network to which the user posted the comment.
													partnerData 	  	Deprecated. This is for backward compatibility, please use CID.
													CID 		string 	The data set by the partner when Wildfire was initialized. (For more information, refer to the CID parameter reference.)
													username 	string 	The name the user entered for the social network.
													content 	string 	The content that was posted. */
												break;
												
				case GIGYA_EVENT_EMBED_COPY:	/* 	type 		string 	The name of the event: "copy".
													ModuleID 	string 	The ID of the module that triggered the event.
													network 	string 	The social network to which the user posted the comment. (NOTE on the Gigya first page this is "")
													CID 		string 	The data set by the partner when Wildfire was initialized. (For more information, refer to the CID parameter reference.)
													content 	string 	The content that was posted. */
												WSEventTracker.event('edecs', null, 0, 'embed');
												break;
												
				case GIGYA_EVENT_CLOSE:			/*	type 		string 	The name of the event: "close".
													ModuleID 	string 	The ID of the module that triggered the event. */
												break;
												
				case GIGYA_EVENT_EMAIL:			/*	type 		string 	The name of the event: "email".
													ModuleID 	string 	The ID of the module that triggered the event.
													recipients 	Array 	An array of objects that each has a name property and an email property corresponding to the recipients of the email that was sent.
													senderName 	string 	The sender's name, as he entered in the Wildfire UI. */
												break;
												
				case GIGYA_EVENT_RENDERDONE:	/*	type 		string 	The name of the event: "renderDone".
													ModuleID 	string 	The ID of the module that triggered the event.
													page 		string 	The name of the screen that had been rendered. Possible values for this field are: "NetworkSelection", "AfterOpenURL", "SelectEmailContacts", "PostToSocialNetwork", "ImportEmailContacts", "AskAboutRemember". */
												App.mediator.processing_ended( PROCESS_LOADING );
												ui.placeholder.visible = true;	// show their menu
												break;
												
				case GIGYA_EVENT_NETWORK:		/*	type 		string 	The name of the event: "networkButtonClicked".
													ModuleID 	string 	The ID of the module that triggered the event.
													network 	string 	The name of the social network whose associated button (icon) has been clicked. */
												WSEventTracker.event('edecs', null, 0, _obj.network);
												break;
												
				default:						/*	unknown event, possibly one that is new event that was implemented after this controller was written */
			}
		}
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}	
		private function shortcut_close_win(  ):void 		
		{	if (ui.visible)
				close_win();	
		}
		 /*******************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
	}

}





import com.oddcast.utils.*;
import com.oddcast.utils.gateway.Gateway;
import com.oddcast.workshop.*;

internal class XML_Settings
{
	private const XML_FILENAME	:String = 'xml/gigya.xml';
	private var xml_data		:XML;
	
	public function XML_Settings()
	{}
	/**
	 * loads and parses the Gigya settings xml
	 * @param	_callback	callbacks take NO parameters
	 */
	public function initialize( _callback:Callback_Struct ):void 
	{	if (xml_data)	_callback.fin();	// xml was previously loaded... why load it again fool!?!?!
		else			load_xml();
		
		function load_xml():void 
		{	var url:String = ServerInfo.default_url + XML_FILENAME;
			//Gateway.download_XML( new Gateway_Request( url, new Callback_Struct( fin, null, error ) ) );
			Gateway.retrieve_XML( url, new Callback_Struct( fin, null, error ) );
			function fin(_xml:XML):void 
			{	xml_data = _xml;
				_callback.fin();
			}
			function error(_msg:String = null):void 
			{	_callback.error();
			}
		}
	}
	/**
	 * applies properties from the XML or defaults if not there
	 * @param	_conf	gigya object
	 */
	public function add_params_from_xml( _conf:Object ):void
	{	
		for (var i:int; i < xml_data.PARAM.length(); i++ )
		{	
			var prop_name	:String		= xml_data.PARAM[i].@NAME;
			var prop_value	:String		= xml_data.PARAM[i];
			var escaped		:Boolean	= xml_data.PARAM[i].@ESCAPED == 'true';
			if (escaped)	prop_value	= unescape(prop_value);
			if (prop_value != '')
			{
				// handle special cases before applying to obj
				switch ( prop_name.toLowerCase() )
				{	
					case 'facebookpreviewurl3':		if ( prop_value.indexOf('://') < 0 )
														prop_value = ServerInfo.content_url_door + prop_value;
													break;
				}
				
				_conf[ prop_name ] = prop_value;
			}
		}
	}
	/**
	 * retrieve an embed xml parameter
	 * @param	_param_name	parameter name eg wmode
	 * @return	value of the param if found
	 */
	public function get_embed_param( _param_name:String ):String
	{	for (var i:int = 0; i < xml_data.EMBED_PARAM.length(); i++) 
		{	var prop_name	:String		= xml_data.EMBED_PARAM[i].@NAME;
			if (prop_name == _param_name)
			{	var prop_value	:String		= xml_data.EMBED_PARAM[i];
				var escaped		:Boolean	= xml_data.EMBED_PARAM[i].@ESCAPED == 'true';
				if (escaped)	prop_value	= unescape(prop_value);
				return prop_value;
			}
		}
		return '';
	}
}
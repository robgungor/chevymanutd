package code.controllers.share_misc 
{
	import code.skeleton.App;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ExternalInterface_Proxy;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSEventTracker;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Share_Misc
	{
		private var btn_embed			:InteractiveObject;
		private var btn_get_url			:InteractiveObject;
		private var btn_facebook		:InteractiveObject;
		private var btn_download_video	:InteractiveObject;
		
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INIT */
		/**
		 * Constructor
		 */
		public function Share_Misc(_btn_embed:InteractiveObject, _btn_get_url:InteractiveObject, _btn_facebook:InteractiveObject, _btn_download_video:InteractiveObject) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			App.listener_manager.add(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE, app_initialized, this);
			
			// reference to controllers UI
			btn_embed			= _btn_embed;
			btn_get_url			= _btn_get_url;
			btn_facebook		= _btn_facebook;
			btn_download_video	= _btn_download_video;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			App.ws_art.copyURL.visible = false;
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				App.listener_manager.remove(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE, app_initialized);
				App.listener_manager.remove(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE, app_initialized);
				// init this after the application has been inaugurated
				init();
			}
		}
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	
			App.listener_manager.add( btn_embed, MouseEvent.CLICK, _onEmbedClicked, this );
			//App.listener_manager.add( App.ws_art.mainPlayer.link_btn, MouseEvent.CLICK, _onBigShowGetURLClicked, this );
			App.listener_manager.add( btn_get_url, MouseEvent.CLICK, _onGetURLClicked, this );
			//App.listener_manager.add( btn_facebook, MouseEvent.CLICK, share_to_facebook, this );
			App.listener_manager.add( App.ws_art.mainPlayer.facebook_btn, MouseEvent.CLICK, share_to_facebook_bigshow, this );
			App.listener_manager.add( btn_download_video, MouseEvent.CLICK, download_video, this );
		}
		/************************************************
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
		* 
		***************************** INTERFACE API */
		/************************************************
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
		* 
		***************************** INTERNALS */
		private function _onEmbedClicked(e:MouseEvent):void
		{
		//	App.mediator.checkOptIn(embed_code);
			WSEventTracker.event("ce13");  
			embed_code();
		}
		private function embed_code( ):void 
		{	if (!App.mediator.checkPhotoExpired()) 	return;
			// App.mediator.scene_editing.stopAudio();
			App.utils.mid_saver.save_message(new SendEvent(SendEvent.SEND, SendEvent.EMBED_CODE), new Callback_Struct( fin, null, null ) );
			
			function fin():void 
			{	var url:String = ServerInfo.acceleratedURL + "php/api/getEmbed/doorId=" + ServerInfo.door + "/clientId=" + ServerInfo.client + "/mId=" + App.asset_bucket.last_mid_saved + "/type=myspace";
				Gateway.retrieve_XML( url, new Callback_Struct( fin, null, error ));
				function fin( _content:XML ):void 
				{	var result:String = unescape(_content.toString().split("+").join(" "));
					App.mediator.alert_user( new AlertEvent(null,'f9t553',result, {embed:result}, embed_user_response, false) );
					//WSEventTracker.event("uieb");
					
					function embed_user_response( _ok:Boolean ):void 
					{	if (_ok)
							System.setClipboard( result );
					}
				}
				function error( _msg:String ):void 
				{	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t113', 'Unable to retrieve embed code'));
				}
			}
		}
		private function _onGetURLClicked(e:MouseEvent):void
		{
			WSEventTracker.event("ce12");
			//App.mediator.checkOptIn(get_url);
			get_url();
		}
		private function _onBigShowGetURLClicked(e:MouseEvent):void
		{
			WSEventTracker.event("gce7");
			//App.mediator.checkOptIn(get_url);
			get_url();
		}
		private function get_url( ):void 
		{	if (!App.mediator.checkPhotoExpired()) 	return;
			// App.mediator.scene_editing.stopAudio();
			App.utils.mid_saver.save_message(new SendEvent(SendEvent.SEND, SendEvent.GET_PLAYER_URL), new Callback_Struct( fin, null, null ) );
			
			function fin():void 
			{	
				var message_id	:String =  App.asset_bucket.last_mid_saved ? '?mId=' + App.asset_bucket.last_mid_saved + '.3' : "";
				//var message_id	:String = '?mId=' + App.asset_bucket.last_mid_saved + '.3';
				var embed_url	:String = ServerInfo.pickup_url + message_id;
				
				//App.mediator.alert_user(  new AlertEvent(null,'f9t554',embed_url, {url:embed_url},url_user_response,false) );
				App.ws_art.copyURL.tf_url.text = embed_url;
				App.ws_art.copyURL.visible = true;
				WSEventTracker.event("uiebws");
				App.ws_art.copyURL.btn_copy.addEventListener(MouseEvent.CLICK, url_user_response);
				App.ws_art.copyURL.btn_ok.addEventListener(MouseEvent.CLICK, onclose);
				App.ws_art.copyURL.btn_close.addEventListener(MouseEvent.CLICK, onclose);
				function url_user_response( e:MouseEvent ):void 
				{	
					System.setClipboard( embed_url );
				}	
				function onclose(e:MouseEvent):void
				{
					System.setClipboard( embed_url );
					App.ws_art.copyURL.btn_copy.removeEventListener(MouseEvent.CLICK, url_user_response);
					App.ws_art.copyURL.btn_ok.removeEventListener(MouseEvent.CLICK, onclose);
					App.ws_art.copyURL.btn_close.addEventListener(MouseEvent.CLICK, onclose);
					App.ws_art.copyURL.visible = false;
				}
			}	
		}
		private function _onCopyURLCloseClick(e:MouseEvent):void
		{
			App.ws_art.copyURL.visible = false;
		}
		private function share_to_facebook( _e:MouseEvent ):void 
		{	
			WSEventTracker.event("ce9");
			// App.mediator.scene_editing.stopAudio();
			var share_with_js:Boolean = true;
			if (share_with_js)
				share_to_facebook_js();
			else
				share_to_facebook_php();
		}
		private function share_to_facebook_bigshow( _e:MouseEvent ):void 
		{	
			WSEventTracker.event("gce6");
			WSEventTracker.event("ce9");
			// App.mediator.scene_editing.stopAudio();
			var share_with_js:Boolean = true;
			if (share_with_js)
				share_to_facebook_js();
			else
				share_to_facebook_php();
		}
		
		/**
		 * share to facebook via javascript
		 */
		private function share_to_facebook_js( ):void 
		{
			//App.mediator.checkOptIn(App.mediator.facebook_post_new_mid_to_user);
			App.mediator.facebook_post_new_mid_to_user();
		}
		/**
		 * share to facebook via php
		 */
		private function share_to_facebook_php( ):void 
		{
			if (!App.mediator.checkPhotoExpired()) 	return;
			App.utils.mid_saver.save_message(new SendEvent(SendEvent.SEND, SendEvent.FACEBOOK), new Callback_Struct( fin, null, null ) );
			function fin():void 
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "f9t150", "Click OK to continue...", null, postFacebook));
		
				function postFacebook(_ok:Boolean):void
				{	if (!_ok)
						return;
					var url			:String = ServerInfo.acceleratedURL + "php/api/facebook/doorId=" + ServerInfo.door + "/clientId=" + ServerInfo.client + "/mId=" +App.asset_bucket.last_mid_saved;
					var popup_name	:String = App.settings.SHARE_APP_TITLE;
					var facebookUrl	:String = "http://www.facebook.com/sharer.php?t=" + popup_name + "&u=" + encodeURIComponent(url);
					
					try 			{	ExternalInterface_Proxy.call("window.open", facebookUrl, "Window1", "menubar=no,width=540,height=535,toolbar=no,scrollbars=yes");			}
					catch (e:Error)	{	App.mediator.open_hyperlink(facebookUrl);			}
					WSEventTracker.event("uiebfb");
				}
			}
		}
		private function download_video( _e:MouseEvent ):void 
		{	/*if (!App.mediator.checkPhotoExpired() ||
				!App.mediator.checkHasAudio())
				return;*/
			
				// App.mediator.scene_editing.stopAudio();
				App.utils.mid_saver.save_message(new SendEvent(SendEvent.SEND, SendEvent.DOWNLOAD_VIDEO), new Callback_Struct( fin, null, null ) );
			
			function fin():void 
			{	App.mediator.download_video_by_mId( App.asset_bucket.last_mid_saved );
				WSEventTracker.event("edvdx");	
			}	
		}
		/************************************************
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
		* 
		***************************** KEYBOARD SHORTCUTS */
		/************************************************
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
package code.controllers.bitly_url 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;

	/**
	 * ...
	 * @author Me^
	 */
	public class Bitly_Url implements IBitly_Url
	{
		private var btn_open	:InteractiveObject;
		private const LOGIN		:String = 'oddcast';
		private const API_KEY	:String = 'R_f6d82bec8135f3dfa7c1802b5d659302';
		private const PROCESS_SHORTENING	:String = 'PROCESS_SHORTENING for Bitly';
		private const PROCESS_SHORTENING_MSG:String = 'Shortening url...';
				
		public function Bitly_Url( _btn_open:InteractiveObject ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			btn_open		= _btn_open;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				init();
			}
		}
		private function init(  ):void 
		{	App.listener_manager.add(btn_open, MouseEvent.CLICK, save_and_shorten, this);
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
		 * ************************************* INTERFACE *******/
		public function shorten_url( _url:String, _callbacks:Callback_Struct ):void
		{
			var retry_attempts_left:int = 3;
			
			function shorten_url():void 
			{	
				toggle_processing( true );
				var bitlyURL	:String = "http://api.bit.ly/shorten?version=2.0.1&format=xml&longUrl=" + escape(_url) + "&login=" + LOGIN + "&apiKey=" + API_KEY;
				
				Gateway.retrieve_XML( bitlyURL, new Callback_Struct( url_xml_loaded, null, error ) );
				function url_xml_loaded( _xml:XML ):void 
				{	
					toggle_processing( false );
					if ( new Eval_PHP_Response( _xml ).is_response_valid() )
					{	try					
						{	var short_url:String = _xml.results.nodeKeyVal.shortUrl;
							if (short_url && short_url.indexOf('://') > 0)
							{	
								if (_callbacks.fin != null)
									_callbacks.fin( short_url );
							}
							else	error();
						}
						catch (err:Error)	{	error();	}
					}
					else error();
				}
			}
			function error( _msg:String = null ):void
			{	
				retry_attempts_left--;
				if (retry_attempts_left < 0)
				{
					toggle_processing( false );
					if (_callbacks.error != null)
						_callbacks.error(_msg);
				}
				else	shorten_url();
			}
			function toggle_processing( _on:Boolean ):void 
			{	
				if (_on)	App.mediator.processing_start( PROCESS_SHORTENING, PROCESS_SHORTENING_MSG );
				else		App.mediator.processing_ended( PROCESS_SHORTENING );
			}
		}
		/**********************************************************
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
		 * ************************************* PRIVATEERS ******/
		private function save_and_shorten( _e:MouseEvent ):void 
		{	
			App.mediator.scene_editing.stopAudio();
			App.utils.mid_saver.save_message( null, new Callback_Struct(fin_save) );
			function fin_save():void
			{
				var url:String = ServerInfo.pickup_url + '?mId=' + App.asset_bucket.last_mid_saved + '.3';
				shorten_url( url, new Callback_Struct(fin_shorten, null, error_shorted ));
				
				function fin_shorten(_url:String):void
				{
					App.mediator.alert_user( new AlertEvent(AlertEvent.CONFIRM, 
															'f9t552',
															'Click ok to copy this url: \n\n' + _url,
															{url:_url},
															user_response,
															false ) );
					
					function user_response( _ok:Boolean ):void 
					{	
						if ( _ok )	
							System.setClipboard( _url );
					}
				}
				function error_shorted( _msg:String ):void
				{
					App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, '', 'Error preparing Bitly URL', { details:_msg } ) );
				}
			}
		}
		/**********************************************************
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
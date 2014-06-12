/**
* ...
* @author Sam Myer, Me^
*/
package com.oddcast.workshop 
{
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class AudioList extends EventDispatcher 
	{
		private var is_processing:Boolean=false;
		/* holder of all items */
		private var arr:Array;
		/* dictionary by name (each name has to be unique) */
		private var dic_names:Dictionary;
		
		
		public function AudioList() 
		{}
		
		
		/**
		 *	loads the canned audio list 
		 * @param _callback fin(), error(AlertEvent)
		 * 
		 */		
		public function load( _callback:Callback_Struct ):void 
		{
			if (is_loaded())
				_callback.fin();
			else
			{	
				var url:String = ServerInfo.acceleratedURL+"php/vhss_editors/getAudios/doorId="+ServerInfo.door;
				Gateway.retrieve_XML( url, new Callback_Struct( fin, null, error ) );
				
				function fin( _xml:XML ):void
				{	
					parseAudios( _xml ); 
					_callback.fin();
				}
				function error( _e:AlertEvent ):void 
				{	
					var alert:AlertEvent = new AlertEvent(AlertEvent.ERROR, 'f9t547', 'Error loading canned audios' )
					_callback.error( _e );
				}
			}
		}
		
		private function parseAudios(_xml:XML):void
		{
			arr = new Array();
			dic_names = new Dictionary();
			var item:XML;
			var audio:AudioData;
			var baseUrl:String=_xml.@BASEURL;
			var audioUrl:String;
			var num_of_audios:int = _xml.AUDIO.length()
			for (var i:int=0;i<num_of_audios;i++) 
			{
				item=_xml.AUDIO[i];
				audioUrl = item.@URL.toString();
				if (audioUrl.indexOf("http://") != 0) audioUrl = baseUrl + audioUrl;
				if (audioUrl.lastIndexOf(".")<=audioUrl.lastIndexOf("/")) audioUrl+=".mp3";
				audio=new AudioData(audioUrl,parseInt(item.@ID),AudioData.PRERECORDED,unescape(item.@NAME));
				add_audio_to_list(audio);
			}
		}
		
		private function add_audio_to_list(_audio:AudioData):void
		{
			arr.push(_audio);
			
			// by name
				dic_names[_audio.name] = _audio;
		}
		
		public function audio_by_name(_name:String):AudioData 
		{
			return dic_names[_name];
		}
		
		public function get audioArr():Array {
			if (arr == null) return([]);
			else return(arr);
		}
		
		private function is_loaded():Boolean 
		{
			return(arr != null);
		}
	}
	
}
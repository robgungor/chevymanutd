package code.models.items
{
	import code.models.*;
	
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.*;
	
	public class List_Canned_Audios
	{
		public var is_loaded:Boolean;
		public var model:Model_Item=new Model_Item();
		
		private const ERROR_LOADING_CODE:String='f9t547';
		private const ERROR_LOADING_MSG:String='Error loading canned audios';
		private const SUB_URL:String="php/vhss_editors/getAudios/doorId=";
		
		public function List_Canned_Audios()
		{}
		
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
		 * 
		 * ****************************** PUBLIC *****************/
		public function load(_url:String=null, _callbacks:Callback_Struct=null):void
		{
			if (is_loaded)
				model_loaded();
			else
			{
				var url:String = _url ? _url : ServerInfo.acceleratedURL+SUB_URL+ServerInfo.door;
				
				Gateway.retrieve_XML( url, new Callback_Struct(fin, progress, error), response_eval);
				function response_eval(_xml:XML):Boolean
				{
				/*
					<AUDIOS RES="OK" NUM="4" BASEURL="http://host-a.staging.oddcast.com/ccs1/customhost/239/audio/">
						<AUDIO ID="41151" URL="1230132851_239" TYPE="prerec" NAME="testb"/>
						<AUDIO ID="61693" URL="1254772028645492" TYPE="prerec" NAME="phase1_female_12"/>
						<AUDIO ID="61692" URL="1254772026681602" TYPE="prerec" NAME="phase1_female_13aaasfdsf"/>
						<AUDIO ID="61691" URL="1254772024323932" TYPE="prerec" NAME="phase1_female_11aaaa"/>
					</AUDIOS>
				*/
					return (_xml && _xml.AUDIO && _xml.AUDIO.length() > 0 );
				}
				function fin(_content:XML):void
				{
					parse(_content);
					model_loaded();
				}
				function progress(_percent:int):void
				{
					if (_callbacks&&_callbacks.progress!=null)
						_callbacks.progress(_percent);
				}
				function error(_msg:String):void
				{
					if (_callbacks&&_callbacks.error!=null)
						_callbacks.error(new AlertEvent(AlertEvent.ERROR,ERROR_LOADING_CODE,ERROR_LOADING_MSG));
				}
			}
				
			function model_loaded():void
			{
				is_loaded=true;
				if (_callbacks&&_callbacks.fin!=null)
					_callbacks.fin();
			}
		}
		/***************************************
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
		private function parse( _xml:XML ):void
		{
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
				model.add_item(audio);
			}
		}
	}
}
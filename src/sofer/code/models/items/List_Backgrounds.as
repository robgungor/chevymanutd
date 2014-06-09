package code.models.items
{
	import code.models.*;
	
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.*;
	
	public class List_Backgrounds
	{
		public var is_loaded:Boolean;
		/** model for WSBackgroundStruct items */
		public var model:Model_Item = new Model_Item();
		
		private const ERROR_LOADING_CODE:String='f9t310';
		private const ERROR_LOADING_MSG:String='Error loading backgrounds list';
		private const SUB_URL:String="php/vhss_editors/getBackgrounds/doorId=";
		
		public function List_Backgrounds()
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
				var url:String = _url ? _url : ServerInfo.acceleratedURL + SUB_URL + ServerInfo.door;
				
				Gateway.retrieve_XML( url, new Callback_Struct(fin, progress, error), response_eval);
				function response_eval(_xml:XML):Boolean
				{
				/*
					<BGS RES="OK" NUM="2" BASEURL="http://host-a.staging.oddcast.com/ccs1/customhost/239/bg/">
						<BG ID="28448" FILENAME="http://host-a.staging.oddcast.com/ccs1/customhost/239/bg/1272406533276443.jpg" THUMB="http://host-a.staging.oddcast.com/ccs1/customhost/239/bg/thumbs/1272406533276443.jpg" DESC="default_bg_2" FILETYPE="jpg"/>
						<BG ID="28449" FILENAME="http://host-a.staging.oddcast.com/ccs1/customhost/239/bg/1272406533427031.jpg" THUMB="http://host-a.staging.oddcast.com/ccs1/customhost/239/bg/thumbs/1272406533427031.jpg" DESC="default_bg_1" FILETYPE="jpg"/>
					</BGS>
				*/
					return (_xml && _xml.BG && _xml.BG.length() > 0 );
				}
				function fin(_content:XML):void
				{
					parse(_content);
					model.get_all_items().sortOn('name');
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
			var item		:XML;
			var bg			:WSBackgroundStruct;
			var baseUrl		:String					= _xml.@BASEURL;
			var bgUrl		:String;
			var thumbUrl	:String;
			var default_bg	:Boolean				= true;	// these are all default backgrounds to avoid cropping or editting them
			for (var i:int = 0, n:int=_xml.BG.length(); i<n; i++) 
			{
				item		= _xml.BG[i];
				bgUrl		= item.@FILENAME.toString();
				
				if (bgUrl.indexOf("http://") != 0)	
					bgUrl = baseUrl + bgUrl;
				
				thumbUrl	= item.@THUMB.toString();
				bg			= new WSBackgroundStruct(bgUrl, parseInt(item.@ID.toString()), thumbUrl, item.@DESC.toString(), 0, 0, default_bg);
				model.add_item(bg);
			}
		}
	}
}
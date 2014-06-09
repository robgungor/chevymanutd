package code.models.items
{
	import code.models.*;
	
	import com.adobe.fileformats.vcard.Address;
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.*;
	
	import flash.xml.XMLNode;
	
	public class List_Errors
	{
		public var is_loaded:Boolean;
		public var model:Model_Item=new Model_Item();
		
		private const ERROR_LOADING_CODE:String='';
		private const ERROR_LOADING_MSG:String='Error loading errors list';
		private const SUB_URL:String="xml/errors.xml";
		
		public function List_Errors()
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
				var url:String = _url ? _url : ServerInfo.default_url + SUB_URL;
				
				Gateway.retrieve_XML( url, new Callback_Struct(fin, progress, error), response_eval);
				function response_eval(_xml:XML):Boolean
				{
				/*
					<data>
						<error code="apc2">There was an error processing your request. Please try again.</error>
						<error code="apc2.0">Cropping the image failed</error>
						<error code="apc2.1">APS error</error>
						...
					</data>
				*/
					return (_xml && _xml.error && _xml.error.length() > 0 );
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
		public function has_error_code( _error_code:String ) : Boolean
		{
			var error_items:Array = model.get_items_by_property('code',_error_code);
			return error_items && error_items[0]; 
		}
		public function get_error_text( _error_code:String, _default_text:String, _dynamic_text:Object = null ) : String
		{
			var error_items:Array = model.get_items_by_property('code',_error_code);
			if (error_items && error_items[0])
			{
				var item:Error_Item = error_items[0];
				var item_text:String = item.text;
				
				// replace dynamic text parts
				if (_dynamic_text)
				{
					for (var key:String in _dynamic_text)
					{
						var replacee:String = '{'+key+'}';
						var replaced:String = _dynamic_text[key];
						item_text = item_text.split( replacee ).join( replaced );
					}
				}
				
				return item_text;
			}
			return _default_text;
		}
		public function get_error_title( _error_code:String ) : String
		{
			var error_items:Array = model.get_items_by_property('code',_error_code);
			if (error_items && error_items[0])
			{	
				var item:Error_Item = error_items[0];
				return item.title;
			}
			return null;
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
			var error_item	:Error_Item;
			var code : String, text : String, title : String;
			loop1: for (var i:int = 0, n:int = _xml.error.length(); i<n; i++ )
			{
				item = _xml.error[ i ];
				code = item.@code;
				title = item.@title;
				text = item.toString();
				error_item = new Error_Item( code, text, title );
				model.add_item( error_item, ['code'] );
				// break loop1;
			}
		}
	}
}













class Error_Item
{
	/** error code eg APC1.2 */
	public var code		: String;
	/** popup alert title */
	public var title	: String;
	/** error text */
	public var text	: String;

	public function Error_Item ( _code : String, _text : String, _title : String )
	{
		code = _code;
		title = _title;
		text = _text;
	}
}
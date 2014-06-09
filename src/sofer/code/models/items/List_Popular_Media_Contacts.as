package code.models.items
{
	import code.controllers.popular_media.Popular_Media_Contact_Item;
	import code.models.*;
	
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.net.URLVariables;
	import flash.xml.XMLDocument;
	
	
	public class List_Popular_Media_Contacts
	{
		public var is_loaded:Boolean;
		public var model:Model_Item=new Model_Item();
		
		private const ERROR_LOADING_CODE:String='f9t547';
		private const ERROR_LOADING_MSG:String='Error loading canned audios';
		private const SUB_URL:String="sendPPMedia.php";
		
		public function List_Popular_Media_Contacts()
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
		public function load(_username:String, _password:String, _provider:String, _callbacks:Callback_Struct=null):void
		{
			var url:String = ServerInfo.localURL+SUB_URL;
			
			var vars:URLVariables = new URLVariables();
			vars.MODE			= "PPM";
			vars.USERNAME		= _username;
			vars.USERPASSW		= _password;
			vars.CONTACTPROVD	= _provider;
			
			Gateway.upload(vars, new Gateway_Request( url, new Callback_Struct(fin, progress, error) ) );
			function fin( _content:String ):void
			{
				var xml:XML=new XML(_content);
				if (xml && xml.@stat == "ok")
				{
					parse(xml);
				if (_callbacks&&_callbacks.fin!=null)
					_callbacks.fin();
				}
				else // errored
				{
					var errorCode:Number	= xml.error.@code;
					var errorMsg:String		= xml.error.message;
					var alert:AlertEvent = new AlertEvent	
						(
							AlertEvent.ERROR, 
							'pop_' + errorCode,
							'Error retrieving contacts from popular media: ' + errorMsg,
							{code:errorCode, msg:errorMsg }
						);
					if (_callbacks&&_callbacks.error!=null)
						_callbacks.error(alert);
				}
			}
			
			function progress(_percent:int):void
			{
				if (_callbacks&&_callbacks.progress!=null)
					_callbacks.progress(_percent);
			}
			function error( _msg:String ):void
			{
				if (_callbacks&&_callbacks.error!=null)
					_callbacks.error(new AlertEvent(AlertEvent.ERROR,'f9t549','Cannot contact popular media'));
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
			var contactList:XMLList = _xml.contacts.contact;
			var name:String;
			var email:String;
			for (var i = 0; i < contactList.length(); i++) 
			{
				name	= htmlUnescape(contactList[i].name.toString());
				email	= htmlUnescape(contactList[i].email.toString());
				model.add_item(new Popular_Media_Contact_Item(name,email),[]);// dont index anything
			}	
			
			/** converts stuff like &#126; --> ~ */
			function htmlUnescape(str:String):String
			{
				if (str == null || str == '')
					return '';
				else
				{
					try 
					{	return new XMLDocument(str).firstChild.nodeValue;	}
					catch(_e:Error)
					{	return '';	}
				}
				return '';
			}
		}
	}
}
package code.skeleton
{
	import com.oddcast.utils.*;
	import com.oddcast.workshop.ServerInfo;
	
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import workshop.ui.LocalizedButton;
	
	
	public dynamic class Localizer
	{
		public function Localizer()
		{
			_translations = new Dictionary();
			//_translations["homescreen_btn_facebook"] = "LCL FACEBOOK"; 
		}
		
		/** list of variables not to retrieve from the xml when auto parsing it */
		private var ignore_from_xml:Array = ['code.skeleton.BUILD_TIMESTAMP'];
		
		private var _language		:String = 'en';
		private var _translations	:Dictionary;
		
//		public var loading_screen_loading:String;
//		public var loading_screen_hashtag:String;
//		public var loading_screen_quote:String;
//		public var loading_screen_quote_name:String;
//		public var homescreen_title_upload:String;
//		public var homescreen_subtitle_upload:String;
//		public var homescreen_cta_upload:String;
//		public var homescreen_btn_facebook:String;
//		public var homescreen_btn_webcam:String;
//		public var homescreen_btn_googleplus:String;
//		public var webcam_title_capture:String;
//		public var webcam_subtitle_capture:String;
//		public var webcam_btn_capture:String;
//		public var webcam_btn_recapture:String;
//		public var webcam_btn_next:String;
//		public var webcam_btn_back:String;
//		public var webcam_example_top:String;
//		public var webcam_example_bottom:String;
//		public var adjust_title:String;
//		public var adjust_subtitle:String;
//		public var adjust_zoom:String;
//		public var adjust_contrast:String;
//		public var adjust_rotate:String;
//		public var adjust_hairstyle:String;
//		public var adjust_btn_next:String;
//		public var adjust_btn_back:String;
//		public var adjust_example_top:String;
//		public var adjust_example_bottom:String;
//		public var fb_upload_title:String;
//		public var fb_upload_btn_back:String;
//		public var browse_btn_upload:String;
//		public var browse_title:String;
//		public var preview_title:String;
//		public var preview_subtitle:String;
//		public var preview_btn_upload_new:String;
//		public var email_title:String;
//		public var email_subtitle_to:String;
//		public var email_your_name_txt:String;
//		public var email_your_email_txt:String;
//		public var email_friend_name_txt:String;
//		public var email_friend_email_txt:String;
//		public var email_btn_add:String;
//		public var email_btn_send:String;
//		public var email_confirmation_title:String;
//		public var email_confirmation_subtitle:String;
//		public var email_confirmation_btn_ok:String;
//		public var fb_share_title:String;
//		public var fb_share_btn_profile:String;
//		public var fb_share_btn_post:String;
//		public var fb_share__or:String;
//		public var twitter_share_title:String;
//		public var twitter_share__or:String;
//		public var twitter_share_btn_profile:String;
//		public var twitter_share_btn_tweet:String;
//		public var copy_url_title:String;
//		public var copy_url_subtitle:String;
//		public var copy_url_btn_ok:String;
//		public var alert_title:String;
//		public var alert_btn_ok:String;
//		public var alert_size:String;
//		public var alert_terms:String;
//		public var alert_email_invalid_from_email:String;
//		public var alert_email_invalid_to_email:String;
//		public var alert_email_invalid_from_name:String;
//		public var alert_email_invalid_to_name:String;
//		public var alert_email_max_limit:String;
//		public var alert_faild_message:String;
//		public var alert_social_photo_upload:String;
//		public var alert_photo_upload_expiration:String;
//		public var alert_blocked_link:String;
//		public var alert_webcam_missing:String;
//		public var alert_webcam_failure:String;
//		public var alert_webcam_support:String;
//		public var alert_file_failure:String;
//		public var alert_file_in_use:String;
//		public var alert_connection_failure:String;
//		public var alert_generic:String;

		
		public function localize(ui:DisplayObjectContainer, prefix:String = ''):void
		{
			for (var i:int = 0; i<ui.numChildren; i++)
			{
				var child:* = ui.getChildAt(i);
				var translation:String = getTranslation(prefix+"_"+child.name);
				if(child is LocalizedButton)
				{
					if(translation) (child as LocalizedButton).setText( translation, _language);
				} else if(child is TextField)
				{
					if(translation) (child as TextField).text = translation;
				}
			}
		}
		
		
		public function parse_xml( _xml:XML ) : void
		{
			/*
			<type name="workshop::Settings" base="Object" isDynamic="false" isFinal="false" isStatic="false">
			<extendsClass type="Object"/>
			<variable name="MAX_EMAILS_SELECTABLE" type="int"/>
			<variable name="UPLOAD_MAX_FILES" type="int"/>
			<variable name="BG_MIN_SIZE_KB" type="Number"/>
			...
			</type>
			*/
			var settings_properties:XML = describeType(this);
			var var_name:String, var_type:String, var_node:XML;
			var xml_value:String;
			var ignore_xml_value:Boolean;
			//loop1: for (var i:int = 0, n:int = settings_properties.variable.length(); i<n; i++ )
			loop1: for (var i:int = 0, n:int = _xml.children().length(); i<n; i++ )
			{
				
				var_node = _xml.children()[i];//.toXMLString();//settings_properties.variable[i];
				
				var_name = var_node.name().localName//@name;
				var_type = 'String';//var_node.@type;
				xml_value = var_node;
				ignore_xml_value = ignore_from_xml.indexOf(var_name)>=0;
				
				if (!ignore_xml_value)
				{					
					switch (var_type)
					{
						case 'int':
							this[var_name] = parseInt(xml_value);
							break;
						case 'Number':
							this[var_name] = parseFloat(xml_value);
							break;
						case 'Boolean':
							this[var_name] = is_true(xml_value);
							break;
						case 'String':
							trace("ADDING TRANSLATION "+var_name+": "+xml_value);
							this[var_name] = xml_value;
							break;
						case 'Array':
							this[var_name] = xml_value.split('|');
							break;
						default:
							trace ( '(Oo) Settings.as :: Error cannot set',var_name,'value due to unhandled type : var_type =',var_type );
					}
				}
				// break loop1;
			}
			
			
			function is_true( _value:String ):Boolean 
			{	
				return _value.toLowerCase() == 'true';
			}
			
			// set default params
			
			
			//FACEBOOK_POST_IMAGE_URL = "http://content-vs.oddcast.com/ccs6/customhost/1009/misc/fb-thumb.jpg";	
		}
		
		public function getTranslation(key:String):String
		{	
			trace('getting translation for '+key);
			if(this[key] != null) 
			{
				trace('getting translation for '+key+': '+this[key] );
				return this[key];
			}else 
			{
				return '';
			}
			
			return _translations[key];
		}
	}
}
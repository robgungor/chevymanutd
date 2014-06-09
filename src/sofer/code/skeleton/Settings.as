package code.skeleton 
{
	
	import com.oddcast.utils.*;
	import com.oddcast.workshop.ServerInfo;
	
	import flash.utils.describeType;

	/**
	 * @about stores data parsed from settings XML in hardcoded params format for autocompletion
	 * 
	 * ADDING NEW PARAMETERS:
	 * 		the name of the param needs to match the same node name in the xml... example
	 * 			public var MAX_EMAILS_SELECTABLE		:int;
	 * 		will be read from
	 *  		<MAX_EMAILS_SELECTABLE>1000</MAX_EMAILS_SELECTABLE>
	 * 
	 * for Array types have node value be split by the | character such as
	 * 			<NODE_NAME>valA|valB|valC<NODE_NAME>
	 * 
	 * @author Me^
	 */
	public class Settings 
	{
		
		/** list of variables not to retrieve from the xml when auto parsing it */
		private var ignore_from_xml:Array = ['code.skeleton.BUILD_TIMESTAMP']; 
		
		
		/** build date of this application module (format: yymmddhhmm) */
		public var BUILD_TIMESTAMP				:String	= '1012281121';
		
		
		
		
		/** path to the errors xml (eg: xml/errors.xml ) */
		public const ERRORS_XML_PATH			:String = 'xml/errors.xml';
		/** settings xml path (eg: xml/settings.xml) */
		public const SETTINGS_XML_PATH			:String = 'xml/settings.xml';
		/** path to the engine swf */
		public const ENGINE_PATH				:String = 'swf/editor_sofer.swf';
		/** error initializing application -- needs to be hardcoded since xmls cannot load due to initial load failure */
		public const ERROR_INITIALIZATION		:String	= 'Cannot initialize application.';
		
		
		
		
		
		/** allow domain strings which are appended to ".oddcast.com" such as "http://host-vd" */
		public var ALLOW_DOMAINS				:Array;
		
		
		
		
		
		/** email oddcast optin default selected value */
		public var EMAIL_DEFAULT_OPTIN_VALUE	: Boolean;
		/** if to allow multiple emails in the to_email field */
		public var EMAIL_ALLOW_MULTIPLE_EMAILS	: Boolean;
		/** what characters to restrict in the to_email field when one is allowed */
		public var EMAIL_SINGLE_TF_RESTRICT		: String;
		/** what characters to restrict in the to_email field when multiples are allowed */
		public var EMAIL_MULTIPLE_TF_RESTRICT	: String;
		/** if to replace bad words in the email field or alert */
		public var EMAIL_REPLACE_BAD_WORDS		: Boolean;
		/** maximum emails that can be selected in the popular media panel */
		public var MAX_EMAILS_SELECTABLE		:int;
		/** max number of recipients per email sending */
		public var MAX_EMAIL_RECIPIENTS			:int;
		/** oddcast fan checkbox default setting */
		public var ODDCAST_FAN_DEFAULT			:Boolean;
		/** the server api for communicating the Oddcast Fan optin (eg: http://host.oddcast.com/api/oddcastFan.php )*/
		public var API_ODDCAST_FAN				:String;
		/** which characters to restrict for tts input */
		public var TTS_RESTRICT_TEXT			:String;
		/** the default text to display in the tts input */
		public var TTS_DEFAULT_TEXT				:String;
		/** the default language to load on first load */
		public var TTS_DEFAULT_LANG				:String;
		/** the default voice to load on first load */
		public var TTS_DEFAULT_VOICE			:String;
		/** if to replace or alert on a bad word */
		public var TTS_REPLACE_BAD_WORD			: Boolean;
		/** script to load tts data */
		public var API_TTS_INIT					:String;
		/** flag indicating if to load bad words or not */
		public var USE_BAD_WORDS				:Boolean;
		/** microphone recording limit in seconds */
		public var MIC_SECONDS_REC_LIMIT		:Number;
		/** microphone app parameter for orc */
		public var MIC_APP_PARAM				:String;
		/** microphone uid parameter for orc */
		public var MIC_UID_PARAM				:String;
		/** microphone recording format */
		public var MIC_RECORD_FORMAT			:String;
		/** if to load thumbnails for vhosts panel */
		public var LOAD_MODEL_THUMBS			:Boolean;
		/** if to load thumbnails for backgrounds panel */
		public var LOAD_BG_THUMBS				:Boolean;
		/** if to load thumbnails for accessories panel */
		public var LOAD_ACC_THUMBS				:Boolean;
		/** name of the title when sharing to misc destinations like DIGG and delicious */
		public var SHARE_APP_TITLE				:String;
		/** DIGG share topic name */
		public var DIGG_SHARE_TOPIC				:String;
		/** DIGG share description */
		public var DIGG_SHARE_DESC				:String;
		/** the time for the apc to poll for status updates */
		public var APC_POLLING_TIME				:String;
		/** scheduler url for creating videos at a later time like post to youtube */
		public var SCHEDULER_URL				:String;
		/** scheduler name for the task created */
		public var SCHEDULER_TASK_NAME			:String;
		/** if the masking includes the ears or not */
		public var APC_MASKING_INCLUDING_EARS	:Boolean;
		/** how much the photo moves per click */
		public var APC_MOVE_AMT					:Number;
		/** how much the photo rotates per click */
		public var APC_ROT_AMT					:Number;
		/** how much the photo zooms per click */
		public var APC_ZOOM_AMT					:Number;
		/** milliseconds of repeat clicks if button is held down */
		public var APC_REPEAT_TIME				:Number;
		/** processing text for apc loader */
		public var APC_PROCESSING_MESSAGE_RETRIEVING:String;
		/** processing text for apc loader */
		public var APC_PROCESSING_MESSAGE_SUBMITTING:String;
		/** processing text for apc loader */
		public var APC_PROCESSING_MESSAGE_QUEUED:String;
		/** processing text for apc loader */
		public var APC_PROCESSING_MESSAGE_ANALYZING:String;
		/** processing text for apc loader */
		public var APC_PROCESSING_MESSAGE_CONVERTING:String;
		/** avatar position x */
		public var AVATAR_POS_X					:Number = 0;
		/** avatar position y */
		public var AVATAR_POS_Y					:Number = 0;
		/** avatar scale 0<->1 */
		public var AVATAR_SCALE					:Number = 1;
		/** terms and conditions body */
		public var TERMS_CONDITIONS_TEXT		:String = '';
		/** privacy policy body */
		public var PRIVACY_POLICY_TEXT			:String = '';
		/** alert user of the hyperlink they clicked on in case it was blocked by a popup */
		public var ALERT_ON_LINK				:Boolean = false;
		/** will change simple message to this: Alert #####: msg msg */
		public var ALERT_SHOW_CODE				:Boolean=false;
		/** milliseconds for external events to expire, calls to javascript etc */
		public var EVENT_TIMEOUT_MS				:int	= 30000;
		/** minutes that a user cannot flag the same message again */
		public var FLAGGING_BAN_MIN				:int	= 60;
		/** minimum size for uploading a background in KB */
		public var BG_MIN_SIZE_KB				:Number	= 1;
		/** maximum size for uploading a background in MB */
		public var BG_MAX_SIZE_MB				:Number	= 6;
		/** maxumim files that can be uploaded at once with the multi file uploader */
		public var UPLOAD_MAX_FILES				:int = 10;
		/** uploading a file timeout in seconds */
		public var UPLOAD_TIMEOUT_SEC			:Number;
		/** text populated when publishing to twitter */
		public var TWITTER_DEFAULT_TEXT			: String;
		
		/** move the user to the front of the list of friends */
		public var FACEBOOK_CONNECT_USER_FRONT_OF_LIST			: Boolean;
		/** posting to facebook user param MESSAGE */
		public var FACEBOOK_POST_MESSAGE		:String;
		/** posting to facebook user param NAME */
		public var FACEBOOK_POST_NAME			:String;
		/** posting to facebook user param CAPTION */
		public var FACEBOOK_POST_CAPTION		:String;
		/** posting to facebook user param DESCRIPTION */
		public var FACEBOOK_POST_DESCRIPTION	:String;
		/** posting to facebook user param IMAGE
		 * NOTE
		 * this can be relative - append to doors content misc folder url
		 * this can be absolute - use as is
		 */
		public var FACEBOOK_POST_IMAGE_URL		:String;
		/** if to auto generate posting to facebook image */
		public var FACEBOOK_POST_GENERATE_IMAGE	:Boolean;
		/** mode of opening the page, popup iframe etc.. */
		public var FACEBOOK_POST_DISPLAY		:String;
		public var USE_THIRD_DANCE:Boolean= false;
		public var TERMS_CONDITIONS_LINK:String = "";
		public function Settings(  )
		{}
		
		
		
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
			loop1: for (var i:int = 0, n:int = settings_properties.variable.length(); i<n; i++ )
			{
				var_node = settings_properties.variable[i];
				var_name = var_node.@name;
				var_type = var_node.@type;
				xml_value = _xml[var_name].toString();
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
			
			if (MAX_EMAIL_RECIPIENTS < 10)
				MAX_EMAIL_RECIPIENTS = 10;
			
			if (FACEBOOK_POST_IMAGE_URL.indexOf('://')==-1) // doesnt contain http:// then we add the stem
				FACEBOOK_POST_IMAGE_URL = ServerInfo.content_url_door + 'misc/' + FACEBOOK_POST_IMAGE_URL;
			
			if(TERMS_CONDITIONS_LINK.indexOf('://')==-1)
				TERMS_CONDITIONS_LINK = "http://content.oddcast.com/ccs6/customhost/1083/misc/terms.html";
			
			//FACEBOOK_POST_IMAGE_URL = "http://content-vs.oddcast.com/ccs6/customhost/1009/misc/fb-thumb.jpg";	
		}
		
	}
	
}
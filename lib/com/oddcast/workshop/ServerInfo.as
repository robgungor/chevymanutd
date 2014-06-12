/**
* ...
* @author Sam, Me^
* @version 3.1
* 
* workshop.swf?stem=http://host-d.staging.oddcast.com/getWorshopInfo?door=###
* 
* @update mid 2009
* 	all query parameters have been moved to the getWorkshopInfo call and to the settings.xml
* 
*/

package com.oddcast.workshop 
{
	import com.oddcast.audio.*;
	
	import flash.display.*;
	
	public class ServerInfo 
	{
		/** flag that app is a workshop */
		public static const WORKSHOP_APP				:String = "workshop";
		/** flag that app is a videostar */
		public static const VIDEOSTAR_APP				:String = "videostar";
		/** stem url pointing to getWorkshoInfo call eg: http://host-d.oddcast.com/php/api/getWorkshopInfo/doorId=239 */
		public static var stem_gwi						:String;
		/** project door id retrieved from loading url */
		public static var door							:int;
		/** project client id retrieved from loading url */
		public static var client						:int;
		/** used for Gallery - needs a seperate PHP call for this value to be retrieved */
		public static var topic							:int;
		/** project saved message id for playback retrieved from loading url (eg: 123456)*/
		public static var mid							:String;
		/** application folder (eg: template_F9_3D) pulled from default_url */
		public static var app_folder_name				:String;
		/** e.g. http://host-d.oddcast.com/ */
		public static var acceleratedURL				:String;
		/** e.g. http://host.oddcast.com/ */
		public static var localURL						:String;
		/** e.g. http://content.oddcast.com/host/template_F9_3D/swf/ */
		public static var swfPathURL					:String;
		/** built locally then replaced with value from server xml eg: http://cache-a.oddcast.com */
		public static var cachedURL						:String;
		/** value from server xml eg: http://char.dev.oddcast.com/ */
		public static var cache_oh_url					:String;
		/** built locally then replaced with value from server xml eg: c_fs */
		public static var cachedFolder					:String;
		/** value from server xml eg: http://otc.oddcast.com/ */
		public static var otcURL						:String;
		/** value from server xml (eg: http://fms.dev.oddcast.com/) */
		public static var orcURL						:String;
		/** value from server xml (eg:http://mobile.dev.oddcast.com/index.php) */
		public static var mobileURL						:String;
		public static var trackingURL					:String;
		public static var errorTrackURL					:String;
		/** built from server xml eg: http://content.oddcast.com/ */
		public static var contentURL					:String;
		/** door specific content url eg: http://content.dev.oddcast.com/ccs1/customhost/239/ */
		public static var content_url_door				:String;
		/** full body content url eg: http://content.oddcast.com/ccs2/fb3d/ */
		public static var full_body_content_url_door	:String;
		public static var otcAppName					:String;
		public static var otcAppXML						:XMLList;
		public static var videostar_pingUrl				:String;
		public static var videostar_pingDelay			:int		= 4000;
		public static var videostar_videoTimeoutSeconds	:Number 	= 1800;
		/** 30 minute timeout, dynamic from getWorkshopInfo */
		public static var sessionTimeoutSeconds			:Number 	= 1800;
		/** for testing of luxand - passed in as a query param to the swf when needed */
		public static var luxand_threshold				:String;
		/** flag indicating what this application type is.  By default its a workshop */
		public static var appType						:String		= WORKSHOP_APP;
		public static var appId							:int;
		/** autophoto app id needed for Using the APC autophoto component */
		public static var autophotoAppId				:int		= NO_VALUE_NUM;
		/** built locally then replaced with value from server xml eg: http://autophoto.oddcast.com/ */
		public static var autoPhotoURL					:String		= NO_VALUE_STRING;
		/** param needed in the autophoto url when loading */
		public static var autoPhoto_param_apd			:String		= NO_VALUE_STRING;
		/** param needed in the autophoto url when loading */
		public static var autoPhoto_param_apad			:String		= NO_VALUE_STRING;
		/** autophoto masking property 0:OFF 1:"" 2:"simple".  Value pulled from getWorkshopInfo */
		public static var autoPhoto_mask_mode			:int		= 0;
		public static var hasEventTracking				:Boolean	= false;
		public static var hasErrorTracking				:Boolean 	= false;
		public static var viralSourceId					:int;
		public static var isEmailSession				:Boolean	= false;
		public static var isEmbedSession				:Boolean	= false;
		public static var is3D							:Boolean	= false;
		public static var ttsCharLimit					:int		= 600;
		public static var isExpired						:Boolean	= false;
		/** OA1 files are uploaded in packets and this is the max packet size in KB, also value updated from server XML */
		public static var OA1_upload_limit				:Number		= 30;
		private static var expiryTimeStamp				:uint;
		/** url from loader info passed into this class LoaderInfo.url */
		private static var swfUrl						:String		= null;
		/** url to be used for getUrl and Bookmarking built from server xml customizable in the admin.	default: http://host.staging.oddcast.com/template_videostarV2/ */
		public static var pickup_url					:String		= '';
		/** cached url to the application for relative calls.	eg: http://content.dev.oddcast.com/host/template_F9_3D/ */
		public static var default_url					:String		= '';
		/** persistent image type string used for filterring, built from server xml eg: m0-4-30-53 where m0 comes from the masking for autophoto */
		public static var persistent_image_gf_params	:String		= '';
		/** the type of access given to persisnte image 0=off 1=read only 2=read write (see constants).  Set from server XML */
		public static var persistent_image_access_type	:int		= 0;
		/** persistent image engine url, built from server xml. eg: /autophoto/eng/apcpic/Persistent_Image_Engine_latest.swf */
		public static var persistent_image_engine_url	:String		= '';
		/** a parameter meant to be passed to the upload script for converting uploaded images to a usable format such as JPG if a user uploads a BMP
		 * default = true */
		public static var convert_uploaded_images		:Boolean	= true;
		/** list of products (String) that are applicable to purchasing via paypal, retrieved form GWI */
		public static var arr_paypal_product_sku		:Array		= new Array();
		/** indication if to show authored creation patent information during autophoto creation */
		public static var show_authored_create			:Boolean	= false;
		/** marketing distribution id for this application */
		public static var distribution_id				:String;
		/** php for reporting the distribution id, parent mid and new mid eg: 'http://data-vd.oddcast.com/distribution.php' retrieved from GWI*/
		public static var distribution_id_reporting_url	:String
		/** the mId of the application that the user came from */ 
		public static var parent_mId					:String;
		/** allow shared objects to be interacted with */
		public static var shared_objects_enabled		:Boolean = true;
		
		/** indicated what type of door we are currently running, eg: ServerInfo.APP_TYPE_Flash_9_3D */
		public static var app_type						:String		= NO_VALUE_STRING;
		public static const APP_TYPE_Flash_8			:String		= 'APP_TYPE_Flash_8';
		public static const APP_TYPE_Flash_9_3D			:String		= 'APP_TYPE_Flash_9_3D';
		public static const APP_TYPE_Flash_10_FB_3D		:String		= 'APP_TYPE_Flash_10_FB_3D';
		public static const APP_TYPE_Videostar			:String		= 'APP_TYPE_Videostar';
		public static const APP_TYPE_Morph				:String		= 'APP_TYPE_Morph';
		public static const APP_TYPE_Flash_9_2D			:String		= 'APP_TYPE_Flash_9_2D';
		public static const APP_TYPE_OTC_Only			:String		= 'APP_TYPE_OTC_Only';
		public static const APP_TYPE_ORC_Only			:String		= 'APP_TYPE_ORC_Only';
		public static const APP_TYPE_Videostar_Widget	:String		= 'APP_TYPE_Videostar_Widget';
		
		
		/** the maximum allowed autophoto sessions for uploading photos for this application */
		public static var throttle_microphone_max_count					:int		= NO_VALUE_NUM;
		/** the maximum allowed autophoto sessions for uploading photos for this application */
		public static var throttle_autophoto_upload_max_count			:int		= NO_VALUE_NUM;
		/** this is what separates low traffic to high traffic but not past max traffic */
		public static var throttle_autophoto_upload_low_traffic_index	:int		= NO_VALUE_NUM;
		/** how many autophoto requests are allowed during moderate traffic times */
		public static var throttle_autophoto_upload_allowance			:int		= NO_VALUE_NUM;
		/** limit to be appended to the back of the mp3 when requested in cases of high traffic to avoid overload */
		public static var throttle_tts_max_count						:int		= NO_VALUE_NUM;
		/** this is what separates low traffic to high traffic but not past max traffic */
		public static var throttle_tts_low_traffic_index				:int		= NO_VALUE_NUM;
		/** how many tts requests are allowed during moderate traffic times */
		public static var throttle_tts_allowance						:int		= NO_VALUE_NUM;
		/** maximum system load where all calls will be rejected if surpassed - not the same as the count */
		public static var throttle_max_load								:int		= NO_VALUE_NUM;
		/** script for checking server capacities eg: */
		public static var throttle_capacity_url							:String		= NO_VALUE_STRING;
		
		
		public static const PERSISTANT_IMAGE_OFF		:int		= 0;
		public static const PERSISTANT_IMAGE_READ_ONLY	:int		= 1;
		public static const PERSISTANT_IMAGE_READ_WRITE	:int		= 2;
		public static const NO_VALUE_STRING				:String		= 'no value set';
		public static const NO_VALUE_NUM				:int		= -373737;	// has to be random enough so that its not used anywhere...
		
		/**
		 * init some params based on url query string
		 * @param	swfInfo loaderInfo object (root.loaderInfo)
		 */
		public static function setLoaderInfo(swfInfo:LoaderInfo):void
		{		
				viralSourceId 	= 0;
				
			// get the message id for playback or for the parent mid that this session was opened from
				mid 			= null;
				var message_id:String;
				
				if (!isEmptyString(swfInfo.parameters.mId)) 		message_id = swfInfo.parameters.mId;
				else if (!isEmptyString(swfInfo.parameters.mid)) 	message_id = swfInfo.parameters.mid;
				if (message_id)
				{
					if (parseFloat(message_id)<0)// this is a parent mid and not meant for playback
						parent_mId = message_id.substr(1).split('.').shift();
					else
						mid = message_id.split('.').shift();
					
					set_viral_source( message_id );
				}
				
				if (!isEmptyString(swfInfo.parameters.dId))
					distribution_id = swfInfo.parameters.dId;
			
			// testing of luxand
				if (!isEmptyString(swfInfo.parameters.luxand)) 
					luxand_threshold = swfInfo.parameters.luxand;
					
			stem_gwi = swfInfo.parameters.stem;
			
			function set_viral_source(_mid:String):void
			{
				if (_mid && _mid.indexOf('.'))
					viralSourceId = _mid.split('.').pop();
				else
					viralSourceId = 0;
				
				isEmbedSession = viralSourceId == 1;
				isEmailSession = viralSourceId == 2;
			}
		}
		
		
		/**
		 * keep track of which mid this app was opened with 
		 * @param _parent mId
		 * 
		 */		
		public static function set_parent_mId( _parent:String ):void
		{
			parent_mId = _parent;
		}
		
		/**
		 * true if there is a valid MID set
		 */
		public static function get hasMessage():Boolean 
		{	if (isEmptyString(mid) 
				|| 
				mid == "0" 
				|| 
				isNaN(parseInt(mid))) 	
					return(false);
			else 	return(true);
		}
		
		/**
		 * check if a string has a valid value
		 * @param	s
		 */
		private static function isEmptyString(s:String):Boolean
		{	if (s == null || s == "") 	return true;
			else 						return false;
		}
		
		/**
		 * parses and stores parameters from the getWorkshopInfo call
		 * @param	_xml xml from server
		 */
		public static function parseXML(_xml:XML):void
		{	
			var i:int, n:int;
			
			if (_xml.hasOwnProperty('DOORTYPE'))
			{	var xml_app_type:Number = parseFloat( _xml.DOORTYPE.@ID );
				switch ( xml_app_type )
				{	case 1:			app_type = APP_TYPE_Flash_8;								break;
					case 2:			app_type = APP_TYPE_Flash_9_3D;			is3D = true;		break;
					case 3:			app_type = APP_TYPE_Videostar;								break;
					case 4:			app_type = APP_TYPE_Morph;									break;
					case 5:			app_type = APP_TYPE_Flash_9_2D;								break;
					case 6:			app_type = APP_TYPE_OTC_Only;								break;
					case 7:			app_type = APP_TYPE_ORC_Only;								break;
					case 8:			app_type = APP_TYPE_Videostar_Widget;						break;
					case 9:																		break;
					case 10:		app_type = APP_TYPE_Flash_10_FB_3D;		is3D = true;		break;
				}
			}
			if (_xml.hasOwnProperty('INFO'))
			{	door	= parseInt(_xml.INFO.@D);
				client	= parseInt(_xml.INFO.@C);
			}
			if (_xml.hasOwnProperty('ACCEL'))			acceleratedURL					= _xml.ACCEL.@URL;
			if (_xml.hasOwnProperty('LOCAL'))			localURL						= _xml.LOCAL.@URL;
			if (_xml.hasOwnProperty("ORC"))	 			orcURL							= _xml.ORC.@URL;
			if (_xml.hasOwnProperty("OTC")) 			otcURL							= _xml.OTC.@URL+"/";
			if (_xml.hasOwnProperty("CONTENT")) 		contentURL						= _xml.CONTENT.@URL.toString();
			if (_xml.hasOwnProperty("DOORCONTENT")) 	content_url_door				= _xml.DOORCONTENT.@URL.toString();
			if (_xml.hasOwnProperty("FB_DOORCONTENT"))	full_body_content_url_door		= _xml.FB_DOORCONTENT.@URL.toString();
			if (_xml.hasOwnProperty("DISTRIBUTION"))	distribution_id_reporting_url	= _xml.DISTRIBUTION.@URL.toString();
			if (_xml.hasOwnProperty("OTCAPPNAME")) 
			{	otcAppName	= _xml.OTCAPPNAME[0].@NAME;
				otcAppXML	= _xml.OTCAPPNAME;
			}
			if (_xml.hasOwnProperty("CAP")) 		throttle_capacity_url	= _xml.CAP.@URL;
			if (_xml.hasOwnProperty("AUTOPHOTO")) 
			{	autoPhotoURL					= _xml.AUTOPHOTO.@APCURL;
				autoPhotoURL					= ( autoPhotoURL.length > 5 ) ? autoPhotoURL : NO_VALUE_STRING;
				autoPhoto_param_apd				= _xml.AUTOPHOTO.@URL+'/';
				autoPhoto_param_apad			= _xml.AUTOPHOTO.@ACCURL+'/';
				autophotoAppId					= parseInt(_xml.AUTOPHOTO.@APPID);
				autophotoAppId					= ( autophotoAppId > 0 ) ? autophotoAppId : NO_VALUE_NUM;
				autoPhoto_mask_mode				= parseInt(_xml.AUTOPHOTO.@MASK);
				persistent_image_engine_url		= _xml.AUTOPHOTO.@ENG;
				persistent_image_access_type	= parseInt(_xml.AUTOPHOTO.@PER_IMG_ACCESS);
				persistent_image_gf_params		= 'm' + ((autoPhoto_mask_mode > 0)?1:0) + '-' + _xml.AUTOPHOTO.@PSTR;	// eg: m0-4-30-53
			}
			if (_xml.hasOwnProperty("MOBILE")) 
			{	mobileURL	= _xml.MOBILE.@URL+"/";
				appId		= parseInt(_xml.MOBILE.@APPID);
			}
			if (_xml.hasOwnProperty("CACHE")) 
			{	cachedURL		= _xml.CACHE.@URL+"/";
				cachedFolder	= _xml.CACHE.@CDIR;
				CachedTTS.setDomain(cachedURL);
				CachedTTS.setServerFolder(cachedFolder);
			}
			if (_xml.hasOwnProperty("CACHE")) 
			{	cache_oh_url	= _xml.CACHE_OH.@URL;
			}
			if (_xml.hasOwnProperty("VIDEOSTAR")) 
			{	videostar_pingUrl	= _xml.VIDEOSTAR.@URL.toString();
				videostar_pingDelay	= parseInt(_xml.VIDEOSTAR.@DELAY.toString());
				if (videostar_pingDelay < 10)
					videostar_pingDelay = 4000;
			}
			if (_xml.hasOwnProperty("TRACKING")) 
			{	trackingURL		= _xml.TRACKING.@URL+"/";
				hasEventTracking= true;
			}
			if (_xml.hasOwnProperty("TRACKERROR")) 
			{	errorTrackURL	= _xml.TRACKERROR.@URL;
				hasErrorTracking= true;
			}
			if (_xml.hasOwnProperty("EXPIRED")) 
			{	isExpired 		= (_xml.EXPIRED.@VALUE.toString() == "true");
				expiryTimeStamp = parseInt(_xml.EXPIRED.@WHEN.toString());
			}
			if (_xml.hasOwnProperty("PARAMETERS")) 
			{	
				if (_xml.PARAMETERS.hasOwnProperty("TTSLIMIT")) 
				{	var ttsLimitStr:String = _xml.PARAMETERS.TTSLIMIT.@VAL.toString();
					if (ttsLimitStr!=null&&ttsLimitStr.length>0) ttsCharLimit = parseInt(ttsLimitStr);
				}
				var paramObj	:Object		= new Object();
				var xmlParams	:XMLList	= _xml.PARAMETERS[0].PARAM;
				
				for (i = 0, n=xmlParams.length(); i < n; i++)
					paramObj[xmlParams[i].@NAME.toString()] = xmlParams[i].@VALUE.toString();
				
				if (paramObj.authCreate != undefined)		show_authored_create	= paramObj.authCreate == 'true';
				if (paramObj.sessionTimeOut != undefined) 
				{	sessionTimeoutSeconds			= parseFloat(paramObj.sessionTimeOut) * 60;
					videostar_videoTimeoutSeconds 	= sessionTimeoutSeconds;
				}
				if (paramObj.oa1UploadSize 	!= undefined)	OA1_upload_limit		= paramObj.oa1UploadSize;
				if (paramObj.pickUpUrl 		!= undefined) 	pickup_url				= paramObj.pickUpUrl;
				if (paramObj.defaultUrl 	!= undefined)
				{	default_url				= paramObj.defaultUrl;
					swfPathURL				= default_url + 'swf/';
					
					// pull app name
						var temp_arr	:Array	= default_url.split('/');
						app_folder_name			= temp_arr[temp_arr.length - 2];
				}
				if (paramObj.convertImage != undefined)
				{
					if (paramObj.convertImage.toLowerCase() == 'false')
							convert_uploaded_images = false;
					else	convert_uploaded_images = true;
				}
				
				if (paramObj.fmsThreshold != undefined)		throttle_microphone_max_count				= (parseInt(paramObj.fmsThreshold) 		== 0) ? NO_VALUE_NUM : parseInt(paramObj.fmsThreshold);
				if (paramObj.apcThrottle != undefined)		throttle_autophoto_upload_max_count			= (parseInt(paramObj.apcThrottle) 		== 0) ? NO_VALUE_NUM : parseInt(paramObj.apcThrottle);
				if (paramObj.apcUpAllowance != undefined)	throttle_autophoto_upload_allowance			= (parseInt(paramObj.apcUpAllowance) 	== 0) ? NO_VALUE_NUM : parseInt(paramObj.apcUpAllowance);
				if (paramObj.apcLowTraffic != undefined)	throttle_autophoto_upload_low_traffic_index	= (parseInt(paramObj.apcLowTraffic) 	== 0) ? NO_VALUE_NUM : parseInt(paramObj.apcLowTraffic);
				if (paramObj.ttsThrottle != undefined)		throttle_tts_max_count						= (parseInt(paramObj.ttsThrottle) 		== 0) ? NO_VALUE_NUM : parseInt(paramObj.ttsThrottle);
				if (paramObj.ttsAllowance != undefined)		throttle_tts_allowance						= (parseInt(paramObj.ttsAllowance) 		== 0) ? NO_VALUE_NUM : parseInt(paramObj.ttsAllowance);
				if (paramObj.ttsLowTraffic != undefined)	throttle_tts_low_traffic_index				= (parseInt(paramObj.ttsLowTraffic) 	== 0) ? NO_VALUE_NUM : parseInt(paramObj.ttsLowTraffic);
				if (paramObj.overLoad != undefined)			throttle_max_load							= (parseInt(paramObj.overLoad) 			== 0) ? NO_VALUE_NUM : parseInt(paramObj.overLoad);
				if (paramObj.noCookies != undefined)		shared_objects_enabled						= !(paramObj.noCookies == "true");
			}
			if (_xml.hasOwnProperty('STOREPRODUCTS') && (_xml.STOREPRODUCTS.hasOwnProperty('PRODUCT')))
			{
				for (n = _xml.STOREPRODUCTS.PRODUCT.length(), i = 0; i < n; i++)
					arr_paypal_product_sku.push( _xml.STOREPRODUCTS.PRODUCT[i].@SKU );
			}
		}
	}
	
}
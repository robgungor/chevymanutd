package code.models
{
	import code.models.items.List_Backgrounds;
	import code.models.items.List_Canned_Audios;
	import code.models.items.List_Errors;
	import code.models.items.List_Popular_Media_Contacts;
	import code.models.items.List_TTS_Voices;
	import code.models.items.List_Vhost_Accessories;
	import code.models.items.List_Vhosts;

	public class Model_Store
	{
		public var list_tts_voices					: List_TTS_Voices = new List_TTS_Voices();
		/** prerecorded canned audio information */
		public var list_canned_audio				: List_Canned_Audios = new List_Canned_Audios();
		/** parsed data from the backgrounds xml list */
		public var list_backgrounds					: List_Backgrounds = new List_Backgrounds();
		/** data parsed from the xml pertaining to error text, title etc */
		public var list_errors						: List_Errors = new List_Errors();
		/** data parsed from the accessories xml for each vhost ID */
		public var list_vhost_accessories			: List_Vhost_Accessories = new List_Vhost_Accessories();
		/** data parsed from the getModels xml */
		public var list_vhosts						: List_Vhosts = new List_Vhosts();
		
//		public var list_popular_media_contacts:List_Popular_Media_Contacts=new List_Popular_Media_Contacts();
		
		public function Model_Store()
		{
		}
	}
}
package code.skeleton
{
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import workshop.ui.LocalizedButton;

	public class Localizer
	{
		public function Localizer()
		{
			_translations = new Dictionary();
			//_translations["homescreen_btn_facebook"] = "LCL FACEBOOK"; 
		}
		private var _language		:String = 'en';
		private var _translations	:Dictionary;
		
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
		
		
		public function getTranslation(key:String):String
		{
			trace('getting translation for: '+key);
			return _translations[key];
		}
	}
}
package code.skeleton
{
	import fl.motion.easing.Circular;
	import fl.text.TLFTextField;
	
	import flash.display.Loader;
	import flash.text.Font;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.Direction;

	public class FontManager
	{
//		
//		kr – korean                 (louis font)
//		jp – japan                   (Meiryo UI font)
//		th – thai                      (circular font)
//		ru – Russia/Cyrillic   (arial font)
//		arabic                         (arial font)
//		cn – china                  (Microsoft YaHei UI font)
		
		public static var arial_bold			:ArialBold 			= new ArialBold();
		public static var arial_regular			:ArialRegular 		= new ArialRegular();		
		public static var arial_italic			:ArialItalic		= new ArialItalic(); //italic
		public static var arial_boldItalic		:ArialBoldItalic	= new ArialBoldItalic(); //italic
		
//		public static var circular_regular		:CircularRegular	= new CircularRegular(); //regular
//		public static var circular_Bold_regular	:CircularBold		= new CircularBold(); //regular
		
//		public static var appleGothic	:AppleGothic				= new AppleGothic(); //regular
//		public static var adobeGothic	:AdobeGothicStd				= new AdobeGothicStd(); //bold
		
		public static var louis_bold			:LouisBold			= new LouisBold(); //regular
		public static var louis_bold_italic		:LouisBoldItalic	= new LouisBoldItalic(); //regular
		public static var louis_italic			:LouisItalic		= new LouisItalic(); //regular
		public static var louis_regular			:LouisRegular		= new LouisRegular(); //regular
		
//		public static var meiryoUI_bold			:MeiryoUIBold		= new MeiryoUIBold(); //bold
//		public static var meiryoUI_boldItalic	:MeiryoUIBoldItalic = new MeiryoUIBoldItalic(); //boldItalic
//		public static var meiryoUI_italic		:MeiryoUIItalic 	= new MeiryoUIItalic(); //italic
//		public static var meiryoUI_regular 		:MeiryoUIRegular	= new MeiryoUIRegular(); //regular
		
		//public static var microsoftYaHeiUI_regular	:MicrosoftYaHeiUIRegular	= new MicrosoftYaHeiUIRegular(); //regular
		//public static var microsoftYaHeiUI_bold		:MicrosoftYaHeiUIBold		= new MicrosoftYaHeiUIBold(); //bold
		
		
		
		
		
		public function FontManager()
		{
			
		}
		
		public static function registerFonts( l:Loader, lang:String ):void
		{			
			languages[lang] = new Language(lang, registerFont("regular"), registerFont("italic"), registerFont("bold"), registerFont("bolditalic"));	
			_enumerateFonts();
			
			function registerFont(fontName:String):Font
			{
				var font:Font;
				var FontClass:Class = l.contentLoaderInfo.applicationDomain.hasDefinition(fontName) ? l.contentLoaderInfo.applicationDomain.getDefinition(fontName) as Class : null;
				if(FontClass)
				{
					font = new FontClass();// (l.contentLoaderInfo.applicationDomain.getDefinition("bold") as Class);
					Font.registerFont(FontClass);
				}
				return font;
			}	
			function _enumerateFonts():void
			{				
				var embeddedFonts:Array = Font.enumerateFonts(false);
				embeddedFonts.sortOn("fontName", Array.CASEINSENSITIVE);
				
				for(var i:int = 0;i<embeddedFonts.length;i++){
					var font:Font = embeddedFonts[i];
					//trace(font.fontName+": "+font.fontStyle);			
				}
			}
		}
		
		public static function replaceFonts(field:TextField, lang:String):TLFTextField
		{			
			var language:Language = languages.hasOwnProperty(lang) ? languages[lang] : null;
			
			// if it's not in the list, don't replace it!
			if(language == null) return null;
			
			var tf:TextFormat 	 = field.defaultTextFormat;
			var fontStyle:String = tf.font.split("Louis").join("").split(" ").join("").toLowerCase();
			
			// if we recognize it as 
			var newFont:Font	 = language.hasOwnProperty(fontStyle) ? language[fontStyle] : language['regular'];
			if(newFont)	
			{							
				tf.font = newFont.fontName;
				tf.kerning = false;
			
				if(lang == "cn") {
					
					tf.letterSpacing 	= tf.size.valueOf()/3;
					tf.leading 			= -tf.size.valueOf()/5;
					field.gridFitType 	= GridFitType.PIXEL;
				}
				if(lang == "kr" && fontStyle == "bolditalic") {
					
					//tf.letterSpacing 	= tf.size.valueOf()/3;
					tf.leading 			= tf.size.valueOf()*.1;
					//field.gridFitType 	= GridFitType.PIXEL;
				}
				
				if(lang == "jp" && fontStyle == "bolditalic") {
					
					tf.letterSpacing 	= 0//tf.size.valueOf()/10;
					tf.leading 			= -tf.size.valueOf()/5;
					tf.size 			= tf.size.valueOf()*.8;
					field.gridFitType 	= GridFitType.PIXEL;
				}
				
				if(lang == "ru" && fontStyle == "bolditalic") {								
					tf.size 			= tf.size.valueOf()*.65;
					tf.leading 			= tf.leading+5;
				}
				field.defaultTextFormat = tf;
			}
			
			if(lang.indexOf("arabic")>-1)
			{
				var tlf:TLFTextField = new TLFTextField();
				tlf.width 				= field.width;
				tlf.height 				= field.height;
				tlf.name 				= field.name;
				tlf.x					= field.x;
				tlf.y					= field.y;
				tlf.antiAliasType 		= field.antiAliasType;
				tlf.direction 			= Direction.RTL;
				//tlf.text 				= field.text;
				tlf.defaultTextFormat 	= tf;
				tlf.embedFonts			= true;
				tlf.selectable 			= field.selectable;
				tlf.gridFitType			= field.gridFitType;
				
				return tlf;
			}
			return null;
		}
		private static var _languages:Languages;
		public static function get languages():Languages 
		{
			if(_languages == null) _languages = new Languages();
			return _languages;
		}
	}
}

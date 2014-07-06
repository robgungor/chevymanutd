package code.skeleton
{
	public dynamic class Languages
	{
		public var kr		:Language;
		public var jp		:Language;
		public var arabic	:Language;
		public var ru		:Language;
		public var cn		:Language;
		public var th		:Language;
		
		public function Languages()
		{
			//kr 		= new Language("kr", 		FontManager.appleGothic,				FontManager.appleGothic,		FontManager.adobeGothic);
			//jp 		= new Language("jp", 		FontManager.meiryoUI_regular, 			FontManager.meiryoUI_italic, 	FontManager.meiryoUI_bold, 			FontManager.meiryoUI_boldItalic);
			//arabic 	= new Language("arabic", 	FontManager.arial_regular, 				FontManager.arial_italic, 		FontManager.arial_bold, 			FontManager.arial_boldItalic);
			ru	 	= new Language("ru", 		FontManager.arial_regular, 				FontManager.arial_italic, 		FontManager.arial_bold, 			FontManager.arial_boldItalic);
			//cn	 	= new Language("cn", 		FontManager.microsoftYaHeiUI_regular, 	null, 							FontManager.microsoftYaHeiUI_bold, 	null);
			//th	 	= new Language("th", 		FontManager.circular_regular, 			null, 							FontManager.circular_Bold_regular, 	null);
		}
	}
}



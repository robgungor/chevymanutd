package code.skeleton
{
	import flash.text.Font;

	public class Language
	{
		public var name			:String;
		public var regular		:Font;
		public var italic		:Font;
		public var bold			:Font;
		public var bolditalic	:Font;
		
		public function Language(lang:String, regularFont:Font = null, italicFont:Font = null, boldFont:Font = null, boldItalicFont:Font = null)
		{
			name 		= lang;
			if(regularFont == null) return;
			regular 	= regularFont;
			italic  	= italicFont || boldItalicFont || regular;
			bold 		= boldFont || regular;		
			bolditalic 	= boldItalicFont || italicFont || boldFont || regularFont;
		}

	}
}
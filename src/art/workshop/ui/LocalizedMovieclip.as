package workshop.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	
	public class LocalizedMovieclip extends MovieClip implements ILocalizable
	{
		protected var _value:String;		
		protected var _key:String;
		protected var _translation:String;
		private var _textValue:String;
			
		public function LocalizedMovieclip()
		{
			super();
		}
			
		public function setText(value:String, language:String = '', useDeviceFonts:Boolean = false, replaceFontsFunction:Function = null):void
		{
//			var child:DisplayObjectContainer =  getChildByName(language) as DisplayObjectContainer || getChildAt(0) as DisplayObjectContainer;
//						
//			// loop through states and set text accordingly
//			
//				for (var i:int = 0; i<child.numChildren; i++)
//				{
//					if(child.getChildAt(i) is TextField) 
//						(child.getChildAt(i) as TextField).text = value;						
//				}
//				
		}
			
	}
}
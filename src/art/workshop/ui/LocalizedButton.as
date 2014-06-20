package workshop.ui
{		
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	
	public class LocalizedButton extends MovieClip implements ILocalizable
	{
		private var _textValue:String;
		
		public function LocalizedButton()
		{		
			super();			
		}
		
		protected var _value:String;		
		protected var _key:String;
		protected var _translation:String;
		
		public function setText(value:String, language:String = '', useDeviceFonts:Boolean = false, replaceFontsFunction:Function = null):void
		{
			var btn:SimpleButton =  getChildByName(language) as SimpleButton || getChildAt(0) as SimpleButton;
			
			var states:Array = [btn.upState, btn.overState, btn.downState, btn.hitTestState];
			
			// loop through states and set text accordingly
			for each( var state:* in states )
			{
				if(state is DisplayObjectContainer) 
				{
					for (var i:int = 0; i<state.numChildren; i++)
					{
						if(state.getChildAt(i) is TextField) 
						{
							var tf:TextField = (state.getChildAt(i) as TextField)
							//tf.embedFonts = !useDeviceFonts;
							trace("REPLACING FONTS IN LOCALIZED BUTTON: "+replaceFontsFunction);
							replaceFontsFunction(tf, language);
							(state.getChildAt(i) as TextField).text = value;						
						}
					}
				}
			}
		}
	}
}
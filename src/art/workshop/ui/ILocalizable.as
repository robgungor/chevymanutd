package workshop.ui
{
	public interface ILocalizable
	{
		function setText(value:String, language:String = '', useDeviceFonts:Boolean = false, replaceFontsFunction:Function = null):void
	}
}
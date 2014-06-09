package code.controllers.bitly_url
{
	import com.oddcast.workshop.Callback_Struct;

	public interface IBitly_Url
	{
		function shorten_url( _url:String, _callbacks:Callback_Struct ):void
	}
}
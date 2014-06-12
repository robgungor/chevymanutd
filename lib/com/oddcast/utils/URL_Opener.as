package com.oddcast.utils 
{
	import com.oddcast.workshop.ExternalInterface_Proxy;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Me^
	 * 
	* the embed page needs this function in the <head> to work properly:
		<script type="text/javascript">
			function popup(url, name)
			{
				var newwindow = window.open(url, name);
				if (window.focus) { newwindow.focus(); }
				return name;	// return it for verification that the function was called correctly
			}
		</script>
	 */
	public class URL_Opener 
	{
		public static const SELF		:String	= '_self';
		public static const TOP			:String	= '_top';
		public static const BLANK		:String	= '_blank';
		
		/**
		 * opens a url in the best method for avoiding popup blockers
		 * @param	url		url to open
		 * @param	window	window mode (eg: URL_Opener.BLANK)
		 * @param	_error	
		 */
		public static function open_url( url:String, window:String=BLANK, _error:Function = null):void
		{	switch (window)
			{	case SELF	:	nav_to_url( url, window);		break;
				case TOP	:	nav_to_url( url, window);		break;
				case BLANK	:	var win_target	:String	= 'oddcast_newwin_' + Math.floor(new Date().time).toString();	// need a new name to not open a new popup and then all new requests to reload the same window
								var js_return	:String;																// string returned from the javascript function if it was called correctly
								try				{	js_return = ExternalInterface_Proxy.call("popup", url, win_target);	 }	// try to call javascript
								catch (e:Error)	{	}
								trace('(Oo) :: com.oddcast.utils.URL_Opener.open_url() ' + ((win_target == js_return)?'called javascript':'calling navigateToURL'), 'js_return:', js_return );
								if (win_target != js_return && js_return != 'true' )									// if the name doesnt match or not true then function wasnt called correctly
									nav_to_url( url, window);															// javascript didnt work so use the conventional method
								break;
			}
			
			function nav_to_url( _url:String, _win:String ):void
			{	try				{	navigateToURL(new URLRequest(_url), _win);		}
				catch(_e:Error)	{	if (_error != null)	_error(url);
									/* common issue -> embed allowNetworking="internal" */	
								}
			}
		}
		
		/****************************** all links ******************************/
		public static function open_oddcast		( e:Event = null ):void	{	open_url('http://www.oddcast.com', BLANK);		}
		
	}
	
}
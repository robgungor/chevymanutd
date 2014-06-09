package code.controllers.alert 
{
	import com.oddcast.event.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IAlert 
	{	
		function alert(_e:AlertEvent):void
		function report_error( _alert:AlertEvent, _alert_text:String = null ):void;
		function set_properties( _show_alert_code:Boolean ):void;
	}
	
}
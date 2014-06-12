/**
* @author Sam Myer, Me^
* 
* static class used to report errors to the server.  userText is the text shown to the user
*/
package com.oddcast.workshop 
{
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	public class ErrorReporter 
	{
		private static var browserInfo		:String = Capabilities.os + " " + Capabilities.version;
		private static const NOT_SET		:String = 'not set';
		private static var clicked_history	:Array;
		
		public static function init( _stage:Stage ):void 
		{	
			if (_stage)
			{
				clicked_history = new Array();
				_stage.addEventListener(MouseEvent.CLICK,clicked);
			}
			function clicked(_e:MouseEvent):void
			{
				var nume:String = _e.target.name;
				if (nume)
					clicked_history.push(nume);
			}
		}
		
		/**
		 * reports an error to the back end
		 * @param	_e	user generated error
		 * @param	_user_text	specific error text
		 * @param	_compile_time	compilation time of this swf (eg: YYMMDDHHMM)
		 */
		public static function report( _e:AlertEvent, _user_text:String = null, _compile_time:String = NOT_SET):void
		{
			if (browserInfo == null) 
				browserInfo = Capabilities.os + " " + Capabilities.version;
			
			//report the error
			if (ServerInfo.hasErrorTracking) 
			{
				var sendVars:URLVariables	= new URLVariables();
				sendVars.error				= _user_text == null ? _e.text : _user_text;
				sendVars.type 				= _e.alertType;
				sendVars.code 				= _e.code;
				sendVars.originator 		= getQualifiedClassName(_e.target);
				sendVars.plugin 			= browserInfo;
				sendVars.door 				= ServerInfo.door;
				sendVars.appVer				= escape( (_compile_time == NOT_SET) ? NOT_SET : _compile_time );
				
				var debugArr:Array = new Array();
				var infoKey	:String;
				for (infoKey in _e.moreInfo)
					debugArr.push(infoKey + ":" + escape(_e.moreInfo[infoKey]));
					
				// add clicked buttons history list
				if (clicked_history)
				{
					var btn_history:String = clicked_history.toString();
					var start:int = btn_history.length - 100;
					if (start<0) start = 0;
					var end:int = btn_history.length;
					btn_history = btn_history.substr( start, end );
					debugArr.push('btn_history:' + escape(btn_history));
				}
					
				if (debugArr.length > 0) 
					sendVars.addInfo = debugArr.join(" ");
				
				XMLLoader.sendVars(ServerInfo.errorTrackURL, null, sendVars);
			}
		}
	}
	
}
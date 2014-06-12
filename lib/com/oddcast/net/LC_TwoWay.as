/*
Package
	com.oddcast.net 
Class 
	public class LC_TwoWay 
Inheritance 
	LC_TwoWay -> EventDispatcher

Language version:  ActionScript 3.0 
Player version:  Flash Player 9 

The LC_TwoWay class uses local connection for both sending and receiving of messages
This class allows flash 9 (as3) swfs to communicate with other swfs flash 6 and up (as1, as2)

The local connection is asynchronous and should be used with caution.
For best results wait for a SUCCESS event before assuming the sending of a message was succesful

Public Methods:
	LC_TwoWay(receiverName:String,scope:Object,domains:String)
		Creates an LC_TwoWay Object
	init():void
		Initialized the LC_TwoWay object
	send(connName:String,methodName:String,assocArr:Array):void
		Triggers the methodName on the receiving end of the LocalConnection

Events:
	implements com.oddcast.event.LCEvents
	
Properties:

Examples:
	The following example shows ...
	
///////////////////////////////////////////

package 
{
	import flash.events.Event;    
	import com.oddcast.net.LC_TwoWay;

	public class LC_User extends Sprite {			
			private var lc:LC_TwoWay;
			private var _sSendConId:String = "ssss123";
			private var _sRecConId:String = "rrrr123";
				
			public function LC_User() {
				//this is the scope in which functions will be invoked via local connection calls
				lc = new LC_TwoWay(_sRecConId,this); 
				lc.addEventListener(LCEVENT.SUCCESS, onLCEventHandler);
				lc.addEventListener(LCEVENT.FAILED, onLCEventHandler);
				lc.addEventListener(LCEVENT.NAME_TAKEN, onLCEventHandler);
				lc.init();					
			}									
			
			private function sendMessage():void
			{				
				var ar:Array = new Array();
				ar["one"] = Math.random();
				ar["two"] = Math.random();
				ar["three"] = Math.random();			
				lc.send(_sSendConId,"remoteFunction",ar);
				
			}
			
			private function onLCEventHandler(evt:LCEvent):void
			{
				switch (evt.type)
				{
					case "success":
						trace("send LC success");
						break;
					case "failed":
						trace("send LC failed");
						break;
					case "isTaken":
						trace("receive LC name is in use");
						break;
				}
			}
			
			//this function can be invoked from a LocalConnection object on a different swf
			public function remoteFunction(ar:Array):void
			{
				for (var i in ar)
				{
					trace(i+"->"+ar[i]);
				}
			}
	}
}
///////////////////////////////////////////
		
*/
package com.oddcast.net
{        
	import com.oddcast.event.LCEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.LocalConnection;    
    import flash.events.StatusEvent;
    

    public class LC_TwoWay extends EventDispatcher{
        
		//public static const SUCCESS:String = "success";
		//public static const FAILED:String = "failed";
		//public static const NAME_TAKEN:String = "isTaken";
		private var _connSender:LocalConnection;
        private var _connReceiver:LocalConnection;
		private var _oAPI:Object;
		private var _sReceiverName:String;
		private var _sAllowedDomain:String;
        // UI elements        
        
        function LC_TwoWay(receiverName:String,scope:Object,domains:String = "*")
		{
			_oAPI = scope;
			_sReceiverName = receiverName;		
			_sAllowedDomain = domains;
		}
				
		
		public function init():void {           
            
			//setup sender
			_connSender = new LocalConnection();
			_connSender.addEventListener(StatusEvent.STATUS, onSendStatus);			
			
			//setup receiver
			_connReceiver = new LocalConnection();
			_connReceiver.client = _oAPI;
			trace("LC_TwoWay::init allowDomain for "+_sAllowedDomain)
			_connReceiver.allowDomain(_sAllowedDomain);
			_connReceiver.allowInsecureDomain(_sAllowedDomain);
			try {
				trace("LC_TwoWay::init trying to connect to "+_sReceiverName)
                _connReceiver.connect(_sReceiverName);
            } catch (error:ArgumentError) {
				var t_ev:LCEvent = new LCEvent(LCEvent.NAME_TAKEN);
				dispatchEvent(t_ev);
				//dispatchEvent(new Event(LC_TwoWay.NAME_TAKEN));
                trace("LC_TwoWay::init Can't connect...the connection name is already being used by another SWF"+error);
            }
            
        }
        
        public function send(connName:String,methodName:String,assocArr:Array = null):void {
            _connSender.send(connName, methodName, assocArr);
        }
        
        private function onSendStatus(event:StatusEvent):void {           
			switch (event.level) {
                case "status":
                    //trace("LocalConnection.send() succeeded");
					dispatchEvent(new LCEvent(LCEvent.SUCCESS));
                    break;
                case "error":
					dispatchEvent(new LCEvent(LCEvent.FAILED));
                    //trace("LocalConnection.send() failed");
                    break;
            }
        }               
    }
}

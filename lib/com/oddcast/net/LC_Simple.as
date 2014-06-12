/**
* ...
* @author Sam Myer
* @version 0.1
* 
*/

package com.oddcast.net {
	
	public class LC_Simple extends LC_TwoWay {
		private var lcName:String;
		private var listener:Object;
	
		public function LC_Simple(in_lcName:String, domains:String = "*") {
			//trace("LC SIMPLE --- construtor "+in_lcName);
			lcName=in_lcName;
			super("_8to9_"+lcName,this,domains);
			init();
		}
		
		public function lc_send(... args):void {
			//trace("LC SIMPLE --- send "+lcName+"   args: "+args);
			send("_9to8_"+lcName,"lc_receive",args);
		}
		
		public function lc_receive(args:Array):void {
			//trace("LC SIMPLE --- receive   args: "+args);
			var fnName:String=args[0];
			//dispatchEvent(new LCEvent(fnName,args.slice(1)));
			var f:Function=listener==null?null:listener[fnName];
			if (f!=null) f.apply(listener,args.slice(1));
		}
		
		public function addListener(in_listener:Object) {
			listener=in_listener;
		}
	}
}
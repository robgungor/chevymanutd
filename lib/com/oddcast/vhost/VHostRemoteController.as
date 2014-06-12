/**
* ...  
* @author Sam Myer
* @version 0.1
* 
* 
* Flash 9 Object that remotely controls a Flash 8 Host SWF via local connection
*/

package com.oddcast.vhost {
	import com.oddcast.event.AudioEvent;
	import flash.events.Event;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.net.LC_Simple;
	import com.oddcast.vhost.OHUrlParser;
	import flash.events.EventDispatcher;

	public class VHostRemoteController extends EventDispatcher {
		private var lc:LC_Simple;
		
		private var colors:Object;
		private var ranges:Object;
		private var accTypes:Array;
		private var accessories:Object;
		
		public function VHostRemoteController(in_lcName:String) {
			trace("vhostremotecontroller lcName="+in_lcName);
			lc=new LC_Simple(in_lcName);
			lc.addListener(this);
		}
		
		//keeping track of stuff functions
		
/*		public function setInitialVariablesFromURL(in_url:String) {
			var ohObj:Object=OHUrlParser.getOHObject(in_url);
			var typeId:Number;
			for (var accName:String in ohObj) {
				typeId=accessoryTypes.getTypeId(accName);
				if (typeId!=undefined) accessories[typeId]=new AccessoryData(ohObj[accName],"",typeId,"",0);
			}
		}
		
		public function getConfigString():String {		
		}*/				
		
		
		//communication functions
		
		public function configDone() {
			trace("CONFIG DONE IN FLASH 9!!!!!!!!!")
			getConfigObj();
		}
		
		public function hostLoaded() {
			
		}
		
		public function setScale(s:String,x:Number) {
			if (ranges==null) return;
			if (ranges[s]!=null) {
				ranges[s].val=x;
				lc.lc_send("setScale",s,x);
			}
		}
		public function setAccessory(acc:AccessoryData) {
			if (acc==null) return;
			trace("setAccessory : "+acc);
			
			//if (accessories==null) accessories=new Object();
			//if (accTypes.indexOf(acc.typeId)>=0||true) {
			//accessories[acc.typeId.toString()]=acc;
			var accObj:Object=acc.getFlash8Object();
			lc.lc_send("setAccessory",accObj);
		}
		
		public function setHexColor(s:String,hexCol:Number) {
			trace("setHexColor in remote control : s="+s+" hex="+hexCol+" colors[s]="+colors[s]);
			if (colors==null) return;
			if (colors[s]!=null) {
				colors[s]=hexCol;
				lc.lc_send("setHexColor",s,hexCol);
			}
		}
		
		public function getConfigObj() {
			lc.lc_send("getConfigObj");
		}
		
		public function gotConfigObj(o:Object) {
			trace("got config obj : ")
			for (var i:String in o) {
				trace(i+" : "+o[i]);
				for (var j:String in o[i]) {
					trace("--------"+j+" : "+o[i][j]);
				}
			}
			colors=o.colors;
			ranges=o.ranges;
			//accTypes=o.accTypes;
			dispatchEvent(new Event("configDone"));
		}
		
		public function accessoryLoaded(typeId:Number) {
			dispatchEvent(new Event("accessoryLoaded"));
		}
		
		public function accessoryLoadError() {
			dispatchEvent(new Event("accessoryLoadError"));
		}
		
		public function getColors():Object {
			return(colors);
		}
		
		public function getRanges():Object {
			return(ranges);
		}
		
		public function say(s:String) {
			lc.lc_send("say",s);
		}
		public function stopSpeech() {
			lc.lc_send("stopSpeech");
		}
		
		public function talkStarted() {
			dispatchEvent(new Event("talkStarted"));
		}
		
		public function talkEnded() {
			dispatchEvent(new Event("talkEnded"));
		}
		
		public function soundError() {
			dispatchEvent(new Event("talkError"));
		}
	}
	
}
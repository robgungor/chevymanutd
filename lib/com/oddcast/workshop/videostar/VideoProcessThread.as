package com.oddcast.workshop.videostar {
	
	/**
	* ...
	* @author Sam Myer
	*/
	import com.oddcast.audio.AudioData;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSBackgroundStruct;
	import com.oddcast.workshop.WSVideoStruct;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class VideoProcessThread extends EventDispatcher {
		private var pingTimer:Timer;
		private var sessionId:String;
		public var videoUrl:String;
		public var percentDone:Number;
		private var inputVideo:VideoStruct;
		private var outputVideo:WSVideoStruct;
		
		public function VideoProcessThread() {
			trace("ping delay = "+ServerInfo.videostar_pingDelay);
			pingTimer=new Timer(ServerInfo.videostar_pingDelay,1);
			pingTimer.addEventListener(TimerEvent.TIMER_COMPLETE,doPing,false,0,true);
		}
		
		public function processVideo(vid:VideoStruct) {
			inputVideo = vid;
			var videoXML:XML=createVideoXML(inputVideo);
			trace("creating video");
			trace(videoXML.toXMLString());
			
			percentDone=0;
			var url:String=ServerInfo.localURL+"videostar/processVideo.php";
			var vars:URLVariables=new URLVariables();
			vars.xmlData=videoXML.toXMLString();
			vars.doorId=ServerInfo.door;
			XMLLoader.sendVars(url,gotSessionId,vars);
		}
		
		public function getOutput():WSVideoStruct {
			return(outputVideo);
		}
		
		public function gotSessionId(_xml:XML) {
			trace("gotSessionId : " + _xml.toXMLString());
			
			var alertEvt:AlertEvent = XMLLoader.checkForAlertEvent("f9t401");
			if (alertEvt != null) {
				dispatchEvent(alertEvt);
				return;
			}

			/*if (_xml==null) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t401", "Error loading session ID XML : "+XMLLoader.lastError));
				return;
			}
			else if (_xml.name() == null) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t401", "Error loading session ID XML"));	
				return;
			}
			else if (_xml.name() == "APIERROR") {
				trace("Video error #" + _xml.@CODE + " : " + unescape(_xml.@ERRORSTR));
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, _xml.@CODE, unescape(_xml.@ERRORSTR)));
				return;
			}*/
			
			sessionId=_xml.@SESSID.toString();
			pingTimer.start();
		}
		
		private function doPing(evt:TimerEvent) {
			var url:String=ServerInfo.videostar_pingUrl+"?sesId="+sessionId+"&rand="+getTimer();
			XMLLoader.loadXML(url,gotPingResponse);
		}
		
		public function gotPingResponse(_xml:XML) {
			trace("pingResponse::"+_xml.toXMLString());
			var alertEvt:AlertEvent = XMLLoader.checkForAlertEvent("f9t370");
			if (alertEvt != null) {
				if (alertEvt.moreInfo == null) alertEvt.moreInfo = new Object();
				alertEvt.moreInfo.sessionId = sessionId;
				dispatchEvent(alertEvt);
				return;
			}
			/*if (_xml==null) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t402", "Error loading aps status XML : "+XMLLoader.lastError));
				return;
			}
			else if (_xml.name() == null) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9t402", "Error loading aps status XML"));	
				return;
			}
			else if (_xml.name() == "APIERROR") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, _xml.@CODE, unescape(_xml.@ERRORSTR),{sessionId:sessionId}));
				return;
			}*/
			
			var res:String = _xml.@RES.toString();
			if (res.length>0&&res != "OK") { //i.e. res=="ERROR"
				var errorStr:String = _xml.@INFORMATION.toString() + _xml.@RES.toString() + unescape(_xml.@ERRORSTR.toString()) + " session id=" + sessionId.toString();
				dispatchEvent(new AlertEvent(AlertEvent.ERROR,_xml.@CODE.toString(),errorStr,{sessionId:sessionId}));
				return;
			}
			
			var status:int=parseInt(_xml.@STATUS.toString());
			//trace("status="+status);
			if (status==2) { //done
				videoUrl = _xml.@URL.toString();
				outputVideo = new WSVideoStruct(videoUrl);
				outputVideo.setVideostarSource(inputVideo);
				percentDone=1;
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else { //processing
				percentDone=parseFloat(_xml.@PERCENT.toString())/100;
				//trace("percent done : "+percentDone+" --  "+_xml.@PERCENT);
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
				pingTimer.reset();
				pingTimer.start();
				//trace("resetting pingtimer");
			}
		}
		
		private function createVideoXML(vid:VideoStruct):XML {
			var videoXML:XML = new XML("<VideoStarConfiguration version=\"1.0\" />");
			var i:int;
			var j:int;
			
			var clipXML:XML;
			var faceXML:XML;
			var actor:ActorStruct;
			
			var audioUrl:String;
						
			videoXML.Clips=new XML();

			clipXML=new XML("<Clip use-default-audio=\"false\" />");
			clipXML.@name=vid.name;
			clipXML.@id = vid.id;
			if (vid.cutoffTime <= 0 || isNaN(vid.cutoffTime)) clipXML.@cutoffTime = "20000"; //default 20 seconds
			else clipXML.@cutoffTime=vid.cutoffTime.toString();
			for (j=0;j<vid.actors.length;j++) {
				actor=vid.actors[j];
				faceXML=new XML("<Face />");
				faceXML.Fg=actor.fgUrl;
				faceXML.Name=actor.name;
				if (vid.audio!=null) {
					audioUrl=vid.audio.url;
					if (audioUrl.indexOf(".mp3?")>0) audioUrl=audioUrl.slice(0,audioUrl.indexOf(".mp3?")+4);
					faceXML.audio=audioUrl;
				}

				clipXML.appendChild(faceXML);
			}

			if (vid.settings != null) {
				var settings:VideoSettings = vid.settings;
				
				var apsVarName:String;
				if (settings.aps != null) {
					var paramListXML:XML = new XML("<params />");
					var paramXML:XML;
					for (apsVarName in settings.aps) {
						paramXML = new XML("<param />");
						paramXML.@name = apsVarName;
						paramXML.@value = settings.aps[apsVarName].toString();
						paramListXML.appendChild(paramXML);
					}
					videoXML.appendChild(paramListXML);
				}			
				
				var id:String;
				var bg:WSBackgroundStruct;
				if (settings.images != null) {
					clipXML.images = new XML();
					trace("@@@"+settings.images);
					for (id in settings.images) {
						trace("!!!!!!!! "+id+" - "+settings.images[id])
						bg=settings.images[id];
						var imageXML:XML=new XML("<Image />");
						imageXML.appendChild(bg.url);
						imageXML.@id=id;
						clipXML.images.appendChild(imageXML);
					}
				}
				
				if (settings.bgImages!=null) {
					trace("@@@"+settings.bgImages);
					for (id in settings.bgImages) {
						trace("!!!!!!!! "+id+" - "+settings.bgImages[id])
						bg=settings.bgImages[id];
						var bgXML:XML=new XML("<Background_Image />");
						bgXML.@source=bg.url;
						bgXML.@name=id;
						videoXML.appendChild(bgXML);				
					}
				}
				
				if (settings.audios!=null) {
					var audio:AudioData;
					trace("@@@"+settings.audios);
					for (id in settings.audios) {
						trace("!!!!!!!! "+id)
						audio=settings.audios[id];
						var audioXML:XML=new XML("<mp3 />");
						//audioXML.@id=audio.id;
						//audioXML.@name=audio.name;
						//audioXML.@url=audio.url;
						audioXML.appendChild(audio.url);
						videoXML.appendChild(audioXML);
					}
				}
				
				if (settings.captions!=null) {
					var textXML:XML;
					for (i=0;i<settings.captions.length;i++) {
						if (settings.captions[i].text=="") continue;
						textXML=new XML("<caption />");
						textXML.@color = toHexString(settings.captions[i].fillColor);
						textXML.@font=settings.captions[i].font;
						textXML.@name=settings.captions[i].name;
						textXML["@point-size"]=settings.captions[i].pointSize.toString();
						//textXML["@stroke-size"]=settings.captions[i].strokeSize.toString();
						textXML["@stroke-color"]=toHexString(settings.captions[i].strokeColor);
						textXML.@align=settings.captions[i].align;
						textXML.appendChild(settings.captions[i].text);
						clipXML.appendChild(textXML);
					}
				}
			}
			
			videoXML.Clips.appendChild(clipXML);
			
			return(videoXML);
		}
		
		private function toHexString(n:uint) { //converts numbers to hex formatted string eg. 0xFF to '#0000FF'
			var str:String = n.toString(16);
			if (str.length > 6) str = str.slice( -6);
			while (str.length < 6) str = "0" + str;
			return("#" + str);
		}
		
		public function destroy() {
			pingTimer.stop();
			pingTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, doPing);
		}
		
	}
	
}
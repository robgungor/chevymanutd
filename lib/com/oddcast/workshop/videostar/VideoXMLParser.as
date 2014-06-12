/**
* ...
* @author Default
* @version 0.1
*/

package com.oddcast.workshop.videostar {

	public class VideoXMLParser {
		public var actorArr:Array;
		public var videoArr:Array;
		
		public function parseVideoXML(_xml) {
			actorArr=new Array();
			var actorXML:XMLList=_xml.ACTORS.ACTOR;
			
			var xid:int;
			var xname:String;
			var xdesc:String;
			var xurl:String;
			var xthumb:String;
			var xlength:Number;
			var actorIds:XMLList;
			var xactorArr:Array;
			var xstopPoints:Array;
			var video:VideoStruct;
			var i:int;
			var j:int;
			
			var baseUrl:String=_xml.ACTORS.@BASE_URL;
			var thumbBaseUrl:String=_xml.ACTORS.@THUMB_BASE_URL;
			
			for (i=0;i<actorXML.length();i++) {
				xid=parseInt(actorXML[i].@ID);
				xname=actorXML[i].@NAME;
				actorArr[xid]=new ActorStruct(xid,xname);
				if (actorXML[i].@FG.toString()=="") actorArr[xid].fgUrl="";
				else actorArr[xid].fgUrl=baseUrl+actorXML[i].@FG.toString();
				if (actorXML[i].@THUMB.toString()=="") actorArr[xid].thumbUrl="";
				else actorArr[xid].thumbUrl=thumbBaseUrl+actorXML[i].@THUMB.toString();
			}
			videoArr=new Array();
			baseUrl=_xml.VIDEOS.@BASE_URL;
			thumbBaseUrl=_xml.VIDEOS.@THUMB_BASE_URL;
			var videoXML:XMLList=_xml.VIDEOS.VIDEO;
			
			for (i=0;i<videoXML.length();i++) {
				xid=parseInt(videoXML[i].@ID);
				xurl = baseUrl + videoXML[i].@URL;
				if (videoXML[i].@THUMB.toString() == "") xthumb = "";
				else xthumb=thumbBaseUrl+videoXML[i].@THUMB;
				xname=videoXML[i].@NAME;
				xdesc=videoXML[i].@DESCRIPTION;
				xlength=parseFloat(videoXML[i].@LENGTH);
				if (xlength<=0||isNaN(xlength)) xlength=0;
				actorIds=videoXML[i].ACTOR;
				
				xactorArr=new Array();
				for (j=0;j<actorIds.length();j++) xactorArr.push(actorArr[parseInt(actorIds[j].toString())]);
				
				xstopPoints=unescape(videoXML[i].@STOPPOINTS).split(",");
				for (j=0;j<xstopPoints.length;j++) xstopPoints[j]=parseFloat(xstopPoints[j]);
				
				video=new VideoStruct(xurl,xid,xthumb,xname,xdesc,xlength,xactorArr)
				video.stopPoints=xstopPoints;
				videoArr.push(video);
			}
		}
	}
	
}
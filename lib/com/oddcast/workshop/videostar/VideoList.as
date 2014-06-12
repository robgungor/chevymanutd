package com.oddcast.workshop.videostar {
	import com.oddcast.assets.structures.LoadedAssetStruct;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.workshop.ModelList;
	import com.oddcast.workshop.ServerInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class VideoList extends EventDispatcher {
		private var videoArr:Array;
		private var catArr:Array;
		private var actorArr:Array;
		private var modelList:ModelList;
		
		public function VideoList($modelList:ModelList = null) {
			modelList = $modelList;
		}
		
		public function loadVideoCategories(callback:Function=null) {
			var url:String = ServerInfo.acceleratedURL + "php/videostar/listAllCategories/doorId=" + ServerInfo.door;
			XMLLoader.loadXML(url, gotCategories,callback);
		}
		
		private function gotCategories(_xml:XML,callback:Function) {
			parseCategoryXML(_xml);
			if (callback != null) callback();
		}
		
		public function categoryIsLoaded(catId:uint):Boolean {
			return(videoArr[catId] != null);
		}
		
		private function actorIsLoaded(actorId:uint):Boolean {
			return(actorArr[actorId] != null);
		}
		
		public function loadVideosByCategory(catId:int,callback:Function=null) {
			if (categoryIsLoaded(catId)) {
				if (callback!=null) callback();
			}
			
			var url:String = ServerInfo.acceleratedURL + "php/videostar/listVideoCategories/doorId=" + ServerInfo.door;// + "/catId=" + catId;
			XMLLoader.loadXML(url, gotVideos,catId,callback);
		}
		
		private function gotVideos(_xml:XML,catId:int,callback:Function) {
			parseVideoXML(_xml, catId);
			if (callback != null) callback();
		}
		
		private function parseCategoryXML(_xml) {
			catArr = new Array();
			videoArr = new Array();
			actorArr = new Array();
			
			var thumbBase:String = _xml.CATEGORIES.@thumb_stem;
			var categoryXML:XML;
			var catId:int;
			var catName:String;
			var catDesc:String;
			var category:VideoCategory;
			for (var i:int = 0; i < _xml.CATEGORIES.CATEGORY.length(); i++) {
				categoryXML = _xml.CATEGORIES.CATEGORY[i];
				catId = parseInt(categoryXML.ID.toString());
				catName = categoryXML.TITLE.toString();
				catDesc = categoryXML.DESCRIPTION.toString();
				category = new VideoCategory(catId, catName, catDesc);
				catArr.push(category);
			}
		}
		
		private function parseVideoXML(_xml:XML,catId:int) {
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
			var xfgUrl:String;
			var xmodelId:int;
			var video:VideoStruct;
			var actor:ActorStruct;
			var i:int;
			var j:int;
			
			var baseUrl:String=_xml.ACTORS.@BASE_URL;
			var thumbBaseUrl:String=_xml.ACTORS.@THUMB_BASE_URL;
			
			for (i=0;i<actorXML.length();i++) {
				xid = parseInt(actorXML[i].@ID);
				if (actorIsLoaded(xid)) continue; //actor exists, don't load it again
				
				xname=actorXML[i].@NAME;
				actor = new ActorStruct(xid, xname);
				xfgUrl = actorXML[i].@FG.toString();
				xmodelId = parseInt(actorXML[i].@MODEL.toString());
				
				if (xmodelId > 0
					&&
					modelList != null)
					actor.model = modelList.get_model_by_id( xmodelId );
				else if (xfgUrl.length > 0) 
					actor.fgUrl = baseUrl + actorXML[i].@FG.toString();
				else 
					actor.model = null;
					
				actor.defaultModel = actor.model;
				
				if (actorXML[i].@THUMB.toString()=="") actor.thumbUrl="";
				else actor.thumbUrl = thumbBaseUrl + actorXML[i].@THUMB.toString();
				
				actor.defaultModel = actor.model;
				actorArr[xid] = actor;
			}

			baseUrl=_xml.VIDEOS.@BASE_URL;
			var keyFileArr:Array = new Array();
			var keyFileXML:XMLList = _xml.KEYFILES.KEYFILE;
			for (i = 0; i < keyFileXML.length(); i++) {
				xid = parseInt(keyFileXML[i].@ID.toString());
				xurl = baseUrl + keyFileXML[i].text().toString();
				keyFileArr[xid]=new LoadedAssetStruct(xurl, xid);
			}
			
			var vidArr:Array=new Array();
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
				
				xactorArr = new Array();
				var xkeyFileArr:Array = new Array();
				var keyFileId:String;
				for (j = 0; j < actorIds.length(); j++) {
					xactorArr.push(actorArr[parseInt(actorIds[j].toString())]);
					keyFileId = actorIds[j].@KF.toString();
					if (keyFileId==null||keyFileId == "" || isNaN(parseInt(keyFileId))) xkeyFileArr.push(null);
					else xkeyFileArr.push(keyFileArr[parseInt(keyFileId)]);
				}
				
				xstopPoints=unescape(videoXML[i].@STOPPOINTS).split(",");
				for (j=0;j<xstopPoints.length;j++) xstopPoints[j]=parseFloat(xstopPoints[j]);
				
				video = new VideoStruct(xurl, xid, xthumb, xname, xdesc, xlength, xactorArr)
				video.keyFileArr = xkeyFileArr;
				video.stopPoints=xstopPoints;
				vidArr.push(video);
			}
			
			videoArr[catId] = vidArr;
		}
		
		public function getCategories():Array {
			return(catArr);
		}
		
		public function getVideosByCategory(catId:uint):Array {
			return(videoArr[catId]);
		}
		
		public function getActorsForCategory(catId:uint):Array {
			return(getActorsForVideos(getVideosByCategory(catId)));
		}
		
		public static function getActorsForVideos(vidArr:Array):Array {
			if (vidArr == null) return null;
			
			var i:int;
			var j:int;
			var selectedActors:Array = new Array();
			var selectedActorIds:Array = new Array();
			var actor:ActorStruct;
			for (i = 0; i < vidArr.length; i++) {
				for (j=0;j<vidArr[i].actors.length;j++) {
					actor = vidArr[i].actors[j];
					if (selectedActorIds.indexOf(actor.id) >= 0) continue; //actor already in array
					
					selectedActorIds.push(actor.id);
					selectedActors.push(actor);
				}
			}
			return(selectedActors);
		}
		
	}
	
}
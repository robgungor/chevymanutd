/**
* ...
* @author Sam, Me^
* @version 0.3
* 
* Data structure to contain all the information about the scene needed for saving:
* 
* PROPERTIES:
* 
* model - the model associated with this scene
* hostMatrix - host position given as a matrix - equivalent to host.transform.matrix
* bgArr - an array of WSBackgroundStruct objects
* audioArr - an array of AudioData objects
* videoArr - an array of WSVideoStruct objects
* bgPosArr - an array of Matrix objects that represent the posision of the respective backgrounds in bgArr
* 
* optimizedHost - for 3D models only : this is the binary file information for the saved 3D host returned by
* jake's engine.  You shouldn't have to set this.  When you call the saving function in the SceneController class,
* SceneController3D calls some functions on the engine and stores the results in this variable.
* 
* ohUrl - used to store the location of the optimized host after it has been uploaded to the server.  this
* is generally set by the WorkshopSaver class
* 
* GETTER/SETTER:
* 
* bg - gets/sets the first element in the bgArr array.  used for backwards compatibility and for convenience
* in scenes where there is only one bg
* audio - gets/sets the first element in the audioArr array.
* video - gets/sets the first element in the videoArr array.
* bgMatrix - gets/sets the first element in the bgPosArr array.  scene.bgMatrix is the position of scene.bg
* 
* hasFileData - returns if the scene has been assigned an optimizedHost object
* 
*/

package com.oddcast.workshop {
	import com.oddcast.assets.structures.*;
	import com.oddcast.audio.*;
	import com.oddcast.host.api.*;
	import flash.geom.*;

	public class SceneStruct {
		public var id:int = -1;
		
		/** array of WSSceneCharStruct */
		public var modelArr:Array;
		/** array of WSBackgroundStruct */
		public var bgArr:Array;
		/** array of AudioData */
		public var audioArr:Array;
		/** array of WSVideoStruct */
		public var videoArr:Array;
		/** array of Matrix */
		public var bgPosArr:Array;
		/** storage for full body data meant for saving */
		public var body_data:Full_Body_Scene_Data = new Full_Body_Scene_Data();
		
		public function SceneStruct($model:WSModelStruct = null, $bg:WSBackgroundStruct = null, $audio:AudioData = null, $hostPosition:Matrix = null, $bgPosition:Matrix = null) 
		{	modelArr 		= new Array();
			audioArr 		= new Array();
			bgArr 			= new Array();
			bgPosArr 		= new Array();
			videoArr 		= new Array();
			
			model			= $model;
			bg				= $bg;
			audio 			= $audio;
			hostMatrix 		= $hostPosition;
			
			if ($bgPosition != null)	bgPosArr.push($bgPosition);
		}
		
		public function get hasFileData():Boolean {
			if (modelArr == null || modelArr.length == 0) return(false);
			else return(modelArr[0].hasFileData);
		}
		
		//these getter/setters are provided for backwards-compatilibility for a time when a scene didn't
		//support multiple models, bgs, etc.
		
		public function get bg():WSBackgroundStruct {
			return(bgArr==null?null:bgArr[0]);
		}
		public function set bg($bg:WSBackgroundStruct) : void {
			bgArr = new Array();
			if ($bg!=null) bgArr.push($bg);
		}
		
		public function get bgMatrix():Matrix {
			return(bgPosArr == null?null:bgPosArr[0]);
		}
		
		public function get audio():AudioData {
			return(audioArr==null?null:audioArr[0]);
		}
		public function set audio($audio:AudioData) : void {
			audioArr = new Array();
			if ($audio!=null) audioArr.push($audio);
		}
		
		public function get video():WSVideoStruct {
			return(videoArr==null?null:videoArr[0]);
		}
		public function set video($video:WSVideoStruct) : void {
			videoArr = new Array();
			if ($video!=null) videoArr.push($video);
		}
		
		public function get model():WSModelStruct {
			if (modelArr == null||modelArr.length==0) return(null);
			else return(modelArr[0].model);
		}
		
		public function set model($model:WSModelStruct):void {
			if (modelArr == null) modelArr = new Array();
			if ($model!=null) {
				if (modelArr.length == 0) modelArr.push(new WSSceneCharStruct($model));
				else modelArr[0].model = $model;
			}
		}
		
		public function get hostMatrix():Matrix {
			if (modelArr == null||modelArr.length==0) return(null);
			else return(modelArr[0].pos);
		}
		
		public function set hostMatrix($pos:Matrix):void {
			if (modelArr == null||modelArr.length==0) return;
			else modelArr[0].pos = $pos;
		}
		
		public function get optimizedHost():FileData {
			if (modelArr == null||modelArr.length==0) return(null);
			else return(modelArr[0].oa1File);
		}
		
		public function set optimizedHost($oa1File:FileData):void {
			if (modelArr == null||modelArr.length==0) return;
			else modelArr[0].oa1File = $oa1File;
		}
		
		public function get ohUrl():String {
			if (modelArr == null||modelArr.length==0) return(null);
			else return(modelArr[0].ohUrl);
		}
		
		public function set ohUrl($ohUrl:String):void {
			if (modelArr == null||modelArr.length==0) return;
			else modelArr[0].ohUrl = $ohUrl;
		}
		
		public function toString():String {
			var i:int;
			var s:String = "--------------------------- SCENE " + id + " ---------------------------";
			var char:WSSceneCharStruct;
			for (i = 0; i < modelArr.length; i++) {
				char = modelArr[i];
				s += "\nMODEL #" + i;
				s += "\n\tid : " + char.model.id;
				s += "\n\turl : " + char.model.url;
				s += "\n\t3d : " + char.model.is3d + "  has oa1? : " + (char.oa1File != null);
				s += "\n\tchar url : " + char.ohUrl;
				s += "\n\tkeyfile : " + (char.keyFile == null?"null":char.keyFile.url);
			}
			var asset:LoadedAssetStruct;
			for (i = 0; i < bgArr.length; i++) {
				asset = bgArr[i];
				s += "\nBG #" + i;
				s += "\n\tid : " + asset.id;
				s += "\n\turl : " + asset.url;
			}
			for (i = 0; i < audioArr.length; i++) {
				asset = audioArr[i];
				s += "\nAUDIO #" + i;
				s += "\n\tid : " + asset.id;
				s += "\n\turl : " + asset.url;
			}
			for (i = 0; i < videoArr.length; i++) {
				asset = videoArr[i];
				s += "\nVIDEO #" + i;
				s += "\n\tid : " + asset.id;
				s += "\n\turl : " + asset.url;
			}
			s += "\n----------------------------------------------------------------";
			return(s);
		}
	}
	
}












class Full_Body_Scene_Data
{
	public var camera_aim:String;
	public var camera_position:String;
	public var scene_id:String;
	public function Full_Body_Scene_Data(  )
	{
	}
}
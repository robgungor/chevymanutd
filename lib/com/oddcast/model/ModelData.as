/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* Data structure for models - in progress
* Required: url
* Optional id, thumb url, name
*/

package com.oddcast.model {
	import com.oddcast.data.IThumbSelectorData;

	public class ModelData implements IThumbSelectorData {
		public var url:String;
		public var name:String;
		private var modelId:int;
		private var modelThumbUrl:String;
		
		protected static var tempCounter:int=1;
		private var _tempId:int=-1;
		
		public var isAutoPhoto:Boolean=false;
		
		private var gender:String;
		private var accessories,defaultAccessories:Object;
		public var engine:EngineData;
		
		//WORKSHOP VARS ---
		/*private var readOnly,isAutoPhoto:Boolean;
		private var autoPhoto_sessionId:String;
		private var template,gender:String;
		private var accessories:Array;
		public var defaultConfig:ModelConfig;*/
		
		//SITEPAL VARS --
		/*public var level:Number;
		private var owned,isPrivate:Boolean;	
		//from getmodelinfo.php
		public var catId:Number;
		private var initialAccArr:Array;
		private var availableTypes:Array;
		public static var typeNames:Object=new Object();*/
		
		public function ModelData(in_url:String,in_id:int=-1,in_thumb:String="",in_name:String="") {
			_tempId=tempCounter;
			tempCounter++;
			
			url=in_url;
			id=in_id;
			thumbUrl=in_thumb;
			name=in_name;
			accessories=new Object();
		}
		
		public function get thumbUrl():String {
			return(modelThumbUrl);
		}
		
		public function set thumbUrl(s:String) {
			modelThumbUrl=s;
		}
		
		public function get id():int {
			return(modelId);
		}
		
		public function set id(n:int) {
			modelId=n;
		}
		
		public function get hasId():Boolean {
			return(modelId>0);
		}
		
		public function get tempId():int {
			if (hasId) return(-1);
			else return(_tempId);
		}
		
		/*public function get saveId():String {
			//returns id string for the purpose of saving xml -- old
			if (hasId) return("temp"+_tempId.toString());
			else return(modelId.toString())
		}*/
		
	}
	
}
/**
* 
* @author Sam Myer, Me^
* This class is for loading and storing a list of model accessories.  In the MVC pattern, this is the model class.
* 
* Functions:
* loadAccessories(modelId:int) - loads accessories from the server and dispatches COMPLETE or ERROR event.
* if accessories are already loaded for this model, event is dispatched immediately
* 
* parseAccessories(_xml:XML) - parses accessory list directly from xml
* 
* getAvailableTypeIds
* getAvailableTypeNames - returns an array of available types
* 
* getTypeName(typeId:int) - translates type id number into type name as string
* 
* getAccessoriesByTypeId
* getAccessoriesByTypeName
* getAccessoriesByName
* getAccessoriesById - return an array of AccessoryData objects matching specified criterion
* 
* Properties:
* accArr - array of AccessoryData objects for this model
* 
* Events:
* Event.COMPLETE - dispatched when requested data is loaded & ready.  if data has already been loaded, this event
* is dispatched immediately
* AlertEvent.ERROR - dispatched when there is an error loading data
*/
package com.oddcast.workshop {
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.vhost.accessories.*;
	
	import flash.events.*;
	import flash.utils.*;
	
	public class AccessoryList extends EventDispatcher {
		private var isProcessing:Boolean;
		/* holder of all items */
		private var arr:Array;
		/* dic[id:int] = [acc1,acc2,acc3] */
		private var dic_id_types:Dictionary;
		/* dic[id:int] = acc */
		private var dic_ids:Dictionary;
		/* dic[name:String] = acc (names have to be unique) */
		private var dic_names:Dictionary;
		private var typeNames:Object;
		private var curModelId:int = -1;
		
		public function AccessoryList() 
		{
			arr = new Array();
			dic_id_types = new Dictionary();
			dic_names = new Dictionary();
			dic_ids = new Dictionary();
		}
		
		/**
		 *	loads accessories per model ID 
		 * @param _model_id		model ID (same model ID will not be reloaded)
		 * @param _callbacks	fin(), error(AlertEvent);
		 * 
		 */		
		public function load_accessories_by_model_id( _model_id:int, _callbacks:Callback_Struct ):void 
		{	
			if (curModelId==_model_id)
				_callbacks.fin();
			else
			{
				add_listeners();
				loadAccessories( _model_id );
			}
			
			function loaded( _e:Event ):void
			{	remove_listeners();
				_callbacks.fin();
			}
			function error( _e:AlertEvent ):void
			{	remove_listeners();
				_callbacks.error( _e );
			}
			function add_listeners():void
			{	addEventListener( Event.COMPLETE, loaded );
				addEventListener( AlertEvent.EVENT, error );
			}
			function remove_listeners():void
			{	removeEventListener( Event.COMPLETE, loaded );
				removeEventListener( AlertEvent.EVENT, error );
			}
		}
		
		private function loadAccessories(modelId:int) {
			if (isProcessing) return;
			var url:String = ServerInfo.acceleratedURL + "php/vhss_editors/getAccessories/doorId=" + ServerInfo.door + "/modelId=" + modelId.toString();
			XMLLoader.loadXML(url,gotAccessories,modelId);
		}
		
		private function gotAccessories(_xml:XML,modelId:int) {
			isProcessing = false;
			var alertEvt:AlertEvent = XMLLoader.checkForAlertEvent("f9t300");
			if (alertEvt != null) {
				dispatchEvent(alertEvt);
				return;
			}
			
			
			curModelId = modelId;
			doParseAccessories(_xml);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function parseAccessories(_xml:XML) {
			curModelId = -1;
			doParseAccessories(_xml);
		}
		
		private function doParseAccessories(_xml:XML) {
			if (_xml.ITEM.length() == 0) arr = new Array();
			else {
				var is3d:Boolean = _xml.ITEM[0].@IS3D.toString() == "1";
				if (is3d) doParseAccessories3d(_xml);
				else doParseAccessories2d(_xml);
			}
		}
		
		private function add_accessory_to_list( _acc:AccessoryData ):void
		{
			arr.push(_acc);
			
			// add by type id
			if (dic_id_types[_acc.typeId])
				dic_id_types[_acc.typeId].push(_acc);
			else
				dic_id_types[_acc.typeId] = [_acc];
			
			// add by name
			if (dic_names[_acc.name])
				dic_names[_acc.name].push(_acc);
			else
				dic_names[_acc.name] = [_acc];
			
			// add by id
			if (dic_ids[_acc.id])
				dic_ids[_acc.id].push(_acc);
			else
				dic_ids[_acc.id] = [_acc];
				
		}

/*
<ACCESSORIES COUNT="0" BASE_URL="http://content.dev.oddcast.com//content2/mam/">
	<ASSETTBASE ID="43" FILENAME="99/a2/a_43.oa1"/>
	<ITEM ID="18044" NAME="Glasses000_01" CATID="5" CATEGORY="Default" COMPAT="0" COMPATID="0" THUMB="/a8/9f/accessory_thumnail_18044.jpg" IS3D="1" TYPE="4" TYPENAME="Glasses" TYPEGROUP="Glasses" ZORDER="0">
		<FRAGMENT TYPE="MAIN" ID="1">
			<ASSET TYPE="Base" VALUE="43"/>
			<ASSET TYPE="BMP" VALUE="19/f8/a_48.oa1"/>
		</FRAGMENT>
	</ITEM>
</ACCESSORIES>
*/
		private function doParseAccessories3d(_xml:XML) {
			var accNode:XML;
			var fragNode:XML;
			var acc:AccessoryData3D;
			var i:int;
			var j:int;
			var baseUrl:String = _xml.@BASE_URL;
			var accId:int;
			var accType:int;
			var accThumb:String;
			var accName:String;
			var accTypeName:String;
			var accCompat:int;
			var fragUrl:String;
			var fragBaseUrl:String;
			var fragId:int;
			var fragType:String;
			var assetList:XMLList;
			var typeGroupName:String;
			
			//typedAccArr = new Array();
			arr = new Array();
			typeNames = new Object();
			
			//var typeId:int=AccessoryData.getTypeId(_xml.@TYPE.toLowerCase());
			for (i=0;i<_xml.ITEM.length();i++) {
				accNode = _xml.ITEM[i];
				accId = parseInt(accNode.@ID.toString());
				accType = parseInt(accNode.@TYPE.toString());
				accThumb = baseUrl + accNode.@THUMB.toString();
				accName = accNode.@NAME.toString();
				accCompat = parseInt(accNode.@COMPATID.toString());
				accTypeName = accNode.@TYPENAME.toString();
				typeGroupName = accNode.@TYPEGROUP.toString();
				
				typeNames[accType.toString()] = accTypeName;
				
				acc = new AccessoryData3D(accId, accName, accType, accThumb, accCompat);
				acc.accGroupName = accNode.@TYPEGROUP.toString();
				acc.zOrder = parseFloat(accNode.@ZORDER.toString());
				
				for (j = 0; j < accNode.FRAGMENT.length(); j++) {
					fragNode = accNode.FRAGMENT[j];
					
					assetList = fragNode.ASSET.(@TYPE == "BMP");
					if (assetList.length() == 0) fragUrl=null;
					else fragUrl = baseUrl + assetList[0].@VALUE.toString();
					
					assetList = fragNode.ASSET.(@TYPE == "Base");
					if (assetList.length() == 0) fragBaseUrl = null;
					else fragBaseUrl = baseUrl + _xml.ASSETTBASE.(@ID == assetList[0].@VALUE).@FILENAME.toString();
					
					fragId = parseInt(fragNode.@ID.toString());
					fragType = fragNode.@TYPE.toString();
					
					acc.addFragment3d(new AccessoryFragment(fragType, fragUrl, fragId, fragBaseUrl));
					
				}
				
				add_accessory_to_list( acc );
			}

		}
		
		
/*
<ITEM ID="15847" NAME="female_halloween_black_mask" CATID="5" CATEGORY="Default" COMPAT="0" COMPATID="0" THUMB="/zz/zz/thumb_placeholder.jpg" IS3D="0" TYPE="4" TYPENAME="Glasses" TYPEGROUP="" ZORDER="">
	<FRAGMENT TYPE="Mirror" FILENAME="/fb/9a/fragment_ac15847_fr6.swf"/>
</ITEM>
<ITEM ID="15852" NAME="asian hair test -- dave" CATID="5" CATEGORY="Default" COMPAT="0" COMPATID="0" THUMB="/zz/zz/thumb_placeholder.jpg" IS3D="0" TYPE="3" TYPENAME="Hair" TYPEGROUP="" ZORDER="">
	<FRAGMENT TYPE="Left" FILENAME="/01/aa/fragment_ac15852_fr1.swf"/>
	<FRAGMENT TYPE="Back" FILENAME="/70/b9/fragment_ac15852_fr3.swf"/>
	<FRAGMENT TYPE="Right" FILENAME="/77/27/fragment_ac15852_fr2.swf"/>
</ITEM>*/
		private function doParseAccessories2d(_xml:XML) {
			var accNode:XML;
			var fragNode:XML;
			var acc:AccessoryData;
			var i:int;
			var j:int;
			var baseUrl:String = _xml.@BASE_URL;
			var accId:int;
			var accType:int;
			var accThumb:String;
			var accName:String;
			var accTypeName:String;
			var accCompat:int;
			var fragUrl:String;
			var fragType:String;
			
			//typedAccArr = new Array();
			arr = new Array();
			typeNames = new Object();
			
			//var typeId:int=AccessoryData.getTypeId(_xml.@TYPE.toLowerCase());
			for (i=0;i<_xml.ITEM.length();i++) {
				accNode = _xml.ITEM[i];
				accId = parseInt(accNode.@ID.toString());
				accType = parseInt(accNode.@TYPE.toString());
				accThumb = baseUrl + accNode.@THUMB.toString();
				accName = accNode.@NAME.toString();
				accCompat = parseInt(accNode.@COMPATID.toString());
				accTypeName = accNode.@TYPENAME.toString();
				
				typeNames[accType.toString()] = accTypeName;
				//trace("availableTypes[" + accType + "] = " + accTypeName + ";");
				
				acc = new AccessoryData(accId, accName, accType, accThumb, accCompat);
				
				for (j = 0; j < accNode.FRAGMENT.length(); j++) {
					fragNode = accNode.FRAGMENT[j];
					fragType = fragNode.@TYPE;
					fragUrl = fragNode.@FILENAME;
					fragUrl = fragUrl.split("/fragment").join("/f9_fragment");
					if (fragUrl.indexOf("http://") == -1) fragUrl = baseUrl + fragUrl;
					acc.addFragment(fragType,fragUrl);
				}
				add_accessory_to_list(acc);
			}
		}
		
		public function get accArr():Array {
			return(arr);
		}
		
		public function getAvailableTypeIds():Array {
			var availableTypes:Array = new Array();
			for (var typeIdStr:String in typeNames) {
				availableTypes.push(parseInt(typeIdStr));
			}
			return(availableTypes);
		}
		
		public function getAvailableTypeNames():Array {
			var availableTypes:Array = new Array();
			for each (var typeName:String in typeNames) {
				availableTypes.push(typeName);
			}
			return(availableTypes);
		}
		
		public function getTypeName(typeId:int):String 
		{
			return(typeNames[typeId]);
		}
		
		public function getAccessoriesByTypeId(typeId:int):Array 
		{
			return dic_id_types[typeId];
		}
		
		public function getAccessoryByName(_name:String):AccessoryData 
		{
			return dic_names[_name];
		}
		
		public function getAccessoryById(_id:int):AccessoryData {
			return dic_ids[_id];
		}
	}
	
}
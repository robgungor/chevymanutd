/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* Data structure for accessories
* required: id
* optional: name, typeId, thumbUrl, catId, isPrivate, incompatibleWith
* 
* Methods:
* 
* addFragment()
* getFragments()
* getFragmentUrl(s) - these 3 methods are for adding and removing the fragment URLs
* 
* getTypeName(id) [static] - converts a type id into a type name  eg 9 -> "hat"
* getTypeId(name) [static] - converts a type name into a type id
* getFlash8Object/setFromObject - these methods are only used for sending the instance data over the local connection
*/

package com.oddcast.vhost.accessories {
	import com.oddcast.data.IThumbSelectorData;

	public class AccessoryData implements IThumbSelectorData {	
		public static var typeArr:Object;
		
		public var id:int;
		public var name:String;
		public var typeId:int;
		/** category type name, eg. mouth or hair */
		public var type_name:String;
		private var _thumbUrl:String;
		public var incompatibleWith:int;
		//extra vars for new sitepal - sam
		public var isPrivate:Boolean=false;
		public var catId:Number;
		
		private var _arFragments:Array;
		private var _nFragments:int;
	
		public function AccessoryData(in_id:Number,in_name:String="",in_typeId:int=-1,in_thumbUrl:String="",incompatWith:Number=0) {
			id = in_id;
			name = in_name;
			typeId = in_typeId;
			thumbUrl = in_thumbUrl;
			incompatibleWith = incompatWith;
			_arFragments = new Array();
			_nFragments=0;
			catId=0;
		}
		
		public function get is3d():Boolean {
			return(false);
		}
	
		public function addFragment(type:String, url:String) : void
		{
			if (type.length>1)
			{
				type = type.charAt(0).toLowerCase();
			}
			//trace("Accessory.addFragment "+type);
			if (_arFragments[type]==null) _nFragments++;			
			_arFragments[type] = url;
			
		}
		
		public function get isMirror():Boolean {
			return (_arFragments["m"]!=null);
		}
		
		public function get thumbUrl():String { return _thumbUrl; }
		
		public function set thumbUrl(value:String):void {
			_thumbUrl = value;
		}
		
		public function getFragmentUrl(s:String):String
		{
			//trace("Accessory::getFragmentUrl("+s+")");
			return isMirror?_arFragments["m"]:_arFragments[s];
		}
		
		public function getFragments():Array {
			return _arFragments;
		}
			
/*		public function get typeName():String
		{
			return getTypeName(typeId);
		}*/
		
		private static function initTypes() : void {
			if (typeArr!=null) return;
			typeArr = new Object();
			typeArr["hair"] = {id:3, type:"Model"};
			typeArr["glasses"] = {id:4, type:"Class"};
			typeArr["costume"] = {id:6, type:"Class"};
			typeArr["necklace"] = {id:8, type:"Class"};
			typeArr["hat"] = {id:9, type:"Model"};
			typeArr["fhair"] = {id:10, type:"Model"};
			typeArr["mouth"] = {id:12, type:"Class"};
			typeArr["bottom"] = {id:13, type:"Class"};
			typeArr["shoes"] = {id:14, type:"Class"};
			typeArr["props"] = {id:15, type:"Class"};
			typeArr["headphones"] = {id:18, type:"Class"};
		}
	
		public static function getTypeId(s:String):int	{
			initTypes();
			if (typeArr[s.toLowerCase()]==undefined) return(0);
			else return typeArr[s.toLowerCase()].id;
		}
		
		public static function getAssignmentee(s:String):String {
			initTypes();
			return typeArr[s].type;
		}
		
		public static function getTypeName(n:int):String {
			initTypes();
			for (var i:* in typeArr) {
				if (typeArr[i].id==n) return i;
			}
			return "untitled";
		}
/*
		public function getFlash8Object():Object {
			var o:Object=new Object();
			o._nId=id;
			o._nTypeId=typeId;
			o._sThumbUrl=thumbUrl;
			o._arFragments=_arFragments;
			o._nFragments=_nFragments;
			o._bIsMirror=isMirror;
			o._nIncompatibleWith=incompatibleWith;
			return(o);
		}

		public function setFromObject(o:Object) {
			id=o.id;
			typeId=o.typeId;
			thumbUrl=o.thumbUrl;
			_arFragments=o._arFragments;
			_nFragments=o._nFragments;
			incompatibleWith=o.incompatibleWith;
		}
*/
		
		/*
		private var _nId:int;
		private var _sName:String;
		private var _nTypeId:int;
		private var _sThumbUrl:String;
		private var _nIncompatibleWith:int;
		//extra vars for new sitepal - sam
		private var _bIsPrivate:Boolean;
		private var _nCatId:Number;

		public function set id(n:int) {_nId=n}
		public function get id():int {return _nId}
		public function set name(s:String) {_sName=s}
		public function get name():String {return _sName}
		public function set typeId(n:int) {_nTypeId=n}
		public function get typeId():int {return _nTypeId}
		public function set thumbUrl(s:String) {_sThumbUrl=s}
		public function get thumbUrl():String {return _sThumbUrl}
		public function set incompatibleWith(n:int) {_nIncompatibleWith=n}
		public function get incompatibleWith():int {return _nIncompatibleWith}
		public function get isPrivate():Boolean {return _bIsPrivate}
		public function set isPrivate(b:Boolean) {_bIsPrivate=b}
		public function set catId(n:int) {_nCatId=n}
		public function get catId():int {return _nCatId}*/
		
	}
	
}